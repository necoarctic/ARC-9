SWEP.ViewModelPos = Vector(0, 0, 0)
SWEP.ViewModelAng = Angle(0, 0, 0)
SWEP.VMZOffsetForCamera = 0

SWEP.BenchGunViewModelPos = nil
SWEP.BenchGunViewModelAng = nil
local lht = 0
local sht = 0

-- local somevector = Vector(-1, 0, 1)
-- local somevector2 = Vector(0, 1, 0)
local somevector3 = Vector(-1, -1, 1)
-- local cangup = Vector(1, 0, 0)
-- local cangforward = Vector(0, 0, -1)
local oldpos = Vector(0, 0, 0)
local oldang = Angle(0, 0, 0)
local offsetpos = Vector(0, 0, 0)
local offsetang = Angle(0, 0, 0)
local extra_offsetpos = Vector(0, 0, 0)
local extra_offsetang = Angle(0, 0, 0)
local rotateAroundAngle = Angle(0, 0, 0)
local halfPi = math.pi / 2
local vmAddX = GetConVar("arc9_vm_addx")
local vmAddY = GetConVar("arc9_vm_addy")
local vmAddZ = GetConVar("arc9_vm_addz")
local arc9DevBenchGun = GetConVar("arc9_dev_benchgun")
local isSingleplayer = game.SinglePlayer()

local Lerp = function(a, v1, v2)
    local d = v2 - v1

    return v1 + (a * d)
end

local LerpVector = function(a, v1, v2)
    local d = v2 - v1

    return v1 + (a * d)
end

local LerpVectorEdit = function(a, v1, v2)
    local v11, v12, v13 = v1[1], v1[2], v1[3]
    local v21, v22, v23 = v2[1], v2[2], v2[3]
    v1[1] = Lerp(a, v11, v21)
    v1[2] = Lerp(a, v12, v22)
    v1[3] = Lerp(a, v13, v23)
end

local LerpAngle = function(a, v1, v2)
    -- angle aware lerp with Angles()
    local v11 = v1[1]
    local v12 = v1[2]
    local v13 = v1[3]
    local v21 = v2[1]
    local v22 = v2[2]
    local v23 = v2[3]
    local d1 = math.AngleDifference(v21, v11)
    local d2 = math.AngleDifference(v22, v12)
    local d3 = math.AngleDifference(v23, v13)
    
    return Angle(v11 + (a * d1), v12 + (a * d2), v13 + (a * d3))
end


local math_ease = math.ease

local funnyvectorIn = Vector(-1.9, 2, 1.95) * 1
local funnyvectorOut = Vector(1, 1, -0.8) * 1

local LerpVectorFunny = function(a, v1, v2, mode)
    local d = v2 - v1

    local a1 = mode and math_ease.OutExpo(a) or math_ease.InQuad(a)
    local a2 = mode and math_ease.InOutBack(a) or math_ease.InSine(a)
    local a3 = mode and math_ease.OutQuad(a) or math_ease.InSine(a)
    
    local funkymidoffset = math.sin(3.1415926 * (mode and math_ease.OutSine(a) or math_ease.InOutQuad(a)))
    local funkymidoffset2 = math.sin(3.1415926 * (mode and math_ease.OutCubic(a * a) or math_ease.InSine(a)))

    local yay = LerpVector((mode and a or 0) * a, funnyvectorOut, funnyvectorIn)

    local vv1 = v1[1] + yay[1] * funkymidoffset
    local vv2 = v1[2] + yay[2] * funkymidoffset
    local vv3 = v1[3] + yay[3] * funkymidoffset2

    return Vector(vv1 + (a1 * d[1]), vv2 + (a2 * d[2]), vv3 + (a3 * d[3]))
end

local funnyangleIn = Angle(-3, -2, 8) * 0.85
local funnyangleOut = Angle(1.75, -2, -7) * 0.85

local LerpAngleFunny = function(a, v1, v2, mode)
    local v11 = v1[1]
    local v12 = v1[2]
    local v13 = v1[3]
    local v21 = v2[1]
    local v22 = v2[2]
    local v23 = v2[3]
    local d1 = math.AngleDifference(v21, v11)
    local d2 = math.AngleDifference(v22, v12)
    local d3 = math.AngleDifference(v23, v13)
    
    local a1 = a
    local a2 = a
    local a3 = a

    local v3 = Angle(v11 + (a1 * d1), v12 + (a2 * d2), v13 + (a3 * d3))
    
    local funkymidoffset = math.sin(3.1415926 * (mode and math_ease.OutSine(a) or math_ease.InOutQuad(a)))
    v3:Add(LerpAngle((mode and 1 or 0), funnyangleOut, funnyangleIn) * funkymidoffset)

    return v3
