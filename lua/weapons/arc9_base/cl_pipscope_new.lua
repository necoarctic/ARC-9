ARC9_ENABLE_NEWSCOPES_MEOW = true

local arc9_fx_rt_shader = GetConVar("arc9_fx_rt_shader")
local arc9_fx_rt_alwaysdraw = GetConVar("arc9_fx_rt_alwaysdraw")
local arc9_fx_rtvm = GetConVar("arc9_fx_rtvm")
local arc9_fx_rt_fxaa = GetConVar("arc9_fx_rt_fxaa")
local arc9_scope_r = GetConVar("arc9_scope_r")
local arc9_scope_g = GetConVar("arc9_scope_g")
local arc9_scope_b = GetConVar("arc9_scope_b")

local fuckopengl = system.IsLinux() or system.IsOSX()

local scrw, scrh = ScrW(), ScrH()

local rt_main = GetRenderTargetEx( "arc9_optic_main", scrw, scrh, 
    RT_SIZE_FULL_FRAME_BUFFER, 
    MATERIAL_RT_DEPTH_SHARED, 
    bit.bor(4,8,256,512), 
    0, 
    IMAGE_FORMAT_RGB888
)

local rt_shaderpass = GetRenderTargetEx("arc9_optic_shaderpass",  scrw, scrh, 
    RT_SIZE_FULL_FRAME_BUFFER, 
    MATERIAL_RT_DEPTH_NONE, 
    bit.bor(4,8,256,512), 
    0, 
    IMAGE_FORMAT_RGB888
)

local rt_legacy_reticle = GetRenderTargetEx("arc9_optic_legacy_reticle",  scrh, scrh,
    RT_SIZE_LITERAL, 
    MATERIAL_RT_DEPTH_NONE, 
    bit.bor(4,8,256,512), 
    0, 
    IMAGE_FORMAT_RGBA8888
)

local rt_cheap = GetRenderTargetEx("arc9_optic_cheap",  scrw, scrh, 
    RT_SIZE_FULL_FRAME_BUFFER, 
    MATERIAL_RT_DEPTH_NONE, 
    bit.bor(4,8,256,512), 
    0, 
    IMAGE_FORMAT_RGB888
)

local mat_rt_expensive = CreateMaterial( "arc9_mat_optic", "UnlitGeneric", {
    ["$basetexture"] = rt_main:GetName(),
    ["$translucent"] = 0,
    ["$vertexcolor"] = 1
} )

local mat_rt_cheap = CreateMaterial( "arc9_mat_optic_cheap", "UnlitGeneric", {
    ["$basetexture"] = rt_cheap:GetName(),
    ["$translucent"] = 0,
    ["$vertexcolor"] = 1
} )

local mat_legacy_reticle = CreateMaterial( "arc9_mat_optic_legacy_reticle", "UnlitGeneric", {
    ["$basetexture"] = rt_legacy_reticle:GetName(),
    ["$translucent"] = 1,
    ["$vertexcolor"] = 1
} )

local mat_shader_lense = Material("arc9/lense_shader")
local mat_pixel_lense = Material("arc9/pixelation_shader")

-- Shader precalculations on cpu sideeeee

local function smoothstep(edge0, edge1, x)
    local t = math.Clamp((x - edge0) / (edge1 - edge0), 0, 1)
    return t * t * (3 - 2 * t)
end

-- static stuff

-- local shader_LENS_K_Base = -0.525 -- lens K
-- local shader_LENS_K_Base = -0.9 -- lens K
local shader_LENS_K_Base = -0.4 -- lens K
local shader_LENS_K = shader_LENS_K_Base
local shader_CA_STRENGTH_Base = 1.25 -- CA
local shader_CA_STRENGTH = shader_CA_STRENGTH_Base

local shader_VIG_FORG_Base = 5.5 -- vignette forgiveness
local shader_VIG_FORG = shader_VIG_FORG_Base
local shader_VIG_OFFSET = 4.75 -- vignette offset
local shader_VIG_R1 = 0.124 -- vignette rad1
local shader_VIG_R2 = 0.7 -- vignette rad2

local shader_EYE_OFFSET_INFLUENCE = 0.8
local shader_EYE_DISTANCE_INFLUENCE = 0.1

local scrlength = math.sqrt(scrw * scrw + scrh * scrh)

local function shadersetstaticvalues()
    mat_shader_lense:SetFloat("$c1_z", shader_VIG_R2 * scrh)
    mat_shader_lense:SetFloat("$c1_w", 0.8 * shader_VIG_R2 * scrh)
    mat_shader_lense:SetFloat("$c3_x", shader_LENS_K)
    mat_shader_lense:SetFloat("$c3_z", scrw)
    mat_shader_lense:SetFloat("$c3_w", scrh)

    mat_pixel_lense:SetFloat("c0_z", scrw/scrh)
