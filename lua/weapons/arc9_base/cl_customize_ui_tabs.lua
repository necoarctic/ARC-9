local ARC9ScreenScale = ARC9.ScreenScale
local deadzonex = GetConVar("arc9_hud_deadzonex")

local function tabWanted(self, def)
    if !def.condition then return true end
    local ok, res = pcall(def.condition, self)
    if !ok then
        ErrorNoHalt("[ARC9] Customize tab \"" .. tostring(def.id) .. "\" condition errored: " .. tostring(res) .. "\n")
        return false
    end
    return !!res
end

local buttonCache = {}

local function getTabButton(def)
    local btn = buttonCache[def.id]
    if btn and btn.def == def then return btn end

    btn = {
        title = def.title,
        registeredtab = def.id,
        def = def,
        cutcorner = 0,
        func = function(self2) self2:OpenRegisteredTab(def.id) end,
    }
    buttonCache[def.id] = btn
    return btn
end

function SWEP:SyncCustomizeTabs()
    if !ARC9.GetCustomizeTabs then return false end
    if self.WantToInvalidateCache then self:DoInvalidateCache() end

    local buttons = self.CustomizeButtons
    local activebtn = buttons[self.CustomizeTab + 1]
    local changed = false

    for i = #buttons, 1, -1 do
        local b = buttons[i]
        if b.registeredtab then
            local def = ARC9.CustomizeTabs[b.registeredtab]
            if !def or b.def != def or !tabWanted(self, def) then
                table.remove(buttons, i)
                changed = true
            end
        end
    end

    local pos = 1
    for i, b in ipairs(buttons) do
        if b.customize or b.personalize then pos = i + 1 end
    end

    for _, def in ipairs(ARC9.GetCustomizeTabs()) do
        local present = false
        for _, b in ipairs(buttons) do
            if b.registeredtab == def.id then present = true break end
        end

        if !present and tabWanted(self, def) then
            table.insert(buttons, pos, getTabButton(def))
            changed = true
        end

        if tabWanted(self, def) then pos = pos + 1 end
    end

    local newindex
    for i, b in ipairs(buttons) do
        if b == activebtn then newindex = i break end
    end
    self.CustomizeTab = newindex and newindex - 1 or 0

    return changed, newindex == nil
end

function SWEP:RefreshCustomizeTabs()
    if !self.CustomizeHUD or self.RemovingCustHud then return end
    if !IsValid(self.CustomizeHUD.lowerpanel) then return end

    local activebtn = self.CustomizeButtons[self.CustomizeTab + 1] or {}
    local changed, activeremoved = self:SyncCustomizeTabs()

    if changed then self:BuildCustomizeTabButtons() end

    if activeremoved then
        self.CustomizeButtons[self.CustomizeTab + 1].func(self)
    elseif activebtn.registeredtab then
        self:OpenRegisteredTab(activebtn.registeredtab, true)
    end
end

function SWEP:OpenRegisteredTab(id, keepsize)
    local def = ARC9.CustomizeTabs and ARC9.CustomizeTabs[id]
    local lowerpanel = self.CustomizeHUD and self.CustomizeHUD.lowerpanel
    if !def or !IsValid(lowerpanel) then return end

    if self.WantToInvalidateCache then self:DoInvalidateCache() end
    if !tabWanted(self, def) then
        self:RefreshCustomizeTabs()
        return
    end

    self:ClearTabPanel()

    local bg = vgui.Create("DPanel", lowerpanel)
    bg:SetPos(ARC9ScreenScale(4), ARC9ScreenScale(19))
    bg:SetSize(lowerpanel:GetWide() - ARC9ScreenScale(8), ARC9ScreenScale(74 + def.height - 24))
    bg.Paint = function() end
    bg:SetAlpha(0)
    bg:AlphaTo(255, 0.2, 0, nil)
    self.BottomBar = bg

    local ok, err = pcall(function()
        if def.build then
            def.build(self, bg)
        elseif def.options then
            local spec = def.options(self)
            if spec then ARC9.CreateOptionsPanel(bg, spec) end
        end
    end)
    if !ok then ErrorNoHalt("[ARC9] Customize tab \"" .. tostring(id) .. "\" failed to build: " .. tostring(err) .. "\n") end

    if keepsize then return end

    lowerpanel.Extended = nil
    self:ClosePresetMenu()

    lowerpanel:MoveTo(ARC9ScreenScale(19) + deadzonex:GetInt(), ScrH() - ARC9ScreenScale(93 + def.height), 0.2, 0, 0.5, nil)
    lowerpanel:SizeTo(ScrW() - ARC9ScreenScale(38) - deadzonex:GetInt() * 2, ARC9ScreenScale(74 + def.height), 0.2, 0, 0.5, nil)

    lowerpanel:AlphaTo(255, 0.2, 0, nil)
    self.CustomizeHUD.topright_panel:AlphaTo(255, 0.2, 0, nil)
    self.CustomizeHUD.topleft_panel:AlphaTo(255, 0.2, 0, nil)
end