end

local LerpAngleEdit = function(a, v1, v2)
    local v11 = v1[1]
    local v12 = v1[2]
    local v13 = v1[3]
    local v21 = v2[1]
    local v22 = v2[2]
    local v23 = v2[3]
    local d1 = math.AngleDifference(v21, v11)
    local d2 = math.AngleDifference(v22, v12)
    local d3 = math.AngleDifference(v23, v13)
    v1[1] = v11 + (a * d1)
    v1[2] = v12 + (a * d2)
    v1[3] = v13 + (a * d3)
end

-- local ApproachVector = function(a1, a2, d)
--     a1[1] = math.Approach(a1[1], a2[1], d)
--     a1[2] = math.Approach(a1[2], a2[2], d)
--     a1[3] = math.Approach(a1[3], a2[3], d)
--     return a1
-- end
-- local Damp = function(a, v1, v2)
--     return Lerp(1 - math.pow(a, FrameTime()), v2, v1)
-- end
local DampVector = function(a, v1, v2)
    a = 1 - math.pow(a, RealFrameTime())

    return LerpVector(a, v2, v1)
end

local DampVectorEdit = function(a, v1, v2)
    a = math.pow(a, RealFrameTime())
    LerpVectorEdit(a, v1, v2)
end

local DampAngle = function(a, v1, v2)
    a = 1 - math.pow(a, RealFrameTime())

    return LerpAngle(a, v2, v1)
end

local DampAngleEdit = function(a, v1, v2)
    a = math.pow(a, RealFrameTime())
    LerpAngleEdit(a, v1, v2)
end

local function GoodAngleLerp(from, to, t)
    local diff = to - from
    local shortestAngle = ((diff + 180) % 360) - 180
    return from + shortestAngle * t
end

local swepGetProcessedValue = SWEP.GetProcessedValue

