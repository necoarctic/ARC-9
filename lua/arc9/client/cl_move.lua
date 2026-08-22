
local arc9_autoreload = GetConVar("arc9_autoreload")
local arc9_cruelty_reload = GetConVar("arc9_cruelty_reload")

ARC9.ReloadAmount = 0

local nav_nextmeowpress, nav_lastpage_addr, nav_lastpage_mode, nav_lastpage_path = 0
local foldersound = "arc9/newui/uimouse_click_forward.ogg"
local backsound = "arc9/newui/uimouse_click_return.ogg"

hook.Add("CreateMove", "ARC9_CreateMove", function(cmd)
    local wpn = LocalPlayer():GetActiveWeapon()
    local ply = LocalPlayer()

    if !IsValid(wpn) then return end
    if !wpn.ARC9 then return end

    local cust = wpn:GetCustomize()

    if (arc9_autoreload:GetBool() or wpn:GetRequestReload()) and
		!wpn:GetReloading() and
        !cust and
        wpn:CanReload() and
        cmd:TickCount() % 2 == 0
    then
        if wpn:GetUBGL() then
            if !LocalPlayer():KeyDown(IN_USE) and wpn:Clip2() == 0 and wpn:Ammo2() > 0 then
                cmd:AddKey(IN_RELOAD)
            end
        else
            if !LocalPlayer():KeyDown(IN_USE) and wpn:Clip1() == 0 and wpn:Ammo1() > 0 then
                cmd:AddKey(IN_RELOAD)
            end
        end
    end

    if ARC9.KeyPressed_Menu then
        cmd:AddKey(IN_WEAPON1)
    end

    if ARC9.KeyPressed_Melee then
        cmd:AddKey(ARC9.IN_MELEE)
    end

    if ARC9.KeyPressed_UBGL then
        cmd:AddKey(ARC9.IN_UBGL)
    end

    if ARC9.KeyPressed_Inspect then
        cmd:AddKey(ARC9.IN_INSPECT)
    end

    if ARC9.KeyPressed_SwitchSights then
        cmd:AddKey(ARC9.IN_SWITCHSIGHTS)
    end

    if ARC9.DeferFakeToggleAtts then
        cmd:SetImpulse(ARC9.IMPULSE_FAKETOGGLEATTS)
        ARC9.DeferFakeToggleAtts = false
    end

    if arc9_cruelty_reload:GetBool() then
        local buttons = cmd:GetButtons()

        local shouldreload = false

        // reload like in cruelty squad!

        if bit.band(cmd:GetButtons(), IN_RELOAD) == IN_RELOAD then
            local mouseY = cmd:GetMouseY()

            if mouseY > 0 then
                ARC9.ReloadAmount = ARC9.ReloadAmount + (mouseY / ScrH())
            end

            cmd:SetMouseY(0)
            if lastviewangles then
                cmd:SetViewAngles(lastviewangles)
            end

            buttons = bit.band(buttons, bit.bnot(IN_RELOAD))
        else
            lastviewangles = cmd:GetViewAngles()
        end

        if ARC9.ReloadAmount >= 1 then
            shouldreload = true
        end

        // deny reload unless shouldreload is true

        if shouldreload then
            buttons = bit.bor(buttons, IN_RELOAD)
        else
            buttons = bit.band(buttons, bit.bnot(IN_RELOAD))

            if bit.band(cmd:GetButtons(), IN_USE) == IN_USE then
                buttons = bit.bor(buttons, ARC9.IN_INSPECT)
            end
        end

        cmd:SetButtons(buttons)
    end

    if cust then
        if nav_nextmeowpress < CurTime() then

            local pagedown, pageup = input.WasMousePressed(MOUSE_5), input.WasMousePressed(MOUSE_4)
            if pageup then
                nav_nextmeowpress = CurTime() + engine.TickInterval() * 1.5
                local didanything = false

                if wpn.BottomBarPath and #wpn.BottomBarPath > 0 then
                    nav_lastpage_path = table.Copy(wpn.BottomBarPath)
                    nav_lastpage_addr = wpn.BottomBarAddress
                    nav_lastpage_mode = wpn.BottomBarMode

                    table.remove(wpn.BottomBarPath)

                    didanything = true
                elseif wpn.BottomBarAddress then
                    nav_lastpage_path = table.Copy(wpn.BottomBarPath)
                    nav_lastpage_addr = wpn.BottomBarAddress
                    nav_lastpage_mode = wpn.BottomBarMode

                    wpn.BottomBarAddress = nil
                    wpn.BottomBarMode = 0

                    didanything = true
                end
                if didanything then
                    wpn:CreateHUD_Bottom()
                    surface.PlaySound(foldersound)
                end
            elseif pagedown and nav_lastpage_path and wpn.BottomBarPath != nav_lastpage_path then
                nav_nextmeowpress = CurTime() + 0.1
                wpn.BottomBarPath = nav_lastpage_path
                wpn.BottomBarAddress = nav_lastpage_addr
                wpn.BottomBarMode = nav_lastpage_mode
                wpn:CreateHUD_Bottom()
                surface.PlaySound(foldersound)
            end
        end
    else
        if nav_lastpage_path then
            nav_lastpage_path = nil
            wpn.BottomBarPath = nil
            wpn.BottomBarAddress = nil
            wpn.BottomBarMode = 0
        end

        if ARC9.RadialMenuOpen and wpn.LastSelectedAttSlot and ARC9.NextRadialToggleTime < CurTime() then
            if input.WasMousePressed(MOUSE_FIRST) then
                ARC9.DeferFakeToggleAtts = true
                wpn:ToggleStat(wpn.LastSelectedAttSlot.Slot.Address)
                wpn:PostModify()
                ARC9.NextRadialToggleTime = CurTime() + 0.25
            elseif input.WasMousePressed(MOUSE_RIGHT) then
                ARC9.DeferFakeToggleAtts = true
                wpn:ToggleStat(wpn.LastSelectedAttSlot.Slot.Address, -1)
                wpn:PostModify()
                ARC9.NextRadialToggleTime = CurTime() + 0.25
            end
        end
    end
end)

local performedAprilFoolsCheck = false

hook.Add("Think", "ARC9_cruelty_think_client_reload", function()
    if !performedAprilFoolsCheck then
        -- is it april fools today
        local date = os.date("*t")

        local day = date.day
        local month = date.month

        if day == 1 and month == 4 then
            if !GetConVar("arc9_cruelty_reload_april_fools"):GetBool() then
                RunConsoleCommand("arc9_cruelty_reload_april_fools", "1")
                RunConsoleCommand("arc9_cruelty_reload", "1")
            end
        else
            if GetConVar("arc9_cruelty_reload_april_fools"):GetBool() then
                RunConsoleCommand("arc9_cruelty_reload_april_fools", "0")
                RunConsoleCommand("arc9_cruelty_reload", "0")
            end
        end

        performedAprilFoolsCheck = true
    end

    if !GetConVar("arc9_cruelty_reload"):GetBool() then return end

    ARC9.ReloadAmount = ARC9.ReloadAmount - (FrameTime() * 2)

    ARC9.ReloadAmount = math.Clamp(ARC9.ReloadAmount, 0, 1.5)
end)