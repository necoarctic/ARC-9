ARC9.RelativeCamAngles = Angle(0, 0, 0)
ARC9.RelativePlayerAngles = Angle(0, 0, 0)
ARC9.FOV = 90

ARC9.RealCamPos = Vector(0, 0, 0)
ARC9.RealCamAng = Angle(0, 0, 0)

local arc9_cam_shoulder = GetConVar("arc9_cam_shoulder")
local sensitivity = GetConVar("sensitivity")
local m_yaw = GetConVar("m_yaw")
local m_pitch = GetConVar("m_pitch")
local arc9_thirdperson_force = GetConVar("arc9_thirdperson_force")
local arc9_thirdperson = GetConVar("arc9_thirdperson")

function ARC9.CalcView( ply, pos, angles, fov )
    local cam_enabled = ARC9.ShouldThirdPerson()
    local znear = 2

    local att = ARC9.EyeAtt
    local cam_forward = 0
    local cam_up = 0
    local cam_right = 0
    local cam_drawviewer = true
    local cam_angoffset = Angle(0, 0, 0)

    local tracestart = pos
    local traceend = nil

    local wpn = ply:GetActiveWeapon()

    -- local view = {}

    if !wpn.ARC9 then return end

    -- if wpn:BeingOvertaken() then return end

    if !cam_enabled then return end
    --if wpn:GetInSights() then return end
	if wpn:GetInSights() and wpn.IronSights["ForceFP"] then return end -- (wpn.IronSights["Scope"] or !GetConVar("arc9_thirdperson_sights"))
    --if wpn:GetSightAmount() >= 0.1 then return end

    -- local targetfov = GetConVar("ARC9_fov"):GetFloat()
    -- local basefov = targetfov

    -- att = GetConVar("ARC9_cam_att"):GetString()
    -- cam_forward = GetConVar("ARC9_cam_forward"):GetFloat()
    -- cam_right = GetConVar("ARC9_cam_right"):GetFloat()
    -- cam_up = GetConVar("ARC9_cam_up"):GetFloat()

    -- if GetConVar("ARC9_rcam"):GetBool() then
    --     att = GetConVar("ARC9_rcam_att"):GetString()
    --     cam_forward = GetConVar("ARC9_rcam_forward"):GetFloat()
    --     cam_right = GetConVar("ARC9_rcam_right"):GetFloat()
    --     cam_up = GetConVar("ARC9_rcam_up"):GetFloat()
    -- end

    -- att = "eyes"
    cam_forward = -48
    cam_right = 16
    cam_up = 4

    -- if wpn:GetCustomize() then
    --     targetfov = targetfov * 0.8
    -- end

    -- local approachspeed = 180

    -- if wpn:GetSighted() then
    --     targetfov = basefov / wpn:GetValue("Magnification")
    --     -- approachspeed = math.huge

    --     if !wpn:GetSafe() then
    --         targetfov = basefov * 0.8
    --     end
    -- end

    -- local attob = ply:LookupAttachment(att)

    local attpos = ply:EyePos() -- pos

    -- if attob > 0 then
    --     attpos = ply:GetAttachment(attob).Pos
    -- end

    -- if GetConVar("ARC9_cam_obj"):GetBool() then
    --     attpos = pos
    -- end

    local trfilter = {ply}

    angles = ARC9.RelativeCamAngles

    local up = angles:Up()
    local right = angles:Right()
    local forward = angles:Forward()

    if !traceend then
        traceend = attpos + (up * cam_up) + (right * cam_right * arc9_cam_shoulder:GetInt()) + (forward * cam_forward)
    end

    local view = {}
    local origin, viewang

    if !wpn.CalcView then return end
    origin, viewang, fov = wpn:CalcView(ply, pos, angles, fov)
    if !origin or !viewang or !fov then return end

    view.origin = origin
    view.angles = viewang
    view.fov = fov
    view.znear = znear
    view.drawviewer = cam_drawviewer
    -- view.viewmodelfov = 90

    -- ARC9.FOV = math.Approach(ARC9.FOV, targetfov, FrameTime() * approachspeed)

    -- view.fov = ARC9.FOV

    local tr = util.TraceLine({
        start = tracestart,
        endpos = traceend,
        filter = trfilter,
        mask = MASK_OPAQUE,
    })

    vorigin = tr.HitPos
    if tr.Hit then
        vorigin = tr.HitPos + (tr.HitNormal * znear * 2)
    end

    view.origin = vorigin
    view.angles:Add(cam_angoffset + LocalPlayer():GetViewPunchAngles())

    ARC9.RealCamPos = view.origin
    ARC9.RealCamAng = view.angles

    return view
