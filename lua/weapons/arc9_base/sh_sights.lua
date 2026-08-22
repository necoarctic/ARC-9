function SWEP:GetSightDelta()
    return self:GetSightAmount()
end

function SWEP:EnterSights()
    if self:GetSprintAmount() > 0.5 then return end
    if !self:GetProcessedValue("HasSights", true) then return end
    if self:GetCustomize() then return end
    if !self:GetProcessedValue("ReloadInSights", true) and self:GetReloading() and self:GetAnimLockTime() > CurTime() then return end
    if self:GetHolsterTime() > 0 then return end
    if self:GetProcessedValue("UBGLInsteadOfSights", true) then return end
    if self:GetSafe() then return end
    if self.SightsInterruptInspect and self:GetInspecting() then self:CancelInspect() end
    if self:GetAnimLockTime() > CurTime() and !self:GetReloading() then return end -- i hope this won't cause any issues later
    if self:GetValue("UBGL") and self:GetOwner():KeyDown(IN_USE) then return end
    if self:GetIsNearWall() and math.abs(self:GetOwner():GetNW2Float("leaning_fraction", 0)) < 0.1 then return end -- leaning mod support
    if self:HasAnimation("bash") and self.SetNextAiming then
        if self.SetNextAiming > CurTime() then return end
    end

    self:SetInSights(true)
    if IsFirstTimePredicted() then
        local soundtab1 = {
            name = "entersights",
            sound = self:RandomChoice(self:GetProcessedValue("EnterSightsSound", true)),
            channel = ARC9.CHAN_FIDDLE,
        }

        self:PlayTranslatedSound(soundtab1)
    end

    if !self:StillWaiting() or self.NoFireDuringSighting then
        if !(self.SightIsAlsoBipodAnims and self:GetBipod()) then
            if self:GetProcessedValue("InstantSightIdle", true) then
                self:PlayAnimation("idle")
            else
                local anim = self:TranslateAnimation("enter_sights")
                local mult = self:GetProcessedValue("AimDownSightsTime") -- Incorrectly uses a time as a multiplier! Preserved for legacy behavior
                if self:GetAnimationEntry(anim).NoStatAffectors then
                    mult = 1
                end
                self:PlayAnimation(anim, mult, self.NoFireDuringSighting, nil, nil, true)
            end
        end
    end

    self:SetShouldHoldType()
end

function SWEP:ExitSights()
    if self:GetInSights() then
        self:SetInSights(false)

        if IsFirstTimePredicted() then
            local soundtab1 = {
                name = "exitsights",
                sound = self:RandomChoice(self:GetProcessedValue("ExitSightsSound", true)),
                channel = ARC9.CHAN_FIDDLE,
            }

            self:PlayTranslatedSound(soundtab1)
        end

        if !self:StillWaiting() or (self.NoFireDuringSighting and !self:GetJammed()) then
            if !(self.SightIsAlsoBipodAnims and self:GetBipod()) then
                if self:GetProcessedValue("InstantSightIdle", true) then
                    self:PlayAnimation("idle")
                else
                    local anim = self:TranslateAnimation("exit_sights")
                    local mult = self:GetProcessedValue("AimDownSightsTime") -- Incorrectly uses a time as a multiplier! Preserved for legacy behavior
                    if self:GetAnimationEntry(anim).NoStatAffectors then
                        mult = 1
                    end
                    self:PlayAnimation(anim, mult, self.NoFireDuringSighting, nil, nil, true)
                end
            end
        end
    end

    self:SetShouldHoldType()
end

function SWEP:ToggleADS()
    return self:GetOwner():GetInfoNum("arc9_toggleads", 0) >= 1
end

SWEP.MultiSightTable = {
    -- {
    --     Pos = Vector(0, 0, 0),
    --     Ang = Angle(0, 0, 0)
    -- }
}

