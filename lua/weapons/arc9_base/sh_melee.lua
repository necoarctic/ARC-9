local bodyDamageCancel = GetConVar("arc9_mod_bodydamagecancel")
local cancelmults = ARC9.CancelMultipliers[engine.ActiveGamemode()] or ARC9.CancelMultipliers[1]

local vmaxs, vmins = Vector(2, 2, 2), Vector(-2, -2, -2)

function SWEP:MeleeAttack(bypass, bash2)
    if !bypass then
        if !self:GetProcessedValue("BashCancelsReload", true) and self:StillWaiting() then return end
        if !self:GetProcessedValue("BashWhileSprint", true) and self:SprintLock() then return end
    end

    if self:RunHook("HookP_BlockFire") then return end

    self:CancelReload()

    self:CallOnClient("CallNonTPIKAnim", "AnimMelee")

    local soundtab1 = {
        name = "meleeswing",
        sound = self:RandomChoice(self:GetProcessedValue("MeleeSwingSound", true)),
        channel = ARC9.CHAN_MELEE
    }

    self:PlayTranslatedSound(soundtab1)

    local owner = self:GetOwner()
    local backstab = false

    local prefix = "Bash"

    if bash2 then
        prefix = "Bash2"
    end

    local range = self:GetProcessedValue(prefix .. "LungeRange")

    local tr = util.TraceHull({
        start = owner:EyePos(),
        endpos = owner:EyePos() + (owner:GetAimVector() * range),
        mask = MASK_SHOT,
        filter = {owner, self:GetShieldEntity(), self.ShieldProp},
        maxs = vmaxs,
        mins = vmins
    })

    if tr.Hit then
        if tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsNextBot() then
            self:SetLungeEntity(tr.Entity)

            if self:GetProcessedValue("Backstab", true) then
                local dot = owner:EyeAngles():Forward():Dot(tr.Entity:EyeAngles():Forward())

                backstab = dot > 0
            end
        end
    end

    if !backstab and self:GetProcessedValue("Backstab", true) then
        local tr2 = util.TraceHull({
            start = owner:EyePos(),
            endpos = owner:EyePos() + (owner:GetAimVector() * self:GetProcessedValue("BackstabRange")),
            mask = MASK_SHOT,
            filter = {owner, self:GetShieldEntity(), self.ShieldProp},
            maxs = vmaxs,
            mins = vmins
        })
        if tr2.Hit then
            if tr2.Entity:IsPlayer() or tr2.Entity:IsNPC() or tr2.Entity:IsNextBot() then
                local dot = owner:EyeAngles():Forward():Dot(tr2.Entity:EyeAngles():Forward())
                backstab = dot > 0
            end
        end
    end

    if backstab then
        prefix = "Backstab"
    end

    local bashspeed = self:GetProcessedValue("BashSpeed")

    self:SetFreeAimAngle(angle_zero)

    self:SetLastMeleeTime(CurTime())

    self:SetNextPrimaryFire(CurTime() + (self:GetProcessedValue("Pre" .. prefix .. "Time") / bashspeed) + (self:GetProcessedValue("Post" .. prefix .. "Time") / bashspeed))

    self.SetNextAiming = CurTime() + (self:GetProcessedValue("Pre" .. prefix .. "Time") / bashspeed) + (self:GetProcessedValue("Post" .. prefix .. "Time") / bashspeed)

    self:SetBash2(bash2)

    if backstab and self:HasAnimation("backstab") then
        self:PlayAnimation("backstab", 1 / bashspeed, false)
    elseif bash2 and self:HasAnimation("bash2") then
        self:PlayAnimation("bash2", 1 / bashspeed, false)
    elseif self:HasAnimation("bash") then
        self:PlayAnimation("bash", 1 / bashspeed, false)
    else
        if game.SinglePlayer() and SERVER then
            self:CallOnClient("MeleeAttack", "true")
        elseif CLIENT then
            self:PlayThirdArmAnim(self:GetProcessedValue("BashThirdArmAnimation", true), false)

            if game.SinglePlayer() and CLIENT then
                return
            end
        end
    end

    --[[]
    if !backstab then
        self:SetInMeleeAttack(true)
    else
        self:MeleeAttackShoot(bash2, true)
    end
    ]]
    self:SetBackstab(backstab)
    self:SetInMeleeAttack(true)

    self.RecentMelee = true

end

local vmaxs2, vmins2 = Vector(2, 2, 2), Vector(-2, -2, -2)