end

timer.Simple(10, shadersetstaticvalues)

-- dynamic stuff

local function CalculateShaderCPU(eye_x, eye_y, eye_dist, camult, kmult) -- 0.5, 0.5, -0.05
    local eyelength = math.sqrt(eye_x * eye_x + eye_y * eye_y)

    local center_p_x = scrw * 0.5
    local center_p_y = scrh * 0.5
    local mouse_p_x = 0
    local mouse_p_y = 0

    if eyelength < 0.01 then
        mouse_p_x = 0.5 * scrw
        mouse_p_y = 0.5 * scrh
    else
        mouse_p_x = eye_x * scrw
        mouse_p_y = eye_y * scrh
    end

    local dir_p_x = mouse_p_x - center_p_x
    local dir_p_y = mouse_p_y - center_p_y
    local dir_len = math.sqrt(dir_p_x * dir_p_x + dir_p_y * dir_p_y)

    local norm_dir_x = 0
    local norm_dir_y = 0

    if dir_len >= 1 then
        norm_dir_x = dir_p_x / dir_len
        norm_dir_y = dir_p_y / dir_len
    end

    -- mouse
    local max_dist = 0.25 * scrlength * shader_VIG_FORG
    local t = math.Clamp(dir_len / max_dist, 0, 1)


    local offset_len = shader_VIG_OFFSET * math.min(scrw, scrh) * t
    local c1_p_x = center_p_x + norm_dir_x * offset_len * 1.75
    local c1_p_y = center_p_y + norm_dir_y * offset_len * 1.75

    mat_shader_lense:SetFloat("$c0_x", c1_p_x)
    mat_shader_lense:SetFloat("$c0_y", c1_p_y)

    -- some radius
    local rad1_p = ((0.8 - eye_dist) + shader_VIG_R1) * scrh

    mat_shader_lense:SetFloat("$c0_z", rad1_p)
    mat_shader_lense:SetFloat("$c0_w", (0.55 - eye_dist) * rad1_p)

    -- vignette
    local c2_p_x = center_p_x - norm_dir_x * offset_len * t * t
    local c2_p_y = center_p_y - norm_dir_y * offset_len * t * t

    mat_shader_lense:SetFloat("$c1_x", c2_p_x)
    mat_shader_lense:SetFloat("$c1_y", c2_p_y)
    
    -- ca
    local mouse_ca_boost = t * 200 * camult
    local lateral_ca = (0.025 + eye_dist / 15) * (1 + mouse_ca_boost)
    local ca_base = (0.5 + camult) * 1.5
    local forg_scale = (1 / shader_VIG_FORG * shader_VIG_FORG) * 0.05
    local ca_t = t * 0.5 + smoothstep(0.02, 0.2, t) * 100
    local ca_scale = ca_base * forg_scale * ca_t * 0.5

    mat_shader_lense:SetFloat("$c2_x", norm_dir_x * ca_scale * 2)
    mat_shader_lense:SetFloat("$c2_y", norm_dir_y * ca_scale * 2)
    mat_shader_lense:SetFloat("$c2_z", lateral_ca * 0.2)
    mat_shader_lense:SetFloat("$c2_w", lateral_ca * 0.8 * t)

    -- distorsion
    mat_shader_lense:SetFloat("$c3_x", shader_LENS_K_Base * kmult)
end

local Lerp = Lerp
local LerpVector = LerpVector

function SWEP:ShouldDoScope()
    if self:GetSight().Disassociate or self:GetOwner().ARC9NoScopes then return false end
	
    return true
end

local mat_optic_surface = Material("effects/arc9/rt")
local mat_cheap = Material("effects/arc9/rt_cheap")
local mat_cheap_sharpen = Material("effects/arc9/rt_cheap_sharpen")

local mat_shadow = Material("arc9/shadow3.png", "mips smooth")
local mat_shadow_2 = Material("arc9/shadow2.png", "mips smooth")
local mat_ahmad = Material("arc9/ahmad.png", "mips smooth")
local mat_black = CreateMaterial("arc9_real_black_mat", "UnlitGeneric", { ["$basetexture"] = "vgui/black", ["$ignorez"] = 1 }) -- vgui/black some reason turns transparent sometimes

local rt_eyeang = Angle()
local rt_eyepos = Vector()
local rt_viewsetup_fov = 90
local rt_viewsetup_fov_unscaled = 90

local invertcolormodif = {
	[ "$pp_colour_addr" ] = 0, [ "$pp_colour_addg" ] = 0, [ "$pp_colour_addb" ] = 0, 
    [ "$pp_colour_brightness" ] = 0, [ "$pp_colour_contrast" ] = 1,
	[ "$pp_colour_colour" ] = 1, [ "$pp_colour_mulr" ] = 0, [ "$pp_colour_mulg" ] = 0, [ "$pp_colour_mulb" ] = 0,
	[ "$pp_colour_inv" ] = 1,
}

