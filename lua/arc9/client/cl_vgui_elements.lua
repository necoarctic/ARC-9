local ARC9ScreenScale = ARC9.ScreenScale
local hoversound = "arc9/newui/uimouse_hover.ogg"
local clicksound = "arc9/newui/uimouse_click_forward.ogg"
local ARC9TopButton = {}
ARC9TopButton.Color = ARC9.GetHUDColor("fg")
ARC9TopButton.ColorClicked = ARC9.GetHUDColor("hi")
ARC9TopButton.ColorNotif = Color(255, 50, 50)
ARC9TopButton.Icon = Material("arc9/ui/settings.png", "mips")
ARC9TopButton.MatIdle = Material("arc9/ui/topbutton.png", "mips")
ARC9TopButton.MatHovered = Material("arc9/ui/topbutton_hover.png", "mips")
ARC9TopButton.MatIdleL = Material("arc9/ui/topbutton_l.png", "mips")
ARC9TopButton.MatHoveredL = Material("arc9/ui/topbutton_hover_l.png", "mips")
ARC9TopButton.MatIdleM = Material("arc9/ui/topbutton_m.png", "mips")
ARC9TopButton.MatHoveredM = Material("arc9/ui/topbutton_hover_m.png", "mips")
ARC9TopButton.MatIdleR = Material("arc9/ui/topbutton_r.png", "mips")
ARC9TopButton.MatHoveredR = Material("arc9/ui/topbutton_hover_r.png", "mips")
ARC9TopButton.MatNotif = Material("arc9/ui/info.png", "mips")

local function syncconvar(self, val)

    if LocalPlayer():IsAdmin() and ARC9.ShouldNetworkConVar(LocalPlayer(), self.m_strConVar) then
        ARC9.NetworkConVar(self.m_strConVar, tostring(val))
    else
        if not self.m_strConVar or #self.m_strConVar < 2 then return end
        RunConsoleCommand(self.m_strConVar, tostring(val))
    end
end

local function syncconvardelayed(self, val)

    if LocalPlayer():IsAdmin() and ARC9.ShouldNetworkConVar(LocalPlayer(), self.m_strConVar) then
        timer.Create("cvarsend_" .. self.m_strConVar, 0.5, 1, function()
            ARC9.NetworkConVar(self.m_strConVar, tostring(val))
        end)
    else
        if not self.m_strConVar or #self.m_strConVar < 2 then return end
        RunConsoleCommand(self.m_strConVar, tostring(val))
    end
end

function ARC9TopButton:Init()
    self:SetText("")
    self:SetSize(ARC9ScreenScale(21), ARC9ScreenScale(21))
    self.DarkMode = !GetConVar("arc9_hud_lightmode"):GetBool()
end

function ARC9TopButton:Paint(w, h)
    local color = self.DarkMode and ARC9.GetHUDColor("bg") or self.Color
    local iconcolor = self.Color
    local icon = self.Icon
    local text = self.ButtonText
    local mat = self.MatIdle
    local matl = self.MatIdleL
    local matm = self.MatIdleM
    local matr = self.MatIdleR

    if self:IsHovered() then
        color = ARC9.GetHUDColor("hi")
        mat = self.MatHovered
        matl = self.MatHoveredL
        matm = self.MatHoveredM
        matr = self.MatHoveredR
    end

    if self:IsDown() or (self.Checkbox and self:GetChecked()) then
        iconcolor = ARC9.GetHUDColor("hi")
    end

    if self.Notif then
        surface.SetDrawColor(self.ColorNotif, 255)
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    surface.SetDrawColor(color)

    -- wide button
    if text then
        surface.SetMaterial(matl)
        for _=1, (self.DarkMode and 4 or 1) do surface.DrawTexturedRect(0, 0, h / 2, h) end
        surface.SetMaterial(matm)
        for _=1, (self.DarkMode and 4 or 1) do surface.DrawTexturedRect(h / 2, 0, w - h, h) end
        surface.SetMaterial(matr)
        for _=1, (self.DarkMode and 4 or 1) do surface.DrawTexturedRect(w - h / 2, 0, h / 2, h) end
        surface.SetFont(self.Font or "ARC9_16")
        local tw = surface.GetTextSize(text)
        surface.SetTextColor(iconcolor)
        surface.SetTextPos(h, h / 8)
        surface.DrawText(text)
    else
        surface.SetMaterial(mat)
        for _=1, (self.DarkMode and 4 or 1) do surface.DrawTexturedRect(0, 0, w, h) end
    end

    surface.SetDrawColor(iconcolor)
    surface.SetMaterial(icon)
    surface.DrawTexturedRect(h / 5, h / 5, h - h / 2.5, h - h / 2.5)

    if self.Notif then
        surface.SetDrawColor(self.ColorNotif)
        surface.SetMaterial(self.MatNotif)
        surface.DrawTexturedRect(w - h / 3, 0, h / 3, h / 3)
    end
end

function ARC9TopButton:OnCursorEntered()
    surface.PlaySound(hoversound)
end

function ARC9TopButton:SetIcon(mat)
    self.Icon = mat
end

function ARC9TopButton:SetNotif(val)
    self.Notif = val
end

function ARC9TopButton:SetButtonText(text, font)
    self.ButtonText = text
    self.Font = font
end

function ARC9TopButton:SetIsCheckbox(bool)
    self.Checkbox = bool
end

