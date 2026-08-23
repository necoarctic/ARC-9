function SWEP:PlayAnimation(anim, mult, lock, no_idle, noproxy, notranslate)
    mult = mult or 1
    lock = lock or false
    local untranslatedanim = anim
    anim = (notranslate == true) and anim or self:TranslateAnimation(anim)
    mult = self:RunHook("Hook_TranslateAnimSpeed", {mult = mult, anim = anim}).Mult or mult
    local omult = mult

    if !self:HasAnimation(anim) then return 0, 1 end

    if self:RunHook("Hook_BlockAnimation", anim) == true then return 0, 1 end

    local mdl = self:GetVM()

    if !IsValid(mdl) then return 0, 1 end

    local animation = self:GetAnimationEntry(anim)

    local source = animation.Source

    if animation.RareSource then
        if util.SharedRandom("ARC9_raresource", 0, 1) <= (animation.RareSourceChance or 0.01) then
            source = animation.RareSource
        end
    end

    if istable(source) then
        source = source[math.Round(util.SharedRandom("ARC9_animsource", 1, #source, CurTime()))]
    end

    local tsource = self:RunHook("Hook_TranslateSource", source) or source

    if mdl:LookupSequence(tsource) != -1 then
        source = tsource
    end

    local seq = 0

    if animation.ProxyAnimation and !noproxy then
        if CLIENT then
            mdl = animation.Model

            if !mdl then
                mdl = self:LocateSlotFromAddress(animation.Address).GunDriverModel
            end
        else
            mdl = ents.Create("prop_physics")
            mdl:SetModel(animation.ModelName)
        end

        self:SetSequenceProxy(animation.Address or 0)

        if IsValid(mdl) then

            seq = mdl:LookupSequence(source)

            if seq == -1 then return 0, 1 end

            if animation.AlsoPlayBase then
                self:PlayAnimation(anim, mult, lock, no_idle, true)
            end

        end
    else
        seq = mdl:LookupSequence(source)

        if seq == -1 then return 0, 1 end

        self:SetSequenceProxy(0)
    end

    local time = 0.1
    local minprogress = 1

    if IsValid(mdl) then
        time = animation.Time or mdl:SequenceDuration(seq)

        local mp_t = animation.MinProgressTime -- New MinProgressTime, seconds-based
        local mp_c = animation.MinProgress -- Classic MinProgress, percentage-based
        minprogress = (mp_t and mp_t/time) or (mp_c and mp_c) or 1

        mult = mult * (animation.Mult or 1)

        if animation.Reverse then
            mult = mult * -1
        end

        local tmult = 1

        tmult = (mdl:SequenceDuration(seq) / time) / mult

        if animation.ProxyAnimation then
            mdl:SetSequence(seq)
            mdl:SetCycle(0)
        else
            mdl:SendViewModelMatchingSequence(seq)
            mdl:SetPlaybackRate(math.Clamp(tmult, -12, 12)) -- It doesn't like it if you go higher
        end

        self:SetSequenceIndex(seq or 0)
        self:SetSequenceSpeed((1 / time) / mult)

        if mult < 0 then
            self:SetSequenceCycle(1)
        else
            self:SetSequenceCycle(0)
        end

        mult = math.abs(mult)

        if animation.EjectAt then
            self:SetTimer(animation.EjectAt * mult, function()
                self:DoEject()
            end, "ejectat")
        end

        if animation.DropMagAt then
            self:SetTimer(animation.DropMagAt * mult, function()
                self:DropMagazine()
            end)
        end

        if animation.DumpAmmo then
            self:SetTimer(minprogress * mult, function()
                if SERVER then
                    self:Unload(self:GetValue("Ammo"))
                end
            end)
        end


        if animation.RestoreAmmo then
            self:Refill(CurTime() + (time * mult * minprogress), animation.RestoreAmmo)
        end

        if animation.IKTimeLine then
            self:SetIKAnimation(anim)
            self:SetIKTimeLineStart(CurTime())
            self:SetIKTime(time * mult)
        end
    end

    self:KillSoundTable()

    if (animation.EventTable or animation.SoundTable) and IsFirstTimePredicted() then
        -- This additional Mult check is necessary because mdl isn't valid above on the client and so the EventTable is off-sync.
        self:PlaySoundTable(animation.EventTable or animation.SoundTable, omult * (animation.Mult or 1))
    end

    self:SetHideBoneIndex(animation.HideBoneIndex or 0)

    if lock then
        local short = isnumber(animation.FireASAP) and animation.FireASAP or minprogress
        -- This fixes shotgun reloads with MinProgress allowing you to shoot or do other things
        -- in the middle of a reload.
        if untranslatedanim == "reload_start" or untranslatedanim == "reload_insert" then
            short = 1
        end
        self:SetAnimLockTime(CurTime() + (time * mult * short))
    else
        self:SetAnimLockTime(0)
    end

    if no_idle or animation.NoIdle or untranslatedanim == "idle" then
        self:SetNextIdle(0)
    else
        self:SetNextIdle(CurTime() + time * mult)
    end

    if animation.PoseParamChanges then
        for i, k in pairs(animation.PoseParamChanges) do
            self.PoseParamState[i] = k
        end
    end

    self:SetFinishFiremodeAnimTime(0)

    if SERVER and animation.ProxyAnimation then
        SafeRemoveEntity(mdl)
    end

    self:SetFiremodePose()

    if self.UnbipodOnLockAnims  then
        if lock and (untranslatedanim != "idle" and untranslatedanim != "fire" and untranslatedanim != "dryfire" and untranslatedanim != "enter_sights" and untranslatedanim != "exit_sights") then
            if self:GetBipodAmount() > 0.9 then
                self:SetBipod(false)
                self:SetEnterBipodTime(CurTime())
            end
        end
    end

    return time * mult, minprogress
end

function SWEP:GetAnimationProxyModel(wm)
    local mdl
    if SERVER then
        local atttbl = self:GetFinalAttTableFromAddress(self:GetSequenceProxy())
        local modelname = atttbl.Model
        mdl = ents.Create("prop_physics")
        mdl:SetModel(modelname)
    else
        local slottbl = self:LocateSlotFromAddress(self:GetSequenceProxy())

        if !slottbl then return end

        if wm then
            mdl = slottbl.WModel
        else
            mdl = slottbl.VModel
        end
    end

    return mdl
end

function SWEP:GetAnimationProxyGunDriver()
    local mdl
    if SERVER then
        local atttbl = self:GetFinalAttTableFromAddress(self:GetSequenceProxy())
        local modelname = atttbl.Model
        mdl = ents.Create("prop_physics")
        mdl:SetModel(modelname)
    else
        local slottbl = self:LocateSlotFromAddress(self:GetSequenceProxy())

        if !slottbl then return end

        mdl = slottbl.GunDriverModel
    end

    return mdl
end

function SWEP:GetAnimationProxyReflectDriver()
    local mdl
    if SERVER then
        local atttbl = self:GetFinalAttTableFromAddress(self:GetSequenceProxy())
        local modelname = atttbl.Model
        mdl = ents.Create("prop_physics")
        mdl:SetModel(modelname)
    else
        local slottbl = self:LocateSlotFromAddress(self:GetSequenceProxy())

        if !slottbl then return end

        mdl = slottbl.ReflectDriverModel
    end

    return mdl
end

function SWEP:IdleAtEndOfAnimation()
    local mdl = self:GetVM()

    local cyc
    local duration
    local rate

    if self:GetSequenceProxy() == 0 then
        cyc = mdl:GetCycle()
        duration = mdl:SequenceDuration()
        rate = mdl:GetPlaybackRate()
    else
        mdl = self:GetAnimationProxyModel()

        cyc = self:GetSequenceCycle()
        duration = mdl:SequenceDuration(self:GetSequenceIndex())
        rate = self:GetSequenceSpeed()

        if SERVER then
            SafeRemoveEntity(mdl)
        end
    end

    local time = (1 - cyc) * (duration / rate)

    self:SetNextIdle(CurTime() + time)
end

function SWEP:Idle()
    if self:GetPrimedAttack() then return end
    if self:GetSafe() then return end

    local anim = "idle"
    local clip = self:Clip1()
    local banim = anim

    for i = 1, self:GetCapacity(self:GetUBGL()) - clip do
        if self:HasAnimation(anim .. "_" .. tostring(i)) then
            banim = anim .. "_" .. tostring(i)
        end
    end
    anim = banim

    local speed = 1

    if self:GetIsNearWall() then
        speed = math.huge
    end
    
    self:SetShouldHoldType()

    self:PlayAnimation(anim, speed)
end

SWEP.PoseParamState = {}

function SWEP:DoPoseParams()
    local vm = self:GetVM()

    if !vm or !IsValid(vm) then return end

    for i, k in pairs(self.PoseParamState) do
        vm:SetPoseParameter(i, k)
    end
end

function SWEP:ThinkAnimation()
    if CLIENT then 
        local seqprox = self:GetSequenceProxy()

        if seqprox != 0 then
            for _, wm in ipairs({true, false}) do
                local mdl = self:GetAnimationProxyModel(wm)

                if !IsValid(mdl) then continue end

                mdl:SetSequence(self:GetSequenceIndex())
                mdl:SetCycle(self:GetSequenceCycle())

                if seqprox == self.LHIKModelAddress then
                    local lhik_mdl

                    if wm then
                        lhik_mdl = self.LHIKModelWM
                    else
                        lhik_mdl = self.LHIKModel
                    end

                    if !lhik_mdl then return end

                    lhik_mdl:SetSequence(self:GetSequenceIndex())
                    lhik_mdl:SetCycle(self:GetSequenceCycle())
                end

                if seqprox == self.RHIKModelAddress then
                    local rhik_mdl

                    if wm then
                        rhik_mdl = self.RHIKModelWM
                    else
                        rhik_mdl = self.RHIKModel
                    end

                    if !rhik_mdl then return end

                    rhik_mdl:SetSequence(self:GetSequenceIndex())
                    rhik_mdl:SetCycle(self:GetSequenceCycle())
                end

                local anim_mdl = self:GetAnimationProxyGunDriver()

                if IsValid(anim_mdl) then
                    anim_mdl:SetSequence(self:GetSequenceIndex())
                    anim_mdl:SetCycle(self:GetSequenceCycle())
                end
            end
        end
    end

    local mult = self:GetSequenceSpeed()

    self:SetSequenceCycle(self:GetSequenceCycle() + (FrameTime() * mult))
end

function SWEP:FireAnimationEvent(pos, ang, event, options, source)
    if self.SuppressDefaultEvents then return true end
end

function SWEP:HandleAnimEvent(event, eventtime, cycle, type, options)
    if self.SuppressDefaultEvents then return true end
end