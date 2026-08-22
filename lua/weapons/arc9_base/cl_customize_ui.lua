local DevMode = false

local ARC9ScreenScale = ARC9.ScreenScale

-- Cycle the selected attachment
function SWEP:CycleSelectedAtt(amt, cyc)
    local activetab = self.CustomizeButtons[self.CustomizeTab + 1]
    if !(activetab.customize or activetab.personalize) then return end

    cyc = cyc or 0
    if #self.AttachmentAddresses <= 0 then return end
    if cyc > #self.AttachmentAddresses then return end

    local addr = self.BottomBarAddress or 1

    local newaddr = addr + amt

    if newaddr < 1 then
        newaddr = #self.AttachmentAddresses
    elseif newaddr > #self.AttachmentAddresses then
        newaddr = 1
    end

    self.BottomBarAddress = newaddr

    self.BottomBarPath = {}

    self.BottomBarMode = 1
    self.BottomBarFolders = {}
    self.BottomBarAtts = {}
    self:CreateHUD_Bottom()

    self.CustomizePanX = 0
    self.CustomizePanY = 0
    self.CustomizePitch = 0

    local slot = self:LocateSlotFromAddress(self.BottomBarAddress)

    if (activetab.customize and self:SlotIsCosmetic(slot)) or (activetab.personalize and !self:SlotIsCosmetic(slot)) or slot.Hidden or self:GetSlotBlocked(slot) then
        self:CycleSelectedAtt(1, cyc + 1)
    end
end

SWEP.CustomizeHUD = nil
SWEP.CustomizeBoxes = nil

SWEP.CustomizeTab = 0

local function swtichtoslotmenu(self)
    if GetConVar("arc9_cust_exit_reset_sel"):GetBool() and self.CustomizeHUD.lowerpanel.Extended then
        self.CustomizeHUD.lowerpanel.Extended = nil
        self.BottomBarMode = 0
        self.BottomBarAddress = nil
        self.BottomBarMode = 0
        self:CreateHUD_Bottom()
    end
end

local deadzonex = GetConVar("arc9_hud_deadzonex")

SWEP.CustomizeButtonsOriginal = {
    {
        title = "customize.panel.customize",
        func = function(self2)
            if self2.BottomBarCategory == 1 then
                self2.BottomBarAddress = nil
                self2.BottomBarMode = 0
                self2:CreateHUD_Bottom()
            end

            self2.BottomBarCategory = 0

            self2:ClearTabPanel()
            self2:CreateHUD_Bottom()

            swtichtoslotmenu(self2)

            if self2.CustomizeHUD.lowerpanel then
                if self2.CustomizeHUD.lowerpanel.Extended then
                    self2.CustomizeHUD.lowerpanel:MoveTo(ARC9ScreenScale(19) + deadzonex:GetInt(), ScrH() - ARC9ScreenScale(93+73.5), 0.2, 0, 0.5, nil)
                    self2.CustomizeHUD.lowerpanel:SizeTo(ScrW() - ARC9ScreenScale(38) - deadzonex:GetInt()*2, ARC9ScreenScale(74+73.5), 0.2, 0, 0.5, nil)
                else
                    self2.CustomizeHUD.lowerpanel:MoveTo(ARC9ScreenScale(19) + deadzonex:GetInt(), ScrH() - ARC9ScreenScale(93), 0.2, 0, 0.5, nil)
                    self2.CustomizeHUD.lowerpanel:SizeTo(ScrW() - ARC9ScreenScale(38) - deadzonex:GetInt()*2, ARC9ScreenScale(74), 0.2, 0, 0.5, nil)
                end

                self2:ClosePresetMenu()
                self2.CustomizeHUD.lowerpanel:AlphaTo(255, 0.2, 0, nil)
                self2.CustomizeHUD.topright_panel:AlphaTo(255, 0.2, 0, nil)
                self2.CustomizeHUD.topleft_panel:AlphaTo(255, 0.2, 0, nil)
            end
        end,
        customize = true,
        cutcorner = 1
    },
    {
        title = "customize.panel.personalize",
        func = function(self2)
            if self2.BottomBarCategory == 0 then
                self2.BottomBarAddress = nil
                self2.BottomBarMode = 0
                self2:CreateHUD_Bottom()
            end

            self2.BottomBarCategory = 1

            self2:ClearTabPanel()
            self2:CreateHUD_Bottom()

            swtichtoslotmenu(self2)

            if self2.CustomizeHUD.lowerpanel then
                if self2.CustomizeHUD.lowerpanel.Extended then
                    self2.CustomizeHUD.lowerpanel:MoveTo(ARC9ScreenScale(19) + deadzonex:GetInt(), ScrH() - ARC9ScreenScale(93+73.5), 0.2, 0, 0.5, nil)
                    self2.CustomizeHUD.lowerpanel:SizeTo(ScrW() - ARC9ScreenScale(38) - deadzonex:GetInt()*2, ARC9ScreenScale(74+73.5), 0.2, 0, 0.5, nil)
                else
                    self2.CustomizeHUD.lowerpanel:MoveTo(ARC9ScreenScale(19) + deadzonex:GetInt(), ScrH() - ARC9ScreenScale(93), 0.2, 0, 0.5, nil)
                    self2.CustomizeHUD.lowerpanel:SizeTo(ScrW() - ARC9ScreenScale(38) - deadzonex:GetInt()*2, ARC9ScreenScale(74), 0.2, 0, 0.5, nil)
                end

                self2:ClosePresetMenu()
                self2.CustomizeHUD.lowerpanel:AlphaTo(255, 0.2, 0, nil)
                self2.CustomizeHUD.topright_panel:AlphaTo(255, 0.2, 0, nil)
                self2.CustomizeHUD.topleft_panel:AlphaTo(255, 0.2, 0, nil)
            end
        end,
        personalize = true,
        cutcorner = 0
    },
    -- {
    --     title = "STATS",
    --     func = function(self2)
    --         self2:CreateHUD_Stats()

    --         if self2.CustomizeHUD.lowerpanel then
    --             self2.CustomizeHUD.lowerpanel.Extended = nil

    --             self2:ClosePresetMenu()

    --             self2.CustomizeHUD.lowerpanel:MoveTo(ARC9ScreenScale(19), ScrH()-ARC9ScreenScale(93+50), 0.2, 0, 0.5, nil)
    --             self2.CustomizeHUD.lowerpanel:SizeTo(ScrW() - ARC9ScreenScale(38), ARC9ScreenScale(74+50), 0.2, 0, 0.5, nil)

    --             self2.CustomizeHUD.lowerpanel:AlphaTo(255, 0.2, 0, nil)
    --             self2.CustomizeHUD.topright_panel:AlphaTo(255, 0.2, 0, nil)
    --             self2.CustomizeHUD.topleft_panel:AlphaTo(255, 0.2, 0, nil)
    --         end
    --     end
    -- },
    {
        title = "customize.panel.stats",
        func = function(self2)
            self2:CreateHUD_Bench()

            if self2.CustomizeHUD.lowerpanel then
                self2.CustomizeHUD.lowerpanel.Extended = nil

                self2:ClosePresetMenu()

                -- self2.CustomizeHUD.lowerpanel:MoveTo(ARC9ScreenScale(19), ScrH() - ARC9ScreenScale(93-55-22.75), 0.2, 0, 0.5, nil)
                -- self2.CustomizeHUD.lowerpanel:SizeTo(ScrW() - ARC9ScreenScale(38), ARC9ScreenScale(74-55), 0.2, 0, 0.5, nil)

                self2.CustomizeHUD.lowerpanel:MoveTo(ARC9ScreenScale(19) + deadzonex:GetInt(), ScrH()-ARC9ScreenScale(93+50), 0.2, 0, 0.5, nil)
                self2.CustomizeHUD.lowerpanel:SizeTo(ScrW() - ARC9ScreenScale(38) - deadzonex:GetInt()*2, ARC9ScreenScale(74+50), 0.2, 0, 0.5, nil)

                self2.CustomizeHUD.lowerpanel:AlphaTo(255, 0.2, 0, nil)
                self2.CustomizeHUD.topright_panel:AlphaTo(255, 0.2, 0, nil)
                self2.CustomizeHUD.topleft_panel:AlphaTo(255, 0.2, 0, nil)
            end
        end
    },
    {
        title = "customize.panel.trivia",
        func = function(self2)
            self2:CreateHUD_Trivia()

            if self2.CustomizeHUD.lowerpanel then
                self2.CustomizeHUD.lowerpanel.Extended = nil

                self2:ClosePresetMenu()

                self2.CustomizeHUD.lowerpanel:MoveTo(ARC9ScreenScale(19) + deadzonex:GetInt(), ScrH()-ARC9ScreenScale(93+50), 0.2, 0, 0.5, nil)
                self2.CustomizeHUD.lowerpanel:SizeTo(ScrW() - ARC9ScreenScale(38) - deadzonex:GetInt()*2, ARC9ScreenScale(74+50), 0.2, 0, 0.5, nil)

                self2.CustomizeHUD.lowerpanel:AlphaTo(255, 0.2, 0, nil)
                self2.CustomizeHUD.topright_panel:AlphaTo(255, 0.2, 0, nil)
                self2.CustomizeHUD.topleft_panel:AlphaTo(255, 0.2, 0, nil)
            end
        end,
        cutcorner = 2
    },
    {
        title = "customize.panel.inspect",
        func = function(self2, page)
            self2:ClearTabPanel()

            if self2.LastCustomizeTab == page then
                self2.CustomizeTab = 0
                self2.CustomizeButtons[1].func(self2)
            elseif self2.CustomizeHUD.lowerpanel then
                self2.CustomizeHUD.lowerpanel.Extended = nil

                self2:ClosePresetMenu()

                self2.CustomizeHUD.lowerpanel:MoveTo(ARC9ScreenScale(19) + deadzonex:GetInt(), ScrH() - ARC9ScreenScale(93-55-22.75), 0.2, 0, 0.5, nil)
                self2.CustomizeHUD.lowerpanel:SizeTo(ScrW() - ARC9ScreenScale(38) - deadzonex:GetInt()*2, ARC9ScreenScale(74-55), 0.2, 0, 0.5, nil)

                self2.CustomizeAlphaBuffer = math.max(self2.CustomizeAlphaBuffer or 0, CurTime() + 0.5)
            end
        end,
        inspect = true,
        cutcorner = 3
    },
}

