hook.Add("PreRender", "ARC9_PreRender", function()
    local lp = LocalPlayer()
    if lp:ShouldDrawLocalPlayer() then return end
    local wpn = lp:GetActiveWeapon()

    if !wpn.ARC9 then return end

    wpn:RunHook("Hook_DoRT")

    if wpn:IsCheapScope() then return end

    if ARC9_ENABLE_NEWSCOPES_MEOW and wpn.RTScopeModel and wpn.RTScopeModel.RTScopeDrawingRN then
        wpn:RenderRT(false, wpn:GetRTScopeMagnification())
    end
end)

hook.Add("PreDrawViewModels", "ARC9_PreDrawViewModels", function()
    local wpn = LocalPlayer():GetActiveWeapon()

    if !wpn.ARC9 then return end
    
    if ARC9.StencilFuckery then 
        render.SetStencilEnable( true )
        render.SetStencilWriteMask(64) 
        render.SetStencilTestMask(64)
        render.SetStencilReferenceValue(68)
        render.SetStencilCompareFunction(STENCIL_ALWAYS)
        -- render.SetStencilPassOperation(STENCIL_REPLACE)
        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilZFailOperation(STENCIL_KEEP)
    end

    if !wpn:IsCheapScope() then return end

    if ARC9_ENABLE_NEWSCOPES_MEOW and wpn.RTScopeModel and wpn.RTScopeModel.RTScopeDrawingRN then
        wpn:RenderRT(true)
    end
end)

local mat_dof = Material( "effects/arc9/vm_dof" )

hook.Add("RenderScreenspaceEffects", "ARC9_PostDrawViewModels", function()
    local lp = LocalPlayer()
    if lp:ShouldDrawLocalPlayer() then return end
    local wpn = lp:GetActiveWeapon()

    if !wpn.ARC9 then return end
    
    if !ARC9.IntelGPUDetected and mat_dof:GetFloat("$c0_x") > 0.4 then -- thats prob cheaper than checking for all conditions, handled in cl_vm anyway
        wpn:RenderDoF()
    end

    local atttbl = wpn:IsScoping()
    
    if wpn.RTScope then wpn.RTScopeModel = wpn:GetVM() end

    wpn:DrawRTReticle(wpn.RTScopeModel, atttbl or {}, nil, wpn:IsCheapScope())
end)


-- intel gpu detection
ARC9.IntelGPUDetected = false

if !system.IsLinux() and !system.IsOSX() then
    hook.Add("DrawOverlay", "IntelGPUDetector3000", function()
        hook.Remove("DrawOverlay", "IntelGPUDetector3000") -- run only once
        
        local RGBA8888 = 0
        local BGRA4444 = 19
        
        for _, d3dformat in ipairs( { BGRA4444, RGBA8888 } ) do
            local rt = GetRenderTargetEx("gpu_vendorcheck_" .. d3dformat, 16, 16, 0, 0, 32768, 0, d3dformat)
            if !rt then continue end
            
            render.PushRenderTarget(rt)
                cam.Start2D()
                    render.Clear(12, 77, 137, 211, true, true)
                    render.CapturePixels()
                    
                    local thepixel = render.ReadPixel(8, 8) 
                cam.End2D()
            render.PopRenderTarget()

            if d3dformat == BGRA4444 and thepixel == 16 then
                ARC9.IntelGPUDetected = true -- modern ARC - something diffferent with bgra4444
                break
            elseif d3dformat == RGBA8888 and math.abs(thepixel - 61) <= 2 then
                ARC9.IntelGPUDetected = true  -- legacy intel - applies a 2.2 gamma
                break
            end
        end
    end)
else -- opengl treated as intel too cuz weak
    ARC9.IntelGPUDetected = true
end