local lodcvar = GetConVar("arc9_lod_distance")
local drawprojlights = GetConVar("arc9_drawprojectedlights")

local v0, a0 = Vector(0, 0, 0), Angle(0, 0, 0)
local swepGetProcessedValue = SWEP.GetProcessedValue

local function drawModelWithTwoEyeAiming(self, model, flags, depthPrepass)
    local alpha = self.GetTwoEyeAimingAlpha and self:GetTwoEyeAimingAlpha(model) or 1

    if alpha < 1 and self.DrawModelTwoEyeAiming then
        self:DrawModelTwoEyeAiming(model, flags, alpha, depthPrepass)
    else
        model:DrawModel(flags)
    end

    return alpha
end

local function getscopebound(self, scopeent)
    local vm = self:GetVM()
    if !IsValid(scopeent) or !IsValid(vm) or !self:GetInSights() then return nil end
    local owo, uwu = scopeent:GetModelBounds()
    
    local awoo, uwoo = scopeent:GetPos(), scopeent:GetAngles()
    local scopelength = WorldToLocal(awoo, uwoo, vm:GetPos(), vm:GetAngles()).x + uwu.x
    -- debugoverlay.BoxAngles(awoo, owo, uwu, uwoo, 2, color_white)
    if scopelength < 5 or scopelength > 45 then return nil end
    if ARC9.Dev(1) then print("ARC9: Calculated scope length of", string.match(scopeent:GetModel(), "([^/]+).mdl$"), scopelength) end
    return scopelength
end


function SWEP:ShouldLOD()
    if self.IsStatue then return 0 end

    if self:GetIsStatue() then
        self.IsStatue = true
        return 0
    end

    local ct = CurTime()
    if (self.NextLODCheck or 0) > ct then return self.LastLOD or 0 end
    self.NextLODCheck = ct + 0.5

    local owner, lp = self:GetOwner(), LocalPlayer()
    if lp == owner then return 0 end

    local result = 0

    local screenSize = render.ComputePixelDiameterOfSphere(self:GetPos(), 0.5) -- same thing as in source:tm:
    screenSize = screenSize * math.Clamp(lodcvar:GetFloat(), 0.3, 3)
    local metric = screenSize > 0 and 100 / screenSize or 0
    if !IsValid(owner) then metric = metric * 1.5 end

    if metric > 128 then result = 2
    elseif metric > 96 then result = 1.5
    elseif metric > 64 then result = 1 end -- middle value for tpik lod

    self.LastLOD = result
    return result
end