SWEP.CustomizeButtons = table.Copy(SWEP.CustomizeButtonsOriginal)

SWEP.TabPanel = nil

function SWEP:ClearTabPanel()
    if self.TabPanel then
        self.TabPanel:Remove()
        self.TabPanel = nil
    end

    self:ClearBottomBar()
end

function SWEP:RefreshCustomizeMenu()
end

local mat_3dslot = Material("arc9/ui/3d_slot.png", "mips smooth")
local mat_3dslot_empty = Material("arc9/ui/3d_slot_empty.png", "mips smooth")
local mat_gear = Material("arc9/gear.png", "mips smooth")
local mat_plus = Material("arc9/ui/plus.png")
local mat_dash = Material("arc9/ui/dash.png")
local mat_info = Material("arc9/ui/info.png")

local lmbdown = false
local rmbdown = false

local lastmousex = 0
local lastmousey = 0

local dragging = false
local dragging_r = false
local dragging_m = false

SWEP.CustomizePanX = 0
SWEP.CustomizePanY = 0

SWEP.CustomizePitch = 0
SWEP.CustomizeYaw = 0
SWEP.CustomizeRoll = 0

SWEP.CustomizeZoom = 0

SWEP.CustomizeHints = {}

local gpX = 0
local gpY = 0

local Press1 = false
local Press2 = false

local Release1 = false
local Release2 = false
local setscroll = 0
hook.Add("StartCommand", "ARC9_GamepadHUD", function(ply, cmd)
    if IsValid(LocalPlayer()) and IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon().ARC9 and LocalPlayer():GetActiveWeapon():GetCustomize() then
        local wpn = LocalPlayer():GetActiveWeapon()

        local pox = math.Round(math.TimeFraction(-32768, 32767, input.GetAnalogValue(ANALOG_JOY_U))-0.5, 1)*2
        local poy = math.Round(math.TimeFraction(-32768, 32767, input.GetAnalogValue(ANALOG_JOY_R))-0.5, 1)*2

        local p1x = math.Round(math.TimeFraction(-32768, 32767, input.GetAnalogValue(ANALOG_JOY_X))-0.5, 1)*2
        local p1y = math.Round(math.TimeFraction(-32768, 32767, input.GetAnalogValue(ANALOG_JOY_Y))-0.5, 1)*2

        if ARC9.ControllerMode() then
            if cmd:KeyDown(IN_JUMP) then
                cmd:RemoveKey(IN_JUMP)
                if !Press1 then
                    gui.InternalMousePressed(MOUSE_LEFT)
                    Press1 = true
                end
                Release1 = true
            else
                if Release1 then
                    gui.InternalMouseReleased(MOUSE_LEFT)
                    Release1 = false
                    Press1 = false
                end
            end
            if cmd:KeyDown(IN_USE) then
                cmd:RemoveKey(IN_USE)
                if !Press2 then
                    gui.InternalMousePressed(MOUSE_RIGHT)
                    Press2 = true
                end
                Release2 = true
            else
                if Release2 then
                    gui.InternalMouseReleased(MOUSE_RIGHT)
                    Release2 = false
                    Press2 = false
                end
            end
        -- end

        -- if true then
            local cx, cy = input.GetCursorPos()

            gpX = ((pox * 160 * (ScrH() / 480)) * RealFrameTime())
            gpY = ((poy * 160 * (ScrH() / 480)) * RealFrameTime())
            input.SetCursorPos(cx+gpX, cy+gpY)
            gpX = 0
            gpY = 0
        end

        if cmd:KeyDown(IN_USE) then
            wpn.CustomizePanX = wpn.CustomizePanX + (p1x * 5 * RealFrameTime())
            wpn.CustomizePanY = wpn.CustomizePanY + (p1y * 5 * RealFrameTime())
        else
            wpn.CustomizePitch = wpn.CustomizePitch - (p1x * 45 * RealFrameTime())
            wpn.CustomizeYaw   = wpn.CustomizeYaw   + (p1y * 1 * RealFrameTime())
        end

        gui.InternalMouseWheeled(setscroll)
        setscroll = 0
    end
end)

local doop = 0
hook.Add("PlayerBindPress", "ARC9_GamepadHUDBinds", function(ply, bind, pressed, code)
    if IsValid(LocalPlayer()) and IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon().ARC9 and LocalPlayer():GetActiveWeapon():GetCustomize() and ARC9.ControllerMode() then
        if bind == "invprev" then
            if doop % 2 == 0 then setscroll = 1 end
            doop = doop + 1
            return true
        elseif bind == "invnext" then
            if doop % 2 == 0 then setscroll = -1 end
            doop = doop + 1
            return true
        end
    end
end)


local ghs = {
    Material("arc9/seasonal/g1.png", "mips smooth"),
    Material("arc9/seasonal/g2.png", "mips smooth"),
    Material("arc9/seasonal/g3.png", "mips smooth"),
    Material("arc9/seasonal/g4.png", "mips smooth"),
    Material("arc9/seasonal/g5.png", "mips smooth"),
    Material("arc9/seasonal/g6.png", "mips smooth"),
}
local bday = {
    Material("arc9/seasonal/birthday1.png", "mips smooth"),
    Material("arc9/seasonal/birthday2.png", "mips smooth"),
    Material("arc9/seasonal/birthday3.png", "mips smooth"),
}
local troll = {
    Material("arc9/seasonal/troll.png", "mips smooth"),
    Material("arc9/seasonal/fuuu.png", "mips smooth")
}
local SeasonalHalloween = {}
local SeasonalHolidays = {}

local hoversound = "arc9/newui/uimouse_hover.ogg"
local clicksound = "arc9/newui/uimouse_click.ogg"
local opensound = "arc9/newui/uimouse_click_forward.ogg"
local backsound = "arc9/newui/uimouse_click_return.ogg"
local popupsound = "arc9/newui/uimouse_click_popup.ogg"
local closesound = "arc9/newui/ui_close.ogg"
local lightonsound = "arc9/newui/ui_light_on.ogg"
local lightoffsound = "arc9/newui/ui_light_off.ogg"
local tabsound = "arc9/newui/uimouse_click_tab.ogg"