vgui.Register("ARC9TopButton", ARC9TopButton, "DCheckBox") -- DButton
local ARC9AttButton = {}
ARC9AttButton.Color = ARC9.GetHUDColor("fg")
ARC9AttButton.ColorBlock = ARC9.GetHUDColor("con")
ARC9AttButton.Icon = Material("arc9/ui/settings.png", "mips")
ARC9AttButton.MatIdle = Material("arc9/ui/att.png", "mips")
ARC9AttButton.MatFolderBack = Material("arc9/ui/folder_back.png", "mips smooth")
ARC9AttButton.MatFolderFront = Material("arc9/ui/folder_front.png", "mips smooth")
ARC9AttButton.MatFolderFrontFav = Material("arc9/ui/folder_front_fav.png", "mips smooth")
ARC9AttButton.MatFolderHeart = Material("arc9/ui/folder_heart.png", "mips smooth")
ARC9AttButton.MatEmpty = Material("arc9/ui/att_empty.png", "mips")
-- ARC9AttButton.MatHover = Material("arc9/ui/att_hover.png", "mips")
ARC9AttButton.MatBlock = Material("arc9/ui/att_block.png", "mips")
ARC9AttButton.MatMarkerInstalled = Material("arc9/ui/mark_installed.png", "mips smooth")
ARC9AttButton.MatMarkerLock = Material("arc9/ui/mark_lock.png", "mips smooth")
ARC9AttButton.MatMarkerLinked = Material("arc9/ui/mark_linked.png", "mips smooth")
ARC9AttButton.MatMarkerModes = Material("arc9/ui/mark_modes.png", "mips smooth")
ARC9AttButton.MatMarkerPaint = Material("arc9/ui/paint.png", "mips smooth")
ARC9AttButton.MatMarkerSlots = Material("arc9/ui/mark_slots.png", "mips smooth")
ARC9AttButton.MatMarkerFavorite = Material("arc9/ui/mark_favorite.png", "mips smooth")

function ARC9AttButton:Init()
    self:SetText("")
    self:SetSize(ARC9ScreenScale(42.7), ARC9ScreenScale(42.7 + 14.6))
end

