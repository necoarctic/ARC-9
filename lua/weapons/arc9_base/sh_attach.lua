SWEP.CustomizeDelta = 0
local sp = game.SinglePlayer()


function SWEP:Attach(addr, att, silent)
    local slottbl = self:LocateSlotFromAddress(addr)
    if !slottbl then -- to not error and reset menu
        self.BottomBarAddress = nil
        self.BottomBarMode = 0
        self:CreateHUD_Bottom()
        return false
    end
    if (slottbl.Installed == att) then return false end
    if !self:CanAttach(addr, att) then return false end
    local atttbl = ARC9.GetAttTable(att) or {}

    self:DetachAllFromSubSlot(addr, true)

    slottbl.Installed = att
    slottbl.ToggleNum = 1

    if !silent then
        self:PlayTranslatedSound({
            name = "install",
            sound = atttbl.InstallSound or slottbl.InstallSound or "arc9/newui/ui_part_install.ogg"
        })
    end

    self:PruneAttachments()
    self:PostModify()

    return true
end

function SWEP:Detach(addr, silent)
    local slottbl = self:LocateSlotFromAddress(addr)
    if !slottbl or !slottbl.Installed then return false end
    if !self:CanDetach(addr) then return false end
    local atttbl = ARC9.GetAttTable(slottbl.Installed) or {}

    slottbl.Installed = nil

    if !silent then
        self:PlayTranslatedSound({
            name = "uninstall",
            sound = atttbl.UninstallSound or slottbl.UninstallSound or "arc9/newui/ui_part_uninstall.ogg"
        })
    end

    self:PruneAttachments()

    self:PostModify()

    return true
end

function SWEP:DetachAllFromSubSlot(addr, silent)
    local slottbl = self:LocateSlotFromAddress(addr)

    self:Detach(addr, silent)

    if slottbl.MergeSlotAddresses then
        for _, addr2 in ipairs(slottbl.MergeSlotAddresses) do
            self:Detach(addr2, silent)
        end
    end
end

function SWEP:GetFilledMergeSlot(addr)
    local slottbl = self:LocateSlotFromAddress(addr)

    if !slottbl then return {} end

    if slottbl.Installed then
        return slottbl
    end

    if slottbl.MergeSlots then
        for _, merge_addr in ipairs(slottbl.MergeSlotAddresses) do
            local mergeslot = self:LocateSlotFromAddress(merge_addr)

            if mergeslot.Installed then
                return mergeslot
            end
        end
    end

    return slottbl
end

SWEP.LastClipSize = 0
SWEP.LastAmmo = ""

local function updatehookp(self, base)
    if IsValid(self) then
        self.PrintName = self:RunHook("HookP_NameChange", ARC9:UseTrueNames() and base.TrueName or base.PrintName)
        self.Description = self:RunHook("HookP_DescriptionChange", base.Description)
        self.Class = self:RunHook("HookP_ClassChange", base.Class)
    end
end

