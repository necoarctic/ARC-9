
function SWEP:SetReloadTimer( time, amount )
    self:SetReloadTime( time )
    self:SetReloadAmount( amount )
end

function SWEP:KillReloadTimer()
    self:SetReloadTime( 0 )
    self:SetReloadAmount( 0 )
end

function SWEP:Reload()
    if self:GetOwner():IsNPC() then
        self:NPC_Reload()
        return
    end

    -- if !self:GetOwner():KeyPressed(IN_RELOAD) then
    --     return
    -- end

    if !self:GetProcessedValue("CanReloadWhileUnCycled", true) and self:GetNeedsCycle() then
        return
    end

    if self:GetIsSprinting() and self:GetProcessedValue("SprintCancelsReload", true) then return end

    -- if !self:GetProcessedValue("UBGLInsteadOfSights") and self:GetValue("UBGL") then
    --     if self:GetOwner():KeyDown(IN_USE) then
    --         return
    --     end
    -- end

    if self:GetJammed() then
        self:UnJam()
        return
    end

    if self:GetOwner():KeyDown(IN_WALK) then
        return
    end

    if !self:CanReload() then return end

    local clip = self:Clip1()
    local ammo = self:Ammo1()
    local getUBGL = self:GetUBGL()

    if getUBGL then
        clip = self:Clip2()
        ammo = self:Ammo2()
    end

    if !self:GetProcessedValue("BottomlessClip", true) then
        if clip >= self:GetCapacity(getUBGL) then return end

        if !self:GetInfiniteAmmo() and ammo <= 0 then
            return
        end
    else
        return
    end


    -- if CLIENT and !self:ShouldTPIK() then
        -- self:DoPlayerAnimationEvent(self:GetProcessedValue("NonTPIKAnimReload"))
    -- else
        -- self:DoPlayerAnimationEvent(self:GetProcessedValue("AnimReload"))
    -- end

    self:CallOnClient("CallNonTPIKAnim", "AnimReload")

    -- self:ScopeToggle(0)
    -- self:ToggleCustomize(false)

    if clip == 0 then
        self:SetEmptyReload(true)
    else
        self:SetEmptyReload(false)
    end

    local anim = "reload"

    if getUBGL then
        anim = "reload_ubgl"
    end

    if self:GetShouldShotgunReload() then
        anim = "reload_start"

        if getUBGL then
            anim = "reload_ubgl_start"
        end

        local anim2

        for i = 1, self:GetCapacity(getUBGL) - clip do
            anim2 = anim .. "_" .. tostring(i)

            if self:HasAnimation(anim2) then
                anim = anim2
                break
            end
        end
    end

    if !self:GetProcessedValue("ReloadInSights", true) then
        self:ExitSights()
    end

    anim = self:RunHook("Hook_SelectReloadAnimation", anim) or anim

    local reloadtimemult = self:GetProcessedValue("ReloadTime")

    local t = self:PlayAnimation(anim, reloadtimemult, true)

    if !self:GetShouldShotgunReload() then
		local animation = self:GetAnimationEntry(self:TranslateAnimation(anim))

        local minprogress = animation.RefillProgress or animation.MinProgress or 1
        minprogress = math.min(minprogress, 0.95)

        if !self:GetAnimationEntry(self:TranslateAnimation(anim)).RestoreAmmo then
            self:SetReloadTimer( CurTime() + (t * minprogress), self:GetValue(getUBGL and "UBGLClipSize" or "ClipSize") )
        end

        local newcliptime = self:GetAnimationEntry(self:TranslateAnimation(anim)).MagSwapTime or 0.5

        if !getUBGL then
            if !self:GetAnimationEntry(self:TranslateAnimation(anim)).NoMagSwap then
                self:SetTimer(reloadtimemult * newcliptime, function()
                    local ammo1 = self:Ammo1()

                    if self:GetInfiniteAmmo() then
                        ammo1 = math.huge
                    end

                    self:SetLoadedRounds(math.min((clip == 0 and self:GetValue("ClipSize") or self:GetCapacity(false)), self:Clip1() + ammo1))
                    self:SetLastLoadedRounds(self:GetLoadedRounds())
                end)
            end
        end
    end

    if !self:PredictionFilter() then
        if self:GetProcessedValue("ShouldDropMag") or self:GetProcessedValue("ShouldDropMagEmpty") and clip == 0 then
            self:SetTimer(self:GetProcessedValue("DropMagazineTime", true) * reloadtimemult, function()
                self:DropMagazine()
            end)
        end
    end

    if !self.NoForceSetLoadedRoundsOnReload then -- sorry
        self:SetLoadedRounds(self:Clip1())
    end

    self:SetReloading(true)
    self:SetEndReload(false)
    self:SetCycleFinishTime(0)
    -- self:ToggleBlindFire(false)
    self:SetRequestReload(false)
    self:SetRecoilAmount(0)
    self:SetNeedTriggerPress(false) -- Allows you to keep spraying with Auto-Reload
    self:SetBurstCount(0)

    -- self:SetTimer(t * 0.9, function()
    --     if !IsValid(self) then return end

    --     self:SetEndReload(false)
    --     self:EndReload()
    -- end)

    self:SetReloadFinishTime(CurTime() + (t * 0.95))

    self:RunHook("Hook_PostReload")
