local ARC9ScreenScale = ARC9.ScreenScale

function SWEP:CreateHUD_Trivia()
    local lowerpanel = self.CustomizeHUD.lowerpanel

    self:ClearTabPanel()

    local descbg = vgui.Create("DPanel", lowerpanel)
    descbg:SetPos(ARC9ScreenScale(4), ARC9ScreenScale(19))
    descbg:SetSize(lowerpanel:GetWide()-ARC9ScreenScale(4), ARC9ScreenScale(100))
    descbg.Paint = function(self2, w, h)
    end

    descbg:SetAlpha(0)
    descbg:AlphaTo(255, 0.2, 0, nil)

    self.BottomBar = descbg

    local desc = vgui.Create("ARC9ScrollPanel", descbg)
    desc:SetPos(0, 0)
    desc:SetSize(descbg:GetWide() * 0.75, descbg:GetTall())
    desc.Paint = function(self2, w, h)
        -- surface.SetDrawColor(144, 0, 0, 100)
        -- surface.DrawRect(0, 0, w, h)
    end

    local desctitle = desc:Add("DPanel")
    desctitle:SetSize(desc:GetWide(), ARC9ScreenScale(7))
    desctitle:Dock(TOP)
    desctitle.title = "customize.trivia.description"
    desctitle.Paint = function(self2, w, h)
        if !IsValid(self) then return end

        surface.SetFont("ARC9_7_Slim")
        surface.SetTextPos(ARC9ScreenScale(2), ARC9ScreenScale(0))
        surface.SetTextColor(ARC9.GetHUDColor("fg"))
        surface.DrawText(ARC9:GetPhrase(self2.title) or self2.title)
    end

	local truedesc = ( ARC9:UseTrueNames() and ARC9:GetPhrase(self.TrueDescription) )
	local descstring = ARC9:GetPhrase( truedesc and self.TrueDescription or self.Description ) or self.Description

	-- local desc_line = vgui.Create("DPanel", desc)
	-- desc_line:SetSize(desc:GetWide(), ARC9ScreenScale(8))
	-- desc_line:Dock(TOP)
	-- desc_line.Paint = function(self2, w, h)
        -- if !IsValid(self) then return end
        -- markup.Parse( "<font=ARC9_8>" .. descstring, desc_line:GetWide() - ARC9ScreenScale(1) ):Draw(ARC9ScreenScale(2), ARC9ScreenScale(0), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
    -- end

    descmultiline = ARC9MultiLineText(descstring, desc:GetWide() - ARC9ScreenScale(1), "ARC9_8")
    for i, text in ipairs(descmultiline) do
        local desc_line = vgui.Create("DPanel", desc)
        desc_line:SetSize(desc:GetWide(), ARC9ScreenScale(8))
        desc_line:Dock(TOP)
        desc_line.Paint = function(self2, w, h)
        if !IsValid(self) then return end
			markup.Parse("<font=ARC9_8>" .. text):Draw(ARC9ScreenScale(2), 0, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
        end
    end


    -- credits
    local creditsscroll = vgui.Create("ARC9ScrollPanel", descbg)
    creditsscroll:SetPos(0, desc:GetTall())
    creditsscroll:SetSize(descbg:GetWide() * 0.75, ARC9ScreenScale(17)) -- descbg:GetTall()
    creditsscroll.Paint = function(self2, w, h)
        -- surface.SetDrawColor(0, 144, 0, 100)
        -- surface.DrawRect(0, 0, w, h)
    end

    local creditssorted = {}
    for title, credit in pairs(self:GetValue("Credits")) do
        if title == "BaseClass" then continue end
        local credittbl = {}
        credittbl.credit = credit
        if tonumber(title[#title]) then
            credittbl.order = title[#title]
            credittbl.title = string.sub(title, 0, #title-1)
        else
            credittbl.order = 0
            credittbl.title = title
        end

        table.insert(creditssorted, credittbl)
    end

    for _, credittbl in SortedPairsByMemberValue(creditssorted, "order", false) do
        local creditline = creditsscroll:Add("DPanel")

        local desctall = math.max(descbg:GetTall()*0.45, desc:GetTall()-ARC9ScreenScale(17)) - ARC9ScreenScale(2)
        local creditstall = math.min(creditsscroll:GetTall()+ARC9ScreenScale(17), descbg:GetTall()*0.55)
        desc:SetTall(desctall)
        creditsscroll:SetTall(creditstall)
        creditsscroll:SetPos(0, desc:GetTall() + ARC9ScreenScale(2))

        creditline:SetSize(creditsscroll:GetWide(), ARC9ScreenScale(17))
        creditline:Dock(TOP)
        creditline.title = ARC9:GetPhrase(credittbl.title) or credittbl.title
        creditline.credit = credittbl.credit
        creditline.Paint = function(self2, w, h)
            if !IsValid(self) then return end

            local titlestring = string.Replace(self2.title, "_", " ") 

            surface.SetFont("ARC9_7_Slim")
            surface.SetTextPos(ARC9ScreenScale(2), 0)
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            surface.DrawText(titlestring)

            local major = self2.credit

            surface.SetFont("ARC9_9")
            surface.SetTextPos(ARC9ScreenScale(2), ARC9ScreenScale(6))
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            surface.DrawText(major)
            -- self:DrawTextRot(self2, major, 0, 0, math.max(ARC9ScreenScale(1), 0), ARC9ScreenScale(6), w, true)
        end
    end

    -- trivia
    local triviascroll = vgui.Create("ARC9ScrollPanel", descbg)
    triviascroll:SetPos(descbg:GetWide() * 0.76, 0)
    triviascroll:SetSize(descbg:GetWide() * 0.24 - ARC9ScreenScale(4), descbg:GetTall() + ARC9ScreenScale(8))
    triviascroll.Paint = function(self2, w, h)
        -- surface.SetDrawColor(0, 0, 144, 100)
        -- surface.DrawRect(0, 0, w, h)
    end

    local triviasorted = {}
    for title, trivia in pairs(self:GetValue("Trivia")) do
        if title == "BaseClass" then continue end
        local triviatbl = {}
        triviatbl.trivia = trivia
        if tonumber(title[#title]) then
            triviatbl.order = title[#title]
            triviatbl.title = string.sub(title, 0, #title-1)
        else
            triviatbl.order = 0
            triviatbl.title = title
        end

        table.insert(triviasorted, triviatbl)
    end

    for _, triviatbl in SortedPairsByMemberValue(triviasorted, "order", false) do
        local trivialine = triviascroll:Add("DPanel")
        trivialine:SetSize(triviascroll:GetWide(), ARC9ScreenScale(17))
        trivialine:Dock(TOP)
        trivialine.title = ARC9:GetPhrase(triviatbl.title) or triviatbl.title
        trivialine.trivia = ARC9:GetPhrase(triviatbl.trivia) or triviatbl.trivia
        trivialine.Paint = function(self2, w, h)
            if !IsValid(self) then return end
            
            local titlestring = string.Replace(self2.title, "_", " ") 

            surface.SetFont("ARC9_7_Slim")
            local tw = surface.GetTextSize(titlestring)
            surface.SetTextPos(w-tw-ARC9ScreenScale(2), 0)
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            surface.DrawText(titlestring)

            local major = self2.trivia

            surface.SetFont("ARC9_9")
            local tw = surface.GetTextSize(major)
            surface.SetTextPos(w-tw-ARC9ScreenScale(3), ARC9ScreenScale(6))
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            surface.DrawText(major)
            -- self:DrawTextRot(self2, major, 0, 0, math.max(ARC9ScreenScale(1), 0), ARC9ScreenScale(6), w, true)
        end
    end
end