function SWEP:PostModify(toggleonly)
    self:InvalidateCache()

    self.AffectorsCache = nil -- fixes printnames being late
    self.ElementsCache = nil

    if !toggleonly then
        self.ScrollLevels = {} -- moved from invalidcache
        self:CancelReload()
        -- self:PruneAttachments()
        self:SetNthReload(0)
    end

    local client = self:GetOwner()
    local validplayerowner = IsValid(client) and client:IsPlayer()

    local base = baseclass.Get(self:GetClass())

    if ARC9:UseTrueNames() then
        self.PrintName = base.TrueName
        self.PrintName = self:GetValue("TrueName")
    else
        self.PrintName = base.PrintName
        self.PrintName = self:GetValue("PrintName")
    end

    if !self.PrintName then
        self.PrintName = base.PrintName
        self.PrintName = self:GetValue("PrintName")
    end

    self.Description = base.Description
    updatehookp(self, base)
    timer.Simple(0.1, function() updatehookp(self, base) end)

    if CLIENT then
        -- self:PruneAttachments()
        if !toggleonly then -- bruh
            self:SendWeapon()
            self:KillModel()
            self:SetupModel(true)
            self:SetupModel(false)
            self:SavePreset()
        else
            timer.Simple(0, function() self:KillFlashlights() end)
            self:CreateFlashlights()
        end

        self:BuildMultiSight()
        self.InvalidateSelectIcon = true
    else
        if validplayerowner then
            if self:GetValue("ToggleOnF") and client:FlashlightIsOn() then
                client:Flashlight(false)
            end

            timer.Simple(0, function() -- PostModify gets called after each att attached
                if (self.LastAmmo != self:GetValue("Ammo") or self.LastClipSize != math.Round(self:GetValue("ClipSize"))) and self.AlreadyGaveAmmo then
                        self:Unload(self.LastAmmo)
                        self:SetRequestReload(true)
                elseif !self.AlreadyGaveAmmo then
                        self:SetClip1(math.Round(self:GetProcessedValue("ClipSize")))
                        self.AlreadyGaveAmmo = true
                end

                self.LastAmmo = self:GetValue("Ammo")
                self.LastClipSize = math.Round(self:GetProcessedValue("ClipSize"))
            end)


            if self:GetValue("UBGL") then
                if !self.AlreadyGaveUBGLAmmo then
                    self:SetClip2(self:GetMaxClip2())
                    self.AlreadyGaveUBGLAmmo = true
                end

                if (self.LastUBGLAmmo) then
                    if (self.LastUBGLAmmo != self:GetValue("UBGLAmmo") or self.LastUBGLClipSize != self:GetValue("UBGLClipSize")) then
                        client:GiveAmmo(self:Clip2(), self.LastUBGLAmmo)
                        self:SetClip2(0)
                        self:SetRequestReload(true)
                    end
                end

                self.LastUBGLAmmo = self:GetValue("UBGLAmmo")
                self.LastUBGLClipSize = self:GetValue("UBGLClipSize")


            end

            if self:GetProcessedValue("BottomlessClip", true) then
                self:RestoreClip()
            end
        end
    end

    if self:GetUBGL() and !self:GetProcessedValue("UBGL") then
        self:ToggleUBGL(false)
    end

    if sp and validplayerowner then
        self:CallOnClient("RecalculateIKGunMotionOffset")
    end

    self:SetupAnimProxy()

    self:SetBaseSettings()

    if self:GetAnimLockTime() <= CurTime() then
        self:Idle()
    end
end

local mathApproach = math.Approach
local FrameTime = FrameTime
local IsFirstTimePredicted = IsFirstTimePredicted
local ENTITY = FindMetaTable("Entity")
local entityGetOwner = ENTITY.GetOwner
local PLAYER = FindMetaTable("Player")
local entityKeyPressed = PLAYER.KeyPressed
local entityKeyDown = PLAYER.KeyDown

function SWEP:ThinkCustomize()
    local owner = entityGetOwner(self)
    local swepDt = self.dt

    if entityKeyPressed(owner, ARC9.IN_CUSTOMIZE) and !entityKeyDown(owner, IN_USE) and !swepDt.GrenadePrimed then
        self:ToggleCustomize(!swepDt.Customize)
    end

    if sp or (CLIENT and IsFirstTimePredicted()) then
        local cd = self.CustomizeDelta
        if swepDt.Customize then
            if cd < 1 then
                self.CustomizeDelta = mathApproach(cd, 1, FrameTime() * 6.666666666666667)
            end
        else
            if cd > 0 then
                self.CustomizeDelta = mathApproach(cd, 0, FrameTime() * 6.666666666666667)
            end
        end
    end
end

function SWEP:ToggleCustomize(on)
    if on == self:GetCustomize() then return end
    if self.NotAWeapon then return end

    self:SetCustomize(on)

    self:SetShouldHoldType()

    self:SetInSights(false)

    if !on then
        if self:HasAnimation("postcustomize") then
            self:CancelReload()
            self:PlayAnimation("postcustomize", 1, true)
        end
    end
end