function SWEP:DrawCustomModel(wm, custompos, customang, flags)
    flags = flags or STUDIO_RENDER
    local isDepthPass = ( bit.band( flags, STUDIO_SSAODEPTHTEXTURE ) != 0 || bit.band( flags, STUDIO_SHADOWDEPTHTEXTURE ) != 0 )
    local owner = self:GetOwner()
    local validowner = IsValid(owner)

    if !wm and !validowner then return end
    local lod = self:ShouldLOD()
    local isnpc = owner:IsNPC() or lod > 0
    if !wm and isnpc then return end
    if wm and ARC9.RTScopeRender then return end
    if custompos then wm = true end
    if !swepGetProcessedValue then swepGetProcessedValue = self.GetProcessedValue end

    local mdl = self.VModel

    if wm then
        if custompos then
            mdl = self.CModel
        else
            mdl = self.WModel

            if !isDepthPass and lod == 0 and mdl and mdl[1]:IsValid() then
                mdl[1]:SetMaterial(swepGetProcessedValue(self, "Material", true))
                
                if !mdl[1].MaterialAmount then mdl[1].MaterialAmount = table.Count(mdl[1]:GetMaterials() or {}) end

                for ind = 0, mdl[1].MaterialAmount do
                    local val = swepGetProcessedValue(self, "SubMaterial" .. ind, true)
                    if val then
                        mdl[1]:SetSubMaterial(ind, val)
                    end
                end
            end
        end

        if lod >= 2 then
            self:DrawModel()
            return
        end
    end

    if !mdl then
        self:KillModel()
        self:SetupModel(wm, lod, !!custompos)

        mdl = self.VModel

        if wm then
            mdl = self.WModel
            if custompos then
                mdl = self.CModel
            end
        end
    end

    if lod < 2 then
        local onground = wm and !validowner
    
        local hidebones = isnpc and {} or self:GetHiddenBones(wm)

        local customCamoTexture = swepGetProcessedValue(self, "CustomCamoTexture", true)
        local customCamoScale, customBlendFactor
        
        if customCamoTexture then 
            customCamoScale = swepGetProcessedValue(self, "CustomCamoScale", true)
            customBlendFactor = swepGetProcessedValue(self, "CustomBlendFactor", true)
        end

        local activesightadress = self:GetActiveSightSlotTable().Address
        local getpos = self:GetPos()
        local ARC9RTScopeRender = ARC9.RTScopeRender
        local scopecondition = !ARC9.PresetCam and !ARC9.RTScopeRender and !ARC9.OverDraw

        for _, model in ipairs(mdl or {}) do
            if model.IsAnimationProxy then continue end
            if !IsValid(model) then self:KillModel() return end

            local slottbl = model.slottbl
            local atttbl = self:GetFinalAttTable(slottbl)

            if isDepthPass and atttbl.StickerMaterial then continue end


            if !onground or model.OptimizPrevWMPos != getpos then -- mega optimiz
                if onground then model.OptimizPrevWMPos = getpos else model.OptimizPrevWMPos = nil end

                if ARC9RTScopeRender and atttbl.RTScope then continue end -- dont draw scope model while drawing vm from scope position
                
                model.hidden = false

                if model.charmparent then
                    continue
                else
                    if hidebones[slottbl.Bone or -1] then
                        model.hidden = true
                        continue
                    end

                    if model.Duplicate then
                        local duplitbl = (slottbl.DuplicateModels or {})[model.Duplicate]

                        if hidebones[(duplitbl or {}).Bone or -1] then
                            model.hidden = true
                            continue
                        end
                    end

                    local apos, aang = self:GetAttachmentPos(slottbl, wm, false, false, custompos, customang or a0, model.Duplicate)
                    model:SetPos(apos)
                    model:SetAngles(aang)
                    model:SetRenderOrigin(apos)
                    model:SetRenderAngles(aang)
                    model:SetupBones()

                    if model.charmmdl then
                        local bpos, bang

                        local bonename = atttbl.CharmBone
                        if bonename then
                            local boneindex = model:LookupBone(bonename)

                            local bonemat = model:GetBoneMatrix(boneindex)
                            if bonemat then
                                bpos = bonemat:GetTranslation()
                                bang = bonemat:GetAngles()
                            end

                            if bpos and bang then
                                local coffset = atttbl.CharmOffset or v0
                                local cangle = atttbl.CharmAngle or a0

                                bpos = bpos + bang:Forward() * coffset.y
                                bpos = bpos + bang:Up() * coffset.z
                                bpos = bpos + bang:Right() * coffset.x

                                local up, right, forward = bang:Up(), bang:Right(), bang:Forward()

                                bang:RotateAroundAxis(up, cangle.p)
                                bang:RotateAroundAxis(right, cangle.y)
                                bang:RotateAroundAxis(forward, cangle.r)

                                model.charmmdl:SetPos(bpos)
                                model.charmmdl:SetAngles(bang)
                                model.charmmdl:SetupBones()
                                model.charmmdl:DrawModel()
                            end
                        end
                    end
                end

                -- if !wm and atttbl.HoloSight then
                --     self:DoHolosight(model, atttbl)
                -- end

                if scopecondition then
                    if !wm and atttbl.RTScope or self.RTScope then
                        if !ARC9_ENABLE_NEWSCOPES_MEOW then self:DoRTScope(model, atttbl, slottbl.Address == activesightadress) end

                        if slottbl.Address == activesightadress then
                            self.RTScopeModel = model
                            if self.RTScope then atttbl.RTScopeNew_DisableShaderEyeOffset = true end
                            self.RTScopeAtttbl = atttbl
                        end
                    elseif !wm and atttbl.RTScopeNew_BlurTexture then
                        model.RTScope_BlurTexture = atttbl.RTScopeNew_BlurTexture
                        self.RTScope_ForceBlurModel = model
                    end
                end
            end

            model.CustomCamoTexture = customCamoTexture
            model.CustomCamoScale = customCamoScale
            model.CustomBlendFactor = customBlendFactor


            if !model.NoDraw and !(model.istranslucent and !ARC9.PresetCam and !onground and !isnpc) then
                -- if !wm then model:SetRenderOrigin(self.ViewModelPos or (IsValid(self:GetVM()) and self:GetVM():GetPos() or self:GetPos())) end
                if !wm and !isDepthPass then
                    drawModelWithTwoEyeAiming(self, model, flags, true)
                else
                    model:DrawModel(flags)
                end

                if !isDepthPass and (drawprojlights:GetBool() or rttenabled == false) then
                    render.RenderFlashlights(function()
                        if !wm then
                            drawModelWithTwoEyeAiming(self, model, flags, false)
                        else
                            model:DrawModel(flags)
                        end
                    end)
                end
            end

            if self.RTScopeModel == model and !model.RTScopeLength then model.RTScopeLength = getscopebound(self, model) end

            if atttbl.DrawFunc and !isDepthPass then
                atttbl.DrawFunc(self, model, wm)
            end
        end
    end