local tune_nohdr = Vector(1, 0, 0 )

local fpslock_texture = GetRenderTargetEx("arc9_optic_motionblur2",  scrw, scrh, 
    RT_SIZE_FULL_FRAME_BUFFER, 
    MATERIAL_RT_DEPTH_NONE, 
    bit.bor(4,8,256,512), 
    0, 
    IMAGE_FORMAT_RGB888
)
local fpslock_mat = CreateMaterial( "arc9_mat_optic_motionblur2", "UnlitGeneric", {
    ["$basetexture"] = fpslock_texture:GetName(),
    ["$translucent"] = 0,
    ["$vertexcolor"] = 1
} )

local fpslock_nextdraw = 0

function SWEP:RenderRT(cheap, magnification)
    local atttbl = self:IsScoping()
    local renderedpicture

    if atttbl and !ARC9.OverDraw then
        local fpslock = atttbl.RTScopeNew_FPSLock

        if fpslock then if fpslock_nextdraw > CurTime() then rt_eyepos = MainEyePos() return end end
        
        if cheap then
            ARC9.DrawPhysBullets()
            renderedpicture = self:RenderRTCheap(atttbl)
        else
            renderedpicture = self:RenderRTExpensive(atttbl, magnification)
        end
        
        local pixely = !fuckopengl and atttbl.RTScopeNew_Pixelation
        if pixely then
            mat_pixel_lense:SetFloat("$c0_x", pixely)
            mat_pixel_lense:SetTexture("$basetexture", renderedpicture)
            render.PushRenderTarget( renderedpicture )
                render.SetMaterial( mat_pixel_lense )
                render.DrawScreenQuad()
            render.PopRenderTarget()
        end

        mat_shader_lense:SetTexture("$basetexture", renderedpicture)
        -- mat_rt_cheap:SetTexture("$basetexture", renderedpicture)
        -- mat_rt_expensive:SetTexture("$basetexture", renderedpicture)

        if fpslock then
            render.UpdateScreenEffectTexture()
            fpslock_mat:SetTexture( "$basetexture", fpslock_texture )
            
            if fpslock_nextdraw < CurTime() then
                fpslock_nextdraw = CurTime() + 1 / fpslock
                render.PushRenderTarget( fpslock_texture )
                    render.SetMaterial( cheap and mat_rt_cheap or mat_rt_expensive )
                    -- render.SetMaterial( pixely and mat_pixel_lense or mat_shader_lense )
                    render.DrawScreenQuad()
                render.PopRenderTarget()
            end
        end
    end
end

function SWEP:RenderRTCheap(atttbl)
    local viewstup = render.GetViewSetup()
    rt_viewsetup_fov, rt_viewsetup_fov_unscaled = viewstup.fov, viewstup.fov_unscaled

    render.UpdateScreenEffectTexture()
    mat_cheap:SetTexture("$basetexture", render.GetScreenEffectTexture())
    render.CopyRenderTargetToTexture( render.GetScreenEffectTexture() )
        
    rt_eyepos = MainEyePos()
    
    render.PushRenderTarget(rt_cheap)
        local oldtune = render.GetToneMappingScaleLinear()
        render.SetToneMappingScaleLinear( tune_nohdr ) -- Turns off hdr

        ARC9.OverDraw = true
        cam.IgnoreZ(false)

        render.Clear(67, 67, 0, 255)

        render.SetMaterial( mat_cheap )
        render.DrawScreenQuad()
        render.UpdateScreenEffectTexture()
        render.SetMaterial( mat_cheap_sharpen )
        render.DrawScreenQuad()

        if atttbl.RTScopeNightVision then
            self:DoNightScopeEffects(atttbl)
        end

        cam.Start3D()
            self:DrawLockOnHUD(true)
        cam.End3D()


        -- if self:GetSight().InvertColors then
            -- DrawColorModify(invertcolormodif)
        --     if atttbl.RTScopePostInvertFunc then
        --         atttbl.RTScopePostInvertFunc(self)
        --     end
        -- end

        cam.IgnoreZ(false)
        ARC9.OverDraw = false
    render.PopRenderTarget()

    render.SetToneMappingScaleLinear( oldtune ) -- Resets hdr
    
    if atttbl.RTScopeFLIR then
        cam.Start3D()
            self:DoFLIR(atttbl, true)
        cam.End3D()
    end

    return rt_cheap
end

local fxaa_mat = Material("effects/arc9/pp_fxaa")

