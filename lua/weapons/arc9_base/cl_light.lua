SWEP.Flashlights = {} -- tracks projectedlights
-- {{att = int, light = ProjectedTexture}}

function SWEP:GetHasFlashlights()
    for i, k in ipairs(self:GetAttachmentList()) do
        local atttbl = self:GetFinalAttTable(k)

        if atttbl.Flashlight then return true end
    end

    return false
end

local nvgon = false
local function checknvg(wpn) -- this func a bit different than what in cl_laser
    local lp = LocalPlayer()
    if !IsValid(lp) then return end
    if lp.quadnodsonlight or lp:GetNWBool("nvg_on", false) then return true end -- arctic nvgs and mw nvgs
    if lp.EZarmor and lp.EZarmor.effects and lp.EZarmor.effects.nightVision then return true end -- jmod
    local sight = wpn:GetSight()
    if sight and wpn:GetSightAmount() > 0.8 and !wpn.Peeking and sight.atttbl and sight.atttbl.RTScopeNightVision then return true end

    return false
end

local arc9_allflash = GetConVar("arc9_allflash")

local irflashcolor = Color(106, 255, 218)

function SWEP:CreateFlashlights()
    self:KillFlashlights()
    self.Flashlights = {}

    local total_lights = 0
    local lp = LocalPlayer()
    nvgon = checknvg(self)
    
    for _, k in ipairs(self:GetSubSlotList()) do
        if !k.Installed then continue end
        local atttbl = self:GetFinalAttTable(k)

        if atttbl.Flashlight then
            local newlight = {
                slottbl = k,
                light = ProjectedTexture(),
                col = atttbl.FlashlightColor or color_white,
                br = atttbl.FlashlightBrightness or 3,
                qca = atttbl.FlashlightAttachment,
                nodotter = atttbl.Flashlight360
            }

            if nvgon and atttbl.FlashlightIR then
                newlight.col = irflashcolor
                newlight.br = 1
            end

            total_lights = total_lights + 1

            local l = newlight.light
            if !IsValid(l) then continue end

            table.insert(self.Flashlights, newlight)

            l:SetFOV(atttbl.FlashlightFOV or 50)


            l:SetFarZ(atttbl.FlashlightDistance or 1024)
            -- l:SetNearZ(4)
            l:SetNearZ(0) -- setting to 4 when drawing to prevent flicker (position here is undefined)

            l:SetQuadraticAttenuation(100)

            l:SetColor(atttbl.FlashlightColor or color_white)
            l:SetTexture(atttbl.FlashlightMaterial or "effects/flashlight001")
            l:SetBrightness(atttbl.FlashlightBrightness or 3)

            
            if nvgon and atttbl.FlashlightIR then
                l:SetFOV((atttbl.FlashlightFOV or 50) * 1.5)
                l:SetFarZ(2048)
                l:SetColor(irflashcolor)
                -- l:SetTexture(atttbl.FlashlightMaterial or "effects/flashlight001")
                l:SetBrightness(1)
            end

            l:SetEnableShadows(true)
            l:Update()

            local g_light = {
                Weapon = self,
                ProjectedTexture = l
            }

            table.insert(ARC9.FlashlightPile, g_light)
        end
    end

    if total_lights > 1 or (arc9_allflash:GetBool() and self:GetOwner() != lp) then -- you are a madman
        for i, k in ipairs(self.Flashlights) do
            if k.light:IsValid() then k.light:SetEnableShadows(false) end
        end
    end
end

function SWEP:KillFlashlights()
    if !self.Flashlights then return end

    for i, k in ipairs(self.Flashlights) do
        if k.light and k.light:IsValid() then
            k.light:Remove()
        end
    end

    self.Flashlights = nil
end

local fuckingbullshit = Vector(0, 0, 0.001)
local gunoffset = Vector(0, 0, -16)

function SWEP:DrawFlashlightsWM()
    local owner = self:GetOwner()
    local lp = LocalPlayer()

    local isotherplayer = owner != lp
    if isotherplayer and !arc9_allflash:GetBool() then return end
    if !isotherplayer and !owner:ShouldDrawLocalPlayer() then return end

    if !self.Flashlights then
        self:CreateFlashlights()
    end
    
    if isotherplayer and lp:EyePos():DistToSqr(owner:EyePos()) > 2048^2 then self:KillFlashlights() return end
    local wmnotdrawn = self.LastWMDrawn != FrameNumber() and isotherplayer

    local anydrawn = false
    for i, k in ipairs(self.Flashlights) do
        local model = (k.slottbl or {}).WModel

        -- if !IsValid(model) then continue end
        anydrawn = true
        if k.br == 0 then continue end

        local pos, ang


        if wmnotdrawn or !IsValid(model) then
            pos = owner:EyePos() + gunoffset
            ang = owner:EyeAngles()
        else
            pos = model:GetPos()
            ang = model:GetAngles()
            
            if k.qca then
                local a = model:GetAttachment(k.qca)
                if a then pos, ang = a.Pos, a.Ang end
                ang:RotateAroundAxis(ang:Up(), 90)
            end
        end
        
        self:DrawLightFlare(pos + fuckingbullshit, ang, k.col, k.br / 6, nil, k.nodotter)
        local tr = util.TraceLine({
            start = pos,
            endpos = pos + ang:Forward() * 16,
            mask = MASK_OPAQUE,
            filter = lp,
        })
        if tr.Fraction < 1 then -- We need to push the flashlight back
            local tr2 = util.TraceLine({
                start = pos,
                endpos = pos - ang:Forward() * 16,
                mask = MASK_OPAQUE,
                filter = lp,
            })
            -- push it as back as the area behind us allows
            pos = pos + -ang:Forward() * 16 * math.min(1 - tr.Fraction, tr2.Fraction)
        else
            pos = tr.HitPos
        end

        k.light:SetNearZ(4)
        k.light:SetPos(pos)
        k.light:SetAngles(ang)
        k.light:Update()
    end
    
    if anydrawn and nvgon != checknvg(self) then
        self:CreateFlashlights()
    end
