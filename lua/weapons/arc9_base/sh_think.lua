local ENTITY = FindMetaTable("Entity")
local entityGetOwner = ENTITY.GetOwner
local entityIsPlayerHolding = ENTITY.IsPlayerHolding
local entityIsNPC = ENTITY.IsNPC

local PLAYER = FindMetaTable("Player")
local playerKeyReleased = PLAYER.KeyReleased
local playerKeyDown = PLAYER.KeyDown
local playerDoAnimationEvent = PLAYER.DoAnimationEvent

local swepIdle = SWEP.Idle
local swepGetProcessedValue = SWEP.GetProcessedValue
local swepPlayAnimation = SWEP.PlayAnimation
local swepPrimaryAttack = SWEP.PrimaryAttack
local swepGetCurrentFiremode = SWEP.GetCurrentFiremode
local swepDoPrimaryAttack = SWEP.DoPrimaryAttack
local swepGetIsWalking = SWEP.GetIsWalking
local swepLoadPreset = SWEP.LoadPreset
local swepDoDeployAnimation = SWEP.DoDeployAnimation

-- uuugghh
-- local swepThinkSprint = SWEP.ThinkSprint
local swepThinkCycle = SWEP.ThinkCycle
local swepThinkHeat = SWEP.ThinkHeat
local swepThinkReload = SWEP.ThinkReload
local swepThinkSights = SWEP.ThinkSights
local swepThinkBipod = SWEP.ThinkBipod
local swepThinkMelee = SWEP.ThinkMelee
local swepThinkGrenade = SWEP.ThinkGrenade
local swepThinkRecoil = SWEP.ThinkRecoil
local swepThinkHoldBreath = SWEP.ThinkHoldBreath
local swepThinkLockOn = SWEP.ThinkLockOn
local swepThinkFiremodes = SWEP.ThinkFiremodes
local swepThinkInspect = SWEP.ThinkInspect
local swepThinkSprint = SWEP.ThinkSprint
local swepThinkNearWall = SWEP.ThinkNearWall
local swepThinkFreeAim = SWEP.ThinkFreeAim
local swepThinkLoopingSound = SWEP.ThinkLoopingSound
local swepThinkAnimation = SWEP.ThinkAnimation
local swepThinkCustomize = SWEP.ThinkCustomize
local swepRunHook = SWEP.RunHook
local swepThinkThirdArm = SWEP.ThinkThirdArm
local swepThinkPeek = SWEP.ThinkPeek
local swepThinkRadialMenu = SWEP.ThinkRadialMenu

local WEAPON = FindMetaTable("Weapon")
local weaponSetNextPrimaryFire = WEAPON.SetNextPrimaryFire
local weaponGetNextPrimaryFire = WEAPON.GetNextPrimaryFire
local isSingleplayer = game.SinglePlayer()

local cvarArcAutosave = GetConVar("arc9_autosave")
local cvarGetBool = FindMetaTable("ConVar").GetBool