end

hook.Add( "CalcView", "ARC9.CalcView", ARC9.CalcView )

ARC9.TurningSpeed = 360
ARC9.CamPitch = 85

function ARC9.InputMouseApply( cmd, x, y, ang )
    if !ARC9.ShouldThirdPerson() then return end

    local ply = LocalPlayer()
    local wpn = ply:GetActiveWeapon()
    local turnspeed = ARC9.TurningSpeed

    if !IsValid(wpn) or !wpn.ARC9 or (wpn:GetInSights() and wpn.IronSights["ForceFP"]) then
        ARC9.RelativeCamAngles = EyeAngles()
        ARC9.RelativePlayerAngles = EyeAngles()
        ARC9.RealCamAng = EyeAngles()
        return
    end

    local relative = false

    if wpn:GetSprintAmount() > 0 then
        relative = true
    end

    if wpn:GetSafe() then
        relative = true
    end

    local mult = 1

    -- if wpn:GetSighted() then
    --     turnspeed = math.huge
    --     mult = 1 / wpn:GetValue("Magnification")
    -- end

    -- if !GetConVar("ARC9_cam_relativemotion"):GetBool() then
    --     relative = false
    -- end

    local targetplayerangles = ARC9.RelativePlayerAngles

    if !relative then
        -- if GetConVar("ARC9_aim_correction"):GetBool() and
        if LocalPlayer():GetMoveType() != MOVETYPE_NOCLIP then
            local eyetrace = util.TraceLine({
                start = ARC9.RealCamPos,
                endpos = ARC9.RealCamPos + ARC9.RealCamAng:Forward() * 2048,
                mask = MASK_SHOT,
                filter = LocalPlayer()
            })

            targetplayerangles = (eyetrace.HitPos - LocalPlayer():EyePos()):GetNormalized():Angle()

            local movevec = Vector(cmd:GetForwardMove(), cmd:GetSideMove(), cmd:GetUpMove())

            movevec = LocalToWorld(movevec, angle_zero, vector_origin, targetplayerangles - ARC9.RealCamAng)

            cmd:SetForwardMove(movevec.x)
            cmd:SetSideMove(movevec.y)
            cmd:SetUpMove(movevec.z)
        else
            targetplayerangles = ARC9.RelativeCamAngles
        end
    else
        local movevec = Vector(cmd:GetForwardMove(), cmd:GetSideMove(), cmd:GetUpMove())

        if movevec:Length() > 0 then
            targetplayerangles = ARC9.RelativeCamAngles - movevec:Angle()

            cmd:SetForwardMove(movevec:Length())
            cmd:SetSideMove(0)
            cmd:SetUpMove(0)
        end
    end

    if ply:InVehicle() then
        targetplayerangles = targetplayerangles - ply:GetVehicle():GetAngles()
    end

    ARC9.RelativePlayerAngles = targetplayerangles

    local c_angles = cmd:GetViewAngles()

    if ply:InVehicle() then
        c_angles = c_angles
    end

    local sensa = mult * sensitivity:GetFloat() / 100

    local deltax = x * sensa
    local deltay = y * sensa

    if m_yaw:GetFloat() < 0 then
        deltax = deltax * -1
    end

    if m_pitch:GetFloat() < 0 then
        deltay = deltay * -1
    end

    ARC9.RelativeCamAngles.p = math.Clamp(ARC9.RelativeCamAngles.p + deltay, -ARC9.CamPitch, ARC9.CamPitch)

    ARC9.RelativeCamAngles.y = ARC9.RelativeCamAngles.y - deltax

    ARC9.RelativeCamAngles.r = 0

    c_angles[1] = math.ApproachAngle(c_angles[1], targetplayerangles[1], FrameTime() * turnspeed)
    c_angles[2] = math.ApproachAngle(c_angles[2], targetplayerangles[2], FrameTime() * turnspeed)
    c_angles[3] = math.ApproachAngle(c_angles[3], targetplayerangles[3], FrameTime() * turnspeed)

    cmd:SetViewAngles(c_angles)

    return
end

hook.Add( "InputMouseApply", "ARC9.InputMouseApply", ARC9.InputMouseApply )

ARC9.ShouldThirdPerson = function()
    local force = arc9_thirdperson_force:GetInt()
    local should = arc9_thirdperson:GetBool()

    if force == 1 then
        should = true
    elseif force >= 2 then
        should = false
    end

    local wpn = LocalPlayer():GetActiveWeapon()

    if !wpn.ARC9 then return false end

    if wpn:GetCustomize() then return false end

    return should
end

