-- Render thermal highlighting to the currently active RT.

local lastentcount = 0
local lastents = {}

local coldtime = 20

local monochrometable = {
    ["$pp_colour_addr"] = 0,
    ["$pp_colour_addg"] = 0,
    ["$pp_colour_addb"] = 0,
    ["$pp_colour_brightness"] = 0,
    ["$pp_colour_contrast"] = 1,
    ["$pp_colour_colour"] = 0,
    ["$pp_colour_mulr"] = 0,
    ["$pp_colour_mulg"] = 0,
    ["$pp_colour_mulb"] = 0,
    ["$pp_colour_inv"] = 0
}

local defaultcolortable = {
    ["$pp_colour_addr"] = 0,
    ["$pp_colour_addg"] = 0,
    ["$pp_colour_addb"] = 0,
    ["$pp_colour_brightness"] = 0,
    ["$pp_colour_contrast"] = 1,
    ["$pp_colour_colour"] = 1,
    ["$pp_colour_mulr"] = 0,
    ["$pp_colour_mulg"] = 0,
    ["$pp_colour_mulb"] = 0,
    ["$pp_colour_inv"] = 0
}

local mat_ColorMod = Material( "pp/colour" )

local ref = 32
local r_def = 2048

local function resetcolormod()
    for k, v in pairs( defaultcolortable ) do
        mat_ColorMod:SetFloat( k, v )
    end
end

local scrw, scrh = ScrW(), ScrH()

local rt_spare = GetRenderTargetEx( "arc9_optic_cheap_spare", scrw, scrh, 
    RT_SIZE_FULL_FRAME_BUFFER, 
    MATERIAL_RT_DEPTH_SHARED, 
    bit.bor(4,8,256,512), 
    0, 
    IMAGE_FORMAT_RGB888
)

local rt_cheap = GetRenderTargetEx("arc9_optic_cheap",  scrw, scrh, 
    RT_SIZE_FULL_FRAME_BUFFER, 
    MATERIAL_RT_DEPTH_NONE, 
    bit.bor(4,8,256,512), 
    0, 
    IMAGE_FORMAT_RGB888
)

local opaqueglass = Material("effects/arc9/opaqueglass")
local opaqueglassbrush = Material("effects/arc9/opaqueglassbrush")

local function isglass(ent)
    if ent.ARC9_IsGlass then return true end

    local class = ent:GetClass()
    if class == "func_breakable_surf" then
        ent.ARC9_IsGlass = true
        return true
    elseif class == "func_breakable" and ent.GetBrushSurfaces then 
        local surfs = ent:GetBrushSurfaces()
        local mat = surfs and surfs[1] and surfs[1]:GetMaterial()

        if mat and string.find(mat:GetName(), "glass") then
            ent.ARC9_IsGlass = true
            return true
        end
    elseif (class == "prop_dynamic" or class == "prop_static" or class == "prop_physics") and ent.GetMaterials then 
        local mats = ent:GetMaterials()
        local mat = mats and mats[1]

        if mat and string.find(mat, "glass") then
            ent.ARC9_IsGlass = true
            return true
        end
    end
end

-- touching anything here breaks everything i don't know how this works
-- i think every second frame it draws "screen" outside of gun, but it kinda works