function SWEP:Think()
    local owner = entityGetOwner(self)

    if !IsValid(owner) or entityIsNPC(owner) then return end

    local swepDt = self.dt
    local now = CurTime()

    local shouldRunPredicted = not self:PredictionFilter()

    if not self.NotAWeapon then
        local notPressedAttack = not playerKeyDown(owner, IN_ATTACK)

        if swepGetProcessedValue(self, "TriggerDelay") then
            local primedAttack = swepDt.PrimedAttack
            local triggerDelay = swepDt.TriggerDelay
            local releasetofire = swepGetProcessedValue(self, "TriggerDelayReleaseToFire", true)

            if primedAttack and triggerDelay <= now and releasetofire and playerKeyReleased(owner, IN_ATTACK) and shouldRunPredicted then
                swepPrimaryAttack(self)
            elseif (primedAttack or triggerDelay > now) and playerKeyReleased(owner, IN_ATTACK) then
                swepPlayAnimation(self, "untrigger")

                if swepGetProcessedValue(self, "TriggerDelayCancellable") then
                    self:SetPrimedAttack(false)
                end
            end

            if primedAttack and triggerDelay <= now and notPressedAttack and shouldRunPredicted then
                swepPrimaryAttack(self)
            end
        end

        local currentFiremode = swepGetCurrentFiremode(self)
        local notRunawayBurst = not swepGetProcessedValue(self, "RunawayBurst", true)
        local postBurstDelay = now + swepGetProcessedValue(self, "PostBurstDelay")

        if notPressedAttack then
            self:SetNeedTriggerPress(false)
            if currentFiremode > 1 and notRunawayBurst and swepDt.BurstCount > 0 then
                weaponSetNextPrimaryFire(self, postBurstDelay)
            end
            if notRunawayBurst then
                self:SetBurstCount(0)
            end
        end

        -- :troll:
        if not notRunawayBurst then
            local burstCount = swepDt.BurstCount
            if burstCount >= currentFiremode and currentFiremode > 0 then
                self:SetBurstCount(0)
                weaponSetNextPrimaryFire(self, postBurstDelay)
            elseif burstCount > 0 and burstCount < currentFiremode then
                swepDoPrimaryAttack(self)
            end
        end

        -- if !self:StillWaiting() and self:GetProcessedValue("TriggerDelay") then
        --     local check = (game.SinglePlayer() and SERVER) or CLIENT
        --     if owner:KeyDown(IN_ATTACK) and !self:SprintLock() then
        --         if check and self:GetTriggerDelay() <= 0 then
        --             self:PlayAnimation("trigger", self:GetProcessedValue("TriggerDelayTime") / self.TriggerDelayTime)
        --         end
        --         self:SetTriggerDelay( math.Approach( self:GetTriggerDelay(), 1, FrameTime() * (1 / self:GetProcessedValue("TriggerDelayTime")) ) )
        --     else
        --         if check and self:GetTriggerDelay() != 1 and self:GetTriggerDelay() != 0 then
        --             self:PlayAnimation("untrigger", self:GetProcessedValue("TriggerDelayTime") / self.TriggerDelayTime)
        --         end
        --         self:SetTriggerDelay(0)
        --     end
        -- end

        -- If we have stopped shooting, play the aftershotparticle
        if swepDt.AfterShot and (IsFirstTimePredicted() or isSingleplayer) then
            local delay = 60 / swepGetProcessedValue(self, "RPM")

            if weaponGetNextPrimaryFire(self) + delay + swepGetProcessedValue(self, "AfterShotParticleDelay") < now then
                self:SetAfterShot(false)
                if swepGetProcessedValue(self, "AfterShotParticle") then
                    local att = swepGetProcessedValue(self, "AfterShotQCA", true) or swepGetProcessedValue(self, "MuzzleEffectQCA", true)

                    local data = EffectData()
                    data:SetEntity(self)
                    data:SetAttachment(att)

                    local effect = swepGetProcessedValue(self, "AfterShotEffect", true)

                    util.Effect(effect, data, true)
                end
            end
        end

        -- Will remove these comments later

        if shouldRunPredicted then
            swepThinkReload(self)
            swepThinkCycle(self)
            swepThinkHeat(self)
            -- Done (no GetVM)
            swepThinkBipod(self)
            swepThinkSights(self)
            swepThinkMelee(self)
            self:ThinkUBGL()
            self:ThinkGrenade()
            self:ThinkTriggerSounds()
        end
        -- Done
        self:ThinkRecoil()
        self:ThinkHoldBreath()
        self:ThinkLockOn()
    end

    if swepDt.NextIdle != 0 and swepDt.NextIdle <= now then
        swepIdle(self)
    end

    if shouldRunPredicted then
        swepThinkFiremodes(self)
        swepThinkInspect(self)
    end

    swepThinkSprint(self)
    swepThinkNearWall(self)
    swepThinkFreeAim(self)
    swepThinkLoopingSound(self)
    swepThinkAnimation(self)
    swepThinkCustomize(self)

    swepRunHook(self, "Hook_Think")

    if CLIENT then
        swepThinkThirdArm(self)
        swepThinkPeek(self)
        swepThinkRadialMenu(self)
    end

    if self.WantToInvalidateCache then
        self:DoInvalidateCache()
    end

    self:ProcessTimers()

    local holdingProp = owner.ARC9_HoldingProp
    if SERVER and holdingProp and (!IsValid(holdingProp) or !holdingProp:IsPlayerHolding()) then
        owner.ARC9_HoldingProp = nil
        net.Start("arc9_stoppickup")
        net.Send(owner)
        playerDoAnimationEvent(owner, ACT_FLINCH_BACK)
    end

    if CLIENT then
        if !self.LoadedPreset and !self:GetNoPresets() then
            timer.Simple(0.075, function() -- idk
                if IsValid(self) then
                    if !self.LoadedPreset then -- still same?
                        self.LoadedPreset = true

                        if cvarGetBool(cvarArcAutosave) then
                            swepLoadPreset(self, "autosave")
                        else
                            swepLoadPreset(self, "default")
                        end
                    end
                end
            end)
        end

        if !self.ClientStarted then
            self.ClientStarted = true
            self:SetReady(false)
            self:DoDeployAnimation()

            if LocalPlayer().ARC9_IncompatibilityCheck != true then
                LocalPlayer().ARC9_IncompatibilityCheck = true

                ARC9.DoCompatibilityCheck()
            end
        end

        if isSingleplayer and self.IsQuickGrenade then owner.ARC9LastSelectedGrenade = self:GetClass() end
    end
end

SWEP.LastClipSize = 0
SWEP.LastAmmo = ""