function SWEP:BuildMultiSight()
    if game.SinglePlayer() then self:CallOnClient("BuildMultiSight", "") end
    self.MultiSightTable = {}
    local modularironsights = {}

    local keepbaseirons = true
    local keepmodularirons = true

    -- local dev3 = ARC9.Dev(3)
    local dev3 = false

    for i, slottbl in ipairs(self:GetSubSlotList()) do
        if !slottbl.Installed then continue end
        if slottbl.BlockSights then continue end
        local atttbl = self:GetFinalAttTable(slottbl)

        if atttbl.Sights then
            local isirons = false
            local kbi = false

            for _, sight in pairs(atttbl.Sights) do
                if !self:GetUBGL() and sight.UBGLOnly then continue end
                if self:GetUBGL() and self:GetProcessedValue("UBGLExclusiveSights", true) and !sight.UBGLOnly then continue end
                local s = {}

                if CLIENT then
                    if dev3 then
                        s = self:GenerateAutoSight({
                            Pos = Vector(GetConVar("arc9_dev_irons_x"):GetFloat(), GetConVar("arc9_dev_irons_y"):GetFloat(), GetConVar("arc9_dev_irons_z"):GetFloat()),
                            Ang = Angle(GetConVar("arc9_dev_irons_pitch"):GetFloat(), GetConVar("arc9_dev_irons_yaw"):GetFloat(), GetConVar("arc9_dev_irons_roll"):GetFloat()),
                            ViewModelFOV = 40,
                            Magnification = 1.1
                        }, slottbl)
                    else
                        s = self:GenerateAutoSight(sight, slottbl)
                    end
                end

                if sight.Disassociate then s.Disassociate = true end
                if sight.NoSensAdjustment then s.NoSensAdjustment = true end

                s.CrosshairInSights = sight.CrosshairInSights

                s.atttbl = atttbl
                if sight.ExtraSightData then
                    s.atttbl = table.Copy(atttbl)
                    table.Merge(s.atttbl, sight.ExtraSightData)
                    s.ExtraSightData = sight.ExtraSightData
                end

                s.OnSwitchToSight = sight.OnSwitchToSight
                s.OnSwitchFromSight = sight.OnSwitchFromSight

                if dev3 then
                    s.OriginalSightTable = {
                        Pos = Vector(GetConVar("arc9_dev_irons_x"):GetFloat(), GetConVar("arc9_dev_irons_y"):GetFloat(), GetConVar("arc9_dev_irons_z"):GetFloat()),
                        Ang = Angle(GetConVar("arc9_dev_irons_pitch"):GetFloat(), GetConVar("arc9_dev_irons_yaw"):GetFloat(), GetConVar("arc9_dev_irons_roll"):GetFloat()),
                        ViewModelFOV = 40,
                        Magnification = 1.1
                    }
                else
                    s.OriginalSightTable = sight
                end
                s.slottbl = slottbl
                s.ViewModelFOV = sight.ViewModelFOV
                s.InvertColors = sight.InvertColors or false

                if sight.DeferSights then
                    if (slottbl.SubAttachments or {})[1] then
                        s.slottbl = slottbl.SubAttachments[1]
                    end
                end

                if sight.IsIronSight then
                    table.insert(modularironsights, s)
                    isirons = true
                else
                    table.insert(self.MultiSightTable, s)
                end

                if sight.Blur == false then s.Blur = false end -- false exactly, not nil because nil is yes

                if sight.KeepBaseIrons then
                    kbi = true
                end

                if self.ScrollLevels[#self.MultiSightTable] then
                    s.ScrollLevel = self.ScrollLevels[#self.MultiSightTable]
                end
            end

            if !kbi and !slottbl.KeepBaseIrons and !atttbl.KeepBaseIrons then
                keepbaseirons = false

                if !isirons then
                    keepmodularirons = false
                end
            end
        end
    end

    if keepbaseirons then
        local tbl = {}
        if dev3 then
            table.insert(tbl, {
                Pos = Vector(GetConVar("arc9_dev_irons_x"):GetFloat(), GetConVar("arc9_dev_irons_y"):GetFloat(), GetConVar("arc9_dev_irons_z"):GetFloat()),
                Ang = Angle(GetConVar("arc9_dev_irons_pitch"):GetFloat(), GetConVar("arc9_dev_irons_yaw"):GetFloat(), GetConVar("arc9_dev_irons_roll"):GetFloat()),
                ViewModelFOV = 40,
                Magnification = 1.1
            })
        else
            table.insert(tbl, self:GetProcessedValue("IronSights"))
        end
        tbl[1].BaseSight = true
        table.Add(tbl, self.MultiSightTable)
        self.MultiSightTable = tbl
    end

    if keepmodularirons then
        table.Add(self.MultiSightTable, modularironsights)
    end

    if self:GetMultiSight() > #self.MultiSightTable then
        self:SetMultiSight(1)
    end
end

function SWEP:SwitchMultiSight(amt)
    if self.NextSightSwitch and self.NextSightSwitch > CurTime() then return end
    self.NextSightSwitch = CurTime() + 0.15

    if self.SwitchSightTime and self.SwitchSightTime > CurTime() then
        if self.SwitchSightDP then self.SwitchSightDP = 0 end
    end

    if game.SinglePlayer() then
        self:CallOnClient("InvalidateCache")
    end

    amt = amt or 1
    local old_msi = self:GetMultiSight()
    msi = old_msi
    msi = msi + amt

    if msi > #self.MultiSightTable then
        msi = 1
    elseif msi <= 0 then
        msi = #self.MultiSightTable
    end

    self:SetMultiSight(msi)

    self:RunHook("Hook_SwitchSight", self.MultiSightTable[msi])

    if self.MultiSightTable[msi] then
        if self.MultiSightTable[msi].OnSwitchToSight then
            self.MultiSightTable[msi].OnSwitchToSight(self, self.MultiSightTable[msi].slottbl)
        end

        if self.MultiSightTable[old_msi] and self.MultiSightTable[old_msi].OnSwitchFromSight then
            self.MultiSightTable[old_msi].OnSwitchFromSight(self, self.MultiSightTable[msi].slottbl)
        end
    end

    self:InvalidateCache()

    if msi != old_msi then
        if self:StillWaiting() then return end

        if (self.MultiSightTable[old_msi].atttbl or {}).ID == (self.MultiSightTable[msi].atttbl or {}).ID then
            if !self:GetUBGL() then -- for me
                self:PlayAnimation("switchsights", 1, false)
            end
        end
    end
end

do
    local ENTITY = FindMetaTable("Entity")
    local entityGetOwner = ENTITY.GetOwner
    local entitySetPoseParameter = ENTITY.SetPoseParameter

    local PLAYER = FindMetaTable("Player")
    local playerKeyDown = PLAYER.KeyDown
    local playerKeyPressed = PLAYER.KeyPressed

    local swepGetIsNearWall = SWEP.GetIsNearWall
    local swepToggleADS = SWEP.ToggleADS
    local swepExitSights = SWEP.ExitSights
    local swepEnterSights = SWEP.EnterSights
    local swepGetBipodAmount = SWEP.GetBipodAmount
    local swepGetSprintAmount = SWEP.GetSprintAmount
    local swepBuildMultiSight = SWEP.BuildMultiSight
    local swepSwitchMultiSight = SWEP.SwitchMultiSight
    local dtapconvar = GetConVar("arc9_dtap_sights")
    local cvarGetBool = FindMetaTable("ConVar").GetBool

    function SWEP:ThinkSights()
        local swepDt = self.dt

        local sighted = swepDt.InSights
        if swepDt.Safe or swepGetIsNearWall(self) then
            sighted = false
        end

        local oldamt = swepDt.SightAmount
        local amt = 0

        if !(!sighted and oldamt == 0) and !(sighted and oldamt == 1) then
            amt = math.Approach(oldamt, sighted and 1 or 0, FrameTime() / self:GetProcessedValue("AimDownSightsTime"))
        elseif sighted and oldamt == 1 then amt = 1 end
        
        if oldamt ~= amt then
            self:SetSightAmount(amt)
        end

        local owner = entityGetOwner(self)
        local toggle = swepToggleADS(self)
        local inatt = playerKeyDown(owner, IN_ATTACK2)
        local pratt = playerKeyPressed(owner, IN_ATTACK2)

        if toggle then
            if sighted and pratt then
                swepExitSights(self)
            elseif not sighted and (inatt and swepDt.SprintAmount > 0 or pratt) then
                self:EnterSights()
            end

            if pratt then
                self:BuildMultiSight()
            end
        else
            if sighted and !inatt then
                swepExitSights(self)
            elseif not sighted and inatt then
                self:EnterSights()
                self:BuildMultiSight()
            end
        end

        if sighted and playerKeyPressed(owner, ARC9.IN_SWITCHSIGHTS) then
            swepSwitchMultiSight(self)
        end

        if cvarGetBool(dtapconvar) then -- Double-Tap Switching Code
            if sighted and playerKeyPressed(owner, IN_USE) and !self:StillWaiting() then
                self.SwitchSightDP = (self.SwitchSightDP or 0) + 1

                if self.SwitchSightDP > 0 then
                self.SwitchSightTime = CurTime() + 0.3
                    if self.SwitchSightDP == 2 then
                        swepSwitchMultiSight(self)
                    end
                end
            end

            if self.SwitchSightDP and self.SwitchSightDP > 2 then
                self.SwitchSightDP = 1
            end

            if self.SwitchSightTime and CurTime() > self.SwitchSightTime then
                if self.SwitchSightDP then self.SwitchSightDP = 0 end
            end
        end

        if self.HasSightsPoseparam then
            if CLIENT then
                entitySetPoseParameter(self:GetVM(), "sights", amt)
            end
            entitySetPoseParameter(self:GetVM(), "sights", math.max(swepDt.SightAmount, swepGetBipodAmount(self)))
        end
    end
end

function SWEP:GetSight()
    -- if ARC9.Dev(2) then
    --     self:BuildMultiSight() -- this is what was fixing toggle sights
    -- end
    -- if !self.MultiSightTable and self:GetValue("Sights") then self:BuildMultiSight() end
    return self.MultiSightTable[self:GetMultiSight()] or self:GetValue("IronSights")
end

local arc9_cheapscopes = GetConVar("arc9_cheapscopes")

function SWEP:GetRTScopeFOV()
    local sights = self:GetSight()

    if !sights then return self:GetOwner():GetFOV() end

    local realzoom = self:GetRealZoom(sights)

    local ratio = ((sights.atttbl and sights.atttbl.ScopeScreenRatio or self.ScopeScreenRatio) or 0.5) - (!self.ExtraSightDistanceNoRT and sights.ExtraSightDistance or 0) * 0.045
    if self.PeekingIsSight and self.Peeking then ratio = ratio + 0.2 end
    local vmfovratio = self:IsCheapScope(sights) and sights.Magnification or self:GetSmoothedFOVMag() -- sights.Magnification
    local funnyfov = self:ScaleFOVByWidthRatio(self:GetOwner():GetFOV(), 1 / vmfovratio * ratio / 1.5 / realzoom)

    return ARC9_ENABLE_NEWSCOPES_MEOW and realzoom or funnyfov
end

function SWEP:GetRTScopeMagnification()
    local sights = self:GetSight()

    if !sights then return 2 end

    local realzoom = self:GetRealZoom(sights)

    return realzoom or 2
end

SWEP.ScrollLevels = {}

function SWEP:Scroll(amt)
    if self:GetOwner():KeyDown(IN_USE) then return end
    local sights = self:GetSight() or {}

    local atttbl = sights.atttbl

    if !atttbl then return end
    if !atttbl.RTScopeAdjustable then return end
    if !atttbl.RTScopeFOVMax and !atttbl.RTScopeMagnificationMax then return end
    if !atttbl.RTScopeFOVMin and !atttbl.RTScopeMagnificationMin then return end

    local scrolllevel = sights.ScrollLevel or 0
    local old = scrolllevel

    sights.ScrollLevel = scrolllevel + (amt / atttbl.RTScopeAdjustmentLevels)

    sights.ScrollLevel = math.Clamp(sights.ScrollLevel, 0, 1)

    self.ScrollLevels[self:GetMultiSight()] = sights.ScrollLevel

    if old != sights.ScrollLevel and atttbl.ZoomSound != false then
        local soundtab1 = {
            name = "zoom",
            sound = atttbl.ZoomSound or "arc9/useatt.ogg",
            pitch = math.Rand(95, 105),
            vol = 1,
            chan = CHAN_ITEM
        }

        self:PlayTranslatedSound(soundtab1)
    end
end

function SWEP:IsScoping()
    local sight = self:GetSight()
    
    local atttbl

    if sight.BaseSight then
        atttbl = self:GetTable()
    else
        atttbl = self:GetFinalAttTable(sight.slottbl)
    end

    if sight.ExtraSightData then
        atttbl = table.Copy(atttbl)
        table.Merge(atttbl, sight.ExtraSightData)
    end

    -- return self:GetSightAmount() > 0 and atttbl.RTScope and atttbl
    return atttbl.RTScope and atttbl
end