function SWEP:RenderRTExpensive(atttbl, magnification)
    local viewstup = render.GetViewSetup()
    rt_viewsetup_fov, rt_viewsetup_fov_unscaled = viewstup.fov, viewstup.fov_unscaled
    -- local rtfov = rt_viewsetup_fov_unscaled / magnification
    local rtfov = self:ScaleFOVByWidthRatio(rt_viewsetup_fov, 0.75) / magnification
    local rtvm = !atttbl.RTScopeNew_DisableRTVM and arc9_fx_rtvm:GetBool()
    
    ARC9.RTScopeRenderFOV = rtfov

    rt_eyeang = MainEyeAngles()
    rt_eyepos = MainEyePos()
    
    local rt = {
        x = scrw/2-scrh/2,
        y = 0,
        w = scrh,
        h = scrh,
        angles = rt_eyeang,
        origin = rt_eyepos,
        drawviewmodel = rtvm,
        fov = rtfov,
        znear = 8,
        zfar = 30000,
        aspectratio = 1,
    }

    render.PushRenderTarget(rt_main)
    -- render.Clear(0,0,0,0)

        ARC9.OverDraw = true
        ARC9.RTScopeRender = rtvm
        render.RenderView(rt)
        
        atttbl = atttbl or {}

        if atttbl.RTScopeFLIR then
            cam.Start3D()
                self:DoFLIR(atttbl)
            cam.End3D()
        end

        if atttbl.RTScopeNightVision then
            self:DoNightScopeEffects(atttbl)
        end

        cam.Start3D()
            self:DrawLockOnHUD(true)
        cam.End3D()

        if !fuckopengl and arc9_fx_rt_fxaa:GetBool() then
            render.UpdateScreenEffectTexture()
            render.CopyRenderTargetToTexture(render.GetScreenEffectTexture())
            render.SetMaterial(fxaa_mat)
            render.DrawScreenQuad()
        end

        ARC9.RTScopeRender = false
        ARC9.OverDraw = false


        -- if self:GetSight().InvertColors then
            -- DrawColorModify(invertcolormodif)
        --     if atttbl.RTScopePostInvertFunc then
        --         atttbl.RTScopePostInvertFunc(self)
        --     end
        -- end
        
    render.PopRenderTarget()
    
    return rt_main
end

local function drawscopequad(scale, range, ang, pos, mat, color, nobox)
    local up, right, forward = ang:Up() * scale, ang:Right() * scale, ang:Forward() * range
    
    local half_up = up * 0.5
    local half_right = right * 0.5
    
    render.SetMaterial(mat)
    render.DrawQuad(
        pos + half_up - half_right + forward,
        pos + half_up + half_right + forward,
        pos - half_up + half_right + forward,
        pos - half_up - half_right + forward,
        color
    )

    if !nobox then
        render.SetMaterial(mat_black)
        
        local up_scaled = up * 0.999
        local right_scaled = right * 0.999
        local up_4 = up_scaled * 16
        local right_8 = right_scaled * 32
        local right_half = right_scaled * 0.5
        
        -- LEFT
        render.DrawQuad(
            pos + up_4 - right_8 + forward,
            pos + up_4 - right_half + forward,
            pos - up_4 - right_half + forward,
            pos - up_4 - right_8 + forward,
            color
        )
        
        -- RIGHT
        render.DrawQuad(
            pos + up_4 + right_half + forward,
            pos + up_4 + right_8 + forward,
            pos - up_4 + right_8 + forward,
            pos - up_4 + right_half + forward,
            color
        )
        
        -- TOP
        render.DrawQuad(
            pos + up_4 - half_right + forward,
            pos + up_4 + half_right + forward,
            pos + half_up + half_right + forward,
            pos + half_up - half_right + forward,
            color
        )
        
        -- BOTTOM
        render.DrawQuad(
            pos - half_up - half_right + forward,
            pos - half_up + half_right + forward,
            pos - up_4 + half_right + forward,
            pos - up_4 - half_right + forward,
            color
        )
    end
end

local scopebounds = {}

local function getscopebound(scopeent)
    local modelmodel = scopeent:GetModel()
    if !scopebounds[modelmodel] then
        local owo, uwu = scopeent:GetModelBounds()
        scopebounds[modelmodel] = {owo.x, uwu.x}
    end
    return scopebounds[modelmodel]
end

