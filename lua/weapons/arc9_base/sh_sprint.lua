function SWEP:GetSprintToFireTime()
    local owner = self:GetOwner()
    local slidingmult = (owner.GetSliding and owner:GetSliding()) and 0.66 or 1
    return self:GetProcessedValue("SprintToFireTime", true) * slidingmult -- Incorrectly uses a time as a multiplier! Preserved for legacy behavior
end

function SWEP:GetTraverseSprintToFireTime()
    return self:GetProcessedValue("SprintToFireTime") * 1.5
end

-- local cachedissprinting = false
-- local cachedsprinttime = 0

function SWEP:GetIsSprinting()
    -- if cachedsprinttime == CurTime() then
    --     return cachedissprinting
    -- end

    -- cachedsprinttime = CurTime()
    -- cachedissprinting = self:GetIsSprintingCheck()

    return self:GetIsSprintingCheck()
end

function SWEP:GetIsWalking()
    local owner = self:GetOwner()

    if !owner:IsValid() or owner:IsNPC() then
        return false
    end

    if owner:KeyDown(IN_SPEED) then return false end
    if !owner:KeyDown(IN_FORWARD + IN_BACK + IN_MOVELEFT + IN_MOVERIGHT) then return false end

    local curspeed = owner:GetVelocity():LengthSqr()
    if curspeed <= 0 then return false end

    return true
end

function SWEP:GetIsSprintingCheck()
    local owner = self:GetOwner()

    if !owner:IsValid() or owner:IsNPC() then
        return false
    end
    if owner:KeyDown(IN_ATTACK2) then return end
    if self:GetInSights() then return false end
    if self:GetCustomize() then return false end
    -- if self:GetIsNearWall() then return true end
    if !owner:KeyDown(IN_SPEED) then return false end
    if !owner:OnGround() or owner:GetMoveType() == MOVETYPE_NOCLIP then return false end
    if !owner:KeyDown(IN_FORWARD + IN_BACK + IN_MOVELEFT + IN_MOVERIGHT) then return false end
    if !owner:IsSprinting() then return false end

    if (self:GetAnimLockTime() > CurTime()) and self:GetProcessedValue("NoSprintWhenLocked", true) then
        return false
    end

    if self:GetProcessedValue("ShootWhileSprint", true) and owner:KeyDown(IN_ATTACK) and !self:GetProcessedValue("BashWhileSprint", true) then
        return false
    end

    if self:GetGrenadePrimed() then
        return false
    end

    if owner.GetSliding and owner:GetSliding() then return false end

    if owner:Crouching() then return false end

    return true
end

function SWEP:GetSprintDelta()
    return self:GetSprintAmount()
end

function SWEP:EnterSprint()
    self:SetShouldHoldType()

    if !self:GetProcessedValue("ReloadWhileSprint", true) then
        self:CancelReload()
    end

    if !self:StillWaiting() then
        if self:GetProcessedValue("InstantSprintIdle", true) then
            self:PlayAnimation("idle")
        else
            local anim = self:TranslateAnimation("enter_sprint")
            local mult = self:GetSprintToFireTime()
            if self:GetAnimationEntry(anim).NoStatAffectors then
                mult = 1
            end
            self:PlayAnimation(anim, mult, nil, nil, nil, true)
        end
    end
end

function SWEP:ExitSprint()
    self:SetShouldHoldType()

    if !self:StillWaiting() then
        if self:GetProcessedValue("InstantSprintIdle", true) then
            self:PlayAnimation("idle")
        else
            local anim = self:TranslateAnimation("exit_sprint")
            local mult = self:GetSprintToFireTime()
            if self:GetAnimationEntry(anim).NoStatAffectors then
                mult = 1
            end
            self:PlayAnimation(anim, mult, nil, nil, nil, true)
        end
    end
end

function SWEP:ThinkSprint()
    local issprinting = self:GetIsSprinting()

    local sprinting = self:GetSafe() or issprinting

    if issprinting and self:GetProcessedValue("SprintCancelsReload", true) then
		self:CancelReload()
    end

    if self:GetSightAmount() >= 1 or (self:GetProcessedValue("ReloadNoSprintPos", true) and self:GetReloading() or self:StillWaiting()) then
        sprinting = false
    end

    local amt = self:GetSprintAmount()
    -- local ts_amt = self:GetTraversalSprintAmount()
    local lastwassprinting = self:GetLastWasSprinting()

    if lastwassprinting and !sprinting then
        self:ExitSprint()
    elseif !lastwassprinting and sprinting then
        self:EnterSprint()
    end

    self:SetLastWasSprinting(sprinting)

    if sprinting and !self:GetPrimedAttack() then
        if amt < 1 then
            amt = math.Approach(amt, 1, FrameTime() / self:GetSprintToFireTime())
        end
        -- if self:GetTraversalSprint() then
        --     ts_amt = math.Approach(ts_amt, 1, FrameTime() / (self:GetTraverseSprintToFireTime()))
        -- end
    else
        if amt > 0 then
            amt = math.Approach(amt, 0, FrameTime() / self:GetSprintToFireTime())
        end
    end

    -- if !self:GetTraversalSprint() then
    --     ts_amt = math.Approach(ts_amt, 0, FrameTime() / (self:GetTraverseSprintToFireTime()))
    -- end

    -- self:SetTraversalSprintAmount(ts_amt)
    self:SetSprintAmount(amt)

    -- if self:GetOwner():KeyDown(IN_FORWARD) and self:GetOwner():KeyPressed(IN_SPEED) then
    --     if self:GetLastPressedWTime() >= (CurTime() - 0.33) then
    --         self:SetTraversalSprint(true)
    --     else
    --         self:SetLastPressedWTime(CurTime())
    --     end
    -- end

    -- if self:GetTraversalSprint() then
    --     if !sprinting then
    --         self:SetTraversalSprint(false)
    --     end

    --     if !self:GetOwner():KeyDown(IN_FORWARD) then
    --         self:SetTraversalSprint(false)
    --     end

    --     if self:GetSprintAmount() <= 0 then
    --         self:SetTraversalSprint(false)
    --     end
    -- end
end