end

function SWEP:CanReload()
    if self:GetOwner():KeyDown(IN_WALK) then return false end
    if self:StillWaiting() then return end
    if self:GetCapacity(self:GetUBGL()) <= 0 then return end
    -- if self:GetTraversalSprintAmount() >= 0 then return end
    local ammo = self:Ammo1()
    if self:GetUBGL() then
        ammo = self:Ammo2()
    end
    if ammo <= 0 and !self:GetInfiniteAmmo() then return end
    if !self:GetProcessedValue("ReloadWhileSprint", true) and self:GetSprintAmount() > 0 then
        return
    end
    if self:GetJammed() then return end
    if self:GetCustomize() then
        return
    end

    return true
end

function SWEP:Unload(ammoType)
    if SERVER then
        self:GetOwner():GiveAmmo(self:Clip1(), ammoType, true)
    end
    self:SetClip1(0)
    self:SetLoadedRounds(0)
end

function SWEP:CancelReload()
    if !self:GetReloading() then return end

    self:SetReloading(false)
    self:SetReloadFinishTime(0)
    self:SetCycleFinishTime(0)
    self:SetNeedTriggerPress(false) -- Allows you to keep spraying with Auto-Reload
    local vm = self:GetVM()
    vm:SetSequence(0)
    vm:SetCycle(0)
    self:SetAnimLockTime(0)
    self:PlayAnimation("idle")
    self:DoPlayerAnimationEvent(ACT_HL2MP_GESTURE_RELOAD_MAGIC)
    self:CancelSoundTable()
    self:KillReloadTimer()
    self:SetIKTimeLineStart(0)
    self:SetIKTime(0)
    self:SetEmptyReload(false)
end

function SWEP:DropMagazine()
    -- if !IsFirstTimePredicted() and !game.SinglePlayer() then return end

    local mdl = self:GetProcessedValue("DropMagazineModel", true)

    if mdl then
        util.PrecacheModel(mdl) -- garry newman moment

        for i = 1, self:GetProcessedValue("DropMagazineAmount", true) do
            local drop_qca = self:GetQCAMagdrop()

            local data = EffectData()
            data:SetEntity(self)
            data:SetAttachment(drop_qca)

            util.Effect(self.DropMagazineEffect or "arc9_magdropeffect", data, true)
            -- local mag = ents.Create("ARC9_droppedmag")

            -- if mag then
            --     mag:SetPos(self:GetOwner():EyePos() - (self:GetOwner():EyeAngles():Up() * 8))
            --     mag:SetAngles(self:GetOwner():EyeAngles())
            --     mag.Model = self:GetProcessedValue("DropMagazineModel")
            --     mag.ImpactSounds = self:GetProcessedValue("DropMagazineSounds")
            --     mag:SetOwner(self:GetOwner())
            --     mag:Spawn()
            --     mag:SetSkin(self:GetProcessedValue("DropMagazineSkin"))

            --     local phys = mag:GetPhysicsObject()

            --     if IsValid(phys) then
            --         phys:AddAngleVelocity(Vector(math.Rand(-300, 300), math.Rand(-300, 300), math.Rand(-300, 300)))
            --     end
            -- end
        end
    end
end

function SWEP:TakeAmmo(amt)
    amt = amt or self:GetProcessedValue("AmmoPerShot")
    if self:GetUBGL() then
        self:TakeSecondaryAmmo(amt)
    else
        if self:GetProcessedValue("BottomlessClip", true) then
            if !self:GetInfiniteAmmo() then
                self:RestoreClip(self:GetValue("ClipSize"))

                if self:Ammo1() > 0 then
                    local ammotype = self:GetValue("Ammo")
                    self:GetOwner():SetAmmo(self:GetOwner():GetAmmoCount(ammotype) - amt, ammotype)
                else
                    self:TakePrimaryAmmo(amt)
                end
            end
        else
            self:TakePrimaryAmmo(amt)
        end
    end
end

function SWEP:GetCapacity(ubgl)
    local cap = 0

    if ubgl then
        cap = math.Round(self:GetValue("UBGLClipSize")) + math.Round(self:GetValue("UBGLChamberSize"))
    else
        cap = math.Round(self:GetValue("ClipSize") or 1) + math.Round(self:GetValue("ChamberSize") or 0)
    end

    return cap
end