function SWEP:DrawRTReticle(model, atttbl, nonatt, cheap)
    if !IsValid(model) then return end

    local alwaydrwa = !atttbl.RTScopeNew_OnlyInSights and arc9_fx_rt_alwaysdraw:GetBool()
    local sightamt_orig = self:GetSightDelta()
    local active = alwaydrwa or sightamt_orig > 0.01

    local modelang = model:GetAngles()
    local modelforward = modelang:Forward()
    local modelpos_original = model:GetPos()
    local toscreen

    local sight = self:GetSight()
    local origsighttablepos = sight.OriginalSightTable and sight.OriginalSightTable.Pos or Vector(0, 0, 0)
    origsighttablepos = origsighttablepos
    local modelpos2 = modelpos_original
    - modelang:Up() * origsighttablepos.z
    - modelang:Right() * origsighttablepos.x


    local diff = MainEyePos() - modelpos2
    local dott = math.abs((-modelforward):Dot(diff) / diff:Length())
    

    if atttbl.RTScopeNew_DisableShaderEyeOffset then nonatt = true end

    -- print(dott)
    if dott < 0.7 and !nonatt then -- not looking at the scope
        active = false
    end

    model.RTScopeDrawingRN = active

    if active and self:ShouldDoScope() then
        local shaderenabled = !fuckopengl and (!atttbl.RTScopeNew_DisableShader and arc9_fx_rt_shader:GetBool() or (atttbl.RTScopeNew_FPSLock and !atttbl.RTScopeNew_Pixelation))

        -- if  then
            self.RenderingRTScope = true
            local sight = self:GetSight()

            local sightamt = math.ease.InBack(sightamt_orig)

            render.PushRenderTarget(cheap and rt_cheap or rt_main)

            if atttbl.RTScopeNew_FPSLock then
                render.SetMaterial( fpslock_mat )
                render.DrawScreenQuad()
            end

            self:DoRTScopeEffects()

            if cheap or !arc9_fx_rtvm:GetBool() then
                local fwd = MainEyeAngles():Forward()
                -- lasers
                cam.Start3D(rt_eyepos + fwd * 40, nil, rt_cheap and rt_viewsetup_fov_unscaled or ARC9.RTScopeRenderFOV, nil, nil, nil, nil, 1, 10000)
                    cam.IgnoreZ(true)
                    self:DrawLasers(false)
                cam.End3D()

                -- muzzleflasheas
                render.UpdateFullScreenDepthTexture()
                cam.Start3D(rt_eyepos + fwd * (cheap and 0 or 30), nil, rt_cheap and rt_viewsetup_fov_unscaled - 15 or ARC9.RTScopeRenderFOV, nil, nil, nil, nil, nil, nil)
                    for _, pcf in ipairs(self.MuzzPCFs) do
                        if IsValid(pcf) then
                            pcf:Render()
                        end
                    end
                    cam.IgnoreZ(false)
                cam.End3D()
            end
            
            local globalscalie = 4 * (atttbl.RTScopeReticleScale or 1)

            globalscalie = globalscalie * (atttbl.ScopeScreenRatio or 0.5)

            globalscalie = globalscalie - (scrw/scrh - 16/9) -- woops
            
            local reticle = sight.Reticle or atttbl.RTScopeReticle
            local color = atttbl.RTScopeColor or color_white
            
            if atttbl.RTScopeColorable then
                color = Color(0, 0, 0)
                color.r = arc9_scope_r:GetInt()
                color.g = arc9_scope_g:GetInt()
                color.b = arc9_scope_b:GetInt()
            end

            local legacydrawfunc = atttbl.RTScopeDrawFunc
            local newdrawfunc = atttbl.RTScopeNew_DrawFunc3D

            if legacydrawfunc then
                render.PushRenderTarget(rt_legacy_reticle)
                    render.Clear(0, 0, 0, 0)
                    cam.Start2D()
                        legacydrawfunc(self, scrh, sight)
                    cam.End2D()
                render.PopRenderTarget()
            end

            local scopebound = nonatt and {-2, 6} or getscopebound(model)
            if atttbl.RTScopeNew_FixAngle then
                if atttbl.RTScopeNew_FixAngle == "print" then
                    print("Angle(".. modelang[1] .. ", " .. modelang[2] .. ", " .. modelang[3] .. ")")
                else
                    modelang:RotateAroundAxis(modelforward, -atttbl.RTScopeNew_FixAngle[3])
                    modelang:RotateAroundAxis(modelang:Right(), -atttbl.RTScopeNew_FixAngle[1])
                    modelang:RotateAroundAxis(modelang:Up(), -atttbl.RTScopeNew_FixAngle[2])
                end
            end

            local modelpos = modelpos_original
            - modelang:Up() * origsighttablepos.z
            - modelforward * (-scopebound[1]) * (atttbl.Scale or 1) * (sight.Scale or 1)
            - modelang:Right() * origsighttablepos.x

            if nonatt then
                modelpos = rt_eyepos
                modelpos_original = rt_eyepos
                modelforward = rt_eyeang:Forward()
            end

            -- lua_run_cl hook.Add("NeedsDepthPass","a",function() return !LASTMEOW end) LASTMEOW = hook.Run("NeedsDepthPass") print(LASTMEOW)

            -- local fuck_fov = self.FOV
            local fuck_fov = 90

            cam.Start3D(nil, nil, fuck_fov, nil, nil, nil, nil, 0.1, 10000)
                cam.IgnoreZ(true)
                    toscreen = !nonatt and modelpos:ToScreen() or {x = scrw/2, y = scrh/2}
                    
                    local offsetx, offsety = 
                        (math.Clamp(toscreen.x / scrw, 0.3, 0.8) - 0.5) * shader_EYE_OFFSET_INFLUENCE * (atttbl.RTScopeNew_ShadowIntensity or 1),
                        (math.Clamp(toscreen.y / scrh, 0.3, 0.8) - 0.5) * shader_EYE_OFFSET_INFLUENCE * (atttbl.RTScopeNew_ShadowIntensity or 1)

                    local mreow =  math.max(math.abs(offsetx), math.abs(offsety)) * 1
                    
                    local eyedistance2 = modelpos_original:Distance(rt_eyepos) - origsighttablepos.y + mreow * 20

                    -- shader settings
                    if shaderenabled then
                        shader_VIG_FORG = shader_VIG_FORG_Base / ((atttbl.RTScopeNew_ShadowIntensity or 1) * 0.5)
                        shader_CA_STRENGTH = shader_CA_STRENGTH_Base * (atttbl.RTScopeNew_ChromaticAberrationMult or 1)
                        CalculateShaderCPU(offsetx + 0.5, offsety + 0.5, math.Clamp((mreow + eyedistance2 * 0.1) * shader_EYE_DISTANCE_INFLUENCE, -0.15, 0.8), shader_CA_STRENGTH, (atttbl.RTScopeNew_ShaderDistorsionMult or 1))
                    end

                    -- drawing stuffs
                    local dir = modelpos - rt_eyepos
                    local eyedistance = math.abs(dir:Dot(modelforward))
                    local lerped = Lerp(sightamt, modelpos, rt_eyepos + modelforward * eyedistance)

                    if newdrawfunc then newdrawfunc(self, scrh, sight, modelang, lerped) end -- new drawfunc

                    if reticle then drawscopequad(2 * globalscalie, 1.5, modelang, lerped, reticle, color, !atttbl.RTScopeNew_ReticleBlackBox) end -- reticle
                    
                    if legacydrawfunc then drawscopequad(2 * globalscalie, 1.5, modelang, lerped, mat_legacy_reticle, color_white, !atttbl.RTScopeNew_ReticleBlackBox) end -- legacy reticle drawfunc

                    -- local funnynumber2 = ( 1 / math.max(0.1, mreow * 2)) - math.max(0, dott - 0.9) * 20 + 2
                    -- local funnynumber2 = ( 1 / math.max(0.1, mreow * 2)) - math.max(0, dott - 0.9) * 20 + 2
                    -- funnynumber2 = math.max(1.5, funnynumber2 * math.max(0, (dott - 0.9) * 10))
                    -- print(eyedistance2)
                    -- local funnynumber2 = 
                    
                    local funnynumber2 = (self:GetInSights() and sightamt_orig <= 1) and Lerp(sightamt_orig, 2, 7.5) or 7.5 - math.Clamp(eyedistance2 * 1, 0, 6)
                    local funnynumber3 = Lerp(sightamt_orig, 50, 20)
                    
                    local diffy = (modelang - MainEyeAngles())
                    diffy:Normalize()
                    diffy.x = math.Clamp(diffy.x, -4, 4)
                    diffy.y = math.Clamp(diffy.y, -4, 4)
                    diffy.z = math.Clamp(diffy.z, -2, 2)

                    if atttbl.RTScopeAdjustable then
                        funnynumber2 = funnynumber2 - math.ease.InCubic(1 - (sight.SmoothScrollLevel or 0)) * 1.5 * sightamt_orig
                    end

                    if atttbl.RTScopeNew_FrontShadow != false or atttbl.RTScopeBlackBoxShadow != false then
                        drawscopequad(funnynumber2 * globalscalie * (atttbl.RTScopeNew_FrontShadowScale or 1) * (atttbl.RTScopeNew_ShadowScale or 1) * 2, funnynumber3 + (scopebound[2] - scopebound[1]), modelang + diffy * 7, lerped, mat_shadow, color_white) -- end of scope shadow
                        drawscopequad(funnynumber2 * globalscalie * (atttbl.RTScopeNew_FrontShadowScale or 1) * (atttbl.RTScopeNew_ShadowScale or 1), 0 + (scopebound[2] - scopebound[1]), modelang + diffy * -3, lerped, mat_shadow, color_white) -- end of scope shadow
                    end
                    
                    if atttbl.RTScopeNew_BackShadow != false and atttbl.RTScopeNoShadow != true then
                        drawscopequad(1.5 * globalscalie * (atttbl.RTScopeNew_BackShadowScale or 1) * (atttbl.RTScopeNew_ShadowScale or 1), -3, modelang + diffy * 5, lerped, mat_shadow, color_white) -- small shadow before reticle
                    end
                cam.IgnoreZ(false)

                if !cheap then
                    cam.Start2D()
                        surface.SetDrawColor(0, 0, 0, 255)
                        surface.DrawRect(0, 0, scrw/2 - scrh/2, scrh)
                        surface.DrawRect(scrw/2 + scrh/2, 0, scrw, scrh)
                        surface.SetMaterial(mat_shadow_2)
                        surface.DrawTexturedRect(scrw/2-scrh/2, 0, scrh, scrh) -- global shadow
                    cam.End2D()
                end

            cam.End3D()

            render.CopyRenderTargetToTexture(rt_shaderpass)
 
            render.PopRenderTarget()
        -- end

        render.PushRenderTarget(rt_shaderpass)
            render.Clear(0, 0, 0, 255, true)
            cam.Start2D()
                if shaderenabled then
                    render.SetMaterial(mat_shader_lense)
                    render.DrawScreenQuad()
                else
                    render.SetMaterial(cheap and mat_rt_cheap or mat_rt_expensive)
                    render.DrawScreenQuad()
                end

                surface.SetDrawColor(0, 0, 0, (1 - sightamt_orig) * (alwaydrwa and 128 or 255))
                surface.DrawRect(0, 0, scrw, scrh)
                
                if atttbl.RTScopeNew_DrawFunc2D then
                    atttbl.RTScopeNew_DrawFunc2D(self, scrw, scrh, sight)
                end
            cam.End2D()
        render.PopRenderTarget()

        mat_optic_surface:SetTexture("$basetexture", rt_shaderpass)

        model = model or self:GetVM()
        model:SetSubMaterial(atttbl.RTScopeSubmatIndex, "effects/arc9/rt")
        -- model:SetSubMaterial(1, "effects/arc9/rt")
    else
        mat_optic_surface:SetTexture("$basetexture", "vgui/black")
        model:SetSubMaterial(atttbl.RTScopeSubmatIndex, "vgui/black")
    end