function SWEP:MeleeAttackShoot(bash2, backstab)
    local owner = self:GetOwner()

    local prefix = "Bash"

    if bash2 then
        prefix = "Bash2"
    end

    if backstab then
        prefix = "Backstab"
    end

    local tr = util.TraceHull({
        start = owner:EyePos(),
        endpos = owner:EyePos() + (owner:EyeAngles():Forward() * self:GetProcessedValue(prefix .. "Range")),
        mask = MASK_SHOT + 8,
        filter = {owner, self:GetShieldEntity(), self.ShieldProp},
        maxs = vmaxs2,
        mins = vmins2
    })

    self:RunHook("Hook_Bash", tr)

    if tr.Hit then
        if tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsNextBot() then
            if backstab then
                local dot = owner:EyeAngles():Forward():Dot(tr.Entity:EyeAngles():Forward())
                if dot <= 0 then
                    backstab = false
                    prefix = bash2 and "Bash2" or "Bash"
                end
            end
            if backstab then
                local soundtab = {
                    name = "backstab",
                    sound = self:RandomChoice(self:GetProcessedValue("BackstabSound", true)),
                    channel = ARC9.CHAN_MELEE
                }

                self:PlayTranslatedSound(soundtab)
            else
                local soundtab = {
                    name = "meleehit",
                    sound = self:RandomChoice(self:GetProcessedValue("MeleeHitSound", true)),
                    channel = ARC9.CHAN_MELEE
                }

                self:PlayTranslatedSound(soundtab)
            end

            if IsFirstTimePredicted() then
                local fx = EffectData()
                fx:SetStart(tr.StartPos)
                fx:SetOrigin(tr.HitPos)
                fx:SetEntity(tr.Entity)
                fx:SetSurfaceProp(tr.SurfaceProps)
                fx:SetHitBox(tr.HitBox)
                util.Effect("BloodImpact", fx, true)
            end
        else
            local soundtab1 = {
                name = "meleehitwall",
                sound = self:RandomChoice(self:GetProcessedValue("MeleeHitWallSound", true)),
                channel = ARC9.CHAN_MELEE
            }

            self:PlayTranslatedSound(soundtab1)

            util.Decal(self:GetProcessedValue(prefix .. "Decal"), tr.HitPos + (tr.HitNormal * 8), tr.HitPos - (tr.HitNormal * 8), owner)

            if self:GetProcessedValue(prefix .. "Impact") and IsFirstTimePredicted() then
                local fx = EffectData()
                fx:SetStart(tr.StartPos)
                fx:SetOrigin(tr.HitPos)
                fx:SetEntity(tr.Entity)
                fx:SetSurfaceProp(tr.SurfaceProps)
                fx:SetHitBox(tr.HitBox)
                util.Effect("Impact", fx, true)
            end
        end

        if self:HasAnimation("impact") then
            self:PlayAnimation(bash2 and "impact2" or "impact", 1, false)
        end

        if SERVER then
            local dmg = DamageInfo()

            dmg:SetDamage(self:GetProcessedValue(prefix .. "Damage"))
            dmg:SetDamageForce(owner:GetAimVector() * 16000)
            dmg:SetDamagePosition(tr.HitPos)
            dmg:SetDamageType(self:GetProcessedValue(prefix .. "DamageType"))
            dmg:SetAttacker(owner)
            dmg:SetInflictor(self)

            local data = {tr = tr, dmg = dmg}
            self:RunHook("Hook_BashHit", data)

            -- do not need to worry about limb damage because hull traces only returns generic hitgroup
            tr.Entity:DispatchTraceAttack(dmg, tr) -- hits breakable glass surfaces, unlike TakeDamageInfo
        end
    end

    self:SetInMeleeAttack(false)
    self:SetLungeEntity(NULL)
end

local PlayerKeyDown = FindMetaTable("Player").KeyDown

function SWEP:ThinkMelee()
    -- if self:StillWaiting() then return end
    local owner = self:GetOwner()
    local m1 = PlayerKeyDown(owner, IN_ATTACK)
    local m2 = PlayerKeyDown(owner, IN_ATTACK2)
    local marc = owner:KeyPressed(ARC9.IN_MELEE)

    if !(m1 or m2 or marc) and !self:GetInMeleeAttack() then return end

    if !self:GetProcessedValue("ShootWhileSprint", true) and self:GetIsSprinting() then return end

    if self:GetBipod() then return end

    local bashsped = self:GetProcessedValue("BashSpeed", true)

    local prebash = self:GetProcessedValue("PreBashTime", true) / bashsped
    local postbash = self:GetProcessedValue("PostBashTime", true)
    local b2 = false

    if self:GetBash2() and self:GetProcessedValue("SecondaryBash", true) then
        prebash = self:GetProcessedValue("PreBash2Time", true) / bashsped
        postbash = self:GetProcessedValue("PostBash2Time", true)
    end

    if self:GetBackstab() and self:GetProcessedValue("Backstab", true) then
        prebash = self:GetProcessedValue("PreBackstabTime", true) / bashsped
        postbash = self:GetProcessedValue("PostBackstabTime", true)
    end

    if !self:GetGrenadePrimed() then
        if m2 then b2 = true else b2 = false end

        waituntilbashagain = self:GetLastMeleeTime() + prebash + postbash <= CurTime()

        if self:GetProcessedValue("PrimaryBash", true) and m1 and waituntilbashagain then
            if self:GetSafe() then
                self:ToggleSafety(false)
            else
                self:MeleeAttack(nil, b2)
            end
        end

        if self:GetProcessedValue("SecondaryBash", true) and m2 and waituntilbashagain then
            if self:GetSafe() then
                self:ToggleSafety(false)
            else
                self:MeleeAttack(nil, b2)
            end
        end

        if self:GetProcessedValue("Bash", true) and marc and !self:GetInSights() and waituntilbashagain then
            if self:GetSafe() then
                self:ToggleSafety(false)
            else
                self:MeleeAttack()
            end
        end

    end

    if self:GetInMeleeAttack() and self:GetLastMeleeTime() + prebash <= CurTime() then
        self:MeleeAttackShoot(self:GetBash2(), self:GetBackstab())
    end
end
