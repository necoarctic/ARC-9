local scrolleles = {}

local foldericon = Material("arc9/ui/folder.png", "mips smooth")
local folderfavicon = Material("arc9/ui/folder_favorites.png", "mips smooth")
local backicon = Material("arc9/ui/back.png", "mips smooth")
local adminicon = Material("arc9/admin.png", "mips smooth")
local modesicon = Material("arc9/ui/modes.png", "mips smooth")
local camosicon = Material("arc9/ui/paint.png", "mips smooth")

local ARC9ScreenScale = ARC9.ScreenScale

local clicksound = "arc9/newui/uimouse_click.ogg"
local foldersound = "arc9/newui/uimouse_click_forward.ogg"
local backsound = "arc9/newui/uimouse_click_return.ogg"
local tabsound = "arc9/newui/uimouse_click_tab.ogg"
local favsound = "arc9/newui/ui_part_favourite1.ogg"

local function spacer(self, scroll, margin)
    local spacer = vgui.Create("DPanel", scroll)
    spacer:DockMargin(ARC9ScreenScale(margin), 0, ARC9ScreenScale(4), 0)
    spacer:Dock(LEFT)
    spacer:SetSize(ARC9ScreenScale(1), ARC9ScreenScale(2))

    scroll:AddPanel(spacer)
    table.insert(scrolleles, spacer)
    spacer.Paint = function(self2, w, h)
        if !IsValid(self) then return end

        surface.SetDrawColor(ARC9.GetHUDColor("bg"))
        surface.DrawRect(0, ARC9ScreenScale(2), w, ARC9ScreenScale(40))
    end
end

SWEP.BottomBar = nil
SWEP.BottomBarAnchor = nil

-- 0: Preset
-- 1: Attachment
SWEP.BottomBarMode = 0

SWEP.BottomBarAddress = 0

SWEP.BottomBarFolders = {}
SWEP.BottomBarPath = {}
SWEP.BottomBarAtts = {}

-- 0: Customization
-- 1: Personalization
SWEP.BottomBarCategory = 0

SWEP.LastScroll = 0

function SWEP:ClearBottomBar()
    if self.BottomBar then
        self.BottomBar:Remove()
        self.BottomBar = nil
    end

    self:ClearAttInfoBar()
end

local function recursivefoldercount(wep, folder, ownedtbl)
    if !istable(folder) then return 0 end

    local owned = 0
    local count = 0

    for i, k in pairs(folder) do
        if istable(k) then
            local cowned, ccount = recursivefoldercount(wep, k, ownedtbl)
            owned = owned + cowned
            count = count + ccount
        else
            local atttbl = ARC9.GetAttTable(i)
            if !atttbl then continue end

            if ARC9:PlayerGetAtts(LocalPlayer(), i, wep) > 0 then
                if ownedtbl then
                    ownedtbl[i] = true
                end
                owned = owned + 1
                count = count + 1
            elseif GetConVar("arc9_hud_showunowned"):GetBool() then
                count = count + 1
            end
        end
    end

    return owned, count
end

local function tworandomstrings(tbl)
    local valid_strings = {}
    for key, _ in pairs(tbl) do
        if isstring(key) and !string.find(key, "%u") then table.insert(valid_strings, key) end
    end

    local count = #valid_strings
    if count < 2 then return false end

    local first, second = math.random(count), math.random(count)
    while second == first do
        second = math.random(count)
    end

    return valid_strings[first], valid_strings[second]
end