function ARC9AttButton:Paint(w, h)
    local color = self.Color
    local iconcolor = self.Color
    local textcolor = self.Color
    local markercolor = self.Color
    local icon = self.Icon or ARC9TopButton.MatIdle
    local text = self.ButtonText or "<?>"
    local colorclicked = ARC9.GetHUDColor("hi")
    local colorgrey = ARC9.GetHUDColor("unowned")
    local mat = self.MatIdle
    local matmarker = nil
    local favmarker = nil
    local att = self.att

    local qty = ARC9:PlayerGetAtts(LocalPlayer(), att, self.Weapon)
    local free_or_lock = false

    if self:IsHovered() or self.OverrideHovered then
        textcolor = colorclicked
    end

    if self.HasPaint then
        matmarker = self.MatMarkerPaint
    elseif self.HasModes then
        matmarker = self.MatMarkerModes
    elseif self.HasSlots then
        matmarker = self.MatMarkerSlots
    end

    if self.Empty then
        mat = self.MatEmpty
        if self.EmptyGreyOut then
            color = colorgrey
            iconcolor = colorgrey
        end
    elseif not self.CanAttach and not self.Installed then
        if self.MissingDependents then
            matmarker = self.MatMarkerLinked
        else
            matmarker = self.MatMarkerLock
        end
        mat = self.MatBlock
        textcolor = self.ColorBlock
        iconcolor = self.ColorBlock
        markercolor = self.ColorBlock
    elseif self:IsDown() or self.Installed then
        -- mat = self.MatHover
        color = colorclicked
        matmarker = self.MatMarkerInstalled
        markercolor = colorclicked
    elseif qty == 0 and not self.Installed and not self.SlotDisplay then
        color = (self:IsHovered() or self.OverrideHovered) and self.Color or colorgrey
        textcolor = color
        iconcolor = colorgrey
    end

    if ARC9.Favorites[att] then
        favmarker = self.MatMarkerFavorite
    end

    surface.SetDrawColor(color)
    surface.SetMaterial(mat)
    surface.DrawTexturedRect(0, 0, w, w)
    -- icon
    render.SuppressEngineLighting(true)
    surface.SetDrawColor(iconcolor)
    surface.SetMaterial(icon)
    render.SetAmbientLight(255, 255, 255)

    if not self.FullColorIcon then
        surface.DrawTexturedRect(ARC9ScreenScale(2), ARC9ScreenScale(2), w - ARC9ScreenScale(4), w - ARC9ScreenScale(4))
    else
        surface.DrawTexturedRect(ARC9ScreenScale(4), ARC9ScreenScale(4), w - ARC9ScreenScale(8), w - ARC9ScreenScale(8))
    end

    render.SuppressEngineLighting(false)
    render.SetLightingMode(0)

    if matmarker then
        surface.SetDrawColor(markercolor)
        surface.SetMaterial(matmarker)
        surface.DrawTexturedRect(ARC9ScreenScale(3), w - ARC9ScreenScale(11), ARC9ScreenScale(8), ARC9ScreenScale(8))
        -- surface.DrawTexturedRect(0, 0, w, w)
    end

    if favmarker then
        surface.SetDrawColor(markercolor)
        surface.SetMaterial(favmarker)
        surface.DrawTexturedRect(w - ARC9ScreenScale(11), ARC9ScreenScale(3), ARC9ScreenScale(8), ARC9ScreenScale(8))
    end

    if self.FolderContain then -- is folder
        surface.SetFont("ARC9_12")
        local tww = surface.GetTextSize(self.FolderContain)
        surface.SetTextColor(iconcolor)
        surface.SetTextPos((w - tww) / 2, h - ARC9ScreenScale(28))
        surface.DrawText(self.FolderContain)


        if self.FolderIcon1 and !self.FolderIcon2 then -- single icon
            surface.SetMaterial(self.FolderIcon1)
            surface.SetDrawColor(iconcolor) -- icon
            -- draw shadow here, idk how
            surface.DrawTexturedRectRotated(w/2, w/3.3, w/2*1.05, w/2*1.05, 0)
            surface.DrawTexturedRectRotated(w/2, w/3.3, w/2, w/2, 0)
        else
            if self.FolderIcon1 then
                surface.SetMaterial(self.FolderIcon1)
                surface.SetDrawColor(iconcolor) -- icon
                -- draw shadow here, idk how
                surface.DrawTexturedRectRotated(w/3.05, w/3.3, w/2.625*1.07, w/2.625*1.07, 20.4) -- 512/168, 512/155, 512/195
                surface.DrawTexturedRectRotated(w/3.05, w/3.3, w/2.625, w/2.625, 20.4) -- 512/168, 512/155, 512/195
            end

            if self.FolderIcon2 then
                surface.SetMaterial(self.FolderIcon2)
                surface.SetDrawColor(iconcolor)
                surface.DrawTexturedRectRotated(w/1.45, w/3.0, w/2.625*1.07, w/2.625*1.07, -18) -- 512/358, 512/155, 512/195
                surface.DrawTexturedRectRotated(w/1.45, w/3.0, w/2.625, w/2.625, -18) -- 512/358, 512/155, 512/195
            end
        end

        surface.SetDrawColor(color)
        surface.SetMaterial(self.FolderFav and self.MatFolderFrontFav or self.MatFolderFront)
        surface.DrawTexturedRect(0, 0, w, w)

        if self.FolderFav then
            surface.SetDrawColor(colorclicked)
            surface.SetMaterial(self.MatFolderHeart)
            surface.DrawTexturedRect(0, 0, w, w)
        end
    end

    -- text
    surface.SetFont("ARC9_9")
    local tw = surface.GetTextSize(text)
    surface.SetTextColor(textcolor)

    -- print(textcolor)

    if tw > w then
        ARC9.DrawTextRot(self, text, 0, h - ARC9ScreenScale(13.5), 0, h - ARC9ScreenScale(13.5), w, false)
    else
        surface.SetTextPos((w - tw) / 2, h - ARC9ScreenScale(13.5))
        surface.DrawText(text)
        -- markup.Parse("<font=ARC9_9>" .. text):Draw((w - tw) / 2, h - ARC9ScreenScale(13.5), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
    end

    if att then
        local atttbl = ARC9.GetAttTable(att)

        if atttbl.Free or GetConVar("arc9_free_atts"):GetBool() then
            free_or_lock = true
        end

        if GetConVar("arc9_atts_lock"):GetBool() then
            free_or_lock = true
        end

        if not free_or_lock and (qty > 0 or self.Installed) then

            local qtext = "x" .. tostring(qty)

            surface.SetFont("ARC9_9")
            local qtw = surface.GetTextSize(qtext)
            surface.SetTextColor(textcolor)

            surface.SetTextPos(w - qtw - ARC9ScreenScale(4), ARC9ScreenScale(1))
            surface.DrawText(qtext)
        end

        if self.Installed or qty > 0 then
        else
            surface.SetMaterial( ARC9AttButton.MatMarkerLock )
            surface.SetDrawColor( 255, 255, 255, 32 )

            local size = ARC9ScreenScale(14)
            surface.DrawTexturedRect(ARC9ScreenScale(21.5) - size/2, ARC9ScreenScale(21.5) - size/2, size, size )
        end
    end
end

function ARC9AttButton:OnCursorEntered()
    surface.PlaySound(hoversound)
end

function ARC9AttButton:SetIcon(mat)
    self.Icon = mat
end

function ARC9AttButton:SetButtonText(text)
    self.ButtonText = text
end

function ARC9AttButton:SetEmpty(bool)
    self.Empty = bool
end

function ARC9AttButton:SetEmptyGreyOut(bool)
    self.EmptyGreyOut = bool
end

function ARC9AttButton:SetOverrideHovered(bool)
    self.OverrideHovered = bool
end

function ARC9AttButton:SetInstalled(bool)
    self.Installed = bool
end

function ARC9AttButton:SetCanAttach(bool)
    self.CanAttach = bool
end

function ARC9AttButton:SetMissingDependents(bool)
    self.MissingDependents = bool
end


function ARC9AttButton:SetSlotDisplay(bool)
    self.SlotDisplay = bool
end


function ARC9AttButton:SetFolderContain(num)
    self.FolderContain = num
end

function ARC9AttButton:SetHasModes(bool)
    self.HasModes = bool
end

function ARC9AttButton:SetHasPaint(bool)
    self.HasPaint = bool
end

function ARC9AttButton:SetHasSlots(bool)
    self.HasSlots = bool
end

function ARC9AttButton:SetFullColorIcon(bool)
    self.FullColorIcon = bool
end

function ARC9AttButton:SetFolderIcon(id, mat, isfav)
    self.Icon = ARC9AttButton.MatFolderBack
    if id == 1 then self.FolderIcon1 = mat
    elseif id == 2 then self.FolderIcon2 = mat end

    if isfav then self.FolderFav = true end
end

vgui.Register("ARC9AttButton", ARC9AttButton, "DCheckBox") -- DButton
local ARC9ScrollPanel = {}

function ARC9ScrollPanel:Init()
    self.VBar:SetHideButtons(true)
    self.VBar:SetWide(ARC9ScreenScale(2))
    self.VBar:SetAlpha(0) -- to prevent blinking
    self.VBar:AlphaTo(255, 0.2, 0, nil)

    self.VBar.Paint = function(panel, w, h)
        surface.SetDrawColor(ARC9.GetHUDColor("bg"))
        surface.DrawRect(0, 0, w, h)
        panel:AddScroll(0)
    end

    self.VBar.btnGrip.Paint = function(panel, w, h)
        surface.SetDrawColor(ARC9.GetHUDColor("fg"))
        surface.DrawRect(0, 0, w, h)
    end

    local smoothdlta = 0

    self.VBar.AddScroll = function(self2, dlta)
        local OldScroll = self2:GetScroll()
        dlta = dlta * 40
        smoothdlta = Lerp(FrameTime() * 10, smoothdlta, dlta)
        self2:SetScroll(self2:GetScroll() + smoothdlta)

        return OldScroll ~= self2:GetScroll()
    end
end

function ARC9ScrollPanel:Paint(w, h)
end

vgui.Register("ARC9ScrollPanel", ARC9ScrollPanel, "DScrollPanel")
local ARC9HorizontalScroller = {}

local circlemat = Material("arc9/circle.png", "smooth mips")
local circlefillmat = Material("arc9/circlefill.png", "smooth mips")

function ARC9HorizontalScroller:Init()
    local smoothdlta = 0

    self.OnMouseWheeled = function(self2, dlta)
        dlta = dlta * -55
        smoothdlta = Lerp(0.08, smoothdlta, dlta)
        self2.OffsetX = self2.OffsetX + smoothdlta
        self2:InvalidateLayout(true)

        return true
    end
end

function ARC9HorizontalScroller:Think()
    local wep = LocalPlayer():GetActiveWeapon()

    if not IsValid(wep) then return end

    wep.LastScroll = self.OffsetX
end

function ARC9HorizontalScroller:RefreshScrollBar(bar)
    local width = self:GetWide()
    local contentswidth = self.pnlCanvas:GetWide()

    if contentswidth > width then
        -- Create a panel centered in the bottom middle of bar
        -- This will be the scroll bar
        -- Drag the scroll bar to scroll the contents
        -- Width should be the ratio of the width of the bar to the width of the contents

        if IsValid(self.ScrollBarParent) then
            self.ScrollBarParent:Remove()
            self.ScrollBarParent = nil
        end

        self.ScrollBarParent = vgui.Create("DPanel", bar)
        self.ScrollBarParent:SetSize(bar:GetWide(), ARC9ScreenScale(5))
        self.ScrollBarParent:SetPos(0, 0)
        self.ScrollBarParent.Paint = function(panel, w, h)
        end

        local scrollbar = vgui.Create("DPanel", self.ScrollBarParent)
        scrollbar:SetSize(self.ScrollBarParent:GetWide() * (width / contentswidth), ARC9ScreenScale(1))
        scrollbar:SetPos(0, 0)
        scrollbar.Paint = function(panel, w, h)
            surface.SetDrawColor(ARC9.GetHUDColor("hi"))
            surface.DrawRect(0, 0, w, ARC9ScreenScale(1))
        end

        scrollbar.Think = function(panel)
            local x, y = self.pnlCanvas:GetPos()
            local width = self:GetWide()
            local contentswidth = self.pnlCanvas:GetWide()
            local scrollwidth = self.ScrollBarParent:GetWide()
            local scrollpos = math.Clamp(-x / (contentswidth - width), 0, 1)
            local scrollx = scrollpos * (scrollwidth - scrollbar:GetWide())

            panel:SetPos(scrollx, y)
        end

        self.Dragging = false

        self.ScrollBarParent.Think = function(panel)
            -- Scroll functionality
            local scrollwidth = self.ScrollBarParent:GetWide()
            local contentswidth = self.pnlCanvas:GetWide()
            local width = self:GetWide()

            local mx, my = input.GetCursorPos()
            local px, py = panel:LocalToScreen(0, 0)
            local pw, ph = panel:GetSize()

            if input.IsMouseDown(MOUSE_LEFT) then
                if not self.Dragging then
                    if mx > px and mx < px + pw and my > py and my < py + ph then
                        self.Dragging = true
                    end
                end
            else
                self.Dragging = false
            end

            if self.Dragging then
                local scrollpos = math.Clamp((mx - px - (scrollbar:GetWide() / 2)) / (scrollwidth - scrollbar:GetWide()), 0, 1)
                local scrollx = scrollpos * (contentswidth - width)
                self:SetScroll(scrollx)
            else
                self:SetScroll(self.OffsetX)
            end
        end

        self.ScrollBarParent:MoveToFront()
    else
        if IsValid(self.ScrollBarParent) then
            self.ScrollBarParent:Remove()
            self.ScrollBarParent = nil
        end
    end
end

vgui.Register("ARC9HorizontalScroller", ARC9HorizontalScroller, "DHorizontalScroller")
local ARC9ColumnSheet = {}

function ARC9ColumnSheet:Init()
    self.Navigation = vgui.Create("ARC9ScrollPanel", self)
    self.Navigation:Dock(LEFT)
    self.Navigation:SetWidth(100)
    self.Navigation:DockMargin(10, 10, 10, 0)
    self.Content = vgui.Create("Panel", self)
    self.Content:Dock(FILL)
    self.Items = {}
end

vgui.Register("ARC9ColumnSheet", ARC9ColumnSheet, "DColumnSheet")
local ARC9Checkbox = {}
ARC9Checkbox.Color = ARC9.GetHUDColor("fg")
ARC9Checkbox.ColorClicked = ARC9.GetHUDColor("hi")
ARC9Checkbox.MatIdle = Material("arc9/ui/checkbox.png", "mips")
ARC9Checkbox.MatSel = Material("arc9/ui/checkbox_sel.png", "mips")
ARC9Checkbox.MatToggled = Material("arc9/ui/checkbox_toggled.png", "mips")

function ARC9Checkbox:Init()
    self:SetSize(ARC9ScreenScale(13), ARC9ScreenScale(13))
end

function ARC9Checkbox:Paint(w, h)
    local color = self.Color
    local color2 = ARC9.GetHUDColor("hi")
    surface.SetDrawColor(color)
    surface.SetMaterial(self.MatIdle)
    surface.DrawTexturedRect(0, 0, w, w)

    if self:GetChecked() then
        surface.SetDrawColor(color2)
        surface.SetMaterial(self.MatToggled)
        surface.DrawTexturedRect(0, 0, w, w)
    end

    if self:IsHovered() and self:IsEnabled() then
        surface.SetDrawColor(color2)
        surface.SetMaterial(self.MatSel)
        surface.DrawTexturedRect(0, 0, w, w)
    end
end

ARC9Checkbox.ConVarChanged = syncconvar

vgui.Register("ARC9Checkbox", ARC9Checkbox, "DCheckBox")
local ARC9NumSlider = {}
ARC9NumSlider.Color = ARC9.GetHUDColor("fg")
ARC9NumSlider.ColorClicked = ARC9.GetHUDColor("hi")

function ARC9NumSlider:Init()
    local color = self.Color
    local color2 = ARC9.GetHUDColor("hi")
    local color3 = ARC9.GetHUDColor("hint")
    self.Slider.Knob:SetSize(ARC9ScreenScale(1.7), ARC9ScreenScale(7))

    self.Slider.Knob.Paint = function(panel, w, h)
        surface.SetDrawColor(color)
        surface.DrawRect(0, 0, w, h)
    end

    self.Slider.Paint = function(panel, w, h)
        surface.SetDrawColor(color3)
        surface.DrawRect(0, h / 3, w, h / 4)
        surface.SetDrawColor(color)
        surface.DrawRect(0, h / 3, w * self.Scratch:GetFraction(), h / 4)
    end

    self.Scratch.ConVarChanged = syncconvardelayed
    self.TextArea.ConVarChanged = syncconvardelayed

    self.TextArea:SetWide(ARC9ScreenScale(20))
    self.TextArea:DockMargin(ARC9ScreenScale(3), 0, 0, 0)
    self.TextArea:SetHighlightColor(color2)
    self.TextArea:SetCursorColor(color2)
    self.TextArea:SetTextColor(color)
    self.TextArea:SetFont("ARC9_10_Slim")
    -- self.TextArea.Paint = function(panel, w, h)
    --     surface.SetFont("ARC9_10_Slim")
    --     local text = panel:GetValue() or "Owo"
    --     local tw = surface.GetTextSize(text)
    --     surface.SetTextColor(color)
    --     surface.SetTextPos(w-tw, ARC9ScreenScale(0))
    --     surface.DrawText(text)
    -- end
end


vgui.Register("ARC9NumSlider", ARC9NumSlider, "DNumSlider")
local ARC9ComboBox = {}
ARC9ComboBox.Color = ARC9.GetHUDColor("fg")
ARC9ComboBox.ColorClicked = ARC9.GetHUDColor("hi")
ARC9ComboBox.MatIdle = Material("arc9/ui/dd.png", "mips")
ARC9ComboBox.MatSel = Material("arc9/ui/dd_sel.png", "mips")
ARC9ComboBox.MatOpened = Material("arc9/ui/dd_opened.png", "mips")
ARC9ComboBox.MatOpenedSel = Material("arc9/ui/dd_opened_sel.png", "mips")
ARC9ComboBox.MatSingle = Material("arc9/ui/dd_option.png", "mips")
ARC9ComboBox.MatSingleSel = Material("arc9/ui/dd_option_sel.png", "mips")
ARC9ComboBox.MatLast = Material("arc9/ui/dd_option_last.png", "mips")
ARC9ComboBox.MatLastSel = Material("arc9/ui/dd_option_last_sel.png", "mips")

function ARC9ComboBox:Init()
    self:SetSize(ARC9ScreenScale(84), ARC9ScreenScale(13))
    self.DropButton:Remove()
end

-- to fix button we removed
function ARC9ComboBox:PerformLayout()
    DButton.PerformLayout(self, w, h)
end

function ARC9ComboBox:OnSelect(index, value, data)
    self.text = self:GetText()

    if self.Convar then
        if LocalPlayer():IsAdmin() and ARC9.ShouldNetworkConVar(LocalPlayer(), self.Convar) then
            ARC9.NetworkConVar(self.Convar, tostring(data))
        else
            RunConsoleCommand(self.Convar, data)
        end
    end

    self:SetText("")
end

function ARC9ComboBox:CustomSetConvar(cvar)
    self.Convar = cvar
end

function ARC9ComboBox:SetOptions(opt)
    self.IndexToOptions = opt
end

function ARC9ComboBox:OnMenuOpened(menu)
    menu.Paint = function(panel, w, h) end
    menu:SetAlpha(0)
    menu:AlphaTo(255, 0.1, 0, nil)

    -- local mat = self.MatIdle
    for i = 1, menu:ChildCount() do
        local child = menu:GetChild(i)

        child.PerformLayout = function(self22, w22, h22)
            DButton.PerformLayout(self22, w22, h22)
        end

        child:SetSize(ARC9ScreenScale(84), ARC9ScreenScale(13))
        child.id = i
        child.last = i == menu:ChildCount()
        child.text = child:GetText()
        child:SetText("")

        child.Paint = function(self2, w, h)
            local mat = self.MatSingle
            local mat2 = self.MatSingleSel
            local mat3 = self.MatLast
            local mat4 = self.MatLastSel
            local color = self.Color
            local color2 = ARC9.GetHUDColor("hi")

            if self2:IsDown() then
                color = color2
            end

            surface.SetDrawColor(color)
            surface.SetMaterial(self2.last and mat3 or mat)
            surface.DrawTexturedRect(0, 0, w, h)
            local active = self:GetSelectedID() == self2.id

            if active or self2:IsHovered() then
                surface.SetDrawColor(color2)
                surface.SetMaterial(self2.last and mat4 or mat2)
                surface.DrawTexturedRect(0, 0, w, h)
            end

            surface.SetFont("ARC9_10")
            surface.SetTextColor(active and color2 or color)
            surface.SetTextPos(ARC9ScreenScale(4), ARC9ScreenScale(1))
            surface.DrawText(string.sub(child.text or "Owo", 2))
        end
    end
end

function ARC9ComboBox:Paint(w, h)
    local color = self.Color
    local color2 = ARC9.GetHUDColor("hi")
    local mat = self.MatIdle
    local mat2 = self.MatSel
    local mat3 = self.MatOpened
    local mat4 = self.MatOpenedSel
    surface.SetDrawColor(color)
    surface.SetMaterial(self:IsMenuOpen() and mat3 or mat)
    surface.DrawTexturedRect(0, 0, w, h)

    if self:IsHovered() then
        surface.SetDrawColor(color2)
        surface.SetMaterial(self:IsMenuOpen() and mat4 or mat2)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    surface.SetFont("ARC9_10")
    surface.SetTextColor(color)
    surface.SetTextPos(ARC9ScreenScale(4), ARC9ScreenScale(1))
    surface.DrawText(string.sub(self.text or "unselected", 2))
end

vgui.Register("ARC9ComboBox", ARC9ComboBox, "DComboBox")
local ARC9Button = {}
ARC9Button.Color = ARC9.GetHUDColor("fg")
ARC9Button.ColorClicked = ARC9.GetHUDColor("hi")
ARC9Button.MatIdle = Material("arc9/ui/button.png", "mips")
ARC9Button.MatSel = Material("arc9/ui/button_sel.png", "mips")

function ARC9Button:Init()
    self:SetSize(ARC9ScreenScale(84), ARC9ScreenScale(13))
    self.text = self:GetText()
    self:SetText("")
end

function ARC9Button:Paint(w, h)
    local color = self.Color
    local color2 = ARC9.GetHUDColor("hi")

    if self:IsDown() then
        color = color2
    end

    surface.SetDrawColor(color)
    surface.SetMaterial(self.MatIdle)
    surface.DrawTexturedRect(0, 0, w, h)

    if self:IsHovered() then
        surface.SetDrawColor(color2)
        surface.SetMaterial(self.MatSel)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    local text = self.text or ""
    surface.SetFont("ARC9_10")
    local tw = surface.GetTextSize(text)
    surface.SetTextColor(color)
    surface.SetTextPos(w / 2 - tw / 2, ARC9ScreenScale(1.5))
    surface.DrawText(text)
end

vgui.Register("ARC9Button", ARC9Button, "DButton")
local ARC9ColorPanel = {}
ARC9ColorPanel.Color = ARC9.GetHUDColor("fg")
ARC9ColorPanel.ColorClicked = ARC9.GetHUDColor("hi")
ARC9ColorPanel.MatIdle = Material("arc9/ui/colorpanel.png", "mips")
ARC9ColorPanel.MatIdle2 = Material("arc9/ui/colorpanel2.png", "mips")
ARC9ColorPanel.MatCubeR = Material("arc9/ui/colorcube_r")
ARC9ColorPanel.MatCubeD = Material("arc9/ui/colorcube_d")
ARC9ColorPanel.MatCubeF = Material("arc9/ui/colorcube_full")
ARC9ColorPanel.MatSelect = Material("arc9/ui/circle128.png", "mips smooth")
ARC9ColorPanel.MatSelect2 = Material("arc9/ui/circle128_2.png", "mips smooth")

function ARC9ColorPanel:Init()
    self:SetSize(ARC9ScreenScale(84), ARC9ScreenScale(110)) -- increased for hex input
    self:MakePopup()
    self:SetDraggable(true)
    self:SetAlpha(0)
    self:AlphaTo(255, 0.15, 0, nil)
    self:ShowCloseButton(false)
    self.hsvHUE, self.hsvSAT, self.hsvVAL = ColorToHSV(self.startcolor or Color(255, 0, 0))

    self.hsvHUEonly = {
        r = self.hsvHUE,
        g = 1,
        b = 1
    }

    self.ResultColor = self.startcolor or Color(255, 0, 0)

    -- Hex input field
    local hexentry = vgui.Create("DTextEntry", self)
    hexentry:SetPos(ARC9ScreenScale(2.7), ARC9ScreenScale(84))
    hexentry:SetSize(ARC9ScreenScale(79), ARC9ScreenScale(12))
    hexentry:SetFont("ARC9_8")
    hexentry:SetTextColor(color_white)
    hexentry:SetPaintBackground(false)
    hexentry:SetText(string.format("#%02X%02X%02X", self.ResultColor.r, self.ResultColor.g, self.ResultColor.b))
    self.hexentry = hexentry

    hexentry.Paint = function(self2, w, h)
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(0, 0, w, h)
        self2:DrawTextEntryText(color_white, ARC9.GetHUDColor("hi"), color_white)
    end

    hexentry.OnEnter = function(self2)
        local txt = self2:GetText():gsub("#", ""):upper()
        if #txt == 6 or #txt == 8 then
            local r = tonumber(txt:sub(1, 2), 16)
            local g = tonumber(txt:sub(3, 4), 16)
            local b = tonumber(txt:sub(5, 6), 16)
            local a = #txt == 8 and tonumber(txt:sub(7, 8), 16) or nil
            if r and g and b then
                local newcolor = Color(r, g, b, a or 255)
                self:UpdateColor(newcolor)
            end
        end
    end

    local huepanel = vgui.Create("DPanel", self)
    huepanel:SetPos(ARC9ScreenScale(2.7), self:GetTall() - ARC9ScreenScale(13))
    huepanel:SetSize(ARC9ScreenScale(79), ARC9ScreenScale(10.5))
    huepanel:NoClipping(true)
    huepanel.LastX = 0
    self.huepanel = huepanel -- for later integration

    huepanel.OnCursorMoved = function(self2, x, y)
        if not input.IsMouseDown(MOUSE_LEFT) then return end
        x = math.Clamp(x, 0, self2:GetWide())
        self2.LastX = x
        self.hsvHUE = (x / self2:GetWide()) * 360
        self.ResultColor = HSVToColor(self.hsvHUE, self.hsvSAT, self.hsvVAL)
        self.hsvHUEonly = HSVToColor(self.hsvHUE, 1, 1)
        self:UpdateHexText()
    end

    huepanel.OnMousePressed = function(self2, mcode)
        self2:MouseCapture(true)
        self2:OnCursorMoved(self2:CursorPos())
        self2:SetCursor("blank")
    end

    huepanel.OnMouseReleased = function(self2, mcode)
        self2:MouseCapture(false)
        self2:OnCursorMoved(self2:CursorPos())
        self2:SetCursor("none")
    end

    huepanel.Paint = function(self2, w, h)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawRect(self2.LastX - ARC9ScreenScale(0.5), -ARC9ScreenScale(1), ARC9ScreenScale(1), h + ARC9ScreenScale(2))
    end

    local cube = vgui.Create("DPanel", self)
    cube:SetPos(ARC9ScreenScale(2.5), ARC9ScreenScale(2.5))
    cube:SetSize(ARC9ScreenScale(79), ARC9ScreenScale(79))
    cube:NoClipping(true)
    self.cube = cube -- for later integration
    cube.LastX = 0
    cube.LastY = 0

    cube.Paint = function(self2, w, h)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(self.MatCubeF)
        surface.DrawTexturedRect(0, 0, w, h)
        surface.SetDrawColor(self.hsvHUEonly, 255)
        surface.SetMaterial(self.MatCubeR)
        surface.DrawTexturedRect(0, 0, w, h)
        surface.SetDrawColor(0, 0, 0, 255)
        surface.SetMaterial(self.MatCubeD)
        surface.DrawTexturedRect(0, 0, w, h)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(self.MatSelect)
        surface.DrawTexturedRect(self2.LastX - ARC9ScreenScale(4), self2.LastY - ARC9ScreenScale(4), ARC9ScreenScale(8), ARC9ScreenScale(8))
        surface.SetDrawColor(self.ResultColor, 255)
        surface.SetMaterial(self.MatSelect2)
        surface.DrawTexturedRect(self2.LastX - ARC9ScreenScale(4), self2.LastY - ARC9ScreenScale(4), ARC9ScreenScale(8), ARC9ScreenScale(8))
    end

    cube.OnCursorMoved = function(self2, x, y)
        if not input.IsMouseDown(MOUSE_LEFT) then return end
        x = math.Clamp(x, 0, self2:GetWide())
        y = math.Clamp(y, 0, self2:GetTall())
        self2.LastX = x
        self2.LastY = y
        self.hsvSAT = x / self2:GetWide()
        self.hsvVAL = 1 - y / self2:GetTall()
        self.ResultColor = HSVToColor(self.hsvHUE, self.hsvSAT, self.hsvVAL)
        self:UpdateHexText()
    end

    cube.OnMousePressed = function(self2, mcode)
        self2:MouseCapture(true)
        self2:OnCursorMoved(self2:CursorPos())
        self2:SetCursor("blank")
    end

    cube.OnMouseReleased = function(self2, mcode)
        self2:MouseCapture(false)
        self2:OnCursorMoved(self2:CursorPos())
        self2:SetCursor("none")
    end
end

function ARC9ColorPanel:Paint(w, h)
    local color = self.Color
    surface.SetDrawColor(color)
    surface.SetMaterial(self.MatIdle)
    surface.DrawTexturedRect(0, 0, w, h)
end

function ARC9ColorPanel:UpdateColor(clr)
    local hsvh, hsvs, hsvv = ColorToHSV(clr)
    self.hsvHUE, self.hsvSAT, self.hsvVAL = hsvh, hsvs, hsvv
    self.hsvHUEonly = HSVToColor(hsvh, 1, 1)
    self.ResultColor = clr
    self.cube.LastX = self.cube:GetWide() * hsvs
    self.cube.LastY = self.cube:GetTall() * (1 - hsvv)
    self.huepanel.LastX = self.huepanel:GetWide() * hsvh / 360

    if self.Alpha then
        self.Alpha = clr.a
        self.alphapanel.LastX = self.alphapanel:GetWide() * clr.a / 255
    end

    self:UpdateHexText()
end

function ARC9ColorPanel:UpdateHexText()
    if not IsValid(self.hexentry) then return end
    if self.Alpha then
        self.hexentry:SetText(string.format("#%02X%02X%02X%02X", self.ResultColor.r, self.ResultColor.g, self.ResultColor.b, math.floor(self.Alpha)))
    else
        self.hexentry:SetText(string.format("#%02X%02X%02X", self.ResultColor.r, self.ResultColor.g, self.ResultColor.b))
    end
end

function ARC9ColorPanel:EnableAlpha()
    self.Alpha = 255
    self:SetSize(ARC9ScreenScale(84), ARC9ScreenScale(122)) -- increased for hex input + alpha
    self.huepanel:SetPos(ARC9ScreenScale(2.7), self:GetTall() - ARC9ScreenScale(13))
    self.hexentry:SetPos(ARC9ScreenScale(2.7), ARC9ScreenScale(84))
    self.MatIdle = self.MatIdle2
    local alphapanel = vgui.Create("DPanel", self)
    alphapanel:SetPos(ARC9ScreenScale(2.7), self:GetTall() - ARC9ScreenScale(25.05))
    alphapanel:SetSize(ARC9ScreenScale(79), ARC9ScreenScale(10.5))
    alphapanel:NoClipping(true)
    alphapanel.LastX = ARC9ScreenScale(79)
    self.alphapanel = alphapanel -- for later integration

    alphapanel.OnCursorMoved = function(self2, x, y)
        if not input.IsMouseDown(MOUSE_LEFT) then return end
        x = math.Clamp(x, 0, self2:GetWide())
        self2.LastX = x
        self.Alpha = (x / self2:GetWide()) * 255
        self:UpdateHexText()
    end

    alphapanel.OnMousePressed = function(self2, mcode)
        self2:MouseCapture(true)
        self2:OnCursorMoved(self2:CursorPos())
        self2:SetCursor("blank")
    end

    alphapanel.OnMouseReleased = function(self2, mcode)
        self2:MouseCapture(false)
        self2:OnCursorMoved(self2:CursorPos())
        self2:SetCursor("none")
    end

    alphapanel.Paint = function(self2, w, h)
        surface.SetDrawColor(self.ResultColor, 255)
        surface.SetMaterial(self.MatCubeR)
        surface.DrawTexturedRect(0, 0, w, h)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawRect(self2.LastX - ARC9ScreenScale(0.5), -ARC9ScreenScale(1), ARC9ScreenScale(1), h + ARC9ScreenScale(2))
    end
end

vgui.Register("ARC9ColorPanel", ARC9ColorPanel, "DFrame")
local ARC9ColorButton = {}
ARC9ColorButton.Color = ARC9.GetHUDColor("fg")
ARC9ColorButton.ColorClicked = ARC9.GetHUDColor("hi")
ARC9ColorButton.MatIdle = Material("arc9/ui/button_color.png", "mips")
ARC9ColorButton.MatSel = Material("arc9/ui/button_sel.png", "mips")
ARC9ColorButton.MatIcon = Material("arc9/ui/paint.png", "mips smooth")

function ARC9ColorButton:Init()
    self:SetSize(ARC9ScreenScale(84), ARC9ScreenScale(13))
    self:SetText("")
end

function ARC9ColorButton:DoClick()
    local bg = vgui.Create("DFrame")
    bg:SetPos(0, 0)
    bg:SetSize(ScrW(), ScrH())
    bg:SetTitle("")
    bg:SetDraggable(false)
    bg:ShowCloseButton(false)
    bg:SetBackgroundBlur(true)
    bg:MakePopup()
    bg.ParentButton = self
    local newel = vgui.Create("ARC9ColorPanel", bg)

    if self.AlphaEnabled then
        newel:EnableAlpha()
    end

    newel:SetPos(self:LocalToScreen(self:GetX() - ARC9ScreenScale(103), self:GetY() - ARC9ScreenScale(48)))
    newel:UpdateColor(self.rgbcolor)
    newel:ShowCloseButton(false)

    bg.Paint = function(self2, w, h)
        surface.SetDrawColor(0, 0, 0, 0)
        surface.DrawRect(0, 0, w, h)

        if not IsValid(self2.ParentButton) then
            bg:Remove()
            newel:Remove()
        end
    end

    bg.OnMousePressed = function(self2, keycode)
        if newel.Alpha then
            newel.ResultColor.a = newel.Alpha
        end

        if LocalPlayer():IsAdmin() and ARC9.ShouldNetworkConVar(LocalPlayer(), self.m_strConVar) then
            timer.Create("cvarsend_" .. self.Convar, 0.5, 1, function()
                ARC9.NetworkConVar(self.Convar .. "_r", tostring(self.rgbcolor.r))
                ARC9.NetworkConVar(self.Convar .. "_g", tostring(self.rgbcolor.g))
                ARC9.NetworkConVar(self.Convar .. "_b", tostring(self.rgbcolor.b))
                if newel.Alpha then
                    ARC9.NetworkConVar(self.Convar .. "_a", tostring(self.rgbcolor.a))
                end
            end)
        else
            self.rgbcolor = newel.ResultColor
            RunConsoleCommand(self.Convar .. "_r", self.rgbcolor.r)
            RunConsoleCommand(self.Convar .. "_g", self.rgbcolor.g)
            RunConsoleCommand(self.Convar .. "_b", self.rgbcolor.b)

            if newel.Alpha then
                RunConsoleCommand(self.Convar .. "_a", self.rgbcolor.a)
            end
        end

        -- self:ApplyConvar or something idk ()
        newel:Remove()
        bg:Remove()
    end
end

function ARC9ColorButton:EnableAlpha()
    self.AlphaEnabled = true
end

function ARC9ColorButton:CustomSetConvar(cvar)
    self.Convar = cvar
end

function ARC9ColorButton:Paint(w, h)
    local color = self.Color
    local color2 = ARC9.GetHUDColor("hi")
    local color3 = self.rgbcolor or self.Color

    if self:IsDown() then
        color = color2
    end

    surface.SetDrawColor(color3)
    surface.SetMaterial(self.MatIdle)
    surface.DrawTexturedRect(0, 0, w, h)
    surface.SetDrawColor(color)
    surface.SetMaterial(self.MatIcon)
    surface.DrawTexturedRect(w / 2 - h * 0.35, h / 2 - h * 0.35, h * 0.7, h * 0.7)

    if self:IsHovered() then
        surface.SetDrawColor(color2)
    end

    surface.SetMaterial(self.MatSel)
    surface.DrawTexturedRect(0, 0, w, h)
end

vgui.Register("ARC9ColorButton", ARC9ColorButton, "DButton")

local ARC9InputField = {}
ARC9InputField.Color = ARC9.GetHUDColor("fg")
ARC9InputField.ColorClicked = ARC9.GetHUDColor("hi")
ARC9InputField.MatIdle = Material("arc9/ui/button.png", "mips")
ARC9InputField.MatSel = Material("arc9/ui/button_sel.png", "mips")

function ARC9InputField:Init()
    self:SetSize(ARC9ScreenScale(84), ARC9ScreenScale(13))

    self:SetPaintBackground(false)
    self:SetTextColor(color_white)
    self:SetFont("ARC9_10")
    self:SetDrawLanguageID(false)
end

function ARC9InputField:Paint(w, h)
    local color = self.Color
    local color2 = ARC9.GetHUDColor("hi")

    if self:IsEditing() then
        color = color2
    end

    surface.SetDrawColor(color)
    surface.SetMaterial(self.MatIdle)
    surface.DrawTexturedRect(0, 0, w, h)

    if self:IsHovered() then
        surface.SetDrawColor(color2)
        surface.SetMaterial(self.MatSel)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    if self:IsEditing() then
        derma.SkinHook("Paint", "TextEntry", self, w, h) -- stupid bitch gmod does not allow editing DTextEntry text field
    else
        surface.SetFont("ARC9_10")
        surface.SetTextColor(color)
        surface.SetTextPos(ARC9ScreenScale(4), ARC9ScreenScale(1))
        surface.DrawText(self:GetText() == "" and self:GetPlaceholderText() or self:GetValue())
    end

    return false
end

vgui.Register("ARC9InputField", ARC9InputField, "DTextEntry")