function SWEP:GetAttBlocked(atttbl)
    local eles = self:GetElements()

    if atttbl.ExcludeElements then
        for _, group in ipairs(atttbl.ExcludeElements) do
            if !istable(group) then
                group = {group}
            end

            local ok = false
            for _, ele in ipairs(group) do
                if !eles[ele] then ok = true break end
            end

            if !ok then return true end
        end
    end

    if atttbl.RequireElements then
        for _, group in ipairs(atttbl.RequireElements) do
            if !istable(group) then
                group = {group}
            end

            local ok = false
            for _, ele in ipairs(group) do
                if !eles[ele] then ok = true break end
            end

            if !ok then return false end
        end

        return true
    end

    return false
end

local arc9_atts_anarchy = GetConVar("arc9_atts_anarchy")

function SWEP:SlotInvalid(slottbl)
    if arc9_atts_anarchy:GetBool() then return false end

    local eles = self:GetElements()

    if slottbl.ExcludeElements then
        for _, group in ipairs(slottbl.ExcludeElements) do
            if !istable(group) then
                group = {group}
            end

            local ok = false
            for _, ele in ipairs(group) do
                if !eles[ele] then ok = true break end
            end

            if !ok then return true end
        end
    end

    local totalcount = self:CountAttachments()

    if totalcount > ARC9.GetMaxAtts() then return true end

    if slottbl.RequireElements then
        for _, group in ipairs(slottbl.RequireElements) do
            if !istable(group) then
                group = {group}
            end

            local ok = true
            for _, ele in ipairs(group) do
                if !eles[ele] then ok = false break end
            end

            if !ok then return true end
        end
    end

    local att = slottbl.Installed

    if !att then return false end

    if self:RunHook("Hook_BlockAttachment", {att = att, slottbl = slottbl}) == false then return true end

    if (slottbl.RejectAttachments or {})[att] then return true end

    local cat = slottbl.Category

    if !istable(cat) then
        cat = {cat}
    end

    local atttbl = self:GetFinalAttTable(slottbl)

    if atttbl.Max then
        local count = self:CountAttachments(att)

        if slottbl.Installed then
            local installed_atttbl = self:GetFinalAttTable(slottbl)

            if slottbl.Installed == installed_atttbl.InvAtt then
                count = count - 1
            end
        end

        if count > atttbl.Max then return true end
    end

    if self:GetAttBlocked(atttbl) then return true end
    if atttbl.AdminOnly and IsValid(self:GetOwner()) and (self:GetOwner():IsNPC() or !self:GetOwner():IsAdmin()) then return true end

    local attcat = atttbl.Category

    if attcat == "*" then return false end

    if !istable(attcat) then
        attcat = {attcat}
    end

    local cat_true = false

    for _, c in ipairs(attcat) do
        if (slottbl.RejectAttachments or {})[c] then return false end
        if table.HasValue(cat, c) then
            cat_true = true
        end
    end

    return !cat_true
end

function SWEP:GetSlotBlocked(slottbl)
    local eles = self:GetElements()

    if slottbl.ExcludeElements then
        for _, group in ipairs(slottbl.ExcludeElements) do
            if !istable(group) then
                group = {group}
            end

            local ok = false
            for _, ele in ipairs(group) do
                if !eles[ele] then ok = true break end
            end

            if !ok then return true end
        end
    end

    local totalcount = self:CountAttachments()

    if totalcount >= ARC9.GetMaxAtts() then return true end

    if slottbl.RequireElements then
        for _, group in ipairs(slottbl.RequireElements) do
            if !istable(group) then
                group = {group}
            end

            local ok = true
            for _, ele in ipairs(group) do
                if !eles[ele] then ok = false break end
            end

            if !ok then return true end
        end
    end

    return false
end

-- Find any available attachment for the slot the player owns, in no specific order.
function SWEP:FirstAttForSlot(slottbl)
    local atts = ARC9.GetAttsForCats(slottbl.Category)
    for _, v in ipairs(atts) do
        if ARC9:PlayerGetAtts(self:GetOwner(), v, self) > 0 then return v end
    end
    return false
end