function SWEP:GetViewModelPosition(pos, ang)
    local owner = self:GetOwner()
    if !IsValid(owner) then return end
    -- if owner != LocalPlayer() then return end
    if CLIENT and owner ~= LocalPlayer() then return end

    if !swepGetProcessedValue then swepGetProcessedValue = self.GetProcessedValue end

    local curTime = UnPredictedCurTime()

    oldpos:Set(pos)
    oldang:Set(ang)
    local cor_val = self:GetCorVal()
    extra_offsetpos:Zero()
    extra_offsetang:Zero()
    -- print(extra_offsetang)
    offsetpos:Set(swepGetProcessedValue(self, "ActivePos", true))
    offsetang:Set(swepGetProcessedValue(self, "ActiveAng", true))
    local maxspd, vel = owner:GetWalkSpeed() or 250, owner:OnGround() and owner:GetAbsVelocity():Length() or 0
    local movingpv = math.Clamp(math.Remap(vel, 0, maxspd, 0, 1), 0, 1)
    -- local movingpv = self.PV_Move
    local mvpos = swepGetProcessedValue(self, "MovingPos", true)
    local mvang = swepGetProcessedValue(self, "MovingAng", true)

    if (mvpos or mvang) and movingpv > 0.125 then
        -- local ts_movingpv = 0 -- self:GetTraversalSprintAmount()
        movingpv = math_ease.InOutQuad(movingpv)
        -- ts_movingpv = math_ease.InOutSine(ts_movingpv)
        -- movingpv = math.max(movingpv, ts_movingpv)
        if mvpos then
            offsetpos:Add(mvpos * movingpv)
        end
        if mvang then
            offsetang:Add(mvang * movingpv)
        end
        local wim = swepGetProcessedValue(self, "MovingMidPoint", true)
        local mv_midpoint = movingpv * math.cos(movingpv * halfPi)
        local mv_joffset = (wim and wim.Pos or vector_origin) * mv_midpoint
        local mv_jaffset = (wim and wim.Ang or angle_zero) * mv_midpoint
        extra_offsetpos:Add(mv_joffset)
        extra_offsetang:Add(mv_jaffset) -- what does all this extra offset stuff do?
    end

    -- if self.PV_Move > 0.2 and self:GetSprintDelta() == 0 then
    --     offsetpos:Set(swepGetProcessedValue(self, "MovingPos"))
    --     offsetang:Set(swepGetProcessedValue(self, "MovingAng"))
    -- end
    local getbipod = self:GetBipod()
    local reloading = self:GetReloading()

    if getbipod then
        local bipodamount = self:GetBipodAmount()
        bipodamount = math_ease.InOutQuad(bipodamount)
        local sightpos, sightang = self:GetSightPositions()
        local bipodpos, bipodang = swepGetProcessedValue(self, "BipodPos", true), swepGetProcessedValue(self, "BipodAng", true)

        if bipodpos and bipodang then
            LerpVectorEdit(math.Clamp(bipodamount - self:GetSightAmount(), 0, 1), pos, self:GetBipodPos())
            LerpVectorEdit(bipodamount, offsetpos, bipodpos)
            LerpAngleEdit(bipodamount, offsetang, bipodang)
        else
            offsetpos:Add(sightpos * bipodamount)
            offsetang:Add(sightang * bipodamount)
        end
    else
        local crouchpos = swepGetProcessedValue(self, "CrouchPos", true)
        local crouchang = swepGetProcessedValue(self, "CrouchAng", true)
        local viewOffsetZ = owner:GetViewOffset().z
        local crouchdelta = math.Clamp(math_ease.InOutSine((viewOffsetZ - owner:GetCurrentViewOffset().z) / (viewOffsetZ - owner:GetViewOffsetDucked().z)), 0, 1)

        if crouchpos then
            offsetpos:Add(crouchpos * crouchdelta)
            -- LerpVectorEdit(crouchdelta, offsetpos, crouchpos)
        end

        if crouchang then
            offsetang:Add(crouchang * crouchdelta)
            -- LerpAngleEdit(crouchdelta, offsetang, crouchang)
        end
    end

    if VManip != nil and self:GetSightAmount() < 0.3 then
        local vmanipmult = ((VManip:IsActive() and (VManip.VMatrixlerp < 0.3 or VManip.Cycle < 0.3)) and 1 or 0)
        if owner.GetSliding then if owner:GetSliding() then vmanipmult = 0 end end -- vmanip quickslides ASS
        offsetpos:Add(self.VManipOffsetPos * vmanipmult)
        offsetang:Add(self.VManipOffsetAng * vmanipmult)
    end

    if reloading then
        local reloadpos = swepGetProcessedValue(self, "ReloadPos", true)
        local reloadang = swepGetProcessedValue(self, "ReloadAng", true)
        local fuckingreloadprocessinfluence = self:GetReloadingProgress()

        if reloadpos then
            offsetpos:Sub(reloadpos * fuckingreloadprocessinfluence)
        end

        if reloadang then
            offsetang:Sub(reloadang * fuckingreloadprocessinfluence)
        end
    end

    do
        local offsetangRight = offsetang:Right()
        local offsetangForward = offsetang:Forward()
        local offsetangUp = offsetang:Up()
        offsetangRight:Mul(vmAddY:GetFloat())
        offsetangForward:Mul(vmAddX:GetFloat())
        offsetangUp:Mul(vmAddZ:GetFloat())
        offsetpos:Add(offsetangRight)
        offsetpos:Add(offsetangForward)
        offsetpos:Add(offsetangUp)
    end

    local sightdelta_original = self:GetSightDelta()
    local sightdelta = sightdelta_original
    -- cor_val = Lerp(sightdelta, cor_val, 1)
    self.SwayScale = 0

    if sightdelta > 0 then
        local insifgts = self:GetInSights()
        if insifgts then
            sightdelta = Lerp(0.25, math_ease.OutBack(sightdelta), math_ease.InOutSine(sightdelta))
        else
            sightdelta = Lerp(0.7, math_ease.InOutQuad(sightdelta), math_ease.InQuad(sightdelta))
        end

        local sightpos, sightang = self:GetSightPositions()
        local sight = self:GetSight()
        local eepos, eeang = self:GetExtraSightPositions()
		local peekp, peeka = "PeekPos", "PeekAng"
		local fuckingreloadprocess = math.Clamp(1 - (self:GetReloadFinishTime() - curTime) / (self.ReloadTime * self:GetAnimationTime("reload")), 0, 1)
		local reloadanim = self:GetAnimationEntry(self:TranslateAnimation("reload"))
		local shotgun = self:GetShouldShotgunReload()
		
		if (!shotgun and fuckingreloadprocess < (reloadanim.PeekProgress or reloadanim.MinProgress or 0.9)) or (shotgun and self:GetReloading()) then
			if self.PeekPosReloading then peekp = "PeekPosReloading" end
			if self.PeekAngReloading then peeka = "PeekAngReloading" end
		end

        -- if input.IsKeyDown(input.GetKeyCode(input.LookupBinding("menu_context"))) then
        if self.Peeking then
            eepos = eepos + swepGetProcessedValue(self, peekp, true)
            eeang = eeang + swepGetProcessedValue(self, peeka, true)
        end

        if sight.GeneratedSight then
            local t_sightpos = LerpVectorFunny(sightdelta_original, vector_origin, sightpos, insifgts)
            local t_sightang = LerpAngleFunny(sightdelta, angle_zero, sightang, insifgts)
            ang:RotateAroundAxis(oldang:Up(), t_sightang[1])
            ang:RotateAroundAxis(oldang:Right(), t_sightang[2])
            ang:RotateAroundAxis(oldang:Forward(), t_sightang[3])
            local angRight = ang:Right()
            local angForward = ang:Forward()
            local angUp = ang:Up()
            angRight:Mul(t_sightpos[1])
            angForward:Mul(t_sightpos[2])
            angUp:Mul(t_sightpos[3])
            pos:Add(angRight)
            pos:Add(angForward)
            pos:Add(angUp)
            LerpVectorEdit(sightdelta, offsetpos, vector_origin)
            LerpAngleEdit(sightdelta, offsetang, angle_zero)
        else
            offsetpos = LerpVectorFunny(sightdelta_original, offsetpos or vector_origin, sightpos or vector_origin, insifgts)
            offsetang = LerpAngleFunny(sightdelta, offsetang or angle_zero, sightang or angle_zero, insifgts)
        end

        -- local eepos, eeang = Vector(0, 0, 0), Angle(0, 0, 0)
        -- local im = swepGetProcessedValue(self, "SightMidPoint", true)
        -- local midpoint = sightdelta * math.cos(sightdelta * halfPi)
        -- local joffset = (im and im.Pos or vector_origin) * midpoint
        -- local jaffset = (im and im.Ang or angle_zero) * midpoint
        LerpVectorEdit(sightdelta, extra_offsetpos, eepos) -- + joffset) -- midpoint removed
        LerpAngleEdit(sightdelta, extra_offsetang, eeang) -- + jaffset)
        -- self.BobScale = 0
        -- self.SwayScale = Lerp(sightdelta, 1, 0.1)
    end

    local fswayang

    if self.InertiaEnabled then
        fswayang = self:GetInertiaSwayAngles()

        local inertiaanchor
        if self.InertiaCustomAnchor then 
            inertiaanchor = self.InertiaCustomAnchor 
        else
            inertiaanchor = Vector(self.CustomizeRotateAnchor)
            -- inertiaanchor.x = inertiaanchor.x * ((self.RenderingHolosight or self.RenderingRTScope) and 0.75 or 0.4)
        end

        local rap_pos, rap_ang = self:RotateAroundPoint2(pos, ang, inertiaanchor, vector_origin, fswayang * -1.0)
        pos:Set(rap_pos)
        ang:Set(rap_ang)
    else
        fswayang = self:GetFreeSwayAngles()
        if fswayang then
            local getfreeswayang, getfreeswayoffset = fswayang, self:GetFreeAimOffset()
            extra_offsetang[2] = extra_offsetang[2] - (getfreeswayang[1] * cor_val)
            extra_offsetang[1] = extra_offsetang[1] + (getfreeswayang[2] * cor_val)
            extra_offsetang[2] = extra_offsetang[2] - (getfreeswayoffset[1] * cor_val)
            extra_offsetang[1] = extra_offsetang[1] + (getfreeswayoffset[2] * cor_val)
        end
    end

    -- self.CustomizeDelta is modified in ThinkCustomize now

    local curvedcustomizedelta = self:Curve(self.CustomizeDelta)
    -- local sprintdelta = self:Curve(self:GetSprintDelta())
    local sprintdelta = self:GetSprintDelta()

    if sprintdelta > 0 then
        -- local ts_sprintdelta = 0 -- self:GetTraversalSprintAmount()
        sprintdelta = math_ease.InOutQuad(sprintdelta) - curvedcustomizedelta
        -- ts_sprintdelta = math_ease.InOutSine(ts_sprintdelta)
        -- sprintdelta = math.max(sprintdelta, ts_sprintdelta)
        local sprpos = swepGetProcessedValue(self, "SprintPos", true) or swepGetProcessedValue(self, "RestPos", true)
        local sprang = swepGetProcessedValue(self, "SprintAng", true) or swepGetProcessedValue(self, "RestAng", true)
        -- sprpos = LerpVector(ts_sprintdelta, sprpos, swepGetProcessedValue(self, "TraversalSprintPos"))
        -- sprang = LerpAngle(ts_sprintdelta, sprang, swepGetProcessedValue(self, "TraversalSprintAng"))
        LerpVectorEdit(sprintdelta, offsetpos, sprpos)
        LerpAngleEdit(sprintdelta, offsetang, sprang)
        LerpAngleEdit(sprintdelta, extra_offsetang, angle_zero)
        local sim = swepGetProcessedValue(self, "SprintMidPoint", true)
        local spr_midpoint = sprintdelta * math.cos(sprintdelta * halfPi)
        local spr_joffset = (sim and sim.Pos or vector_origin) * spr_midpoint
        local spr_jaffset = (sim and sim.Ang or angle_zero) * spr_midpoint
        extra_offsetpos:Add(spr_joffset)
        extra_offsetang:Add(spr_jaffset)
    end

    local nearwalldelta = self:GetNearWallAmount()

    if nearwalldelta > 0 then
        nearwalldelta = math_ease.InOutQuad(nearwalldelta) - curvedcustomizedelta
        -- sprintdelta = math.max(sprintdelta, ts_sprintdelta)
        local sprpos = swepGetProcessedValue(self, "NearWallPos", true) or swepGetProcessedValue(self, "SprintPos", true) or swepGetProcessedValue(self, "RestPos", true)
        local sprang = swepGetProcessedValue(self, "NearWallAng", true) or swepGetProcessedValue(self, "SprintAng", true) or swepGetProcessedValue(self, "RestAng", true)
        -- sprpos = LerpVector(ts_sprintdelta, sprpos, swepGetProcessedValue(self, "TraversalSprintPos"))
        -- sprang = LerpAngle(ts_sprintdelta, sprang, swepGetProcessedValue(self, "TraversalSprintAng"))
        LerpVectorEdit(nearwalldelta, offsetpos, sprpos)
        LerpAngleEdit(nearwalldelta, offsetang, sprang)
        LerpAngleEdit(nearwalldelta, extra_offsetang, angle_zero)
    end

    if curvedcustomizedelta > 0 then
        local cpos = Vector(swepGetProcessedValue(self, "CustomizePos", true))
        local cang = swepGetProcessedValue(self, "CustomizeAng", true)
        LerpVectorEdit(curvedcustomizedelta, extra_offsetpos, vector_origin)
        LerpAngleEdit(curvedcustomizedelta, extra_offsetang, angle_zero)

        if self.BottomBarMode == 1 then
            cpos[3] = cpos[3] + 2
        else
            cpos[3] = cpos[3] + 1.5
        end

        cpos[1] = cpos[1] + self.CustomizePanX
        cpos[3] = cpos[3] - self.CustomizePanY
        cpos[2] = cpos[2] + self.CustomizeZoom - 15
        LerpVectorEdit(curvedcustomizedelta, offsetpos, cpos)
        LerpAngleEdit(curvedcustomizedelta, offsetang, cang)
    end

    local ht = self:GetHolsterTime()

    if (ht + 0.1) > curTime then
        if ht > lht then
            sht = curTime
        end

        local hdelta = 1 - ((ht - curTime) / (ht - sht))

        if hdelta > 0 then
            hdelta = math_ease.InOutQuad(hdelta)
            LerpVectorEdit(hdelta, offsetpos, self:GetValue("HolsterPos"))
            LerpAngleEdit(hdelta, offsetang, self:GetValue("HolsterAng"))
        end
    end

    lht = ht
    local angup, angright, angforward = ang:Up(), ang:Right(), ang:Forward()
    local oldangup, oldangright, oldangforward = oldang:Up(), oldang:Right(), oldang:Forward()
    angright:Mul(offsetpos[1])
    angforward:Mul(offsetpos[2])
    angup:Mul(offsetpos[3])
    pos:Add(angright)
    pos:Add(angforward)
    pos:Add(angup)
    ang:RotateAroundAxis(oldangup, offsetang.p)
    ang:RotateAroundAxis(oldangright, offsetang.y)
    ang:RotateAroundAxis(oldangforward, offsetang.r)
    angup, angright, angforward = ang:Up(), ang:Right(), ang:Forward()
    ang:RotateAroundAxis(oldangup, extra_offsetang[1])
    ang:RotateAroundAxis(oldangright, extra_offsetang[2])
    ang:RotateAroundAxis(oldangforward, extra_offsetang[3])
    oldangright:Mul(extra_offsetpos[1])
    oldangforward:Mul(extra_offsetpos[2])
    oldangup:Mul(extra_offsetpos[3])
    pos:Add(oldangright)
    pos:Add(oldangforward)
    pos:Add(oldangup)

    -- idle breath
    if curvedcustomizedelta <= 0 then
        local sighted = Lerp(sightdelta, 1, 0.1)
        local ct = curTime * math.pi * Lerp(sightdelta, 1, 0.5)
        -- making parenthesis on (sightes * math.sin) cuz it creates number first and then multiplies vector to it
        -- if we won't do it, then vector would be multiplied by sighted,
        -- new vector will be created and there would be 3 additional vectors, which won't be used
        pos:Sub(angright * (sighted * math.sin(ct * 0.8) * 0.01)) -- X
        pos:Sub(angup * (sighted * math.cos(ct * 0.84) * 0.02)) -- Y
        pos:Sub(angforward * (sighted * math.cos(ct * 0.84) * 0.02)) -- Z
        ang:RotateAroundAxis(angright, sighted * math.sin(ct * 0.84) * -0.07) -- P
        ang:RotateAroundAxis(angup, sighted * math.cos(ct * -0.65) * -0.07) -- Y
        ang:RotateAroundAxis(angforward, sighted * math.sin(ct * 0.5) * 0.25) -- R
    end

    pos, ang = self:GetViewModelRecoil(pos, ang, cor_val)

    if !swepGetProcessedValue(self, "NoViewBob", true) then
        pos, ang = self:GetViewModelBob(pos, ang)
        pos, ang = self:GetMidAirBob(pos, ang)
    end

    -- pos, ang = self:GetViewModelLeftRight(pos, ang)
    pos, ang = self:GetViewModelInertia(pos, ang)
    if !self.InertiaEnabled then pos, ang = self:GetViewModelSway(pos, ang) end
    pos, ang = self:GetViewModelSmooth(pos, ang)
    pos, ang = WorldToLocal(pos, ang, oldpos, oldang)

    -- No point checking IsFirstTimePredicted in a client function (this is not predicted!!)
    -- This was causing choppy viewmodel movement at lower tickrates in dedicated servers
    -- DampVectorEdit(0.0000005, pos, self.ViewModelPos)
    -- DampAngleEdit(0.00001, ang, self.ViewModelAng)
    DampVectorEdit(0.0000005 * (isSingleplayer and 1 or 200), pos, self.ViewModelPos)
    DampAngleEdit(0.00001 * (isSingleplayer and 1 or 200), ang, self.ViewModelAng)
    self.ViewModelPos = pos
    self.ViewModelAng = ang

    pos, ang = LocalToWorld(pos, ang, oldpos, oldang)

    -- CUSTOMISATION ROTATION AFTER DAMPING
    if curvedcustomizedelta > 0 then
        if !self.CustomizeNoRotate then
            self.CustomizePitch = math.NormalizeAngle(self.CustomizePitch) * curvedcustomizedelta
            self.CustomizeYaw = math.NormalizeAngle(self.CustomizeYaw) * curvedcustomizedelta
            self.CustomizeRoll = math.NormalizeAngle(self.CustomizeRoll) * curvedcustomizedelta

            self.CustomizePitchSmooth = GoodAngleLerp((self.CustomizePitchSmooth or 0), self.CustomizePitch, FrameTime() * 13)
            self.CustomizeYawSmooth = GoodAngleLerp((self.CustomizeYawSmooth or 0), self.CustomizeYaw, FrameTime() * 13)
            self.CustomizeRollSmooth = GoodAngleLerp((self.CustomizeRollSmooth or 0), self.CustomizeRoll, FrameTime() * 13)

            -- local CustomizeRotateAnchor = Vector(21.5, -4.27, -5.23)
            rotateAroundAngle[2] = self.CustomizePitchSmooth
            rotateAroundAngle[3] = self.CustomizeYawSmooth
            rotateAroundAngle[1] = self.CustomizeRollSmooth
            
            local rap_pos, rap_ang = self:RotateAroundPoint2(pos, ang, swepGetProcessedValue(self, "CustomizeRotateAnchor", true), vector_origin, rotateAroundAngle)
            pos:Set(rap_pos)
            ang:Set(rap_ang)
        end
    end

    pos, ang = self:GunControllerRHIK(pos, ang)
    pos, ang = self:GunControllerThirdArm(pos, ang)
    self.LastViewModelPos = pos
    self.LastViewModelAng = ang
    local wm = self:GetWM()

    -- if IsValid(wm) and curvedcustomizedelta == 0 then
    --     if !self:ShouldTPIK() then
    --         wm.slottbl.Pos = self.WorldModelOffset.Pos
    --         wm.slottbl.Ang = self.WorldModelOffset.Ang
    --     else
    --         if self.NoTPIKVMPos then
    --             wm.slottbl.Pos = self.WorldModelOffset.TPIKPos or self.WorldModelOffset.Pos
    --             wm.slottbl.Ang = self.WorldModelOffset.TPIKAng or self.WorldModelOffset.Ang
    --         elseif LocalPlayer() == owner then
    --             wm.slottbl.Pos = (self.WorldModelOffset.TPIKPos or self.WorldModelOffset.Pos) - self.ViewModelPos * somevector3
    --             wm.slottbl.Ang = (self.WorldModelOffset.TPIKAng or self.WorldModelOffset.Ang) + Angle(self.ViewModelAng.p, -self.ViewModelAng.y, self.ViewModelAng.r)
    --         end
    --     end
    -- end

    if arc9DevBenchGun:GetBool() and self.BenchGunViewModelPos then return self.BenchGunViewModelPos, self.BenchGunViewModelAng end
    self.BenchGunViewModelPos = pos
    self.BenchGunViewModelAng = ang

    -- shhh, thing for SWEP.RecoilKickAffectPitch
    ang.p = ang.p + self.VMZOffsetForCamera
    pos.z = pos.z + self.VMZOffsetForCamera * 0.05

    return pos, ang
