local mat_plus = Material("arc9/ui/plus.png")
local mat_dash = Material("arc9/ui/dash.png")
local mat_stick = Material("arc9/def_att_icons/sticker.png")

local clicksound = "arc9/newui/uimouse_click.ogg"

local ARC9ScreenScale = ARC9.ScreenScale

function SWEP:SlotIsCosmetic(slottbl)
    if slottbl.CosmeticOnly == nil then
        local hasnoncosmeticslot = false

        local cats = slottbl.Category

        if !istable(cats) then
            cats = {cats}
        end

        for _, cat in ipairs(cats) do
            if !ARC9.CosmeticCategories[cat] or slottbl.ForceNoCosmetics then
                hasnoncosmeticslot = true
                break
            end
        end

        slottbl.CosmeticOnly = !hasnoncosmeticslot

        return !hasnoncosmeticslot
    else
        return slottbl.CosmeticOnly
    end
end

function SWEP:CreateHUD_Slots(scroll)
    local deadzonex = GetConVar("arc9_hud_deadzonex"):GetInt()

    self.CustomizeHUD.lowerpanel:MoveTo(ARC9ScreenScale(19) + deadzonex, ScrH() - ARC9ScreenScale(93), 0.2, 0, 0.5, nil)
    self.CustomizeHUD.lowerpanel:SizeTo(ScrW() - ARC9ScreenScale(38) - deadzonex*2, ARC9ScreenScale(74), 0.2, 0, 0.5, nil)
    self.CustomizeHUD.lowerpanel.Extended = nil

    local spacer = vgui.Create("DPanel", scroll)
    spacer:DockMargin(ARC9ScreenScale(5), 0, 0, 0)
    spacer:Dock(LEFT)
    spacer:SetSize(0, 0)

    scroll:AddPanel(spacer)

    for _, slot in ipairs(self:GetSubSlotList()) do
        if slot.Hidden then continue end
        local ms_slot = self:GetFilledMergeSlot(slot.Address)

        if self.BottomBarCategory == 0 and self:SlotIsCosmetic(ms_slot) then continue end
        if self.BottomBarCategory == 1 and !self:SlotIsCosmetic(ms_slot) then continue end

        if !ms_slot.Installed and self:GetSlotBlocked(slot) then continue end

        local atttbl = self:GetFinalAttTable(ms_slot)

        local atttxt = ARC9:GetPhrase(ms_slot.PrintName) or ms_slot.PrintName or "Slot"

        local slotbtn = vgui.Create("ARC9AttButton", scroll)

        slotbtn.Weapon = self
        slotbtn:SetCanAttach(true)
        slotbtn:SetEmpty(!ms_slot.Installed)
        slotbtn:SetHasModes(!!atttbl.ToggleStats)
        slotbtn:SetHasPaint(!!atttbl.AdvancedCamoSupport)
        slotbtn:SetHasSlots(!!atttbl.Attachments)
        slotbtn:SetFullColorIcon(atttbl.FullColorIcon)
        slotbtn:SetSlotDisplay(true)

        -- slotbtn:DockMargin(ARC9ScreenScale(5), 0, 0, 0)
        slotbtn:DockMargin(0, 0, ARC9ScreenScale(4), 0)
        slotbtn:Dock(LEFT)

        scroll:AddPanel(slotbtn)

        slotbtn.slot = ms_slot
        ms_slot.lowerbutton = slotbtn

        if ms_slot.Installed then
            atttxt = ARC9:GetPhraseForAtt(ms_slot.Installed, "CompactName")
            atttxt = atttxt or ARC9:GetPhraseForAtt(ms_slot.Installed, "PrintName") or ""
            slotbtn:SetIcon(atttbl.Icon)
            -- slotbtn:SetTooltip(ARC9:GetPhraseForAtt(ms_slot.Installed, "PrintName").."\n\nLMB - Customisation\nRMB - Remove attachment")
        else
            if ms_slot.DefaultCompactName then
                atttxt = ARC9:UseTrueNames() and ms_slot.DefaultCompactName_TrueName or ms_slot.DefaultCompactName
                atttxt = atttxt or ms_slot.DefaultName_TrueName or ms_slot.DefaultName or ""
            end
            if ms_slot.DefaultIcon then
                slotbtn:SetIcon(ms_slot.DefaultIcon)
            elseif ms_slot.Category == "stickers" then
                slotbtn:SetIcon(mat_stick)
            elseif GetConVar("arc9_atts_nocustomize"):GetBool() then
                slotbtn:SetIcon(mat_dash)
            else
                slotbtn:SetIcon(mat_plus)
            end

            -- slotbtn:SetTooltip(atttxt .. " slot (unoccupied)\n\nLMB - Customisation")
        end

        slotbtn:SetButtonText(atttxt)

        slotbtn.OnMousePressed = function(self2, kc)
            if kc == MOUSE_LEFT then
                surface.PlaySound(clicksound)
                self.BottomBarMode = 1
                self.BottomBarAddress = slot.Address
                self.BottomBarPath = {}
                self.BottomBarFolders = {}
                self.BottomBarAtts = {}
                self:CreateHUD_Bottom()
            elseif kc == MOUSE_RIGHT then
                if ms_slot.Integral and isstring(ms_slot.Integral) then
                    self:Attach(slot.Address, ms_slot.Integral)
                else
                    self:DetachAllFromSubSlot(slot.Address)
                end
                timer.Simple(0, function() self:CreateHUD_Bottom() end)
                -- self:CreateHUD_Bottom()
            end
        end

        slotbtn.Think = function(self2)
            if !IsValid(self) then return end

            -- if slotbtn.OverrideHovered then
            --     self.CustomizeLastHoveredSlot = self2
            --     self.CustomizeLastHoveredSlot.validforrand = true
            -- end

            if self2:IsHovered() then
                self.CustomizeHints["customize.hint.select"] = "customize.hint.expand"
                self.CustomizeHints["customize.hint.random"] = "customize.hint.randomize"
                if self2.slot.Installed then
                    self.CustomizeHints["customize.hint.deselect"] = "customize.hint.unattach"

                    if input.IsKeyDown(KEY_LSHIFT) then self2:SetTooltip(self2.slot.Installed) else self2:SetTooltip() end

					-- if atttbl.ToggleStats then
						-- self.CustomizeHints["customize.hint.toggleatts"] = "hud.hint.toggleatts"
					-- end
                end
                self2.slot.hovered = true
                self.CustomizeLastHoveredSlot = self2
            else
                self2.slot.hovered = false
            end
        end
    end
end