local ARC9ScreenScale = ARC9.ScreenScale
local hoversound = "arc9/newui/uimouse_hover.ogg"
local clicksound = "arc9/newui/uimouse_click.ogg"

ARC9.CustomizeTabs = ARC9.CustomizeTabs or {}
ARC9.OptionControls = ARC9.OptionControls or {}

function ARC9.RegisterCustomizeTab(id, def)
    def.id = id
    def.order = def.order or 100
    def.height = def.height or 50
    ARC9.CustomizeTabs[id] = def
end

function ARC9.GetCustomizeTabs()
    local list = {}
    for _, def in pairs(ARC9.CustomizeTabs) do table.insert(list, def) end
    table.sort(list, function(a, b)
        if a.order == b.order then return a.id < b.id end
        return a.order < b.order
    end)
    return list
end

function ARC9.RegisterOptionControl(type, create)
    ARC9.OptionControls[type] = create
end

ARC9.RegisterOptionControl("slider", function(row, opt, x, w, h)
    local slider = vgui.Create("ARC9NumSlider", row)
    slider:SetPos(x, 0)
    slider:SetSize(w, h)
    slider:SetText("")
    slider.Label:SetVisible(false)
    slider:SetMin(opt.min or 0)
    slider:SetMax(opt.max or 1)
    slider:SetDecimals(opt.decimals or 2)

    function slider:ARC9Refresh()
        self.ARC9Refreshing = true
        self:SetValue(tonumber(opt.get()) or opt.min or 0)
        self.ARC9Refreshing = nil
    end

    slider:ARC9Refresh()

    slider.OnValueChanged = function(self2, val)
        if self2.ARC9Refreshing then return end
        opt.set(val, true)
    end

    return slider
end)

ARC9.RegisterOptionControl("color", function(row, opt, x, w, h)
    local btn = vgui.Create("ARC9ColorButton", row)
    btn:SetPos(x, ARC9ScreenScale(0.5))
    btn:SetSize(ARC9ScreenScale(42), h - ARC9ScreenScale(2))

    function btn:ARC9Refresh()
        self.rgbcolor = opt.get() or Color(255, 255, 255)
    end

    btn:ARC9Refresh()

    btn.OnColorChanging = function(self2, c) opt.set(c, false) end
    btn.OnColorPicked = function(self2, c) opt.set(c, true) end
    btn.OnCursorEntered = function() surface.PlaySound(hoversound) end

    local oldpaint = row.Paint
    row.Paint = function(self2, pw, ph)
        if oldpaint then oldpaint(self2, pw, ph) end
        local c = opt.get() or color_white
        surface.SetFont("ARC9_10_Slim")
        surface.SetTextColor(ARC9.GetHUDColor("fg"))
        surface.SetTextPos(x + ARC9ScreenScale(46), ARC9ScreenScale(1))
        surface.DrawText(string.format("#%02X%02X%02X", c.r, c.g, c.b))
    end

    return btn
end)

ARC9.RegisterOptionControl("bool", function(row, opt, x, w, h)
    local box = vgui.Create("ARC9Checkbox", row)
    box:SetPos(x, (h - box:GetTall()) / 2)

    function box:ARC9Refresh()
        self.ARC9Refreshing = true
        self:SetChecked(!!opt.get())
        self.ARC9Refreshing = nil
    end

    box:ARC9Refresh()

    box.OnChange = function(self2, val)
        if self2.ARC9Refreshing then return end
        surface.PlaySound(clicksound)
        opt.set(val, true)
    end

    return box
end)

function ARC9.CreateOptionsPanel(parent, spec)
    local w, h = parent:GetWide(), parent:GetTall()
    local rowh = ARC9ScreenScale(14)
    local labelw = w * 0.17
    local controlw = w * 0.3
    local controls = {}

    local header = vgui.Create("DPanel", parent)
    header:SetPos(0, 0)
    header:SetSize(w, rowh)
    header.Paint = function(self2, pw, ph)
        local title = spec.title
        if isfunction(title) then title = title() end
        if isstring(title) then
            surface.SetFont("ARC9_10")
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            surface.SetTextPos(ARC9ScreenScale(2), 0)
            surface.DrawText(ARC9:GetPhrase(title) or title)
        end

        if spec.note then
            local note = ARC9:GetPhrase(spec.note) or spec.note
            surface.SetFont("ARC9_7_Slim")
            local tw = surface.GetTextSize(note)
            surface.SetTextColor(ARC9.GetHUDColor("hint"))
            surface.SetTextPos(pw - tw - (spec.onReset and ARC9ScreenScale(70) or ARC9ScreenScale(2)), ARC9ScreenScale(3))
            surface.DrawText(note)
        end
    end

    if spec.onReset then
        local reset = vgui.Create("ARC9Button", header)
        reset:SetSize(ARC9ScreenScale(60), ARC9ScreenScale(11))
        reset:SetPos(w - ARC9ScreenScale(62), 0)
        reset.text = ARC9:GetPhrase("customize.options.reset") or "Reset"
        reset.DoClick = function()
            surface.PlaySound(clicksound)
            spec.onReset()
            for _, control in ipairs(controls) do
                if IsValid(control) and control.ARC9Refresh then control:ARC9Refresh() end
            end
        end
        reset.OnCursorEntered = function() surface.PlaySound(hoversound) end
    end

    local scroll = vgui.Create("ARC9ScrollPanel", parent)
    scroll:SetPos(0, rowh + ARC9ScreenScale(2))
    scroll:SetSize(w, h - rowh - ARC9ScreenScale(2))
    scroll.Paint = function() end

    for _, opt in ipairs(spec.options or {}) do
        local create = ARC9.OptionControls[opt.type or "slider"]
        if !create then continue end

        local row = scroll:Add("DPanel")
        row:SetTall(rowh)
        row:Dock(TOP)
        row.Paint = function(self2, pw, ph)
            surface.SetFont("ARC9_10")
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            surface.SetTextPos(ARC9ScreenScale(2), ARC9ScreenScale(1))
            surface.DrawText(ARC9:GetPhrase(opt.name) or opt.name or "")
        end

        local control = create(row, opt, labelw, controlw, rowh)
        if control then table.insert(controls, control) end
    end

    return scroll
end