function SWEP:RestoreClip(amt)
    if CLIENT then return end

    amt = amt or math.huge

    amt = math.Round(amt)

    local inf = self:GetInfiniteAmmo()
    local clip = self:Clip1()
    local ammo = self:Ammo1()

    if self:GetUBGL() then
        clip = self:Clip2()
        ammo = self:Ammo2()
    end

    -- amt = math.max(amt, -clip)

    -- clip can be -1 here if defaultclip is being set
    local reserve = inf and math.huge or (math.max(0, clip) + ammo)

    local lastclip

    if self:GetUBGL() then
        lastclip = self:Clip2()

        self:SetClip2(math.min(math.min(clip + amt, self:GetCapacity(true)), reserve))

        reserve = reserve - self:Clip2()

        if !inf and IsValid(self:GetOwner()) then
            self:GetOwner():SetAmmo(reserve, self.Secondary.Ammo)
        end

        clip = self:Clip2()
    else
        lastclip = self:Clip1()

        self:SetClip1(math.min(math.min(clip + amt, self:GetCapacity(false)), reserve))

        reserve = reserve - self:Clip1()

        if !inf and IsValid(self:GetOwner()) then
            self:GetOwner():SetAmmo(reserve, self.Primary.Ammo)
        end

        clip = self:Clip1()

        if !self.NoForceSetLoadedRoundsOnReload then -- sorry
            self:SetLoadedRounds(self:Clip1())
            self:SetLastLoadedRounds(self:Clip1())
        end
    end

    return clip - lastclip
end

function SWEP:GetShouldShotgunReload()
    if self:GetProcessedValue("HybridReload") then
        if (self:Clip1() > self:GetProcessedValue("ChamberSize")) and !self:GetEmptyReload() then
            return true
        else
            return false
        end
    end

    return self:GetProcessedValue("ShotgunReload")
end

local arc9_infinite_ammo = GetConVar("arc9_infinite_ammo")

function SWEP:GetInfiniteAmmo()
    return arc9_infinite_ammo:GetBool() or self:GetProcessedValue("InfiniteAmmo", true)
end

function SWEP:EndReload()
    if self:GetShouldShotgunReload() then
        local clip = self:Clip1()
        local ammo = self:Ammo1()
        local getUBGL = self:GetUBGL()

        if getUBGL then
            clip = self:Clip2()
            ammo = self:Ammo2()
        end

        if self:GetInfiniteAmmo() then
            ammo = math.huge
        end

        local capacity

        if getUBGL then
            capacity = self:GetProcessedValue("UBGLClipSize")
        else
            capacity = self:GetProcessedValue("ClipSize")
        end

        if !self.ShotgunReloadNoChamber then
            if getUBGL then
                if !self:GetEmptyReload() or self:GetProcessedValue("ShotgunReloadIncludesChamber", true) then
                    capacity = capacity + self:GetProcessedValue("UBGLChamberSize")
                end
            else
                if !self:GetEmptyReload() or self:GetProcessedValue("ShotgunReloadIncludesChamber", true) then
                    capacity = capacity + self:GetProcessedValue("ChamberSize")
                end
            end
        end

        if clip >= capacity or ammo == 0 or (self:GetEndReload() and clip > 0) then
            -- finish
            local anim = "reload_finish"

            if getUBGL then
                anim = "reload_ubgl_finish"
            end

            local anim2

            for i = 1, self:GetCapacity(getUBGL) - clip do
                anim2 = anim .. "_" .. tostring(i)

                if self:HasAnimation(anim2) then
                    anim = anim2
                    break
                end
            end

            self:PlayAnimation(anim, self:GetProcessedValue("ReloadTime", nil, 1), true)
            self:SetReloading(false)
            self:SetCycleFinishTime(0)

            self:SetNthShot(0)

            if self:GetEmptyReload() or self:GetProcessedValue("PartialReloadCountsTowardsNthReload", true) then
                self:SetNthReload(self:GetNthReload() + 1)
            end

            self:SetNeedTriggerPress(false) -- Allows you to keep spraying with Auto-Reload
            self:SetEmptyReload(false)
        else
            local anim = "reload_insert"
            if getUBGL then
                anim = "reload_ubgl_insert"
            end

            local attempt_to_restore = 1
            local anim2
            local end_clipsize = self:Clip1()

            for i = 1, self:GetCapacity(getUBGL) - clip do
                anim2 = anim .. "_" .. tostring(i)

                if self:HasAnimation(anim2) then
                    anim = anim2
                    attempt_to_restore = i
                    break
                else
                    anim2 = anim .. "_bullet_" .. tostring(i)

                    if self:HasAnimation(anim2) then
                        anim = anim2
                        attempt_to_restore = 1
                        break
                    end
                end
            end

            end_clipsize = end_clipsize + attempt_to_restore

            local t, minprogress = self:PlayAnimation(anim, self:GetProcessedValue("ReloadTime", nil, 1), true, true)

            local magswaptime = (self:GetAnimationEntry(anim) or {}).MagSwapTime or 0

            if !self.NoForceSetLoadedRoundsOnReload then -- sorry
                self:SetTimer(magswaptime * t, function()
                    self:SetLoadedRounds(end_clipsize)
                    self:SetLastLoadedRounds(end_clipsize)
                end)
            end

            self:SetTimer(minprogress * t, function()
                self:RestoreClip(attempt_to_restore)
            end)

            self:SetReloadFinishTime(CurTime() + t)
        end
    else
        self:SetReloading(false)

        self:SetNthShot(self:GetMaxClip1() - self:Clip1() + self:GetProcessedValue("ChamberSize"))

        if self:GetEmptyReload() or self:GetProcessedValue("PartialReloadCountsTowardsNthReload", true) then
            self:SetNthReload(self:GetNthReload() + 1)
        end
        -- self:SetLoadedRounds(self:Clip1())

        self:SetEmptyReload(false)
    end

    self:RunHook("Hook_EndReload")