function SWEP:CreateCustomizeHUD()
    if !IsValid(self) then return end

    local bg = vgui.Create("DPanel")

    self.CustomizeHUD = bg

    gui.EnableScreenClicker(true)

    surface.PlaySound("arc9/newui/ui_open.ogg") -- w

    gpX = ScrW()/2
    gpY = ScrH()/2

    bg:SetPos(0, 0)
    bg:SetSize(ScrW(), ScrH())

    bg.OnRemove = function(self2)
        if !IsValid(self) then return end
        -- self:SavePreset()
    end

    bg.OnMouseWheeled = function(self2, sd)
        if !IsValid(self) then return end
        if !self2:IsHovered() then return false end -- to prevent wheeling outside area

        self.CustomizeZoom = self.CustomizeZoom - (sd * 2)

        self.CustomizeZoom = math.Clamp(self.CustomizeZoom, -64, 64)
    end

    bg:SetMouseInputEnabled(true)

    table.Empty(SeasonalHalloween)
    table.Empty(SeasonalHolidays)
    if ARC9.ActiveHolidays["Christmas"] then
        bg.Posh = 0
    end

    bg.Paint = function(self2, w, h)
        if !IsValid(self) or LocalPlayer():GetActiveWeapon() != self then
            self2:Remove()
            gui.EnableScreenClicker(false)
            return
        end

        --[[
        if DevMode then
            surface.SetFont("ARC9_10")
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            surface.SetTextPos((w/2) - 10, ARC9ScreenScale(5))
            surface.DrawText("Developer mode")

            surface.SetFont("ARC9_8")

            surface.SetTextColor(255, 174, 0)
            surface.SetTextPos((w/2) - 10, ARC9ScreenScale(16))
            surface.DrawText("bone pos")
            surface.SetTextColor(230, 166, 255)
            surface.SetTextPos((w/2) - 10, ARC9ScreenScale(23))
            surface.DrawText("icon pos")
            surface.SetTextColor(206, 90, 90)
            surface.SetTextPos((w/2) - 10, ARC9ScreenScale(30))
            surface.DrawText("att pos")

        elseif ARC9.ActiveHolidays["Troll Day"] then
            do  -- nice text
                surface.SetFont("ARC9_10")
                local tx = "problem?"
                local tz = surface.GetTextSize(tx)
                surface.SetTextPos((w/2) - (tz/2)+ARC9ScreenScale(1), ARC9ScreenScale(16+1))
                surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                surface.DrawText(tx)
                surface.SetTextPos((w/2) - (tz/2), ARC9ScreenScale(16))
                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                surface.DrawText(tx)
            end

            surface.SetDrawColor(255, 255, 255, 255 / 64)

            for i, v in ipairs(SeasonalHalloween) do
                if isnumber(v.mat) then continue end -- fuck off
                surface.SetMaterial(v.mat)
                local si = ARC9ScreenScale(32)


                v.x = v.x + (v.px * 2 * FrameTime())
                v.y = v.y + (v.py2 * 2 * FrameTime())
                v.py = math.sin((CurTime() + (i / i)) * math.pi * 0.5) * ARC9ScreenScale(8)

                surface.DrawTexturedRectRotated(v.x + v.px, v.y + v.py, si, si, math.sin((CurTime() + (i / i)) * math.pi) * 15)

                if v.x >= w then
                    v.x = 0
                elseif v.x <= 0 then
                    v.x = w
                end

                if v.y >= h then
                    v.y = 0
                elseif v.y <= 0 then
                    v.y = h
                end
            end

            if table.IsEmpty(SeasonalHalloween) then
                for i=1, 13 do
                    table.insert(SeasonalHalloween,
                        {
                            x = w*math.Rand(0, 1),
                            y = h*math.Rand(0, 1),
                            px = math.Rand(-1, 1),
                            py = 0,
                            py2 = math.Rand(-1, 1),
                            mat = table.Random(troll),
                        }
                   )
                end
            end

        elseif ARC9.ActiveHolidays["Birthday - Arctic"] then

            do  -- nice text
                surface.SetFont("ARC9_10")
                local tx = "Happy Birthday to Arctic!"
                local tz = surface.GetTextSize(tx)
                surface.SetTextPos((w/2) - (tz/2)+ARC9ScreenScale(1), ARC9ScreenScale(16+1))
                surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                surface.DrawText(tx)
                surface.SetTextPos((w/2) - (tz/2), ARC9ScreenScale(16))
                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                surface.DrawText(tx)
            end

            surface.SetDrawColor(255, 255, 255, 255/64)

            for i, v in ipairs(SeasonalHalloween) do
                if isnumber(v.mat) then continue end -- fuck off
                surface.SetMaterial(v.mat)
                local si = ARC9ScreenScale(32)


                v.x = v.x + (v.px * 2 * FrameTime())
                v.y = v.y + (v.py2 * 2 * FrameTime())
                v.py = math.sin((CurTime() + (i / i)) * math.pi * 0.5) * ARC9ScreenScale(8)

                surface.DrawTexturedRectRotated(v.x + v.px, v.y + v.py, si, si, math.sin((CurTime() + (i / i)) * math.pi) * 15)

                if v.y >= h then
                    v.y = 0
                    v.x = w*math.Rand(0, 1)
                elseif v.y <= 0 then
                    v.y = h
                    v.x = w*math.Rand(0, 1)
                end
            end

            if table.IsEmpty(SeasonalHalloween) then
                for i=1, 10 do
                    table.insert(SeasonalHalloween,
                        {
                            x = w*math.Rand(0, 1),
                            y = h*math.Rand(0, 1),
                            px = 0,
                            py = 0,
                            py2 = math.Rand(60, 120),
                            mat = table.Random(bday),
                        }
                   )
                end
            end
        elseif ARC9.ActiveHolidays["Summer Break"] then
            do  -- nice text
                surface.SetFont("ARC9_10")
                local tx = "Summer break!"
                local tz = surface.GetTextSize(tx)
                surface.SetTextPos((w/2) - (tz/2)+ARC9ScreenScale(1), ARC9ScreenScale(16+1))
                surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                surface.DrawText(tx)
                surface.SetTextPos((w/2) - (tz/2), ARC9ScreenScale(16))
                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                surface.DrawText(tx)
            end

            surface.SetDrawColor(255, 255, 127, 255*0.04)
            surface.SetMaterial(Material("arc9/seasonal/sun.png", "mips smooth"))
            local si = ARC9ScreenScale(256)
            surface.DrawTexturedRectRotated(w-ARC9ScreenScale(32), ARC9ScreenScale(32), si, si, CurTime()*3)
        elseif ARC9.ActiveHolidays["Halloween"] then

            do  -- nice text
                surface.SetFont("ARC9_10")
                local tx = "Happy Halloween!"
                local tz = surface.GetTextSize(tx)
                surface.SetTextPos((w/2) - (tz/2)+ARC9ScreenScale(1), ARC9ScreenScale(16+1))
                surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                surface.DrawText(tx)
                surface.SetTextPos((w/2) - (tz/2), ARC9ScreenScale(16))
                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                surface.DrawText(tx)
            end

            surface.SetDrawColor(255, 255, 255, 255/64)

            for i, v in ipairs(SeasonalHalloween) do
                if isnumber(v.mat) then continue end -- fuck off
                surface.SetMaterial(v.mat)
                local si = ARC9ScreenScale(32)


                v.x = v.x + (v.px * 2 * FrameTime())
                v.y = v.y + (v.py2 * 2 * FrameTime())
                v.py = math.sin((CurTime() + (i / i)) * math.pi * 0.5) * ARC9ScreenScale(8)

                surface.DrawTexturedRectRotated(v.x + v.px, v.y + v.py, si, si, math.sin((CurTime() + (i / i)) * math.pi) * 15)

                if v.x >= w then
                    v.x = 0
                elseif v.x <= 0 then
                    v.x = w
                end

                if v.y >= h then
                    v.y = 0
                elseif v.y <= 0 then
                    v.y = h
                end
            end

            if table.IsEmpty(SeasonalHalloween) then
                for i=1, 13 do
                    table.insert(SeasonalHalloween,
                        {
                            x = w*math.Rand(0, 1),
                            y = h*math.Rand(0, 1),
                            px = math.Rand(-1, 1),
                            py = 0,
                            py2 = math.Rand(-1, 1),
                            mat = table.Random(ghs),
                        }
                   )
                end
            end
        elseif ARC9.ActiveHolidays["Christmas"] then

            do  -- nice text
                surface.SetFont("ARC9_10")
                local tx = "Happy Holidays!"
                local tz = surface.GetTextSize(tx)
                surface.SetTextPos((w/2) - (tz/2)+ARC9ScreenScale(1), ARC9ScreenScale(16+1))
                surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                surface.DrawText(tx)
                surface.SetTextPos((w/2) - (tz/2), ARC9ScreenScale(16))
                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                surface.DrawText(tx)
            end

            surface.SetDrawColor(255, 255, 255, 255/32)
            surface.SetMaterial(Material("arc9/seasonal/hills.png", "smooth"))
            bg.Posh = math.Approach(bg.Posh or 0, 2, FrameTime() * (1/20))
            if bg.Posh > 1 then
                bg.Posh = 0
            end
            surface.DrawTexturedRect(
                math.Round(0-(ARC9ScreenScale(1024)*bg.Posh), 0),
                h-ARC9ScreenScale(1024/8*0.75) + ((math.sin(CurTime() * math.pi / 10)) * ARC9ScreenScale(16)),
                ARC9ScreenScale(1024),
                ARC9ScreenScale(1024/8)
           )
            surface.DrawTexturedRect(
                math.Round(0+ARC9ScreenScale(1024)-(ARC9ScreenScale(1024)*bg.Posh), 0),
                h-ARC9ScreenScale(1024/8*0.75) + ((math.sin(CurTime() * math.pi / 10)) * ARC9ScreenScale(16)),
                ARC9ScreenScale(1024),
                ARC9ScreenScale(1024/8)
           )

            for i, v in ipairs(SeasonalHolidays) do
                surface.SetMaterial(Material("arc9/seasonal/snowflake.png", "mips smooth"))
                local si = ARC9ScreenScale(16)

                surface.DrawTexturedRectRotated(v[1], v[2], si, si, v[5] or 0)
                v[1] = math.Approach(v[1], v[1] + v[3], FrameTime() * ARC9ScreenScale(1) * 20 * v[3])
                v[2] = math.Approach(v[2], h, FrameTime() * ARC9ScreenScale(1) * 20 * v[4])
                v[5] = math.Approach(v[5] or 0, 370, FrameTime() * ARC9ScreenScale(1) * 20 * v[4])
                if v[2] >= h then
                    v[2] = ARC9ScreenScale(-16)
                end
                if math.abs(v[1]) >= w then
                    v[2] = ARC9ScreenScale(-16)
                    v[1] = w*math.Rand(0, 1)
                end
                if math.abs(v[5]) >= 360 then
                    v[5] = 0
                end
            end

            if table.IsEmpty(SeasonalHolidays) then
                for i=1, 32 do
                    table.insert(SeasonalHolidays,
                        {
                            [1] = w*math.Rand(0, 1),
                            [2] = -h*math.Rand(0, 0.5),
                            [3] = math.Rand(-4, 4),
                            [4] = math.Rand(0.5, 4),
                            [5] = 0,
                        }
                   )
                end
            end
        end
        ]]

        if ARC9.ControllerMode() then
            --[[surface.SetMaterial(Material("arc9/gamepad/corner.png", ""))
            surface.SetDrawColor(255, 255, 255, 255)

            local si = ARC9ScreenScale(6)
            local of = si/2
            local bo = si*2
            surface.DrawTexturedRectRotated(of, of, si, si, 0)
            surface.DrawTexturedRectRotated(of+bo, of, si, si, 270)
            surface.DrawTexturedRectRotated(of+bo, of+bo, si, si, 180)
            surface.DrawTexturedRectRotated(of, of+bo, si, si, 90)

            surface.SetMaterial(Material("arc9/gamepad/pointer.png", ""))
            surface.DrawTexturedRect(si, si, si, si)

            surface.SetMaterial(mat_grad)
            surface.SetDrawColor(0, 0, 0, 250)
            surface.DrawTexturedRect(w - h, 0, h, h)]]--
        end

        local bumpy = {}

        local anyhovered = false

        local function isinaabb(x, y)
            if !self2:IsHovered() then return false end -- to prevent clicking outside area
            if anyhovered then return false end

            local mousex, mousey = input.GetCursorPos()

            local s = ARC9ScreenScale(10) - self.CustomizeZoom * 1.5


            if mousex >= x - s and mousex <= x + s and mousey >= y - (s / 2) and mousey <= y + (s / 2) then
                anyhovered = true
                return true
            else
                return false
            end
        end

        if self.CustomizeButtons[self.CustomizeTab + 1].customize or self.CustomizeButtons[self.CustomizeTab + 1].personalize then

            cam.Start3D(nil, nil, self:WidescreenFix(self:GetViewModelFOV()))

            for _, slot in ipairs(self:GetSubSlotList()) do
                if slot.Hidden then continue end
                if !slot.Pos then continue end
                if !slot.Bone then continue end
                local ms_slot = self:GetFilledMergeSlot(slot.Address)

                if self.BottomBarCategory == 0 and self:SlotIsCosmetic(ms_slot) then continue end
                if self.BottomBarCategory == 1 and !self:SlotIsCosmetic(ms_slot) then continue end

                if !ms_slot.Installed and self:GetSlotBlocked(slot) then continue end

                local atttbl = self:GetFinalAttTable(ms_slot)

                local attpos, attang, icon_offset = self:GetAttachmentPos(slot, false, false, true)
                local attposOffset = attpos

                icon_offset = icon_offset + (atttbl.IconOffset or atttbl.Icon_Offset or vector_origin)

                attposOffset = attposOffset + attang:Right() * icon_offset.y
                attposOffset = attposOffset + attang:Up() * icon_offset.z
                attposOffset = attposOffset + attang:Forward() * icon_offset.x

                local toscreen = attpos:ToScreen()
                local toscreenOffset = attposOffset:ToScreen()

                cam.Start2D()

                local x, y = toscreenOffset.x, toscreenOffset.y
                local xUOS, yUOS = toscreen.x, toscreen.y -- unoffsetted

                local s = ARC9ScreenScale(16) - self.CustomizeZoom * 1.5

                local hoveredslot = false
                ms_slot.fuckinghovered = false

                local dist = 0

                local mousex, mousey = input.GetCursorPos()

                if isinaabb(x, y) then
                    hoveredslot = true
                    dist = math.Distance(x, y, mousex, mousey)

                    for _, bump in ipairs(bumpy) do
                        if isinaabb(bump.x, bump.y) then
                            local d2 = math.Distance(bump.x, bump.y, mousex, mousey)

                            if d2 < dist then
                                hoveredslot = false
                                ms_slot.fuckinghovered = false
                                break
                            end
                        end
                    end
                end

                if mousey > (ScrH() - ARC9ScreenScale(64)) then hoveredslot = false ms_slot.fuckinghovered = false end

                table.insert(bumpy, {x = x, y = y, slot = slot})

                local col = ARC9.GetHUDColor("notoccupied")

                local showname = false

                if hoveredslot or ms_slot.hovered then
                    col = ARC9.GetHUDColor("hi")
                    showname = true
                elseif self.BottomBarAddress == ms_slot.Address then
                    col = ARC9.GetHUDColor("hi")
                elseif slot.Installed then
                    col = ARC9.GetHUDColor("fg")
                end

                if hoveredslot then
                    ms_slot.fuckinghovered = true
                    self.CustomizeLastHoveredSlot2 = ms_slot

                    self.CustomizeHints["customize.hint.select"] = "customize.hint.expand"
                    self.CustomizeHints["customize.hint.random"] = "customize.hint.randomize"
                    if slot.Installed then
                        self.CustomizeHints["customize.hint.deselect"] = "customize.hint.unattach"
                        if atttbl.ToggleStats and !atttbl.AdvancedCamoSupport then
							self.CustomizeHints["customize.hint.toggleatts"] = "hud.hint.toggleatts"
                        elseif atttbl.ToggleStats and (atttbl.AdvancedCamoSupport and self.AdvancedCamoCache) then
                            self.CustomizeHints["customize.hint.toggleatts"] = "hud.hint.togglecamos"
                        end
                    end
                end

                if DevMode then
                    -- local bonepos = self:GetVM():GetBonePosition(self:GetVM():LookupBone(slot.Bone))
                    local bonepos =  self:GetVM():GetBoneMatrix(self:GetVM():LookupBone(slot.Bone)):GetTranslation()
                    local bonepostoscreen = bonepos:ToScreen()
                    local boneposX, boneposY = bonepostoscreen.x, bonepostoscreen.y

                    surface.SetFont("ARC9_4")

                    -- att

                    surface.SetDrawColor(206, 90, 90)
                    surface.DrawRect(xUOS-5, yUOS-5, 10, 10)

                    surface.SetDrawColor(230, 166, 255)
                    surface.DrawLine(x, y, xUOS, yUOS)
                    surface.DrawRect(x-2.5, y-2.5, 5, 5)

                    surface.SetTextColor(230, 166, 255)
                    surface.SetTextPos(x, y-20)
                    surface.DrawText(slot.PrintName)

                    -- bone
                    surface.SetDrawColor(255, 174, 0)
                    surface.DrawLine(xUOS, yUOS, boneposX, boneposY)
                    surface.DrawRect(boneposX-2.5, boneposY-2.5, 5, 5)

                    surface.SetTextColor(255, 174, 0)
                    surface.SetTextPos(boneposX, boneposY)
                    surface.DrawText(slot.Bone)
                else
                    if ms_slot.SubAttachments then
                        local isparenttosomething = false

                        for _, p in ipairs(ms_slot.SubAttachments) do
                            if p.Installed then isparenttosomething = true end
                        end

                        if isparenttosomething then
                            s = s * 0.6
                            col = ARC9.GetHUDColor("hi", 75)
                        end
                    end

                    x, y = x-s/2, y-s/2

                    surface.SetMaterial(mat_3dslot)
                    surface.SetDrawColor(col)
                    surface.DrawTexturedRect(x, y, s, s)

                    local atttxt = ARC9:GetPhrase(ms_slot.PrintName) or ms_slot.PrintName or "SLOT"

                    if ms_slot.Installed then
                        atttxt = ARC9:GetPhraseForAtt(ms_slot.Installed, "CompactName")
                        atttxt = atttxt or ARC9:GetPhraseForAtt(ms_slot.Installed, "PrintName") or ""

                        surface.SetMaterial(atttbl.Icon or mat_3dslot)
                        surface.SetDrawColor(ARC9.GetHUDColor("fg"))
                        render.SuppressEngineLighting(true)
                        if !atttbl.FullColorIcon then
                            surface.DrawTexturedRect(x + ARC9ScreenScale(1), y + ARC9ScreenScale(1), s - ARC9ScreenScale(2), s - ARC9ScreenScale(2))
                        else
                            surface.DrawTexturedRect(x + ARC9ScreenScale(3), y + ARC9ScreenScale(3), s - ARC9ScreenScale(6), s - ARC9ScreenScale(6))
                        end
                        render.SuppressEngineLighting(false)
                    else
                        if ms_slot.DefaultCompactName then
                            atttxt = ARC9:UseTrueNames() and ms_slot.DefaultCompactName_TrueName or ms_slot.DefaultCompactName
                            atttxt = atttxt or ms_slot.DefaultName_TrueName or ms_slot.DefaultName or ""
                        end

                        if ms_slot.DefaultIcon then
                            surface.SetMaterial(ms_slot.DefaultIcon)
                        elseif GetConVar("arc9_atts_nocustomize"):GetBool() then
                            surface.SetMaterial(mat_dash)
                        else
                            surface.SetMaterial(mat_plus)
                        end

                        surface.SetDrawColor(ARC9.GetHUDColor("fg"))
                        surface.DrawTexturedRect(x + ARC9ScreenScale(1), y + ARC9ScreenScale(1), s - ARC9ScreenScale(2), s - ARC9ScreenScale(2))
                    end

                    if showname then
                        surface.SetFont("ARC9_8")
                        local tw = surface.GetTextSize(atttxt)
                        surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                        surface.SetTextPos(x + (s / 2) - (tw / 2) + 1, y + s + ARC9ScreenScale(1.3)) -- x + s + ARC9ScreenScale(2), y + (s / 2)
                        surface.DrawText(atttxt)
                        surface.SetTextColor(ARC9.GetHUDColor("fg"))
                        surface.SetTextPos(x + (s / 2) - (tw / 2), y + s + ARC9ScreenScale(1)) -- x + s + ARC9ScreenScale(2), y + (s / 2)
                        surface.DrawText(atttxt)
                    end
                end

                if hoveredslot then
                    if IsValid(ms_slot.lowerbutton) then ms_slot.lowerbutton:SetOverrideHovered(true) end

                    if input.IsMouseDown(MOUSE_LEFT) and !lmbdown and (self.BottomBarAddress != slot.Address or self.BottomBarMode != 1) then
                        self.BottomBarMode = 1
                        self.BottomBarAddress = slot.Address
                        self.BottomBarPath = {}
                        self.BottomBarFolders = {}
                        self.BottomBarAtts = {}
                        self:CreateHUD_Bottom()

                        -- self.CustomizePanX = 0
                        -- self.CustomizePanY = 0
                        -- self.CustomizePitch = 0
                        surface.PlaySound(clicksound)

                    elseif input.IsMouseDown(MOUSE_RIGHT) and !rmbdown then
                        if ms_slot.Integral and isstring(ms_slot.Integral) then
                            self:Attach(slot.Address, ms_slot.Integral)
                        else
                            self:DetachAllFromSubSlot(slot.Address)
                        end
                        self.BottomBarPath = {}
                        self.BottomBarFolders = {}
                        self.BottomBarAtts = {}
                        timer.Simple(0, function()
                            if !IsValid(self) then return end
                            self:CreateHUD_Bottom()
                        end)
                    end
                else
                    if IsValid(ms_slot.lowerbutton) then ms_slot.lowerbutton:SetOverrideHovered(false) end
                end

                cam.End2D()
            end

            cam.End3D()

        end

        if dragging then
            self2:SetCursor("sizeall")

            if !input.IsMouseDown(MOUSE_LEFT) then
                dragging = false
            else
                local mousex, mousey = input.GetCursorPos()

                local dx = mousex - lastmousex
                local dy = mousey - lastmousey

                self.CustomizePanX = self.CustomizePanX + (dx / ARC9ScreenScale(32))
                self.CustomizePanY = self.CustomizePanY + (dy / ARC9ScreenScale(32))

                self.CustomizePanX = math.Clamp(self.CustomizePanX, -16, 16)
                self.CustomizePanY = math.Clamp(self.CustomizePanY, -8, 8)
            end
        elseif dragging_r then
            self2:SetCursor("sizewe")

            if !input.IsMouseDown(MOUSE_RIGHT) then
                dragging_r = false
            else
                local mousex, mousey = input.GetCursorPos()

                local dx = mousex - lastmousex
                local dy = mousey - lastmousey

                self.CustomizePitch = self.CustomizePitch - (dx / ARC9ScreenScale(4)) * 3
                -- self.CustomizeYaw = math.Clamp(self.CustomizeYaw + (dy / ARC9ScreenScale(8)) * (math.floor(self.CustomizePitch / 90) % 2 == 0 and 1 or -1), -30, 30)
                self.CustomizeYaw = self.CustomizeYaw + (dy / ARC9ScreenScale(8)) * 3
            end
        
        elseif dragging_m then
            self2:SetCursor("sizenesw")

            if !input.IsMouseDown(MOUSE_MIDDLE) then
                dragging_m = false
            else
                local mousex, mousey = input.GetCursorPos()

                local dx = mousex - lastmousex
                local dy = mousey - lastmousey

                self.CustomizeRoll = self.CustomizeRoll + (dx / ARC9ScreenScale(8)) * 3
            end
        elseif input.IsKeyDown(KEY_R) and self2:IsHovered() then
            if self.CustomizeLastHoveredSlot2 then
                if self.CustomizeLastHoveredSlot2.fuckinghovered then return end
            end
            self.CustomizePanX = Lerp(0.25, self.CustomizePanX, 0)
            self.CustomizePanY = Lerp(0.25, self.CustomizePanY, 0)
            self.CustomizePitch = Lerp(0.25, self.CustomizePitch, 0)
            self.CustomizeYaw = Lerp(0.25, self.CustomizeYaw, 0)
            self.CustomizeRoll = Lerp(0.25, self.CustomizeRoll, 0)
            self.CustomizeZoom = Lerp(0.25, self.CustomizeZoom, 0)
        elseif !anyhovered then
            self2:SetCursor("arrow")

            if input.IsMouseDown(MOUSE_LEFT) and !lmbdown and self2:IsHovered() then
                dragging = true
                lastmousex, lastmousey = input.GetCursorPos()
            end

            if input.IsMouseDown(MOUSE_RIGHT) and !rmbdown and self2:IsHovered() then
                dragging_r = true
                lastmousex, lastmousey = input.GetCursorPos()
            end

            if input.IsMouseDown(MOUSE_MIDDLE) and !rmbdown and self2:IsHovered() then
                dragging_m = true
                lastmousex, lastmousey = input.GetCursorPos()
            end
        elseif anyhovered then
            self2:SetCursor("hand")
        end

        lastmousex, lastmousey = input.GetCursorPos()

        lmbdown = input.IsMouseDown(MOUSE_LEFT)
        rmbdown = input.IsMouseDown(MOUSE_RIGHT)
    end

    self:CreateHUD_RHP()

    bg:MoveToFront()

    local trolling = ""
    if ARC9.ControllerMode() then
        trolling = { -- Controller Mode
            {
                action = "customize.hint.select",
                glyph = ARC9.GetBindKey("+jump"),
                hidden = true,
            },
            {
                action = "customize.hint.deselect",
                glyph = ARC9.GetBindKey("+use"),
                hidden = true,
            },
            {
                action = "customize.hint.zoom",
                glyph = ARC9.GetBindKey("invprev"),
                glyph2 = ARC9.GetBindKey("invnext"),
                row2 = true,
            },
            {
                action = "customize.hint.pan",
                glyph = ARC9.GetBindKey("+attack"),
                glyph2 = "shared_touch",
                row2 = true,
            },
            {
                action = "customize.hint.rotate",
                glyph = ARC9.GetBindKey("+attack2"),
                glyph2 = "shared_touch",
                row2 = true,
            },
            {
                action = "customize.hint.recenter",
                glyph = ARC9.GetBindKey("+reload"),
                row3 = true,
            },
            {
                action = "customize.hint.cycle",
                glyph = ARC9.GetBindKey("+showscores"),
                row3 = true,
            },
            {
                action = "customize.hint.last",
                glyph = ARC9.GetBindKey("+use"),
                glyph2 = ARC9.GetBindKey("+showscores"),
                row3 = true,
            },
            {
                action = "customize.hint.favorite",
                glyph = ARC9.GetBindKey("impulse 100"),
                hidden = true,
            },
            {
                action = "customize.hint.random",
                glyph = ARC9.GetBindKey("+reload"),
                hidden = true,
            },
            {
                action = "customize.hint.toggleatts",
                glyph = ARC9.GetBindKey("+zoom"),
                hidden = true,
            },
        }
    else
        trolling = { -- Mouse & Keyboard
            {
                action = "customize.hint.select",
                glyph = ARC9.GetBindKey("+attack"),
                hidden = true,
            },
            {
                action = "customize.hint.deselect",
                glyph = ARC9.GetBindKey("+attack2"),
                hidden = true,
            },
            {
                action = "customize.hint.zoom",
                glyph = ARC9.GetBindKey("invprev"),
                glyph2 = ARC9.GetBindKey("invnext"),
                row2 = true,
            },
            {
                action = "customize.hint.pan",
                glyph = ARC9.GetBindKey("+attack"),
                glyph2 = "shared_touch",
                row2 = true,
            },
            {
                action = "customize.hint.rotate",
                glyph = ARC9.GetBindKey("+attack2"),
                glyph2 = "shared_touch",
                row2 = true,
            },
            {
                action = "customize.hint.recenter",
                glyph = ARC9.GetBindKey("+reload"),
                row3 = true,
            },
            {
                action = "customize.hint.cycle",
                glyph = ARC9.GetBindKey("+showscores"),
                row3 = true,
            },
            {
                action = "customize.hint.last",
                glyph = ARC9.GetBindKey("+use"),
                glyph2 = ARC9.GetBindKey("+showscores"),
                row3 = true,
            },
            {
                action = "customize.hint.favorite",
                glyph = ARC9.GetBindKey("impulse 100"),
                hidden = true,
            },
            {
                action = "customize.hint.random",
                glyph = ARC9.GetBindKey("+reload"),
                hidden = true,
            },
            {
                action = "customize.hint.toggleatts",
                glyph = ARC9.GetBindKey("+use"),
                hidden = true,
            },
        }
    end


    local tips = {
        "tips.custombinds",
        "tips.blacklist",
        "tips.hints",
        "tips.discord",
        "tips.arc-9",
        "tips.development",
        "tips.presets",
        -- "tips.tacrp",
        "tips.bugs",
        "tips.official",
        "tips.external",
        "tips.love",
        "tips.tolerance",
        "tips.cyberdemon",
        "tips.tips",
        "tips.settings",
        "tips.description",
    }

    local tipdelay = 8
    local tipalpha = 0
    local tipfade = 0
    local tipcurrent = math.random(0, #tips)
    local tiplast = 0

    local hintspanel = vgui.Create("DPanel", bg)
    -- hintspanel:SetSize(ARC9ScreenScale(225), ARC9ScreenScale(100))
    -- hintspanel:SetPos(-ARC9ScreenScale(170), -ARC9ScreenScale(40)) -- w = scrw-ARC9Scr
    -- hintspanel:MoveTo(0, ARC9ScreenScale(4), 0.4, 0, 0.1, nil)

    self.CustomizeHUD.hintspanel = hintspanel
    hintspanel:SetPos(ARC9ScreenScale(19), ScrH())
    hintspanel:MoveTo(ARC9ScreenScale(19), ScrH() - ARC9ScreenScale(16.5), 0.6, 0, 0.1, nil)
    hintspanel:SetSize(ScrW() - ARC9ScreenScale(38), ARC9ScreenScale(18))
    hintspanel:MoveToBack()

    hintspanel.Paint = function(self2, w, h)
        if !GetConVar("arc9_cust_hints"):GetBool() then return end
        if !IsValid(self) then
            self2:Remove()
            gui.EnableScreenClicker(false)
            return
        end

        if !(self.CustomizeButtons[self.CustomizeTab + 1].customize or self.CustomizeButtons[self.CustomizeTab + 1].personalize) then return end

        surface.SetFont("ARC9_10")
        surface.SetDrawColor(ARC9.GetHUDColor("fg"))
        surface.SetTextColor(ARC9.GetHUDColor("fg"))

        local ToAdd = {}
        local ToAdd2 = {}
        local ToAdd3 = {}
        for _, v in ipairs(trolling) do
            local act, hid = v.action, v.hidden
            if self.CustomizeHints[v.action] == "" then continue end
            if self.CustomizeHints[v.action] then hid = false end
            if hid then continue end
            if ARC9.CTRL_Lookup[v.glyph] then v.glyph = ARC9.CTRL_Lookup[v.glyph] end
            if ARC9.CTRL_ConvertTo[v.glyph] then v.glyph = ARC9.CTRL_ConvertTo[v.glyph] end
            if ARC9.CTRL_Exists[v.glyph] then v.glyph = Material( "arc9/" .. ARC9.GlyphFamilyCust() .. v.glyph .. ".png", "mips smooth" ) end
            if v.glyph2 then
                if ARC9.CTRL_Lookup[v.glyph2] then v.glyph2 = ARC9.CTRL_Lookup[v.glyph2] end
                if ARC9.CTRL_ConvertTo[v.glyph2] then v.glyph2 = ARC9.CTRL_ConvertTo[v.glyph2] end
                if ARC9.CTRL_Exists[v.glyph2] then v.glyph2 = Material( "arc9/" .. ARC9.GlyphFamilyCust() .. v.glyph2 .. ".png", "mips smooth" ) end
            end

            if v.row3 then
                table.insert(ToAdd3, { v.glyph, ARC9ScreenScale(8) })
                if v.glyph2 then
                    table.insert(ToAdd3, "  ")
                    table.insert(ToAdd3, { v.glyph2, ARC9ScreenScale(8) })
                end
                table.insert(ToAdd3, "  " ..  ARC9:GetPhrase(self.CustomizeHints[v.action] or v.action) .. "    ")
            elseif v.row2 then
                table.insert(ToAdd2, { v.glyph, ARC9ScreenScale(8) })
                if v.glyph2 then
                    table.insert(ToAdd2, "  ")
                    table.insert(ToAdd2, { v.glyph2, ARC9ScreenScale(8) })
                end
                table.insert(ToAdd2, "  " ..  ARC9:GetPhrase(self.CustomizeHints[v.action] or v.action) .. "    ")
            else
                table.insert(ToAdd, { v.glyph, ARC9ScreenScale(8) })
                if v.glyph2 then
                    table.insert(ToAdd, " ")
                    table.insert(ToAdd, { v.glyph2, ARC9ScreenScale(8) })
                end
                table.insert(ToAdd, "  " .. ARC9:GetPhrase(self.CustomizeHints[v.action] or v.action) .. "    ")
            end
        end

        local strreturn = CreateControllerKeyLine({x = self2:GetWide(), y = ARC9ScreenScale(2), size = ARC9ScreenScale(10), font = "ARC9_10", font_keyb = "ARC9_KeybindPreview_Cust" }, Color(255,255,255,175), unpack(ToAdd3)) -- ghost     text only to get width

        if !table.IsEmpty(ToAdd) then
            CreateControllerKeyLine({x = ARC9ScreenScale(8), y = ARC9ScreenScale(2), size = ARC9ScreenScale(10), font = "ARC9_10", font_keyb = "ARC9_KeybindPreview_Cust" }, Color(255,255,255,175), unpack(ToAdd))
            tipalpha = 0
        else
            -- tips
            if GetConVar("arc9_cust_tips"):GetBool() then
                if CurTime() > tiplast then
                    tiplast = CurTime() + tipdelay
                    tipcurrent = tipcurrent + 1
                end

                tipalpha = math.min(tipalpha + FrameTime() * 300, 175)
                tipfade = math.min((tiplast-CurTime()) / tipdelay, 0.025) * 40 * tipalpha
                local tiptext = ARC9:GetPhrase(tips[tipcurrent%(#tips)+1])

                surface.SetMaterial(mat_info)
                surface.SetDrawColor(ARC9.GetHUDColor("fg", tipalpha))
                surface.DrawTexturedRect(ARC9ScreenScale(8), ARC9ScreenScale(2), ARC9ScreenScale(10), ARC9ScreenScale(10))

				-- local btw = surface.GetTextSize(tiptext)
				-- local bw, bh = btw + ARC9ScreenScale(4), ARC9ScreenScale(10)

                -- surface.SetDrawColor(ARC9.GetHUDColor("shadow", (tipalpha * 3)))
                -- surface.DrawRect(ARC9ScreenScale(20), ARC9ScreenScale(1.5), bw, bh)

                surface.SetFont("ARC9_10")
                surface.SetTextPos(ARC9ScreenScale(22), ARC9ScreenScale(2))
                surface.SetTextColor(ARC9.GetHUDColor("fg", tipfade))
                -- surface.DrawText(tiptext)
                ARC9.DrawTextRot(self2, tiptext, ARC9ScreenScale(22), 0, ARC9ScreenScale(22), ARC9ScreenScale(2), w - strreturn - ARC9ScreenScale(32), false)

            end
        end

        CreateControllerKeyLine({x = self2:GetWide() - ARC9ScreenScale(8)-strreturn , y = ARC9ScreenScale(2), size = ARC9ScreenScale(10), font = "ARC9_10", font_keyb = "ARC9_KeybindPreview_Cust" }, Color(255,255,255,175), unpack(ToAdd3))
		
        -- CreateControllerKeyLine({x = self2:GetWide() - ARC9ScreenScale(250)-strreturn , y = ARC9ScreenScale(2), size = ARC9ScreenScale(10), font = "ARC9_10", font_keyb = "ARC9_KeybindPreview_Cust" }, ARC9.GetHUDColor("hint", 255), unpack(ToAdd2))

        table.Empty(self.CustomizeHints)
    end
end

function SWEP:RemoveCustomizeHUD()
    if self.RemovingCustHud then return end

    local bg = self.CustomizeHUD

    local scrh = ScrH()
    local scrw = ScrW()

    local deadzonexx = deadzonex:GetInt()

    if self.CustomizeHUD then
        self.RemovingCustHud = true
        if bg.nameplate then bg.nameplate:MoveTo(0, -ARC9ScreenScale(64), 0.7, 0, 0.05, nil) bg.nameplate:AlphaTo(0, 0.2, 0) end
        if bg.topleft_panel then bg.topleft_panel:MoveTo(-ARC9ScreenScale(70) + deadzonexx, -ARC9ScreenScale(40), 0.7, 0, 0.05, nil) bg.topleft_panel:AlphaTo(0, 0.2, 0) end
        if bg.topright_panel then bg.topright_panel:MoveTo(scrw - deadzonexx, -ARC9ScreenScale(40), 0.7, 0, 0.05, nil) bg.topright_panel:AlphaTo(0, 0.2, 0) end
        if bg.lowerpanel then bg.lowerpanel:MoveTo(ARC9ScreenScale(19) + deadzonexx, scrh, 0.7, 0, 0.05, nil) bg.lowerpanel:AlphaTo(0, 0.2, 0) end
        if bg.hintspanel then bg.hintspanel:MoveTo(ARC9ScreenScale(19) + deadzonexx, scrh, 0.7, 0, 0.05, nil) bg.hintspanel:AlphaTo(0, 0.1, 0) end
        -- if self.TabPanel then self.TabPanel:AlphaTo(0, 0.1, 0) end

        self:ClosePresetMenu()

        gui.EnableScreenClicker(false)

        surface.PlaySound(closesound)

        timer.Simple(0.1, function()
            if !IsValid(self) then return end
            self.CustomizeHUD:Remove()
            self.CustomizeHUD = nil
            self.RemovingCustHud = nil
        end)
    end
end

function SWEP:DrawCustomizeHUD()
    local customize = self:GetCustomize()

    if self.CustomizeHUD and !IsValid(self.CustomizeHUD) then
        self:RemoveCustomizeHUD()
    end

    if customize and !self.CustomizeHUD and !self.RemovingCustHud then
        self:CreateCustomizeHUD()
    elseif !customize and self.CustomizeHUD then
        self:RemoveCustomizeHUD()
    end
end

function SWEP:CreateHUD_RHP()
    local bg = self.CustomizeHUD
    if !IsValid(self) then return end
    if !bg then return end

    local scrh = ScrH()
    local scrw = ScrW()

    local gr_h = scrh
    local gr_w = gr_h

    local nameplate = vgui.Create("DPanel", bg)
    self.CustomizeHUD.nameplate = nameplate
    nameplate:SetPos(0, -ARC9ScreenScale(64)) -- h = ARC9ScreenScale(8)
    nameplate:MoveTo(0, ARC9ScreenScale(8), 1, 0, 0.05, nil)
    nameplate:SetSize(scrw, ARC9ScreenScale(38))
    nameplate:MoveToBack()
    nameplate.Paint = function(self2, w, h)
        if !IsValid(self) then return end

        local redname
        if self.Hook_RedPrintName then redname = self:RunHook("Hook_RedPrintName") end

        -- if (self.CustomizeButtons[self.CustomizeTab + 1] or {}).inspect then return end

        surface.SetFont("ARC9_24")
        local tw = surface.GetTextSize(self.PrintName or "No name ??? wtf")

        surface.SetFont("ARC9_24")
        surface.SetTextPos(w/2 - tw/2, 0)
        surface.SetTextColor(redname and ARC9.GetHUDColor("hi_3d") or ARC9.GetHUDColor("fg"))
        surface.DrawText(self.PrintName or "No name ??? wtf")

        -- class
        surface.SetFont("ARC9_12")
        local tw2 = surface.GetTextSize(ARC9:GetPhrase(self.Class) or self.Class or "No class ??? wtf")

        surface.SetFont("ARC9_12")
        surface.SetTextPos(w/2 - tw2/2, ARC9ScreenScale(25))
        surface.SetTextColor(ARC9.GetHUDColor("fg"))
        surface.DrawText(ARC9:GetPhrase(self.Class) or self.Class or "No class ??? wtf")

        surface.SetDrawColor(ARC9.GetHUDColor("bg"))
        surface.DrawRect(w/2 - tw2/2, ARC9ScreenScale(23), tw2, ARC9ScreenScale(1.5))
    end

    self.CustomizeAlphaBuffer = CurTime() + 1

    local inspectalpha = function(self2, panel, minusnum)
        if self.CustomizeButtons[self.CustomizeTab + 1].inspect then -- probably horrible
            if self2:IsHovered() or (self.CustomizeAlphaBuffer or 0) > CurTime() then
                panel:SetAlpha(math.min(panel:GetAlpha() + 25, 255))
            else
                panel:SetAlpha(math.max(panel:GetAlpha() - minusnum, 0)) -- * number of cust buttons
            end
        end
    end

    local deadzonexx = deadzonex:GetInt()
    local lighthintbrightness = 0

    local topleft_panel = vgui.Create("DPanel", bg)
    self.CustomizeHUD.topleft_panel = topleft_panel
    topleft_panel:SetPos(-ARC9ScreenScale(70) + deadzonexx, -ARC9ScreenScale(40)) -- w = 0, h = 0
    topleft_panel:MoveTo(deadzonexx, 0.1, 0.4, 0, 0.1, nil)
    topleft_panel:SetSize(ARC9ScreenScale(70+40), ARC9ScreenScale(40 + 29))
    topleft_panel:MoveToFront()
    topleft_panel.Paint = function(self2, w, h) 
	
		if ARC9.ControllerMode() then
			surface.SetFont("ARC9_8")
			surface.SetTextColor(ARC9.GetHUDColor("fg"))
			surface.SetTextPos(ARC9ScreenScale(4), ARC9ScreenScale(4))
			surface.DrawText(ARC9:GetPhrase("customize.hint.controller"))
		end

        if self2.topleft_light and self2.topleft_light:IsHovered() and GetConVar("arc9_cust_light"):GetBool() then
            lighthintbrightness = math.Approach(lighthintbrightness, 1, FrameTime() * 10)
        else
            lighthintbrightness = math.Approach(lighthintbrightness, 0, FrameTime() * 10)
		end

        if lighthintbrightness > 0 then
            local clt = (math.Round(GetConVar("arc9_cust_light_brightness"):GetFloat(), 3) + 20) * 2 .. "%"

            surface.SetFont("ARC9_8")
            local cltw = surface.GetTextSize(clt)
            surface.SetTextPos(ARC9ScreenScale(47.5 + 21/2) - cltw /2, ARC9ScreenScale(42))
            surface.SetTextColor(255, 255, 255, lighthintbrightness * 255)
            surface.DrawText(clt)
        end
	end

    local topleft_settings = vgui.Create("ARC9TopButton", topleft_panel)
    topleft_settings:SetPos(ARC9ScreenScale(19), ARC9ScreenScale(19))
    topleft_settings:SetNotif(ARC9.BadPerfromanceSettings())
    topleft_settings.DoClick = function(self2)
        surface.PlaySound(popupsound)
        ARC9_OpenSettings()

        -- self:ToggleCustomize(false)
        -- bg:SetMouseInputEnabled(false)
    end

    local topleft_light = vgui.Create("ARC9TopButton", topleft_panel)
    topleft_light:SetPos(ARC9ScreenScale(47.5), ARC9ScreenScale(19))
    topleft_light:SetIcon(Material("arc9/ui/light.png", "mips smooth"))
    topleft_light:SetIsCheckbox(true)
    topleft_light:SetConVar("arc9_cust_light")
    topleft_light:SetValue(GetConVar("arc9_cust_light"):GetBool())
    topleft_panel.topleft_light = topleft_light
    local oldlightdoclick = topleft_light.DoClick
    topleft_light.DoClick = function(self2)
        oldlightdoclick(self2)

        topleft_light:SetCursor(self2:GetChecked() and "sizens" or "hand")

        surface.PlaySound(self2:GetChecked() and lightonsound or lightoffsound)
    end    

    topleft_light.OnMouseWheeled = function(self2, state)
        if state != 0 then
            surface.PlaySound(hoversound)
            RunConsoleCommand("arc9_cust_light_brightness", math.Clamp(GetConVar("arc9_cust_light_brightness"):GetFloat() + state * 0.5, -20, 30))
        end
    end

    if ARC9.Dev(0) and ARC9.ATTsHaveBeenReloaded then
        local topleft_devreload = vgui.Create("ARC9TopButton", topleft_panel)
        topleft_devreload:SetPos(ARC9ScreenScale(47.5+29), ARC9ScreenScale(19))
        topleft_devreload:SetIcon(Material("arc9/reset.png", "mips smooth"))
        topleft_devreload:SetConVar("arc9_reloadatts")
        local olddevreloaddoclick = topleft_devreload.DoClick
        topleft_devreload.DoClick = function(self2)
            olddevreloaddoclick(self2)
        end
        topleft_devreload.Think = function(self2) if !IsValid(self) then return end inspectalpha(self2, self.CustomizeHUD.topleft_panel, 8) end
    end

    topleft_settings.Think = function(self2) if !IsValid(self) then return end inspectalpha(self2, self.CustomizeHUD.topleft_panel, 8) end
    topleft_light.Think = function(self2) if !IsValid(self) then return end inspectalpha(self2, self.CustomizeHUD.topleft_panel, 8) end

    local topright_panel = vgui.Create("DPanel", bg)
    self.CustomizeHUD.topright_panel = topright_panel
    topright_panel:SetPos(scrw - deadzonexx, -ARC9ScreenScale(40)) -- w = scrw-ARC9ScreenScale(170), h = 0
    topright_panel:MoveTo(scrw - ARC9ScreenScale(170) - deadzonexx, 0, 0.4, 0, 0.1, nil)
    topright_panel:SetSize(ARC9ScreenScale(170), ARC9ScreenScale(40))
    topright_panel:MoveToFront()
    topright_panel.Paint = function(self2, w, h) end

    if self.Attachments[1] and !GetConVar("arc9_atts_nocustomize"):GetBool() then -- no presets if no atts
        local topright_presets = vgui.Create("ARC9TopButton", topright_panel)
        self.CustomizeHUD.topright_panel.topright_presets = topright_presets
        surface.SetFont("ARC9_16")
        local tw = surface.GetTextSize(ARC9:GetPhrase("customize.panel.presets"))
        topright_presets:SetPos(ARC9ScreenScale(123)-(ARC9ScreenScale(28)+tw), ARC9ScreenScale(19))
        topright_presets:SetSize(ARC9ScreenScale(28)+tw, ARC9ScreenScale(21))
        topright_presets:SetIcon(Material("arc9/ui/presets.png", "mips"))
        topright_presets:SetButtonText(ARC9:GetPhrase("customize.panel.presets"))
        topright_presets:SetIsCheckbox(true)
        local oldpresetsdoclick = topright_presets.DoClick
        topright_presets.DoClick = function(self2)
            surface.PlaySound(self2:GetChecked() and backsound or opensound)

            oldpresetsdoclick(self2)

            self.CustomizeHUD.lowerpanel.Extended = nil
            self.BottomBarMode = 0

            self:CreatePresetMenu()
        end

        topright_presets.Think = function(self2) if !IsValid(self) then return end inspectalpha(self2, self.CustomizeHUD.topright_panel, 8) end
    end

    local topright_close = vgui.Create("ARC9TopButton", topright_panel)
    topright_close:SetPos(ARC9ScreenScale(130), ARC9ScreenScale(19))
    topright_close:SetIcon(Material("arc9/ui/close.png", "mips smooth"))
    topright_close.DoClick = function(self2)
        surface.PlaySound(clicksound)
        self:SetCustomize(false)
        net.Start("ARC9_togglecustomize")
        net.WriteBool(false)
        net.SendToServer()
    end

    topright_close.Think = function(self2) if !IsValid(self) then return end inspectalpha(self2, self.CustomizeHUD.topright_panel, 8) end


    local lowerpanel = vgui.Create("DPanel", bg)
    self.CustomizeHUD.lowerpanel = lowerpanel
    lowerpanel:SetPos(ARC9ScreenScale(19) + deadzonexx, scrh) -- h = scrh-ARC9ScreenScale(93)
    -- lowerpanel:MoveTo(ARC9ScreenScale(19), scrh-ARC9ScreenScale(93), 0.6, 0, 0.1, nil) -- CustomizeTab does this for us
    lowerpanel:SetSize(scrw - ARC9ScreenScale(38) - deadzonexx*2, ARC9ScreenScale(74))
    lowerpanel:MoveToBack()

    local hascosmetic = false
    local hasnoncosmetic = false

    for _, slottbl in pairs(self:GetSubSlotList()) do
        if hascosmetic and hasnoncosmetic then break end
        if slottbl.Hidden then continue end
        if self:SlotIsCosmetic(slottbl) then
            hascosmetic = true
        else
            hasnoncosmetic = true
        end
    end

    if !hascosmetic and self.CustomizeButtons[2].personalize then
        table.remove(self.CustomizeButtons, 2)
    end

    if (!hasnoncosmetic) and self.CustomizeButtons[1].customize then  -- NO ATTS CUST PANEL REMOVAL
        table.remove(self.CustomizeButtons, 1)
        self.CustomizeButtons[1].cutcorner = 1
        self.CustomizeTab = 0
    end


    local barlength = -ARC9ScreenScale(1.5)
    local cornercut = ARC9ScreenScale(3.5)
    local inspecttextwidth = 0

    for i, btn in pairs(self.CustomizeButtons) do
        local custtabbtn = vgui.Create("DButton", lowerpanel)
        --
        surface.SetFont("ARC9_12")
        local titlewidth = surface.GetTextSize(ARC9:GetPhrase(btn.title)) + ARC9ScreenScale(12.5)
        --

        if btn.inspect then
            custtabbtn:SetPos(scrw - ARC9ScreenScale(38) - deadzonex:GetInt()*2 - titlewidth, 0)
            inspecttextwidth = titlewidth
        else
            barlength = barlength + titlewidth + ARC9ScreenScale(1.5)
            custtabbtn:SetPos(barlength - titlewidth, 0)
        end

        custtabbtn:SetSize(titlewidth, ARC9ScreenScale(14.5))
        custtabbtn.title = ARC9:GetPhrase(btn.title)
        custtabbtn.page = i - 1
        custtabbtn.func = btn.func
        custtabbtn:SetText("")


        custtabbtn.Paint = function(self2, w, h)
            if !IsValid(self) then return end

            local mainbuttoncolor = ARC9.GetHUDColor("bg")
            local barbuttoncolor = ARC9.GetHUDColor("bg")
            local buttontextcolor = ARC9.GetHUDColor("fg")

            if self.CustomizeTab == self2.page then
                mainbuttoncolor = ARC9.GetHUDColor("hi")
                barbuttoncolor = ARC9.GetHUDColor("hi")
                buttontextcolor = ARC9.GetHUDColor("shadow")
            end

            if self2:IsHovered() then
                barbuttoncolor = ARC9.GetHUDColor("hi")
                if self.CustomizeTab != self2.page then self.CustomizeHints["customize.hint.select"] = "customize.hint.open" end
            end

            surface.SetDrawColor(mainbuttoncolor)
            draw.NoTexture()

            local hcutted = ARC9ScreenScale(11.5)

            if btn.cutcorner == 1 then
                surface.DrawPoly({{x = 0, y = hcutted}, {x = 0, y = cornercut}, {x = cornercut, y = 0}, {x = w, y = 0}, {x = w, y = hcutted}})
            elseif btn.cutcorner == 2 then
                surface.DrawPoly({{x = 0, y = hcutted}, {x = 0, y = 0}, {x = w-cornercut, y = 0}, {x = w, y = cornercut}, {x = w, y = hcutted}})
            elseif btn.cutcorner == 3 then
                surface.DrawPoly({{x = 0, y = hcutted}, {x = 0, y = cornercut}, {x = cornercut, y = 0}, {x = w-cornercut, y = 0}, {x = w, y = cornercut}, {x = w, y = hcutted}})
            else
                surface.DrawPoly({{x = 0, y = hcutted}, {x = 0, y = 0}, {x = w, y = 0}, {x = w, y = hcutted}})
            end

            surface.SetDrawColor(barbuttoncolor)
            surface.DrawRect(0, h - ARC9ScreenScale(1.5), w, h)

            surface.SetFont("ARC9_12")
            local tw = surface.GetTextSize(self2.title)

            surface.SetTextColor(buttontextcolor)
            -- surface.SetTextPos((w - tw) / 2, -ARC9ScreenScale(0.75))
            surface.SetTextPos((w - tw) / 2, 0)
            surface.DrawText(self2.title)
        end
        custtabbtn.Think = function(self2) if !IsValid(self) then return end inspectalpha(self2, self.CustomizeHUD.lowerpanel, 3) end
        custtabbtn.DoClick = function(self2)
            self.LastCustomizeTab = self.CustomizeTab
            self.CustomizeTab = self2.page
            self2.func(self, self2.page)
            surface.PlaySound(tabsound)
        end
        custtabbtn.OnCursorEntered = function(self2)
            surface.PlaySound(hoversound)
        end
        -- custtabbtn.DoRightClick = function(self2)
        --     self.CustomizeTab = 0
        --     self:ClearTabPanel()
        -- end


        lowerpanel.Paint = function(self2, w, h)
            surface.SetDrawColor(ARC9.GetHUDColor("bg"))

            surface.DrawRect(barlength + ARC9ScreenScale(1.5), ARC9ScreenScale(12.75), w - barlength - inspecttextwidth - ARC9ScreenScale(3.2), ARC9ScreenScale(1.75)) -- bar spacer

            draw.NoTexture()

            if self2.Extended then
                surface.DrawPoly({{x = cornercut, y = h},{x = 0, y = h-cornercut}, {x = 0, y = ARC9ScreenScale(15.5+60)}, {x = w*0.5-ARC9ScreenScale(0.75), y = ARC9ScreenScale(15.5+60)}, {x = w*0.5-ARC9ScreenScale(0.75), y = h}})

                surface.DrawRect(0, ARC9ScreenScale(15.5+60-2.5), w*0.5-ARC9ScreenScale(0.5), ARC9ScreenScale(1.5))

                surface.DrawRect(0, ARC9ScreenScale(15.5), w, ARC9ScreenScale(60-3.5))

                surface.SetDrawColor(self2.HasPros and ARC9.GetHUDColor("bg_pro") or ARC9.GetHUDColor("bg"))
                surface.DrawPoly({{x = w*0.5+ARC9ScreenScale(0.75), y = h}, {x = w*0.5+ARC9ScreenScale(0.75), y = ARC9ScreenScale(15.5+60)}, {x = w*0.75-ARC9ScreenScale(0.75), y = ARC9ScreenScale(15.5+60)}, {x = w*0.75-ARC9ScreenScale(0.75), y = h}})

                surface.SetDrawColor(self2.HasPros and ARC9.GetHUDColor("pro") or ARC9.GetHUDColor("bg"))
                surface.DrawRect(w*0.5+ARC9ScreenScale(0.75), ARC9ScreenScale(15.5+60-2.5), w*0.25-ARC9ScreenScale(1), ARC9ScreenScale(1.5))

                surface.SetDrawColor(self2.HasCons and ARC9.GetHUDColor("bg_con") or ARC9.GetHUDColor("bg"))
                surface.DrawPoly({{x = w*0.75+ARC9ScreenScale(0.75), y = h}, {x = w*0.75+ARC9ScreenScale(0.75), y = ARC9ScreenScale(15.5+60)}, {x = w, y = ARC9ScreenScale(15.5+60)}, {x = w, y = h-cornercut}, {x = w-cornercut, y = h}})

                surface.SetDrawColor(self2.HasCons and ARC9.GetHUDColor("con") or ARC9.GetHUDColor("bg"))
                surface.DrawRect(w*0.75+ARC9ScreenScale(1), ARC9ScreenScale(15.5+60-2.5), w*0.25, ARC9ScreenScale(1.5))
            else
                surface.DrawPoly({{x = cornercut, y = h},{x = 0, y = h-cornercut}, {x = 0, y = ARC9ScreenScale(15.5)}, {x = w, y = ARC9ScreenScale(15.5)}, {x = w, y = h-cornercut}, {x = w-cornercut, y = h}})
            end

            -- thingy at bottom
            surface.SetDrawColor(ARC9.GetHUDColor("hi"))
            surface.DrawPoly({{x = cornercut, y = h}, {x = 0, y = h-cornercut}, {x = cornercut, y = h-cornercut*.5}})
            surface.DrawPoly({{x = w, y = h-cornercut}, {x = w-cornercut, y = h}, {x = w-cornercut, y = h-cornercut*.5}})
            surface.DrawPoly({{x = cornercut, y = h-cornercut*.5}, {x = w-cornercut, y = h-cornercut*.5}, {x = w-cornercut, y = h}, {x = cornercut, y = h}, })
        end
    end

    self.CustomizeButtons[self.CustomizeTab + 1].func(self)

    if DevMode then
        self:DevStuffMenu()
    end
end