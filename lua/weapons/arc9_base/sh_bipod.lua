function SWEP:ThinkBipod()
    local bip = self:GetBipod()
    local owner = self:GetOwner()

    if bip then
        if owner:KeyDown(IN_BACK) or self:MustExitBipod() then
            self:ExitBipod()
        end
    else
        if owner:KeyPressed(IN_ATTACK2) and self:CanBipod() then
            self:EnterBipod()
        end
    end
end

function SWEP:MustExitBipod()
    if !self:GetProcessedValue("Bipod", true) then return true end
    if self:GetSprintAmount() > 0 then return true end
    if self:GetUBGL() then return true end

    if self:GetOwner():GetVelocity():LengthSqr() > 100 then return true end

    return false
end

function SWEP:CanBipod(ang)
    if !self:GetProcessedValue("Bipod", true) then return end
    if self:GetSprintAmount() > 0 then return end
    if self:GetReloading() and !self:GetBipod() then return end
    if self:GetUBGL() then return end
    if self:GetAnimLockTime() > CurTime() then return end

    if self:GetEnterBipodTime() + 1 > CurTime() then return end

    local owner = self:GetOwner()

    if owner:KeyDown(IN_FORWARD) or owner:KeyDown(IN_BACK) or owner:KeyDown(IN_MOVELEFT) or owner:KeyDown(IN_MOVERIGHT) then return end

    local pos = owner:EyePos()
    ang = ang or owner:EyeAngles()

    local maxs = Vector(2, 2, 2)
    local mins = Vector(-2, -2, -48)

    local tr = util.TraceLine({
        start = pos,
        endpos = pos + (ang:Forward() * 64),
        filter = owner,
        mask = MASK_PLAYERSOLID
    })

    if tr.Hit then return end

    -- ang:RotateAroundAxis(ang:Right(), -30)

    local d = (tr.HitPos - pos):Length()
    d = d / 2

    mins.z = -d

    local tr2 = util.TraceHull({
        start = pos,
        endpos = pos + (ang:Forward() * 24),
        filter = owner,
        maxs = maxs,
        mins = mins,
        mask = MASK_PLAYERSOLID
    })

    if tr2.Hit then
        return true
    else
        return false
    end
end

function SWEP:EnterBipod()
    if self:GetBipod() then return end

    self:SetBipod(true)
    local soundtab1 = {
        name = "enterbipod",
        sound = self:RandomChoice(self:GetProcessedValue("EnterBipodSound", true))
    }
    self:PlayTranslatedSound(soundtab1)
    self:PlayAnimation(self.SightIsAlsoBipodAnims and "enter_sights" or "enter_bipod", 1, true)
    self:SetEnterBipodTime(CurTime())

    local owner = self:GetOwner()

    self:SetBipodAng(owner:EyeAngles())
    self:SetBipodPos(owner:EyePos() + (owner:EyeAngles():Forward() * 4) - Vector(0, 0, 2))

    self:ExitSights()

    owner.ARC9_HadNoDMGForceEFlag = owner:IsEFlagSet( EFL_NO_DAMAGE_FORCES )
    owner:AddEFlags( EFL_NO_DAMAGE_FORCES )
end

function SWEP:ExitBipod(force)
    if !self:GetBipod() then return end

    self:SetBipod(false)
    local soundtab1 = {
        name = "exitbipod",
        sound = self:RandomChoice(self:GetProcessedValue("ExitBipodSound", true))
    }
    self:PlayTranslatedSound(soundtab1)
    self:SetEnterBipodTime(CurTime())

    self:PlayAnimation(self.SightIsAlsoBipodAnims and "exit_sights" or "exit_bipod", 1, true)

    self:CancelReload()

    self:ExitSights()

    local owner = self:GetOwner()

    if !owner.ARC9_HadNoDMGForceEFlag then owner:RemoveEFlags( EFL_NO_DAMAGE_FORCES ) end
    owner.ARC9_HadNoDMGForceEFlag = nil
end

SWEP.BipodTime = 0.5

function SWEP:GetBipodAmount()
    local bipodamount = 0

    if self:GetBipod() then
        local d = math.Clamp(CurTime() - self:GetEnterBipodTime(), 0, self:GetValue("BipodTime"))
        bipodamount = d / self:GetValue("BipodTime")
    end

    return bipodamount
end