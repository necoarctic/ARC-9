function SWEP:ThinkGrenade()
    if !self:GetProcessedValue("Throwable", true) then return end
    local owner = self:GetOwner()

    owner.ARC9QuickthrowPls = nil
    local QuicknadeBind = owner:KeyDown(IN_GRENADE1)

    if self:GetSafe() and owner:KeyPressed(IN_ATTACK) then self:ToggleSafety(false) return end

    if IsValid(self:GetDetonatorEntity()) then
        if owner:KeyPressed(IN_ATTACK) then
            self:TouchOff()
            return
        end
    end

    local fuse = self:GetProcessedValue("FuseTimer")

    if fuse >= 0 and self:GetGrenadePrimed() then
        local time = CurTime() - self:GetGrenadePrimedTime()

        if time >= fuse then
            self:ThrowGrenade(ARC9.NADETHROWTYPE_EXPLODEINHANDS, 0)

            if self:HasAnimation("explodeinhands") then
                self:PlayAnimation("explodeinhands", 1, true)
            else
                self:PlayAnimation("throw", 1, true)
            end
        end
    end

    local tossable = self:GetProcessedValue("Tossable", true) and self:HasAnimation("toss")

    if !self:GetGrenadePrimed() then
        if self:GetAnimLockTime() > CurTime() then return end

        local throwanimspeed = self:GetProcessedValue("ThrowAnimSpeed", true)
        if self:GetGrenadeRecovering() then
            if self:GetProcessedValue("Disposable", true) and !self:HasAmmoInClip() and !IsValid(self:GetDetonatorEntity()) and SERVER then
                self:Remove()
                owner:ConCommand("lastinv") -- switch to prev weapon
            elseif self.WasThrownByBind then
                self.WasThrownByBind = nil
                self:Holster(owner:GetPreviousWeapon())
                -- owner:ConCommand("lastinv") -- switch to prev weapon man we dont need dis shid!!
            else
                self:PlayAnimation("draw", throwanimspeed, true)
                self:SetGrenadeRecovering(false)
            end
        elseif ((tossable and owner:KeyDown(IN_ATTACK2)) or
        owner:KeyDown(IN_ATTACK)) and
            self:HasAmmoInClip() and
            (!owner:KeyDown(IN_USE) or !self:GetProcessedValue("PrimaryBash", true)) and
            !IsValid(self:GetDetonatorEntity()) and !self:RunHook("HookP_BlockFire")
            then
            self:SetGrenadePrimed(true)
            self:SetGrenadePrimedTime(CurTime())

            if owner:KeyDown(IN_ATTACK2) and self:HasAnimation("pullpin_toss") then
                self:PlayAnimation("pullpin_toss", throwanimspeed, true)
            else
                self:PlayAnimation("pullpin", throwanimspeed, true)
            end
            self:SetGrenadeTossing(owner:KeyDown(IN_ATTACK2))
        end
    else
        if self:GetAnimLockTime() > CurTime() then return end

        if self:GetGrenadeTossing() and (!owner:KeyDown(IN_ATTACK2) or self:GetProcessedValue("ThrowInstantly", true)) then
            local t, mp = self:PlayAnimation("toss", throwanimspeed, true)
            self:ThrowGrenade(ARC9.NADETHROWTYPE_TOSS, t * mp)
        elseif !self:GetGrenadeTossing() and (!(owner:KeyDown(IN_ATTACK) or QuicknadeBind) or self:GetProcessedValue("ThrowInstantly", true)) then
            local t, mp = self:PlayAnimation("throw", throwanimspeed, true)
            self:ThrowGrenade(ARC9.NADETHROWTYPE_NORMAL, t * mp)
        end

        self:SetGrenadeRecovering(true)
    end
end