end

function SWEP:ThinkReload()
    if self:GetReloadTime() != 0 and self:GetReloadTime() <= CurTime() then
        self:RestoreClip( self:GetReloadAmount() )
        self:SetReloadTime( 0 )
        self:SetReloadAmount( 0 )
    end
    if self:GetReloading() and self:GetReloadFinishTime() <= CurTime() then
        self:EndReload()
    end
end

function SWEP:GetLoadingIntoClip()
    local capacity = self:GetCapacity()
    local ammo = self:Ammo1() + self:Clip1()

    if self:GetInfiniteAmmo() then
        ammo = math.huge
    end

    if self:GetProcessedValue("BottomlessClip", true) then
        capacity = ammo
    end

    local newclipsize = math.min(capacity, ammo)

    return newclipsize - self:GetLoadedRounds()
end

function SWEP:GetLoadedClip()
    local clip = self:Clip1()
    local ammo = self:Ammo1()

    if self:GetInfiniteAmmo() then
        ammo = math.huge
    end

    if self:GetUBGL() then
        clip = self:Clip2()

        if self:GetProcessedValue("BottomlessClip", true) then
            clip = self:Ammo2()
        end
    elseif self:GetProcessedValue("BottomlessClip", true) then
        clip = ammo
    end

    return clip
end

function SWEP:HasAmmoInClip()
    if self:GetProcessedValue("BottomlessClip", true) then
        if self:GetUBGL() then
            return self:Clip2() + self:Ammo2() >= self:GetProcessedValue("AmmoPerShot")
        else
            return self:Clip1() + self:Ammo1() >= self:GetProcessedValue("AmmoPerShot")
        end
    else
        if self:GetUBGL() then
            return self:Clip2() >= self:GetProcessedValue("AmmoPerShot")
        else
            return self:Clip1() >= self:GetProcessedValue("AmmoPerShot")
        end
    end
end

function SWEP:DoBulletPose()
    if SERVER then return end
    local pp = self:Clip1()

    local vm = self:GetVM()

    pp = self:RunHook("HookP_ModifyBulletPoseParam", pp) or pp

    vm:SetPoseParameter("bullets", pp)
end

function SWEP:Ammo1()
    if !IsValid(self:GetOwner()) then return math.huge end

    if self:GetInfiniteAmmo() then
        return math.huge
    end

    return self:GetOwner():GetAmmoCount(self:GetProcessedValue("Ammo"))
end

function SWEP:Ammo2()
    if !IsValid(self:GetOwner()) then return math.huge end

    if self:GetInfiniteAmmo() then
        return math.huge
    end

    return self:GetOwner():GetAmmoCount(self:GetProcessedValue("UBGLAmmo"))
end

function SWEP:GetReloadingProgress()
    local fuckingreloadprocessinfluence, fuckingreloadprocess = 0, 0
    if self:GetReloading() and !self:GetProcessedValue("ShotgunReload", true) then
        fuckingreloadprocessinfluence = 1
        fuckingreloadprocess = math.Clamp(1 - (self:GetReloadFinishTime() - CurTime()) / (self.ReloadTime * self:GetAnimationTime("reload")), 0, 1)
        if fuckingreloadprocess <= 0.1 then
            fuckingreloadprocessinfluence = fuckingreloadprocess * 10
        elseif fuckingreloadprocess > 0.75 then
            fuckingreloadprocessinfluence = math.max(0, 1 - ((fuckingreloadprocess - 0.75) * 8))
        end
        
        fuckingreloadprocessinfluence = math.ease.InCirc(fuckingreloadprocessinfluence)
    end

    return fuckingreloadprocessinfluence, fuckingreloadprocess
end