function SWEP:DoFLIR(atttbl, cheap, force)
    if cheap then
        if screen and screen:GetName()  == "_rt_resolvedfullframedepth" then return end
        render.CopyTexture( screen, rt_spare )

        render.PushRenderTarget(screen)
    end

    if force or self:GetSightAmount() > 0.1 then
        render.SetStencilEnable(true)
        render.SetStencilWriteMask(255)
        render.SetStencilTestMask(255)
        render.ClearStencil()

        -- local targets = ents.FindInCone(EyePos(), EyeAngles():Forward(), atttbl.RTScopeFLIRRange or 30000, math.cos(fov + 5))
        local targets = lastents
        local entcount = ents.GetCount()
        local range = (atttbl.FLIRRange or r_def)/ARC9.HUToM

        if lastentcount != entcount then
            targets = ents.GetAll()
            lastents = targets
        end

        lastentcount = entcount

        render.SuppressEngineLighting(true)
        render.SetColorModulation(0, 0, 0)
            render.SetBlend(1)

        if !atttbl.RTScopeFLIRSolid then
            render.SetBlend(atttbl.RTScopeFLIRBlend or 0.25)
            render.SetColorModulation(1, 1, 1)
        else
            render.SetBlend(1)
        end

        cam.IgnoreZ(false)
        render.SetStencilReferenceValue(ref)
        render.SetStencilPassOperation(STENCIL_REPLACE)
        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilZFailOperation(STENCIL_KEEP)
        render.SetStencilCompareFunction(STENCIL_ALWAYS)

        local glassstuff = {}

        for _, ent in ipairs(targets) do
            if ent == self:GetOwner() then continue end
            local hot = self:GetEntityHot(ent, range)
            if atttbl.FLIRHotFunc then
                hot = atttbl.FLIRHotFunc(self, ent)
            end

            if IsValid(ent) and isglass(ent) then
                table.insert(glassstuff, ent)
                hot = true
            end

            if !hot then continue end

            ent:DrawModel()
        end



        -- ARC9.DrawPhysBullets(true) -- you guys think this is a bug

        cam.Start3D()
            cam.IgnoreZ(true)
            for _, pcf in ipairs(self.MuzzPCFs) do
                if IsValid(pcf) then
                    pcf:Render()
                end
            end
            cam.IgnoreZ(false)
        cam.End3D()


            
        -- cam.IgnoreZ(true)

        render.SetColorModulation(1, 1, 1)
        render.SuppressEngineLighting(false)
        render.SetBlend(1)

        render.SetStencilReferenceValue(ref)
        render.SetStencilCompareFunction(STENCIL_EQUAL)
        render.SetStencilPassOperation(STENCIL_KEEP)

        render.SetStencilEnable(false)

        
        render.MaterialOverride(opaqueglass)
        render.BrushMaterialOverride(opaqueglassbrush)
        for _, ent in ipairs(glassstuff) do
            ent:DrawModel()
        end
        render.MaterialOverride()
        render.BrushMaterialOverride()

        render.SetStencilEnable(true)

        if atttbl.RTScopeFLIRSolid then
            render.SetColorMaterial()
            render.DrawScreenQuad()
        end

        if atttbl.RTScopeFLIRMonochrome then
            render.SetStencilCompareFunction(STENCIL_ALWAYS)
            DrawColorModify(monochrometable)
        end

        if atttbl.RTScopeFLIRCCCold then
            render.SetStencilCompareFunction(STENCIL_NOTEQUAL)
            if !atttbl.RTScopeFLIRCCCold["pp_colour_inv"] then atttbl.RTScopeFLIRCCCold["pp_colour_inv"] = 0 end
            DrawColorModify(atttbl.RTScopeFLIRCCCold)
        end

        if atttbl.RTScopeFLIRCCHot then
            render.SetStencilCompareFunction(STENCIL_EQUAL)
            if !atttbl.RTScopeFLIRCCHot["pp_colour_inv"] then atttbl.RTScopeFLIRCCHot["pp_colour_inv"] = 0 end
            DrawColorModify(atttbl.RTScopeFLIRCCHot)
        end

        render.UpdateScreenEffectTexture()

        if atttbl.RTScopeFLIRFunc then
            atttbl.RTScopeFLIRFunc(self)
        end

        if atttbl.RTScopeFLIRHotOnlyFunc then
            atttbl.RTScopeFLIRHotOnlyFunc(self)
        end

        render.SetStencilEnable(false)

    else
        if atttbl.RTScopeFLIRCCCold then
            render.SetStencilCompareFunction(STENCIL_NOTEQUAL)
            if !atttbl.RTScopeFLIRCCCold["pp_colour_inv"] then atttbl.RTScopeFLIRCCCold["pp_colour_inv"] = 0 end
            DrawColorModify(atttbl.RTScopeFLIRCCCold)
        end
        render.UpdateScreenEffectTexture()
    end

    if cheap then
        render.PopRenderTarget()
        render.CopyTexture( screen, rt_cheap )
        render.DrawTextureToScreen(rt_spare)
        -- render.UpdateFullScreenDepthTexture()
    end

	resetcolormod() -- just in case
end

-- local maxrange = (160/ARC9.HUToM)^2 -- 160 m

function SWEP:GetEntityHot(ent, range)
    if !ent:IsValid() or ent:IsWorld() then return false end

    if self:GetPos():DistToSqr(ent:GetPos()) > (range or r_def) ^ 2 then return end

    if ent:IsPlayer() then
        if ent.ArcticMedShots_ActiveEffects and ent.ArcticMedShots_ActiveEffects["coldblooded"] or ent:Health() <= 0 then return false end -- arc stims
        return true
    end

    if ent:IsNPC() or ent:IsNextBot() then -- npcs
        if ent.ARC9CLHealth and ent.ARC9CLHealth <= 0 or ent:Health() <= 0 then return false end
        return true
    end

    if ent:IsRagdoll() then -- ragdolling
        if !ent.ARC9_ColdTime then ent.ARC9_ColdTime = CurTime() + coldtime end
        return ent.ARC9_ColdTime > CurTime()
    end
    if ent:IsVehicle() or ent:IsOnFire() or ent.ArcCW_Hot or ent:IsScripted() and !ent:GetOwner():IsValid() and ent:EntIndex() > 0 then -- arccw_hot for compatibillity
        return true
    end

    if ent:GetClass() == "class CLuaEffect" then
        return true
    end

    return false
end

-- local mat = Material("effects/arc9/opaqueglass")

-- hook.Add("PreDrawTranslucentRenderables", "GlassThermal", function()
--     if !bDrawThermal then return end
--     -- render.WorldMaterialOverride(mat)
--     render.BrushMaterialOverride(mat)
-- end)

-- hook.Add("PostDrawTranslucentRenderables", "GlassThermal", function()
--     if !bDrawThermal then return end
--     -- render.WorldMaterialOverride()
--     render.BrushMaterialOverride()
-- end)