end

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

local noise = Material("arc9/nvnoise")

function SWEP:DoNightScopeEffects(atttbl)
    if atttbl.RTScopeNightVisionMonochrome then
        DrawColorModify(monochrometable)
    end

    if !atttbl.RTScopeNightVisionNoPP then
        cam.Start2D()
        surface.SetMaterial(noise)
        surface.SetDrawColor(atttbl.RTScopeNightVisionNoiseColor or color_white)
        surface.DrawTexturedRectRotated((scrh / 2) + (scrh * math.Rand(-0.25, 0.25)), (scrh / 2) + (scrh * math.Rand(-0.25, 0.25)), scrh, scrh, math.Rand(0, 360))
        surface.DrawTexturedRectRotated((scrh / 2) + (scrh * math.Rand(-0.5, 0.5)), (scrh / 2) + (scrh * math.Rand(-0.5, 0.5)), scrh * 2, scrh * 2, math.Rand(0, 360))
        cam.End2D()

        DrawBloom(0, 1, 10, 1, 1, 1, 1, 1, 1)
    end

    if atttbl.RTScopeNightVisionCC then
        if !atttbl.RTScopeNightVisionCC["pp_colour_inv"] then atttbl.RTScopeNightVisionCC["pp_colour_inv"] = 0 end
        DrawColorModify(atttbl.RTScopeNightVisionCC)
    end

    if atttbl.RTScopeNightVisionFunc then
        atttbl.RTScopeNightVisionFunc(self)
    end