function SWEP:ThrowGrenade(nttype, delaytime)
    delaytime = delaytime or 0
    self:SetGrenadePrimed(false)

    self:TakeAmmo()

    self:DoPlayerAnimationEvent(self:GetProcessedValue("AnimShoot", true))

    if CLIENT then return end

    local time = math.huge
    local fusetimer = self:GetProcessedValue("FuseTimer")
    local forcemax = self:GetProcessedValue("ThrowForceMax")
    local forcemin = self:GetProcessedValue("ThrowForceMin")
    local forcetime = self:GetProcessedValue("ThrowChargeTime")

    time = CurTime() - self:GetGrenadePrimedTime()

    local force = forcemax

    if forcetime > 0 then
        force = forcemin + (forcemax - forcemin) * math.Clamp(time / forcetime, 0, 1)
    end

    local num = self:GetProcessedValue("Num")
    local ent = self:GetProcessedValue("ShootEnt")

    local owner = self:GetOwner()

    if owner:IsNPC() then
        -- ang = self:GetOwner():GetAimVector():Angle()
        spread = self:GetNPCBulletSpread()
    else
        spread = self:GetProcessedValue("Spread")
    end

    spread = math.Max(spread, 0)

    local override = {
        force = force,
        delay = delaytime,
    }
    self:RunHook("Hook_GrenadeThrown", override)

    force = override.force or force
    delaytime = override.delay or delaytime
    time = time + delaytime

    -- The fuse timer would run out during the throw animation, so make it explode in hand
    if nttype != ARC9.NADETHROWTYPE_EXPLODEINHANDS and fusetimer >= 0 and fusetimer <= time then
        delaytime = fusetimer - time
        nttype = ARC9.NADETHROWTYPE_EXPLODEINHANDS
    end

    self:SetTimer(delaytime, function()

        local src, dir
        if self:GetProcessedValue("ThrowOnGround", true) then
            src = owner:EyePos()
            dir = Angle(0, owner:GetAngles().y, 0)

            local shootposoffset = self:GetProcessedValue("ShootPosOffset", true)

            local angRight = dir:Right()
            local angForward = dir:Forward()
            local angUp = dir:Up()

            angRight:Mul(shootposoffset[1])
            angForward:Mul(shootposoffset[2])
            angUp:Mul(shootposoffset[3])

            src:Add(angRight)
            src:Add(angForward)
            src:Add(angUp)

            src, dir = self:GetRecoilOffset(src, dir)

            local tr = util.TraceLine({
                start = src,
                endpos = src - Vector(0, 0, 64),
                mask = MASK_SOLID,
            })
            src = tr.HitPos
        else
            src, dir = self:GetShootPos()
        end

        local nades = {}
        for i = 1, num do
            local nade = ents.Create(ent)

            if !IsValid(nade) then return end
            local dispersion = Angle(math.Rand(-1, 1), math.Rand(-1, 1), 0)

            dispersion = dispersion * spread * 36

            nade:SetPos(src)
            nade:SetAngles(dir)
            nade:SetOwner(owner)
            nade:Spawn()


            if nttype == ARC9.NADETHROWTYPE_EXPLODEINHANDS then
                force = 0
                time = 0
                nade:Detonate()
            else
                if nttype  == ARC9.NADETHROWTYPE_TOSS then
                    force = self:GetProcessedValue("TossForce", true)
                end
                if fusetimer >= 0 then
                    nade.LifeTime = fusetimer - time
                    if nade.LifeTime <= 0 then
                        force = 0
                        time = 0
                        nade:Detonate()
                    end
                end
            end



            if self:GetProcessedValue("Detonator", true) then
                self:SetDetonatorEntity(nade)
            end

            nade:SetPhysicsAttacker(self:GetOwner(), 600)

            local phys = nade:GetPhysicsObject()

            if IsValid(phys) then
                if self:GetProcessedValue("ThrowTumble", true) then
                    nade:SetAngles(Angle(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180)))
                    phys:AddAngleVelocity(Vector(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180)))
                end

                if self:GetProcessedValue("ShootEntInheritPlayerVelocity") then
                    local vel = owner:GetVelocity()
                    local limit = self:GetProcessedValue("ShootEntInheritPlayerVelocityLimit")
                    if isnumber(limit) and limit > 0 and vel:Length() > limit then
                        vel = vel:GetNormalized() * limit
                    end
                    phys:SetVelocity(vel)
                end

                phys:AddVelocity((dir + dispersion):Forward() * force)
            end

            table.insert(nades, nade)
        end

        self:RunHook("Hook_GrenadeCreated", nades)
    end)
end

function SWEP:TouchOff()
    self:PlayAnimation("touchoff", 1, true)

    self:SetGrenadeRecovering(true)

    if SERVER and IsValid(self:GetDetonatorEntity()) then
        self:GetDetonatorEntity():Detonate()
    end
end