-- When attaching or detaching, changes in elements may cause a slot to be enabled when it previously wasn't.
-- We want to find all slots of this type that are Integral so we can fill in an attachment for it.
-- "att" is the attachment to add, set to false for detach
-- Note that the returned slots may not all have an address; subslots that are about to be added don't have one yet
function SWEP:GetDependentIntegralSlots(addr, att, slottbl)
    slottbl = slottbl or self:LocateSlotFromAddress(addr)
    local atttbl = att and ARC9.GetAttTable(att) or ARC9.GetAttTable(slottbl.Installed)

    local eles = {}

    if att then
        -- About to attach; InstalledElements will be involved
        for _, e in pairs(slottbl.InstalledElements or {}) do
            eles[e] = true
        end
        eles[att] = true
    else
        -- About to detach, UnInstalledElements will be involved
        for _, e in pairs(slottbl.UnInstalledElements or {}) do
            eles[e] = true
        end
    end

    -- The attachment's elements will be involved regardless of attaching or detaching
    if atttbl then
        for _, e in pairs(atttbl.ActivateElements or {}) do
            eles[e] = true
        end
    end

    -- If another slot is providing the element too, our changes will have no effect
    local othereles = self:GetElements({[addr] = true})
    for _, e in pairs(othereles) do
        eles[e] = nil
    end

    local slots = {}

    for _, tbl in ipairs(self:GetSubSlotList()) do
        if !tbl.Integral then continue end

        local affected = false
        if att then
            -- If the elements we are trying to add will enable this slot, it is affected
            local required = tbl.RequireElements
            if !istable(required) then required = {required} end
            for _, e in ipairs(required) do
                if eles[e] then
                    affected = true
                    break
                end
            end
        else
            -- If the element we are about to remove is keeping the slot disabled, it is affected
            local excluded = tbl.ExcludeElements
            if !istable(excluded) then excluded = {excluded} end
            for _, e in ipairs(excluded) do
                if eles[e] then
                    affected = true
                    break
                end
            end
        end

        -- TODO: Consider domino effect caused by the slot about to be added?
        if affected then
            slots[#slots + 1] = tbl
        end
    end

    -- Any subslots added by the attachment may need Integral attachments
    if att then
        for _, slot in ipairs(atttbl.Attachments or {}) do
            if slot.Integral then
                slots[#slots + 1] = slot
            end
        end
    end

    return slots
end

function SWEP:GetSlotMissingDependents(addr, att, slottbl)
    self.DependentCache = self.DependentCache or {}
    if !self.DependentCache[addr] or (self.DependentCache[addr][att] or {0, false})[1] != CurTime() then
        self.DependentCache[addr] = self.DependentCache[addr] or {}
        self.DependentCache[addr][att] = {CurTime(), false}
        for _, v in ipairs(self:GetDependentIntegralSlots(addr, att, slottbl)) do
            if !self:FirstAttForSlot(v) then
                self.DependentCache[addr][att][2] = true
                break
            end
        end
    end
    return self.DependentCache[addr][att][2]
end

local arc9_atts_nocustomize = GetConVar("arc9_atts_nocustomize")

function SWEP:WouldConflict(att, atttbl)
    local eles = { [att] = true }

    if atttbl.ActivateElements then
        for _, ele in pairs(atttbl.ActivateElements) do
            eles[ele] = true
        end
    end

    for _, slot in ipairs(self:GetSubSlotList()) do
        if !slot.Installed then continue end

        local installed = ARC9.GetAttTable(slot.Installed)
        if !installed or !installed.ExcludeElements then continue end

        for _, group in ipairs(installed.ExcludeElements) do
            local req = istable(group) and group or {group}

            local conflict = true

            for _, ele in ipairs(req) do
                if !eles[ele] then
                    conflict = false
                    break
                end
            end

            if conflict then return true end
        end
    end

    return false
end

function SWEP:CanAttach(addr, att, slottbl, ignorecount)
    if ARC9.Blacklist[att] then return false end

    if arc9_atts_anarchy:GetBool() then return true end
    if arc9_atts_nocustomize:GetBool() then return false end

    local atttbl = ARC9.GetAttTable(att)
    local invatt = atttbl.InvAtt or att

    slottbl = slottbl or self:LocateSlotFromAddress(addr)

    local curtbl = ARC9.GetAttTable(slottbl.Installed) or {}

    if !ignorecount and ARC9:PlayerGetAtts(self:GetOwner(), att, self) == 0 and (curtbl.InvAtt or slottbl.Installed) != invatt then return false end

    if self:RunHook("Hook_BlockAttachment", {att = att, slottbl = slottbl}) == false then return false end

    if self:GetSlotBlocked(slottbl) then return false end
    if self:WouldConflict(att, atttbl) then return false end

    if (slottbl.RejectAttachments or {})[att] then return false end

    local cat = slottbl.Category

    if !istable(cat) then
        cat = {cat}
    end

    if atttbl.Max then
        local count = self:CountAttachments(att)

        if slottbl.Installed then
            local installed_atttbl = self:GetFinalAttTable(slottbl)

            if slottbl.Installed == installed_atttbl.InvAtt then
                count = count - 1
            end
        end

        if count >= atttbl.Max then return false end
    end

    if self:GetAttBlocked(atttbl) then return false end
    if atttbl.AdminOnly and !self:GetOwner():IsAdmin() then return false end

    -- If attaching will enable any Integral slots, we must own something to put in there
    if self:GetSlotMissingDependents(addr, att, slottbl) then return false end

    local attcat = atttbl.Category

    if attcat == "*" then return true end

    if !istable(attcat) then
        attcat = {attcat}
    end

    local cat_true = false

    for _, c in ipairs(attcat) do
        if (slottbl.RejectAttachments or {})[c] then return false end
        if table.HasValue(cat, c) then
            cat_true = true
        end
    end

    if !cat_true then return false end

    return true
end

function SWEP:CanDetach(addr)
    if arc9_atts_nocustomize:GetBool() then return false end

    local slottbl = self:LocateSlotFromAddress(addr)

    if slottbl and slottbl.Integral then return false end

    if self:RunHook("Hook_CanDetachAttachment", {addr = addr, slottbl = slottbl}) == false then return false end

    return true
end

function SWEP:CountAttachments(countatt)
    local qty = 0

    for _, att in ipairs(self:GetAttachmentList()) do
        if !countatt then
            qty = qty + 1
        else
            if countatt == att then
                qty = qty + 1
            end
        end
    end

    return qty
end

function SWEP:ToggleAllStatsOnF()
    if self:GetReloading() then return true end

    local toggled = false

    for _, slottbl in ipairs(self:GetSubSlotList()) do
        if !slottbl.Installed then continue end

        local atttbl = self:GetFinalAttTable(slottbl)

        if !atttbl.ToggleStats then continue end
        if !atttbl.ToggleOnF then continue end

        toggled = true

        self:ToggleStat(slottbl.Address)
    end

    if toggled then
        self:RunHook("Hook_ToggleAtts")
        self:PostModify(true)
        return true
    end
end

SWEP.CachedToggleAttsStatus = nil

function SWEP:CanToggleAllStatsOnF()
    if self.CachedToggleAttsStatus != nil then
        return self.CachedToggleAttsStatus
    end

    local toggled = 0

    for _, slottbl in ipairs(self:GetSubSlotList()) do
        if !slottbl.Installed then continue end

        local atttbl = self:GetFinalAttTable(slottbl)

        if !atttbl.ToggleStats then continue end
        if !atttbl.ToggleOnF then continue end

        toggled = toggled + 1

        if toggled > 1 then
            break
        end
    end

    return toggled
end

function SWEP:ToggleStat(addr, val)
    val = val or 1
    local slottbl = self:LocateSlotFromAddress(addr)

    if !slottbl or !slottbl.Installed then return end

    local atttbl = self:GetFinalAttTableFromAddress(addr)

    if !atttbl.ToggleStats then return end

    slottbl.ToggleNum = (slottbl.ToggleNum or 1) + val

    if slottbl.ToggleNum > #atttbl.ToggleStats then
        slottbl.ToggleNum = 1
    elseif slottbl.ToggleNum < 1 then
        slottbl.ToggleNum = #atttbl.ToggleStats
    end
end