end

function SWEP:DoRTScopeEffects()
    local atttbl = ((self:GetSight() or {}).atttbl or {})


    if atttbl.RTScopeNoPP then return end

    if atttbl.RTScopeCustomPPFunc then
        render.UpdateScreenEffectTexture()
        atttbl.RTScopeCustomPPFunc(self)
    end
end



if ARC9.Dev(2) then
    local testmat = CreateMaterial( "testpipscope23", "UnlitGeneric", {
        ["$basetexture"] = rt_shaderpass:GetName(), -- You can use "example_rt" as well
        ["$translucent"] = 0,
        ["$vertexcolor"] = 1
    } )

    hook.Add("HUDPaint", "arc9_test_pipscope", function()
        -- if ARC9.Dev(2) then
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(testmat)
            -- surface.DrawTexturedRect(scrw-scrw/4, scrh/2-scrh/3, scrw/4, scrh/4)
            surface.DrawTexturedRect(0, 20, scrw/6, scrh/6)
        -- end
    end)
end

-- Track convar changes for the cheapscopes text display
local cheapscopes_last_change_time = CurTime()
local cheapscopes_last_value = GetConVar("arc9_cheapscopes"):GetBool()


-- improves framerate ⬇️ ✅

--[[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⠀⠙⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠗⠀⠀⣀⣄⠀⢿⣿⣿⣿⠟⠁⢠⡆⠉⠙⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠀⠀⣴⣿⡟⠀⠘⣿⣿⠋⠀⠀⠀⢠⣶⡀⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀⢠⣿⠛⣶⠀⠀⣿⡟⠀⠀⠀⢠⣿⣿⡇⠀⠠⣽⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠅⠀⠀⣿⠏⠀⣿⠀⠀⣿⠁⠀⠀⢠⣿⠟⢻⡇⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠀⠀⣼⣿⠀⢰⡟⠀⠀⠛⠀⠀⠀⣾⡇⠀⢸⡇⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠿⠃⠀⠈⠀⢀⠀⣀⣀⠀⠘⠟⠀⠀⡾⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠃⠀⠀⠀⢀⠂⠀⠈⠉⢴⣽⣿⠵⣿⡶⣂⣄⡀⠀⠀⢰⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⡟⠡⠆⢀⠀⠀⠀⠀⠄⠀⠈⠘⠏⢿⣶⣿⡿⢟⣱⣖⠒⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⡟⣻⠏⣠⠄⠀⢀⡀⠀⠀⠀⠀⠈⠀⠀⠀⢸⣿⢦⠄⠙⣿⡇⠩⣭⣅⠈⢿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣟⣼⡇⠈⢀⣴⠆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠁⠀⢀⠀⠈⠰⣶⡤⠿⠃⢸⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⡟⠉⢠⡶⠋⠀⠀⠀⠀⠀⠀⠀⢀⣤⣤⣴⣶⣤⣄⡀⠀⠀⠂⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⣿⣿
⣿⣿⣿⡏⢀⡠⠀⠀⠀⠀⠀⠀⠀⢀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣶⣦⣄⠀⠀⠂⠀⠈⣿⣿⣿⣿
⣿⣿⣿⢃⠈⠀⢠⠀⠀⠀⠀⠀⢠⣿⣿⣿⠿⣩⣏⡙⣛⣛⣿⣿⣿⣿⣿⣿⣿⡿⢇⠀⠀⠄⠀⠘⣿⣿⣿
⣿⣿⣿⡎⠀⠀⠀⠀⠀⠀⠀⠠⣿⣿⣿⡟⣰⣿⠁⢀⠈⢿⣿⣿⣿⣿⢁⣴⠖⢲⣾⡇⠀⠀⠄⠀⣿⣿⣿
⣿⣿⣿⢀⠀⠀⠀⠀⠀⠀⠀⠀⣏⢿⣿⡇⣿⡇⠀⠀⠀⣼⣿⣿⣿⡇⣼⡏⠀⠀⣿⡇⠀⠀⠀⠀⣻⣿⣿⣿
⣿⣿⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⢸⣄⠻⣷⡘⣷⣀⣀⣴⣿⡟⠉⠛⠓⣿⡇⠀⢰⣿⡇⠀⠀⠀⣼⣿⣿⣿
⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠙⢷⣌⠻⢿⣿⣿⣿⣿⣿⣦⣶⣿⣾⣧⣤⡾⠏⠀⠀⠀⠀⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⠶⢌⣉⣛⠛⠿⠿⠿⠿⠿⠛⠉⠀⠀⠀⠀⣰⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣶⣄⠀⠀⠀⠀⠲⠀⠀⠀⠀⠀⠀⠉⠉⠉⠀⠀⠀⠈⠁⠀⠀⠀⣠⣾⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⠻⠿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⡏⠛⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡘⡻⣿⣿⣿⣿
⣿⣿⣿⣿⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⢨⡛⡛⣁⣿⣿⣿⣿
⣿⣿⣿⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠂⠀⠀⠀⠀⠀⠀⠀⠀⣠⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⠇⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣤⣄⣠⣴⣾⣿⣿⣿⣿⣿⣿
⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⡿⠋⠠⣾⡇⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⡟⢁⣠⣤⣦⣌⡃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣏⡹⢿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⡿⠿⢶⡬⠙⠟⠋⣁⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣏⠛⠚⠃⠀⠀⢰⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣧⣆⣤⣄⣤⣼⠁⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠠⠒⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⠿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣧⣤⣴⣴⣦⠀⣄⠀⠀⠀⠀⠀⠀⠀⠀⢀⡀⠀⠐⠚⠛⠓⠂⢀⡄⠀⢰⢽⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣰⣤⣄⣀⢀⠀⢠⡅⠀⠀⢀⣤⣤⡼⠧⣤⣤⣠⣤⣤⣄⡀⡀⣰⣦⣣⠈⡡⣽
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣹⣿⣿⣿⣾⣷⣾⡗⣒⠶⣿⣿⣿⡷⣾⣿⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣿]]