local function enterfolder(self, scroll, slottbl, fname)
    if fname != true then
        if fname == nil then
            table.remove(self.BottomBarPath)
        else
            table.insert(self.BottomBarPath, fname)
        end
    end

    local folders = self.BottomBarFolders
    for _, v in ipairs(self.BottomBarPath) do
        folders = folders[v]
    end

    for _, p in pairs(scrolleles) do
        p:Remove()
    end

    if IsValid(self.BottomBarAnchor) then
        self.BottomBarAnchor:Remove()
        self.BottomBarAnchor = nil
    end

    local anchor = vgui.Create("DPanel", self.BottomBar)
    anchor:SetPos(ARC9ScreenScale(3), ARC9ScreenScale(3))
    anchor:SetSize(ARC9ScreenScale(57.5), ARC9ScreenScale(57.5))

    function anchor:Paint(w, h)
    end

    self.BottomBarAnchor = anchor

    local backbtn = vgui.Create("ARC9AttButton", anchor)
    backbtn.Weapon = self
    backbtn:SetIcon(backicon)
    backbtn:SetEmpty(true)

    backbtn:DockMargin(ARC9ScreenScale(5), 0, 0, 0)
    backbtn:Dock(LEFT)

    local newspacer = vgui.Create("DPanel", anchor)
    newspacer:DockMargin(ARC9ScreenScale(3.5), 0, ARC9ScreenScale(4), 0)
    newspacer:Dock(LEFT)
    newspacer:SetSize(ARC9ScreenScale(1), ARC9ScreenScale(2))

    newspacer.Paint = function(self2, w, h)
        if !IsValid(self) then return end

        surface.SetDrawColor(ARC9.GetHUDColor("bg"))
        surface.DrawRect(0, ARC9ScreenScale(2), w, ARC9ScreenScale(40))
    end

    if #self.BottomBarPath > 0 then
        backbtn:SetButtonText(ARC9:GetPhrase("folder.back"))
        backbtn.OnMousePressed = function(self2, kc)
            if kc == MOUSE_LEFT then
                enterfolder(self, scroll, slottbl, nil)
                surface.PlaySound(backsound)
            end
        end
    else
        backbtn:SetButtonText(ARC9:GetPhrase("folder.deselect"))
        backbtn.OnMousePressed = function(self2, kc)
            if kc == MOUSE_LEFT then
                self.BottomBarAddress = nil
                self.BottomBarMode = 0
                self:CreateHUD_Bottom()
                surface.PlaySound(backsound)
            end
        end
    end
    -- backbtn.Think = function(self2)
    --     if !IsValid(self) then return end
    --     if self2:IsHovered() then
    --         self.CustomizeHints["customize.hint.select"] = "Return"
    --     end
    -- end

    scroll:SetPos(anchor:GetWide(), ARC9ScreenScale(3))
    scroll:SetWide(self.BottomBar:GetWide() - anchor:GetWide())

    local foldercount = 0
    if folders then
        for folder, children in SortedPairs(folders) do
            if !folders then
                table.remove(self.BottomBarPath)
            end
            if isbool(children) then continue end

            local ownedchildren = {}
            local owned, count = recursivefoldercount(self, children, ownedchildren)

            -- if count > 99 then count = "99+" end

            if count == 0 then continue end

            local display_count = count > owned and (owned .. "/" .. count) or count

            foldercount = foldercount + 1

            local folderbtn = vgui.Create("ARC9AttButton", scroll)

            local isfav = folder == "!favorites"
            folderbtn.Weapon = self
            folderbtn:SetButtonText(isfav and ARC9:GetPhrase("folder.favorites") or ARC9:GetPhrase("folder." .. folder) or folder)
            folderbtn:SetIcon(isfav and folderfavicon or foldericon)
            folderbtn:SetEmpty(true)
            folderbtn:SetEmptyGreyOut(owned == 0)

            local randomatt1, randomatt2 = tworandomstrings(ownedchildren)

            if randomatt1 and randomatt2 then
                randomatt1 = ARC9.GetAttTable(randomatt1)
                randomatt2 = ARC9.GetAttTable(randomatt2)

                if istable(randomatt1) and randomatt1.Icon then
                    folderbtn:SetFolderIcon(1, randomatt1.Icon, isfav)
                end

                if istable(randomatt2) and randomatt2.Icon then
                    folderbtn:SetFolderIcon(2, randomatt2.Icon, isfav)
                end
            elseif randomatt1 then
                randomatt1 = ARC9.GetAttTable(table.GetKeys(ownedchildren)[1])
                if istable(randomatt1) and randomatt1.Icon then
                    folderbtn:SetFolderIcon(1, randomatt1.Icon, isfav)
                end
            end

            folderbtn:DockMargin(0, 0, ARC9ScreenScale(4), 0)
            folderbtn:Dock(LEFT)

            scroll:AddPanel(folderbtn)
            table.insert(scrolleles, folderbtn)
            folderbtn.folder = folder

            folderbtn:SetFolderContain(tostring(display_count))

            folderbtn.OnMousePressed = function(self2, kc)
                if kc == MOUSE_LEFT then
                    enterfolder(self, scroll, slottbl, self2.folder)
                    surface.PlaySound(foldersound)
                end
                -- if kc == MOUSE_RIGHT then -- randomizing attachments from folder! -- Moved to cl_bind reload
                --     local randompool = {}

                --     for _, v in ipairs(self.BottomBarAtts) do
                --         local atbl = ARC9.GetAttTable(v.att)

                --         local checkfolder = self2.folder

                --         local pathprefix = string.Implode("/", self.BottomBarPath)
                --         if pathprefix != "" then checkfolder = pathprefix .. "/" .. self2.folder end

                --         if atbl.Folder == checkfolder or (self2.folder == "!favorites" and ARC9.Favorites[v.att]) then
                --             table.insert(randompool, atbl)
                --             randompool[#randompool].fuckthis = v.slot
                --         end
                --     end

                --     local thatatt = randompool[math.random(0, #randompool)]
                --     if thatatt then
                --         self:Attach(thatatt.fuckthis, thatatt.ShortName, true)
                --     end

                --     surface.PlaySound(tabsound)
                -- end
            end

            folderbtn.Think = function(self2)
                if !IsValid(self) then return end
                if self2:IsHovered() then
                    self.CustomizeHints["customize.hint.select"] = "customize.hint.open"
                    self.CustomizeHints["customize.hint.random"] = "customize.hint.randomize"
                    self.CustomizeLastHoveredFolder = self2
                end
            end
        end
    end

    if foldercount > 1 then spacer(self, scroll, 0) end

    local strpath = string.Implode("/", self.BottomBarPath)

    for _, att in pairs(self.BottomBarAtts) do
        local qty = ARC9:PlayerGetAtts(self:GetOwner(), att.att, self)

        local atttbl = ARC9.GetAttTable(att.att)
        local aslottbl = self:LocateSlotFromAddress(att.slot)
        local installedtbl = ARC9.GetAttTable(aslottbl.Installed) or {}

        if !GetConVar("arc9_hud_showunowned"):GetBool() and !GetConVar("arc9_free_atts"):GetBool() and qty <= 0 and !atttbl.Free and (installedtbl.InvAtt or aslottbl.Installed) != (atttbl.InvAtt or att.att) then continue end

        if atttbl.AdminOnly and !self:GetOwner():IsAdmin() then continue end

        if strpath != "!favorites" and ((!atttbl.Folder and #self.BottomBarPath > 0) or (atttbl.Folder and atttbl.Folder != strpath)) then continue end

        if strpath == "!favorites" and !ARC9.Favorites[att.att] then continue end

        local attname = ARC9:GetPhraseForAtt(att.att, "CompactName") or ARC9:GetPhraseForAtt(att.att, "PrintName") or ARC9:GetPhraseForAtt(att.att, "ShortName") or ""

        local attbtn2 = vgui.Create("ARC9AttButton", scroll)
        attbtn2.Weapon = self
        attbtn2:DockMargin(0, 0, ARC9ScreenScale(4), 0)
        attbtn2:Dock(LEFT)
        attbtn2:SetButtonText(attname)
        attbtn2:SetIcon(atttbl.Icon)
        attbtn2.att = att.att
        attbtn2.attslot = att.slot
        attbtn2.address = aslottbl.Address
        attbtn2.slottbl = aslottbl

        scroll:AddPanel(attbtn2)
        table.insert(scrolleles, attbtn2)
        attbtn2.OnMousePressed = function(self2, kc)
            if kc == MOUSE_LEFT then
                self:Attach(self2.attslot, self2.att, self2.slottbl.Installed == self2.att) -- third parameter is Silent, so sound won't be played twice though att will updated (might be helpful)
                self.CustomizeSelectAddr = self2.address
            elseif kc == MOUSE_RIGHT then
                if self2.slottbl.Integral and isstring(self2.slottbl.Integral) then
                    self:Attach(self2.address, self2.slottbl.Integral)
                else
                    self:DetachAllFromSubSlot(self2.address)
                end
                self.CustomizeSelectAddr = self2.address
            end
        end

        attbtn2.Think = function(self2)
            if !IsValid(self) then return end

            local slot = self:LocateSlotFromAddress(self2.attslot)

            if !slot then return end

            if slot != self2.slottbl then
                local c1 = slot.Category
                local c2 = self2.slottbl.Category

                if istable(c1) then
                    c1 = table.concat(c1, " ")
                end

                if istable(c2) then
                    c2 = table.concat(c2, " ")
                end

                if c1 != c2 then
                    self:ClearAttInfoBar()
                    self:ClearBottomBar()
                    self.BottomBarAddress = nil
                    self.AttInfoBarAtt = nil
                    return
                end

                self2.slottbl = slot
            end

            attbtn2:SetInstalled(slot.Installed == att.att)
            attbtn2:SetHasModes(!!atttbl.ToggleStats)
            attbtn2:SetHasPaint(!!atttbl.AdvancedCamoSupport)
            attbtn2:SetHasSlots(!!atttbl.Attachments)
            attbtn2:SetCanAttach(self:CanAttach(slot.Address, att.att, slot, true))
            attbtn2:SetMissingDependents(self:GetSlotMissingDependents(slot.Address, att.att, slot))
            attbtn2:SetFullColorIcon(atttbl.FullColorIcon)

            if self2:IsHovered() then
                if (qty > 0) and slot.Installed != att.att then
                    self.CustomizeHints["customize.hint.select"] = "customize.hint.attach"
                elseif self2.slottbl.Installed then
                    self.CustomizeHints["customize.hint.deselect"] = "customize.hint.unattach"
                    if atttbl.ToggleStats and !atttbl.AdvancedCamoSupport then
                        self.CustomizeHints["customize.hint.toggleatts"] = "hud.hint.toggleatts"
                    elseif atttbl.ToggleStats and (atttbl.AdvancedCamoSupport and self.AdvancedCamoCache) then
                        self.CustomizeHints["customize.hint.toggleatts"] = "hud.hint.togglecamos"
                    end
                end

                if ARC9.Favorites[att.att] then
                    self.CustomizeHints["customize.hint.favorite"] = "customize.hint.unfavorite"
                else
                    self.CustomizeHints["customize.hint.favorite"] = "customize.hint.favorite"
                end

                if self.AttInfoBarAtt != self2.att then
                    self.AttInfoBarAtt = self2.att
                    self.AttInfoBarAttSlot = slot
                    self:CreateHUD_AttInfo()
                end

                self.CustomizeLastHovered = self2
            end
            
            if input.IsKeyDown(KEY_LSHIFT) then self2:SetTooltip(att.att) else self2:SetTooltip() end
        end
    end

    scroll:RefreshScrollBar(self.BottomBar)
end

surface.CreateFont("ARC9_KeybindPreview_Cust", {
    font = "Arial",
    size = ARC9ScreenScale(8),
    weight = 1000,
    antialias = true,
})

function SWEP:CreateHUD_Bottom()
    -- if true then return end
    local bg = self.CustomizeHUD
    local lowerpanel = bg.lowerpanel

    self:ClearBottomBar()

    self.AttInfoBarAtt = nil

    local bp = vgui.Create("DPanel", lowerpanel)
    bp:SetSize(lowerpanel:GetWide(), ARC9ScreenScale(62))
    bp:SetPos(0, ARC9ScreenScale(15.5))
    bp.Paint = function() end

    self.BottomBar = bp

    scrolleles = {}
    local scroll = vgui.Create("ARC9HorizontalScroller", bp)
    scroll:SetPos(0, ARC9ScreenScale(3))
    scroll:SetSize(lowerpanel:GetWide(), ARC9ScreenScale(57.3))
    scroll:SetOverlap(-ARC9ScreenScale(5)) -- If this is too small, the right side will be cut out. idk why and idk how to fix it elegantly so here you go
    scroll:MoveToFront()

    function scroll.btnLeft:Paint(w, h) end
    function scroll.btnRight:Paint(w, h) end

    local deadzonex = GetConVar("arc9_hud_deadzonex"):GetInt()

    if self.BottomBarMode == 1 then
        self.CustomizeHUD.lowerpanel:MoveTo(ARC9ScreenScale(19) + deadzonex, ScrH() - ARC9ScreenScale(93+73.5), 0.2, 0, 0.5, nil)
        self.CustomizeHUD.lowerpanel:SizeTo(ScrW() - ARC9ScreenScale(38) - deadzonex*2, ARC9ScreenScale(74+73.5), 0.2, 0, 0.5, nil)
        self.CustomizeHUD.lowerpanel.Extended = true

        self:ClosePresetMenu()

        local slottbl = self:LocateSlotFromAddress(self.BottomBarAddress)

        if !slottbl then return end

        if slottbl.Installed then
            self.AttInfoBarAtt = slottbl.Installed
            self.AttInfoBarAttSlot = slottbl
            self:CreateHUD_AttInfo()
        else
            self:ClearAttInfoBar()
        end

        local atts = ARC9.GetAttsForCats(slottbl.Category or "")
        local atts_slots = {}
        local atts_fav = {}

        for _, att in pairs(atts) do
            if (slottbl.RejectAttachments or {})[att] then continue end
            if ARC9.Favorites[att] then atts_fav[att] = true end
            table.insert(atts_slots, {
                att = att,
                slot = self.BottomBarAddress
            })
        end

        if slottbl.MergeSlotAddresses then
            for _, addr in pairs(slottbl.MergeSlotAddresses) do
                local slottbl2 = self:LocateSlotFromAddress(addr)

                local atts2 = ARC9.GetAttsForCats(slottbl2.Category or "")
                table.Add(atts, atts2)
                for _, att in pairs(atts2) do
                    if (slottbl2.RejectAttachments or {})[att] then continue end
                    table.insert(atts_slots, {
                        att = att,
                        slot = addr
                    })
                end
            end
        end

        table.sort(atts_slots, function(a, b)
            a = a.att or ""
            b = b.att or ""

            if a == "" or b == "" then return true end

            local atttbl_a = ARC9.GetAttTable(a)
            local atttbl_b = ARC9.GetAttTable(b)

            local order_a = 0
            local order_b = 0

            order_a = atttbl_a.SortOrder or order_a
            order_b = atttbl_b.SortOrder or order_b

            if ARC9.Favorites[a] then order_a = order_a - ARC9.FavoritesWeight end
            if ARC9.Favorites[b] then order_b = order_b - ARC9.FavoritesWeight end

            local qty_a = ARC9:PlayerGetAtts(self:GetOwner(), a, self)
            local qty_b = ARC9:PlayerGetAtts(self:GetOwner(), b, self)

            if ( (qty_a <= 0) and (slottbl.Installed != a) ) then order_a = order_a - ARC9.UnownedWeight end
            if ( (qty_b <= 0) and (slottbl.Installed != b) ) then order_b = order_b - ARC9.UnownedWeight end

            if order_a == order_b then
                return (atttbl_a.CompactName or atttbl_a.PrintName or "") < (atttbl_b.CompactName or atttbl_b.PrintName or "")
            end

            return order_a < order_b
        end)

        -- BottomBarFolders actually contains every folder and attachment, not just folders!
        self.BottomBarFolders = ARC9.GetFoldersForAtts(atts)
        self.BottomBarAtts = atts_slots

        local foldercount = 0
        local firstfolder = nil
        for k, v in pairs(self.BottomBarFolders) do
            if istable(v) then
                foldercount = foldercount + 1
                firstfolder = k
            end
        end

        if foldercount > 0 and atts_fav != {} then
            self.BottomBarFolders["!favorites"] = atts_fav
        end

        if table.Count(self.BottomBarFolders) == 1 then
            local sub = firstfolder

            -- print(sub)

            if istable(self.BottomBarFolders[sub]) then
                self.BottomBarPath = {}
                enterfolder(self, scroll, slottbl, sub)
                return
            end
        end

        enterfolder(self, scroll, slottbl, true)
    else
        self:CreateHUD_Slots(scroll)
    end

    scroll:RefreshScrollBar(self.BottomBar)

    if self.LastScroll then
        scroll:SetScroll(self.LastScroll)
    end
end

SWEP.AttInfoBar = nil
SWEP.AttInfoBarAtt = nil

function SWEP:ClearAttInfoBar()
    if self.AttInfoBar then
        self.AttInfoBar:Remove()
        self.AttInfoBar = nil
    end
end

function SWEP:CreateHUD_AttInfo()
    local lowerpanel = self.CustomizeHUD.lowerpanel
    -- if true then return end
    local atttbl = ARC9.GetAttTable(self.AttInfoBarAtt)

    self:ClearAttInfoBar()

    if !atttbl then return end

    local infopanel = vgui.Create("DPanel", lowerpanel)
    infopanel:SetSize(lowerpanel:GetWide(), ARC9ScreenScale(70))
    infopanel:SetPos(0, ARC9ScreenScale(75.5))
    infopanel.title = ARC9:GetPhraseForAtt(self.AttInfoBarAtt, "PrintName") or atttbl.PrintName
    infopanel.Paint = function(self2, w, h)
        if !IsValid(self) then return end
        -- surface.SetFont("ARC9_10")
        -- surface.SetTextPos(0, 0)
        -- surface.SetTextColor(ARC9.GetHUDColor("fg"))
        -- ARC9.DrawTextRot(self2, self2.title, 0, 0, ARC9ScreenScale(6), ARC9ScreenScale(3), w, true)

        markup.Parse("<font=ARC9_10>" .. self2.title):Draw(ARC9ScreenScale(6), ARC9ScreenScale(3), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
    end

    self.AttInfoBar = infopanel

    local descscroller = vgui.Create("ARC9ScrollPanel", infopanel)
    descscroller:SetSize(lowerpanel:GetWide() / 2 - ARC9ScreenScale(5), infopanel:GetTall() - ARC9ScreenScale(16))
    descscroller:SetPos(ARC9ScreenScale(4), ARC9ScreenScale(14))

    local multiline = {}
    local desc = ARC9:GetPhraseForAtt(self.AttInfoBarAtt, "Description") or atttbl.Description

    if atttbl.AdvancedCamoSupport and !self.AdvancedCamoCache then
        desc = desc .. (ARC9:GetPhrase("customize.camoslot.nosupport") or "")
        if self.EFTErgo then desc = desc .. (ARC9:GetPhrase("customize.camoslot.eftextra") or "") end
    end

    multiline = ARC9MultiLineText(desc, descscroller:GetWide() - (ARC9ScreenScale(3.5)), "ARC9_9_Slim")

    for i, text in ipairs(multiline) do
        local desc_line = vgui.Create("DPanel", descscroller)
        desc_line:SetSize(descscroller:GetWide(), ARC9ScreenScale(9))
        desc_line:Dock(TOP)
        desc_line.Paint = function(self2, w, h)
            -- surface.SetFont("ARC9_9_Slim")
            -- surface.SetTextColor(ARC9.GetHUDColor("fg"))
            -- surface.SetTextPos(ARC9ScreenScale(2), 0)
            -- surface.DrawText(text)
            markup.Parse("<font=ARC9_9_Slim>" .. text):Draw(ARC9ScreenScale(2), 0, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
        end
    end

    local slot = self.AttInfoBarAttSlot

    local camotoggle = atttbl.AdvancedCamoSupport and self.AdvancedCamoCache

    if slot and ((atttbl.ToggleStats and !atttbl.AdvancedCamoSupport) or camotoggle) then
        local mode_toggle = vgui.Create("ARC9TopButton", infopanel)
        mode_toggle.addr = slot.Address
        surface.SetFont("ARC9_12")
        local curmode = "Togglable"
        local tw = surface.GetTextSize(curmode)
        mode_toggle:SetPos(descscroller:GetWide()/2-(ARC9ScreenScale(24)+tw)/2, ARC9ScreenScale(50))
        mode_toggle:SetSize(0, 0) -- ARC9ScreenScale(24)+tw, ARC9ScreenScale(21*0.75)
        mode_toggle:SetButtonText(curmode, "ARC9_12")
        mode_toggle:SetIcon(camotoggle and camosicon or modesicon)
        mode_toggle.DoClick = function(self2)
            -- surface.PlaySound(clicksound)
            -- self:PlayAnimation("toggle")
            self:EmitSound(camotoggle and favsound or self:RandomChoice(self:GetProcessedValue("ToggleAttSound", true)), 75, 100, 1, CHAN_ITEM)
            self:ToggleStat(self2.addr)
            self:PostModify()
        end

        mode_toggle.DoRightClick = function(self2)
            -- surface.PlaySound(clicksound)
            -- self:PlayAnimation("toggle")
            self:EmitSound(camotoggle and favsound or self:RandomChoice(self:GetProcessedValue("ToggleAttSound", true)), 75, 100, 1, CHAN_ITEM)
            self:ToggleStat(self2.addr, -1)
            self:PostModify()
        end

        mode_toggle.Think = function(self2)
            if !IsValid(self) then return end
            if self.AdvancedCamoCache == false then self2:Remove() return end

            slot = self:LocateSlotFromAddress(self2.addr)

            if !slot then return end

            if slot.Installed == self.AttInfoBarAtt then
                curmode = atttbl.ToggleStats[slot.ToggleNum] and (ARC9:GetPhrase(atttbl.ToggleStats[slot.ToggleNum].PrintName) or atttbl.ToggleStats[slot.ToggleNum].PrintName) or "Toggle"

                surface.SetFont("ARC9_12")
                tw = surface.GetTextSize(curmode)
                mode_toggle:SetPos(descscroller:GetWide() / 2-(ARC9ScreenScale(24) + tw) / 2, ARC9ScreenScale(50))
                mode_toggle:SetSize(ARC9ScreenScale(21) + tw, ARC9ScreenScale(21 * 0.75))
                mode_toggle:SetButtonText(curmode, "ARC9_12")
                if atttbl.ToggleStats[slot.ToggleNum].ToggleIcon then
                    mode_toggle:SetIcon(atttbl.ToggleStats[slot.ToggleNum].ToggleIcon)
                end
            else
                mode_toggle:SetSize(0, 0)
            end

            if self2:IsHovered() then
                self.CustomizeHints["customize.hint.select"] = "customize.hint.nextmode"
                self.CustomizeHints["customize.hint.deselect"] = "customize.hint.lastmode"
            end

        end
        descscroller:SetSize(lowerpanel:GetWide()/2 - ARC9ScreenScale(5), infopanel:GetTall() - ARC9ScreenScale(38)) -- making desc smaller
    end


    local prosscroller = vgui.Create("ARC9ScrollPanel", infopanel)
    prosscroller:SetSize(lowerpanel:GetWide()*0.25 - ARC9ScreenScale(3), infopanel:GetTall() - ARC9ScreenScale(4))
    prosscroller:SetPos(lowerpanel:GetWide()*0.5 + ARC9ScreenScale(3), ARC9ScreenScale(3))

    local consscroller = vgui.Create("ARC9ScrollPanel", infopanel)
    consscroller:SetSize(lowerpanel:GetWide()*0.25 - ARC9ScreenScale(3), infopanel:GetTall() - ARC9ScreenScale(4))
    consscroller:SetPos(lowerpanel:GetWide()*0.75 + ARC9ScreenScale(3), ARC9ScreenScale(3))

    local prosname, prosnum, consname, consnum = ARC9.GetProsAndCons(atttbl, self)

    if table.Count(prosname) > 0 then
        lowerpanel.HasPros = true
        for k, stat in ipairs(prosname) do
            local pro_stat = vgui.Create("DPanel", prosscroller)
            pro_stat:SetSize(prosscroller:GetWide(), ARC9ScreenScale(9))
            pro_stat:Dock(TOP)
            pro_stat.text = stat
            pro_stat.Paint = function(self2, w, h)
                if !IsValid(self) then return end
                surface.SetFont("ARC9_9")
                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                surface.SetTextPos(ARC9ScreenScale(2), 0)
                local tw = surface.GetTextSize(self2.text)
                ARC9.DrawTextRot(self2, self2.text, ARC9ScreenScale(2), 0, ARC9ScreenScale(2), 0, ARC9ScreenScale(110), false)

                local tw = surface.GetTextSize(prosnum[k])
                ARC9.DrawTextRot(self2, prosnum[k], 0, 0, prosscroller:GetWide()-tw-ARC9ScreenScale(6), 0, w, true)
            end
        end
    else
        lowerpanel.HasPros = nil
    end

    if table.Count(consname) > 0 then
        lowerpanel.HasCons = true
        for k, stat in ipairs(consname) do
            local con_stat = vgui.Create("DPanel", consscroller)
            con_stat:SetSize(consscroller:GetWide(), ARC9ScreenScale(9))
            con_stat:Dock(TOP)
            con_stat.text = stat
            con_stat.Paint = function(self2, w, h)
                if !IsValid(self) then return end
                surface.SetFont("ARC9_9")
                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                surface.SetTextPos(ARC9ScreenScale(2), 0)
                local tw = surface.GetTextSize(self2.text)
                ARC9.DrawTextRot(self2, self2.text, ARC9ScreenScale(2), 0, ARC9ScreenScale(2), 0, ARC9ScreenScale(110), false)

                local tw = surface.GetTextSize(consnum[k])
                ARC9.DrawTextRot(self2, consnum[k], 0, 0, consscroller:GetWide()-tw-ARC9ScreenScale(6), 0, w, true)
            end
        end
    else
        lowerpanel.HasCons = nil
    end
end