end

function SWEP:DrawTranslucentPass(wm) -- translucent pass, fuck source and gmod
    if !wm then
        local updatebitch = true
        if self.VModel then
            for _, model in ipairs(self.VModel) do
                if model.istranslucent and !model.hidden and IsValid(model) then
                    if self.CustomizeDelta > 0 then cam.IgnoreZ(true) end
                    if updatebitch then render.UpdatePowerOfTwoTexture() updatebitch = false end

                    drawModelWithTwoEyeAiming(self, model, nil, true)
                    
                    if model.translucentpassextramat then
                        render.MaterialOverride( model.translucentpassextramat )
                        render.SetBlend( model.translucentpassblend or 0.75 )
                        render.OverrideDepthEnable( true, true )
                            drawModelWithTwoEyeAiming(self, model, nil, false)
                            render.OverrideDepthEnable( false, false )
                        render.SetBlend( 1 )
                        render.MaterialOverride()
                    end
                end
            end
        end
    else
        if self.WModel then
            -- local rtt = render.GetRenderTarget()
            -- if rtt and rtt:GetName() == "_rt_waterreflection" then return end -- mirror fix -- doesn't work for some reason

            local lp = LocalPlayer()
            if (!IsValid(lp) or !lp:ShouldDrawLocalPlayer()) and lp == self:GetOwner() then return end -- mirror fix 2

            for _, model in ipairs(self.WModel) do
                if model.istranslucent and !model.hidden and IsValid(model) then
                    model:DrawModel()
                end
            end
        end
    end
end

function SWEP:GetActiveSightSlotTable()
    local sight = self:GetSight() or {}

    return sight.slottbl or {}
end

-- advanced camos

-- SWEP.AdvancedCamoCache = {}

local maxcamos = GetConVar("arc9_atts_maxcamos")

function SWEP:GetAdvancedCamo(att, address)
    if self.AdvancedCamoCache == false then return end -- disable this bitch if no super camo slots
    if !att then att = "" end
    if address then att = address end
    if self.AdvancedCamoCache == nil then self.AdvancedCamoCache = {} end

    if self.AdvancedCamoCache[att] then return self.AdvancedCamoCache[att] end

    local state = 1

    if att != "second" and att != "third" then
        if !address then
            state = (att != "") and self:GetValue(att .. "_camoslot") or 1
        else
            local slott = self:LocateSlotFromAddress(address)
            if istable(slott) and slott.ToggleNum then
                state = slott.ToggleNum
            end
        end
    end

    if att == "second" then state = 2 elseif att == "third" then state = 3 end

    local atts = {}

    local hasadvcamoslots = false
    local camoatt

    for _, i in ipairs(self:GetSubSlotList()) do
        if i["IsAdvancedCamo1"] then hasadvcamoslots = true end
        if i["IsAdvancedCamo" .. state] then
            if i.Installed then camoatt = self:GetFinalAttTable(i) end
        end
    end

    if camoatt then
        self.AdvancedCamoCache[att] = {
            Texture = camoatt.CustomCamoTexture,
            Scale = camoatt.CustomCamoScale,
            Rotate = camoatt.CustomCamoRotate,
            BlendMode = camoatt.CustomCamoBlendMode,
            Factor = camoatt.CustomBlendFactor,
            PhongMult = camoatt.CustomCamoPhongMult,
        }
    end

    if !hasadvcamoslots then self.AdvancedCamoCache = false return end -- disable this bitch if no super camo slots
    
    return self.AdvancedCamoCache[att]
end