end

-- local Damp = function(a, v1, v2) return Lerp(1 - math.pow(a, FrameTime()), v2, v1) end
SWEP.SmoothedViewModelFOV = nil
local arc9Fov = GetConVar("arc9_fov")

function SWEP:GetViewModelFOV()
    local owner = self:GetOwner()
    if !IsValid(owner) then return end
    local ownerfov = owner:GetFOV()
    local convarfov = arc9Fov:GetInt()

    local target_start = (self:GetProcessedValue("ViewModelFOVBase", true) or ownerfov) + (self:GetCustomize() and 0 or convarfov)
    local target = target_start

	local vmfov = (self.IronSights.ViewModelFOV or (self:GetProcessedValue("ViewModelFOVBase", true) or 70))

    if self:GetInSights() then
		target = self:GetSight().ViewModelFOV or (75 + convarfov)
        if self.Peeking then target = math.max(target, self.PeekMaxFOV or 37) end -- low vm fov sights look weird in peek, ez fix
	end

    if self:GetCustomize() then
        target = self.CustomizeSnapshotFOV or 90
    end

    if arc9DevBenchGun:GetBool() then
        target = owner:GetFOV()
    end

    self.SmoothedViewModelFOV = self.SmoothedViewModelFOV or target
    local diff = math.abs(target - self.SmoothedViewModelFOV)
    self.SmoothedViewModelFOV = math.Approach(self.SmoothedViewModelFOV, target, math.max(diff / self:GetProcessedValue("AimDownSightsTime"), diff, 1) * FrameTime()* 2)

    
    local sightdelta = self:GetSightDelta()
    if self:GetInSights() then
        sightdelta = Lerp(0.21, math_ease.OutBack(sightdelta), math_ease.InOutSine(sightdelta))
    else
        sightdelta = Lerp(0.65, math_ease.InOutSine(sightdelta), math_ease.InOutBack(sightdelta))
    end

    return Lerp(sightdelta, target_start, self.SmoothedViewModelFOV)
end