end

function SWEP:DrawFlashlightsVM()
    if !self.Flashlights then
        self:CreateFlashlights()
    end

    local owner = self:GetOwner()
    local lp = LocalPlayer()
    if !IsValid(owner) then return end
    local eyepos = owner:EyePos()

    local anydrawn = false
    
    render.SetStencilEnable(false) -- no flashlights in stencil

    for i, k in ipairs(self.Flashlights) do
        local model = (k.slottbl or {}).VModel

        if !IsValid(model) then continue end
        anydrawn = true
        if k.br == 0 then continue end

        local pos, ang

        if !model then
            pos = eyepos
            ang = owner:EyeAngles()
        else
            pos = model:GetPos()
            ang = model:GetAngles()
        end

        if k.qca then
            a = model:GetAttachment(k.qca)

            if a then
                pos, ang = a.Pos, a.Ang
            else
                ang:RotateAroundAxis(ang:Up(), -90)
            end
        end

        self:DrawLightFlare(pos, ang, k.col, k.br / 6, true, k.nodotter, -ang:Right())

        if k.qca then ang:RotateAroundAxis(ang:Up(), 90) end

        local tr = util.TraceLine({
            start = eyepos,
            endpos = eyepos - -ang:Forward() * 128,
            mask = MASK_OPAQUE,
            filter = lp,
        })
        if tr.Fraction < 1 then -- We need to push the flashlight back
            local tr2 = util.TraceLine({
                start = eyepos,
                endpos = eyepos + -ang:Forward() * 128,
                mask = MASK_OPAQUE,
                filter = lp,
            })
            -- push it as back as the area behind us allows
            pos = pos + -ang:Forward() * 32 * math.min(1 - tr.Fraction, tr2.Fraction)
        end

        k.light:SetNearZ(4)
        k.light:SetPos(pos)
        k.light:SetAngles(ang)
        k.light:Update()
    end
    
    if anydrawn and nvgon != checknvg(self) then
        self:CreateFlashlights()
    end
end

local flaremat = Material("effects/arc9_lensflare", "mips smooth")
local badcolor = Color(255, 255, 255)

function SWEP:DrawLightFlare(pos, ang, col, size, vm, nodotter, dir) -- mostly tacrp
    col = col or badcolor
    size = size or 1

    local lp, owner = LocalPlayer(), self:GetOwner()
    if !vm and owner == lp and !lp:ShouldDrawLocalPlayer() then return end
    
    dir = dir or ang:Forward()

    local dot = -dir:Dot(EyeAngles():Forward())
    local dot2 = dir:Dot((EyePos() - pos):GetNormalized())
    dot = (dot + dot2) / 2
    
    if nodotter then dot, dot2 = 1, 1 end

    if dot < 0 then return end

    local diff = EyePos() - pos

    dot = dot ^ 4
    local tr = util.QuickTrace(pos, diff, {owner, lp, lp:GetViewEntity()})
    local s = math.Clamp(1 - diff:Length() / 700, 0, 1) ^ 1 * dot * 500 * math.Rand(0.95, 1.05) * size
    
    local rtt = render.GetRenderTarget()
    if rtt and rtt:GetName() == "_rt_waterreflection" then tr.Fraction = 1 end -- mirror fix
    
    if vm or tr.Fraction == 1 then
        s = ScreenScale(s)
        local toscreen = pos:ToScreen()
        cam.Start2D()
            surface.SetMaterial(flaremat)
            surface.SetDrawColor(col, 128)
            surface.DrawTexturedRect(toscreen.x - s / 2, toscreen.y - s / 2, s, s)
        cam.End2D()

        if !vm and size > 0.1 then
            local rad = 128 * size * dot2
            col.a = 50 + size * 205

            pos = pos + ang:Forward() * 2
            pos = pos + diff:GetNormalized() * (2 + 14 * size)

            render.SetMaterial(flaremat)
            render.DrawSprite(pos, rad, rad, col)
        end
    end
end
