function SWEP:ThinkTriggerSounds()
    if (!self.TriggerDownSound or self.TriggerDownSound == "") and (!self.TriggerUpSound or self.TriggerUpSound == "") then return end -- no fucking trigger sounds

    if self:GetAnimLockTime() > CurTime() then return end
    if self:StillWaiting() then return end
    if self:SprintLock() then return end
    if self:GetSafe() then return end
    local owner = self:GetOwner()
    local processedValue = self.GetProcessedValue

    if processedValue(self,"Throwable", true) then return end
    if processedValue(self,"PrimaryBash", true) then return end

    local volem = self.TriggerSoundSightVolume and Lerp(self:GetSightAmount(), self.TriggerSoundVolume, self.TriggerSoundSightVolume) or 1

    if owner:KeyReleased(IN_ATTACK) then

		if self.RecentMelee then 
			return 
		end

        local soundtab = {
            name = "triggerup",
            sound = self:RandomChoice(self.TriggerUpSound),
            channel = ARC9.CHAN_TRIGGER+7,
            volume = volem,
        }

        self:PlayTranslatedSound(soundtab)
    elseif owner:KeyPressed(IN_ATTACK) then
        if processedValue(self,"Bash", true) and owner:KeyDown(IN_USE) and !self:GetInSights() then return end

        local soundtab = {
            name = "triggerdown",
            sound = self:RandomChoice(self.TriggerDownSound),
            channel = ARC9.CHAN_TRIGGER+7,
            volume = volem,
        }

        self:PlayTranslatedSound(soundtab)
    end
end