function SWEP:TranslateAnimation(seq)
    if self:GetOwner():IsNPC() then return seq end

    local sds = self:GetProcessedValue("SuppressDefaultSuffixes", true)

    if !sds then
        if self:GetUBGL() and self:HasAnimation(seq .. "_ubgl") then
            seq = seq .. "_ubgl"
        end

        if self:GetGrenadePrimed() and self:HasAnimation(seq .. "_primed") then
            seq = seq .. "_primed"
        end

        if self:GetGrenadeTossing() and self:HasAnimation(seq .. "_toss") then
            seq = seq .. "_toss"
        end

        if self:GetInSights() and self:HasAnimation(seq .. "_iron") then
            seq = seq .. "_iron"
        end

        if self:GetInSights() and self:HasAnimation(seq .. "_sights") then
            seq = seq .. "_sights"
        end

        if self:GetBipod() then
            if !self.SightIsAlsoBipodAnims and self:HasAnimation(seq .. "_bipod") then
                seq = seq .. "_bipod"
            end

            if self.SightIsAlsoBipodAnims and self:HasAnimation(seq .. "_sights") then
                seq = seq .. "_sights"
            end
        end

        if !self:GetProcessedValue("SuppressSprintSuffix", true) and self:GetIsSprinting() and self:HasAnimation(seq .. "_sprint") then
            seq = seq .. "_sprint"
        elseif self:GetIsWalking() and self:HasAnimation(seq .. "_walk") then
            seq = seq .. "_walk"
        end

        local reloading = self:GetReloadFinishTime() > CurTime()
        local empty = !self:GetProcessedValue("SuppressEmptySuffix", true) and (self:Clip1() == 0 or (reloading and self:GetEmptyReload()))

        if empty and self:HasAnimation(seq .. "_empty") then
            seq = seq .. "_empty"
        end

        if empty and self:HasAnimation(seq .. "_glempty") then
            seq = seq .. "_glempty"
        end

        if self:GetUBGL() and self:HasAnimation(seq .. "_ubgl") then
            seq = seq .. "_ubgl"
        end

        if self:GetNeedsCycle() and self:HasAnimation(seq .. "_uncycled") then
            seq = seq .. "_uncycled"
        end

        if IsValid(self:GetDetonatorEntity()) and self:HasAnimation(seq .. "_detonator") then
            seq = seq .. "_detonator"
        end
    end

    local traq = self:RunHook("Hook_TranslateAnimation", seq) or seq

    if self:HasAnimation(traq) then
        seq = traq
    end

    if istable(seq) then
        seq["BaseClass"] = nil
        seq = seq[math.Round(util.SharedRandom("ARC9_animtr", 1, #seq))]
    end

    if self:HasAnimation("1_" .. seq, true) then -- if theres atleast 1 random seq
        local rando = {seq}

        local i = 1
        while self:HasAnimation(tostring(i) .. "_" .. seq, true) do
            table.insert(rando, tostring(i) .. "_" .. seq)
            i = i + 1
        end

        seq = rando[math.Round(util.SharedRandom("ARC9_animtr", 1, #rando))]
    end

    return seq
end

local alwayshave = {
    ["idle"] = true,
    ["fire"] = true,
}

function SWEP:HasAnimation(seq, lq)
    if alwayshave[seq] then return true end
    local seqr = self:RunHook("Hook_BlockHasAnimation", seq)

    if !seqr then return false end

    if self.Animations[seq] or self.IKAnimationProxy[seq] then
        return true
    end

    if lq then return false end

    local vm = self:GetVM()

    if !IsValid(vm) then return true end
    seq = vm:LookupSequence(seq)

    return seq != -1
end

function SWEP:GetAnimationTime(anim)
    local entry = self:GetAnimationEntry(anim)

    if !entry then return 0 end

    if entry.Time then return entry.Time end

    local seq = entry.Source

    if istable(seq) then seq = seq[1] end

    return self:GetSequenceTime(seq)
end

function SWEP:GetSequenceTime(seq)
    local vm = self:GetVM()
    if !IsValid(vm) then return 1 end
    seq = vm:LookupSequence(seq or "")

    return vm:SequenceDuration(seq)
end

function SWEP:GetAnimationEntry(seq)
    if self:HasAnimation(seq) then
        if self.IKAnimationProxy[seq] then
            return self.IKAnimationProxy[seq]
        else
            if self.Animations[seq] then
                return self.Animations[seq]
            elseif !self:GetProcessedValue("SuppressDefaultAnimations", true) then
                return {
                    Source = seq,
                    Time = self:GetSequenceTime(seq)
                }
            end
        end
    else
        return {}
    end
end

SWEP.IKAnimationProxy = {}

function SWEP:AddProxyToAnimProxyTable(tbl, model, atttbl, address)
    for anim, animtable in pairs(tbl) do
        local newanimtable = table.Copy(animtable)
        if !self.IKAnimationProxy[anim] then
            self.IKAnimationProxy[anim] = newanimtable
        else
            if (tbl.Priority or 0) > self.IKAnimationProxy[anim].Priority then
                self.IKAnimationProxy[anim] = newanimtable
            else
                continue
            end
        end

        newanimtable.ProxyAnimation = true
        newanimtable.Model = model
        newanimtable.Priority = newanimtable.Priority or 0
        newanimtable.ModelName = atttbl.Model
        newanimtable.Address = address
        newanimtable.MotionAttachment = atttbl.IKGunMotionQCA
        newanimtable.AlsoPlayBase = atttbl.IKAnimationAlsoPlayBase
    end
end

function SWEP:SetupAnimProxy()
    self.IKAnimationProxy = {}

    for _, slottbl in ipairs(self:GetSubSlotList()) do
        local atttbl = self:GetFinalAttTable(slottbl)

        if atttbl.IKAnimationProxy then
            self:AddProxyToAnimProxyTable(atttbl.IKAnimationProxy, slottbl.GunDriverModel or slottbl.VModel or slottbl.WModel, atttbl, slottbl.Address)
        end
    end
end