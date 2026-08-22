
local ARC9ScreenScale = ARC9.ScreenScale

-- given fov and distance solve apparent size
local function solvetriangle(angle, dist)
    local a = angle / 2
    local b = dist
    return b * math.tan(a) * 2
end

local hits_1 = {}
local hits_3 = {}

local function rollhit(radius)
    local anglerand = math.Rand(0, 360)
    local dist = math.Rand(0, radius)

    local hit_x = math.sin(anglerand) * dist
    local hit_y = math.cos(anglerand) * dist

    return {x = hit_x, y = hit_y}
end

local function rollallhits(self, range_3, range_1)

    hits_1 = {}
    hits_3 = {}

    local ang = self:GetValue("Spread") * 10 / 360

    local radius_1 = solvetriangle(ang, range_1)
    local radius_3 = solvetriangle(ang, range_3)

    local hitcount = math.Clamp(math.max(math.Round(self:GetCapacity(self:GetUBGL()) / 4), math.Round(self:GetValue("Num") * 2)), 10, 20)

    for i = 1, hitcount do
        table.insert(hits_1, rollhit(radius_1))
    end

    for i = 1, hitcount do
        table.insert(hits_3, rollhit(radius_3))
    end
end

local bullseye = Material("arc9/bullseye.png", "mips smooth")
local target_ipsc = Material("arc9/target_ipsc.png", "mips smooth")
local mat_hit = Material("arc9/hit.png", "mips smooth")
local mat_hit_dot = Material("arc9/hit_dot.png", "mips smooth")
local ranger_range = 0

local mat_body = Material("arc9/body.png", "mips smooth")
local mat_body_arms = Material("arc9/body_arms.png", "mips smooth")
local mat_body_head = Material("arc9/body_head.png", "mips smooth")
local mat_body_chest = Material("arc9/body_chest.png", "mips smooth")
local mat_body_stomach = Material("arc9/body_stomach.png", "mips smooth")
local mat_body_legs = Material("arc9/body_legs.png", "mips smooth")

local stk_clr = {
    [1] = Color(75, 25, 25),
    [2] = Color(40, 20, 20),
    [3] = Color(50, 50, 50),
    [4] = Color(75, 75, 75),
    [5] = Color(100, 100, 100),
    [6] = Color(120, 120, 120),
    [7] =  Color(140, 140, 140),
    [8] = Color(160, 160, 160),
    [9] = Color(200, 200, 200),
}

local function getstkcolor(stk)
    if stk_clr[stk] then
        return stk_clr[stk]
    else
        return stk_clr[9]
    end
end

function SWEP:CreateHUD_Bench()
    local bg = self.CustomizeHUD
	local imperial = GetConVar("arc9_imperial"):GetBool()

    self:ClearTabPanel()

    self:CreateHUD_Stats()

    if !self:GetProcessedValue("PrimaryBash", true) and !self:GetProcessedValue("Throwable", true) and !self:GetProcessedValue("ShootEnt") then -- no ballistics
        local tp = vgui.Create("DScrollPanel", bg)
        local width = math.min(ARC9ScreenScale(550), ScrW())
        tp:SetSize(width, ARC9ScreenScale(100))
        tp:SetPos(ScrW()*0.5 - width*0.5, ScrH()-ARC9ScreenScale(275))
        tp:SetAlpha(0)
        tp:AlphaTo(255, 0.2, 0, nil)

        local cornercut = ARC9ScreenScale(3.5)

        tp.Paint = function(self2, w, h)
            surface.SetDrawColor(ARC9.GetHUDColor("bg_menu", 200))
            -- surface.DrawRect(0, 0, w, h)
            draw.NoTexture()
            surface.DrawPoly({{x = cornercut, y = h},{x = 0, y = h-cornercut}, {x = 0, y = cornercut},{x = cornercut, y = 0}, {x = w-cornercut, y = 0},{x = w, y = cornercut}, {x = w, y = h-cornercut}, {x = w-cornercut, y = h}})
        end

        -- local scroll_preset = tp:GetVBar()
        -- scroll_preset.Paint = function() end
        -- scroll_preset.btnUp.Paint = function(span, w, h)
        -- end
        -- scroll_preset.btnDown.Paint = function(span, w, h)
        -- end
        -- scroll_preset.btnGrip.Paint = PaintScrollBar

        self.TabPanel = tp

        -- self:RollRecoil()

        -- local recoilchart = vgui.Create("DButton", tp)
        -- recoilchart:SetSize(ARC9ScreenScale(220), ARC9ScreenScale(220))
        -- recoilchart:SetPos(ARC9ScreenScale(310), ARC9ScreenScale(0))
        -- recoilchart:SetText("")
        -- recoilchart.DoClick = function(self2)
        --     self:RollRecoil()
        -- end
        -- recoilchart.Paint = function(self2, w, h)
        --     surface.SetDrawColor(ARC9.GetHUDColor("bg", 50))
        --     surface.DrawRect(0, 0, w, h)

        --     surface.SetMaterial(target_ipsc)
        --     surface.SetDrawColor(ARC9.GetHUDColor("fg", 75))
        --     surface.DrawTexturedRect(0, 0, w, h)

        --     local scale = ARC9ScreenScale(8)

        --     for i = 1, math.min(self:GetMaxClip1(), 100) do
        --         local hit = recoil_hits[i]
        --         local x = -hit.x * scale + (w / 2)
        --         local y = -hit.y * scale + (h / 2)

        --         local s = ARC9ScreenScale(12)

        --         surface.SetMaterial(mat_hit)
        --         surface.SetDrawColor(ARC9.GetHUDColor("fg", 75))
        --         if i == 1 then
        --             surface.SetDrawColor(Color(255, 0, 0, 75))
        --         end
        --         surface.DrawTexturedRect(x - (s / 2), y - (s / 2), s, s)

        --         if i < math.min(self:GetMaxClip1(), 100) then
        --             local hit2 = recoil_hits[i + 1]
        --             local x2 = -hit2.x * scale + (w / 2)
        --             local y2 = -hit2.y * scale + (h / 2)

        --             surface.DrawLine(x, y, x2, y2)
        --         end
        --     end

        --     local txt_bottom = "ARCTIC SYSTEMS RECOIL TEST"
        --     surface.SetFont("ARC9_6")
        --     local tbw = surface.GetTextSize(txt_bottom)
        --     surface.SetTextColor(ARC9.GetHUDColor("fg"))
        --     surface.SetTextPos((w - tbw) / 2, h - ARC9ScreenScale(12))
        --     surface.DrawText(txt_bottom)
        -- end

        local dmgpanel = vgui.Create("DPanel", tp)
        dmgpanel:SetSize(ARC9ScreenScale(100), ARC9ScreenScale(100))
        dmgpanel:SetPos(0, 0)
        dmgpanel.Paint = function(span, w, h)
            if !IsValid(self) then return end

            surface.SetDrawColor(ARC9.GetHUDColor("bg"))
            -- surface.DrawRect(0, 0, w, h)
            draw.NoTexture()
            surface.DrawPoly({{x = cornercut, y = h},{x = 0, y = h-cornercut}, {x = 0, y = cornercut},{x = cornercut, y = 0}, {x = w-cornercut, y = 0},{x = w, y = cornercut}, {x = w, y = h-cornercut}, {x = w-cornercut, y = h}})

            local dmgv = self:GetDamageAtRange(ranger_range)

            if self:GetProcessedValue("DistributeDamage") then
                dmgv = dmgv
            end

            local bodydamage = self:GetProcessedValue("BodyDamageMults")

            local dmg_head = dmgv * self:GetProcessedValue("HeadshotDamage") * (bodydamage[HITGROUP_HEAD] or 2)
            local dmg_chest = dmgv * self:GetProcessedValue("ChestDamage") * (bodydamage[HITGROUP_CHEST] or 1)
            local dmg_stomach = dmgv * self:GetProcessedValue("StomachDamage") * (bodydamage[HITGROUP_STOMACH] or 1)
            local dmg_legs = dmgv * self:GetProcessedValue("LegDamage") * ((bodydamage[HITGROUP_LEFTLEG] or 0.25) + (bodydamage[HITGROUP_RIGHTLEG] or 0.25)) / 2
            local dmg_arms = dmgv * self:GetProcessedValue("ArmDamage") * ((bodydamage[HITGROUP_LEFTARM] or 0.25) + (bodydamage[HITGROUP_RIGHTARM] or 0.25)) / 2

            local stk_head = math.ceil(100 / dmg_head)
            local stk_chest = math.ceil(100 / dmg_chest)
            local stk_stomach = math.ceil(100 / dmg_stomach)
            local stk_legs = math.ceil(100 / dmg_legs)
            local stk_arms = math.ceil(100 / dmg_arms)

            -- draw the body

            local body_w = ARC9ScreenScale(30)
            local body_h = ARC9ScreenScale(80)
            local body_x = (w - body_w) / 2
            local body_y = (h - body_h) / 2

            surface.SetDrawColor(Color(150, 150, 150, 255))
            surface.SetMaterial(mat_body)
            surface.DrawTexturedRect(body_x, body_y, body_w, body_h)

            local txt_dmg_head = tostring(math.Round(dmg_head, 0)) .. " " .. ARC9:GetPhrase("unit.dmg")
            local txt_dmg_chest = tostring(math.Round(dmg_chest, 0)) .. " " .. ARC9:GetPhrase("unit.dmg")
            local txt_dmg_stomach = tostring(math.Round(dmg_stomach, 0)) .. " " .. ARC9:GetPhrase("unit.dmg")
            local txt_dmg_legs = tostring(math.Round(dmg_legs, 0)) .. " " .. ARC9:GetPhrase("unit.dmg")
            local txt_dmg_arms = tostring(math.Round(dmg_arms, 0)) .. " " .. ARC9:GetPhrase("unit.dmg")

            surface.SetDrawColor(getstkcolor(stk_head))
            surface.SetMaterial(mat_body_head)
            surface.DrawTexturedRect(body_x, body_y, body_w, body_h)

            surface.SetDrawColor(getstkcolor(stk_chest))
            surface.SetMaterial(mat_body_chest)
            surface.DrawTexturedRect(body_x, body_y, body_w, body_h)

            surface.SetDrawColor(getstkcolor(stk_stomach))
            surface.SetMaterial(mat_body_stomach)
            surface.DrawTexturedRect(body_x, body_y, body_w, body_h)

            surface.SetDrawColor(getstkcolor(stk_legs))
            surface.SetMaterial(mat_body_legs)
            surface.DrawTexturedRect(body_x, body_y, body_w, body_h)

            surface.SetDrawColor(getstkcolor(stk_arms))
            surface.SetMaterial(mat_body_arms)
            surface.DrawTexturedRect(body_x, body_y, body_w, body_h)

            surface.SetFont("ARC9_6")
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            surface.SetDrawColor(ARC9.GetHUDColor("fg"))

            surface.SetTextPos(ARC9ScreenScale(4), ARC9ScreenScale(12))
            surface.DrawText(txt_dmg_head)

            surface.DrawLine(ARC9ScreenScale(4), ARC9ScreenScale(18), ARC9ScreenScale(38+8), ARC9ScreenScale(18))

            surface.SetTextPos(ARC9ScreenScale(4), ARC9ScreenScale(25))
            surface.DrawText(txt_dmg_chest)

            surface.DrawLine(ARC9ScreenScale(4), ARC9ScreenScale(25 + 6), ARC9ScreenScale(35+8), ARC9ScreenScale(25 + 6))

            surface.SetTextPos(ARC9ScreenScale(4), ARC9ScreenScale(35))
            surface.DrawText(txt_dmg_stomach)

            surface.DrawLine(ARC9ScreenScale(4), ARC9ScreenScale(35 + 6), ARC9ScreenScale(40+8), ARC9ScreenScale(35 + 6))

            surface.SetTextPos(ARC9ScreenScale(4), ARC9ScreenScale(50))
            surface.DrawText(txt_dmg_arms)

            surface.DrawLine(ARC9ScreenScale(4), ARC9ScreenScale(50 + 6), ARC9ScreenScale(27+8), ARC9ScreenScale(50 + 6))

            surface.SetTextPos(ARC9ScreenScale(4), ARC9ScreenScale(70))
            surface.DrawText(txt_dmg_legs)

            surface.DrawLine(ARC9ScreenScale(4), ARC9ScreenScale(70 + 6), ARC9ScreenScale(30+8), ARC9ScreenScale(70 + 6))

            local txt_tr = tostring(self:GetProcessedValue("Num")) .. "x " .. ARC9:GetPhrase("unit.projectiles")
            local trw = surface.GetTextSize(txt_tr)
            surface.SetTextPos(w - trw - ARC9ScreenScale(2), ARC9ScreenScale(10))
            surface.DrawText(txt_tr)

            local txt_corner = ARC9:GetPhrase("customize.bench.dummy") or ""
            local tw = surface.GetTextSize(txt_corner)
            surface.SetTextPos((w - tw) / 2, ARC9ScreenScale(1))
            surface.DrawText(txt_corner)

			local impm = imperial and "yard" or "meter"
			local impv = imperial and 1.0936 or 1

            local txt_bottom = (ARC9:GetPhrase("customize.bench.effect") or "") .. " " .. tostring(math.Round(ARC9.HUToM * impv * ranger_range, 0)) .. ARC9:GetPhrase("unit." .. impm)
            local tbw = surface.GetTextSize(txt_bottom)
            surface.SetTextPos((w - tbw) / 2, h - ARC9ScreenScale(8))
            surface.DrawText(txt_bottom)
        end

        local ranger = vgui.Create("DPanel", tp)
        local width2 = math.min(ARC9ScreenScale(200), ScrW() / 3)
        ranger:SetSize(width2, ARC9ScreenScale(100))
        ranger:SetPos(ARC9ScreenScale(100) + width / 22, 0)
        ranger.Paint = function(self2, w, h)
            if !IsValid(self) then return end

            surface.SetDrawColor(ARC9.GetHUDColor("bg"))
            -- surface.DrawRect(0, 0, w, h)
            draw.NoTexture()
            surface.DrawPoly({{x = cornercut, y = h},{x = 0, y = h-cornercut}, {x = 0, y = cornercut},{x = cornercut, y = 0}, {x = w-cornercut, y = 0},{x = w, y = cornercut}, {x = w, y = h-cornercut}, {x = w-cornercut, y = h}})

            local sweetspot = self:GetProcessedValue("SweetSpot", true)

            local range_min = self:GetValue("RangeMin")
            local range_max = self:GetValue("RangeMax")
			
            -- local range_min = imperial and (self:GetValue("RangeMin")) or self:GetValue("RangeMin")
            -- local range_max = imperial and (self:GetValue("RangeMax")) or self:GetValue("RangeMax")
            local range_sweet = self:GetValue("SweetSpotRange")

            local dmg_max = self:GetDamageAtRange(range_min)
            local dmg_min = self:GetDamageAtRange(range_max)
            local dmg_sweet = self:GetValue("SweetSpotDamage")

            surface.SetDrawColor(ARC9.GetHUDColor("fg", 75))

            ranger_range = range_min

            local dmg_diff = math.abs(dmg_max - dmg_min)
            local actual_minimum_damage = math.min(dmg_min, dmg_max)
            if sweetspot then
                dmg_diff = math.max(dmg_diff, math.abs(dmg_max - dmg_sweet), math.abs(dmg_min - dmg_sweet))
                actual_minimum_damage = math.min(actual_minimum_damage, dmg_sweet)
            end

            local range_min_x = (w / 5)
            local range_max_x = 4 * (w / 5)
            local range_sweetspot_x = 0

            local range_min_y = 3 * h / 4
            local range_max_y = 3 * h / 4

            local dmg_scale = h / 100
            if dmg_diff > 0 then
                dmg_scale = h * 0.5 / dmg_diff
            end

            if sweetspot and dmg_sweet > dmg_max and dmg_sweet > dmg_min then
                -- sweet spot is top of scale
                if dmg_max > dmg_min then
                    -- max range (right) is bottom of scale
                    range_min_y = h * 0.75 - dmg_scale * (dmg_max - dmg_min)
                elseif dmg_max < dmg_min then
                    -- min range (left) is bottom of scale
                    range_max_y = h * 0.75 - dmg_scale * (dmg_min - dmg_max)
                end
            elseif sweetspot and dmg_sweet < dmg_max and dmg_sweet < dmg_min then
                -- sweet spot is bottom of scale
                range_min_y = h * 0.75 - dmg_scale * (dmg_max - dmg_sweet)
                range_max_y = h * 0.75 - dmg_scale * (dmg_min - dmg_sweet)
            else
                -- sweet spot doesn't exist or is in the middle. scale is unaffected
                if dmg_max > dmg_min then
                    range_min_y = h / 4
                elseif dmg_max < dmg_min then
                    range_max_y = h / 4
                end
            end

            if range_min == 0 then
                range_min_x = 0
            end

            surface.DrawLine(range_min_x, 0, range_min_x, h)
            surface.DrawLine(range_max_x, 0, range_max_x, h)
            if sweetspot then
                range_sweetspot_x = Lerp((range_sweet - range_min) / (range_max - range_min), range_min_x, range_max_x)
                surface.DrawLine(range_sweetspot_x, 0, range_sweetspot_x, h)
            end

            surface.SetDrawColor(ARC9.GetHUDColor("fg"))

            -- Draw range line
            surface.DrawLine(0, range_min_y, range_min_x, range_min_y)
            surface.DrawLine(range_max_x, range_max_y, w, range_max_y)
            -- if sweetspot and dmg_max != dmg_min then
            --     local f = h * Lerp((math.max(dmg_max, dmg_min) - math.min(dmg_max, dmg_min)) / math.max(dmg_max, dmg_min, dmg_sweet), 0.75, 0.25)
            --     if dmg_max > dmg_min then
            --         surface.DrawLine(0, f, range_min_x, f)
            --         surface.DrawLine(range_max_x, range_max_y, w, range_max_y)
            --     elseif dmg_max < dmg_min then
            --         local f = h * Lerp((dmg_max - dmg_min) / math.max(dmg_min, dmg_sweet), 0.25, 0.75)
            --         surface.DrawLine(0, range_min_y, range_min_x, range_min_y)
            --         surface.DrawLine(range_max_x, f, w, f)
            --     end
            -- else
            --     surface.DrawLine(0, range_min_y, range_min_x, range_min_y)
            --     surface.DrawLine(range_max_x, range_max_y, w, range_max_y)
            -- end

            local segments = 50

            local dmg_values = {
                [0] = dmg_max
            }

            for i = 1, segments do
                local range_at_i = Lerp(i / segments, range_min, range_max)
                local dmg_at_i = self:GetDamageAtRange(range_at_i)
                dmg_values[i] = dmg_at_i
            end

            for i = 1, segments do
                local dmg_at_i = dmg_values[i - 1]
                local dmg_at_i2 = dmg_values[i]

                if dmg_at_i then
                    local x1 = Lerp((i - 1) / segments, range_min_x, range_max_x)
                    local x2 = Lerp(i / segments, range_min_x, range_max_x)

                    local y1 = 3 * (h / 4) - (dmg_scale * (dmg_at_i - actual_minimum_damage))
                    local y2 = 3 * (h / 4) - (dmg_scale * (dmg_at_i2 - actual_minimum_damage))

                    surface.DrawLine(x1, y1, x2, y2)
                end
            end

            local mouse_x, mouse_y = input.GetCursorPos()
            mouse_x, mouse_y = self2:ScreenToLocal(mouse_x, mouse_y)

            local draw_rangetext = true

            if mouse_x > 0 and mouse_x < w then
                if mouse_y > 0 and mouse_y < h then
                    local range = 0

                    local range_m_x = 0

                    if mouse_x < range_min_x then
                        range = range_min
                        range_m_x = range_min_x
                    elseif mouse_x > range_max_x then
                        range = range_max
                        range_m_x = range_max_x
                    else
                        local d = (mouse_x - range_min_x) / (range_max_x - range_min_x)
                        range = Lerp(d, range_min, range_max)
                        range_m_x = mouse_x
                    end

                    ranger_range = range

                    local dmg = self:GetDamageAtRange(range)

                    local txt_dmg1 = tostring(math.Round(dmg)) .. " " .. ARC9:GetPhrase("unit.dmg")

                    if self:GetValue("Num") > 1 then
                        txt_dmg1 = math.Round(dmg * self:GetValue("Num")) .. "-" .. txt_dmg1
                    end

                    surface.SetTextColor(ARC9.GetHUDColor("fg"))
                    surface.DrawLine(range_m_x, 0, range_m_x, h)

                    surface.SetFont("ARC9_8")
                    surface.SetTextColor(ARC9.GetHUDColor("fg"))
                    local txt_dmg1_w = surface.GetTextSize(txt_dmg1)
                    surface.SetTextPos((w / 5) - txt_dmg1_w - (ARC9ScreenScale(2)), ARC9ScreenScale(1))
                    surface.DrawText(txt_dmg1)

                    local txt_range1 = self:RangeUnitize(range)

                    local txt_range1_w = surface.GetTextSize(txt_range1)
                    surface.SetTextPos((w / 5) - txt_range1_w - (ARC9ScreenScale(2)), ARC9ScreenScale(1 + 8))
                    surface.DrawText(txt_range1)

                    draw_rangetext = false
                end
            end


            if draw_rangetext then
                local txt_dmg1 = tostring(math.Round(dmg_max)) .. " " .. ARC9:GetPhrase("unit.dmg")

                if self:GetValue("Num") > 1 then
                    txt_dmg1 = math.Round(dmg_max * self:GetValue("Num")) .. "-" .. txt_dmg1
                end

                surface.SetFont("ARC9_8")
                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                local txt_dmg1_w = surface.GetTextSize(txt_dmg1)
                surface.SetTextPos((w / 5) - txt_dmg1_w - (ARC9ScreenScale(2)), ARC9ScreenScale(1))
                surface.DrawText(txt_dmg1)

                local txt_range1 = self:RangeUnitize(range_min)

                local txt_range1_w = surface.GetTextSize(txt_range1)
                surface.SetTextPos((w / 5) - txt_range1_w - (ARC9ScreenScale(2)), ARC9ScreenScale(1 + 8))
                surface.DrawText(txt_range1)

                local txt_dmg2 = tostring(math.Round(dmg_min)) .. " " .. ARC9:GetPhrase("unit.dmg")

                if self:GetValue("Num") > 1 then
                    txt_dmg2 = math.Round(dmg_min * self:GetValue("Num")) .. "-" .. txt_dmg2
                end

                surface.SetTextPos(4 * (w / 5) + (ARC9ScreenScale(2)), ARC9ScreenScale(1))
                surface.DrawText(txt_dmg2)

                local txt_range2 = self:RangeUnitize(range_max)

                surface.SetTextPos(4 * (w / 5) + (ARC9ScreenScale(2)), ARC9ScreenScale(1 + 8))
                surface.DrawText(txt_range2)

                if sweetspot then
                    local txt_dmg3 = tostring(math.Round(dmg_sweet)) .. " " .. ARC9:GetPhrase("unit.dmg")
                    if self:GetValue("Num") > 1 then
                        txt_dmg3 = math.Round(dmg_sweet * self:GetValue("Num")) .. "-" .. txt_dmg3
                    end
                    local txt_dmg3_w = surface.GetTextSize(txt_dmg3)
                    local txt_range3 = self:RangeUnitize(range_sweet)
                    local txt_range3_w = surface.GetTextSize(txt_range3)

                    surface.SetFont("ARC9_8")
                    surface.SetTextColor(ARC9.GetHUDColor("fg"))
                    if range_sweetspot_x < w * 0.5 then
                        surface.SetTextPos(range_sweetspot_x + (ARC9ScreenScale(2)), ARC9ScreenScale(1))
                        surface.DrawText(txt_dmg3)
                        surface.SetTextPos(range_sweetspot_x + (ARC9ScreenScale(2)), ARC9ScreenScale(1 + 8))
                        surface.DrawText(txt_range3)
                    else
                        surface.SetTextPos(range_sweetspot_x - txt_dmg3_w - (ARC9ScreenScale(2)), ARC9ScreenScale(1))
                        surface.DrawText(txt_dmg3)
                        surface.SetTextPos(range_sweetspot_x - txt_range3_w - (ARC9ScreenScale(2)), ARC9ScreenScale(1 + 8))
                        surface.DrawText(txt_range3)
                    end
                end
            end


            -- ttk
            local ttk_dmg = self:GetDamageAtRange(ranger_range)
            if self:GetValue("Num") > 1 then ttk_dmg = ttk_dmg * self:GetValue("Num") end
            local ttk_headdmg = ttk_dmg * self:GetProcessedValue("HeadshotDamage", true) * (self:GetProcessedValue("BodyDamageMults", true)[HITGROUP_HEAD] or 2)

            local ttk_delay = self:GetProcessedValue("TriggerDelay") and self:GetProcessedValue("TriggerDelayTime") or 0

            local ttk_rpm = self:GetTrueRPM()
            local ttk_shots = math.ceil(100 / ttk_dmg)
            local ttk = math.Round((ttk_shots - 1) * (60 / ttk_rpm), 3) + ttk_delay
            local ttk_firsths = math.Round(math.max(0, math.ceil( (100 - ttk_headdmg) / ttk_dmg )) * (60 / ttk_rpm), 3) + ttk_delay

            local txt_ttk =  ARC9:GetPhrase("customize.bench.ttk") .. (ttk == 0 and ARC9:GetPhrase("customize.bench.ttk.instant") or ttk .. ARC9:GetPhrase("unit.second"))
            local txt_ttk2 = ARC9:GetPhrase("customize.bench.ttk.shots") .. ttk_shots
            local txt_ttk3 = ARC9:GetPhrase("customize.bench.ttk.withoneheadshot")
            local txt_ttk4 = ttk_firsths == 0 and ARC9:GetPhrase("customize.bench.ttk.instant") or ttk_firsths .. ARC9:GetPhrase("unit.second")
            local txt_ttk_w = surface.GetTextSize(txt_ttk)
            local txt_ttk2_w = surface.GetTextSize(txt_ttk2)
            local txt_ttk3_w = surface.GetTextSize(txt_ttk3)
            local txt_ttk4_w = surface.GetTextSize(txt_ttk4)
            surface.SetTextPos((w / 5 / 2) - txt_ttk_w / 2, h - ARC9ScreenScale(50))
            surface.DrawText(txt_ttk)
            surface.SetTextPos((w / 5 / 2) - txt_ttk2_w / 2, h - ARC9ScreenScale(42))
            surface.DrawText(txt_ttk2)
            if ttk_headdmg != ttk_dmg then
                surface.SetTextPos((w / 5 / 2) - txt_ttk3_w / 2, h - ARC9ScreenScale(27))
                surface.DrawText(txt_ttk3)
                surface.SetTextPos((w / 5 / 2) - txt_ttk4_w / 2, h - ARC9ScreenScale(19))
                surface.DrawText(txt_ttk4)
            end



            local txt_corner = ARC9:GetPhrase("customize.bench.ballistics") or ""
            surface.SetFont("ARC9_6")
            local tw = surface.GetTextSize(txt_corner)
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            surface.SetTextPos((w - tw) / 2, h - ARC9ScreenScale(8))
            surface.DrawText(txt_corner)
        end

        local range_3 = math.max(math.Round(self:GetValue("RangeMax") / 25) * 25, 50) --self.Range * self:GetBuff_Mult("Mult_Range")
        local range_1 = math.max(math.Round(range_3 / 3 / 25) * 25, 15) --(self.RangeMin or 0) * self:GetBuff_Mult("Mult_RangeMin")

        if range_1 == 0 then
            range_1 = range_3 * 0.5
        end

        rollallhits(self, range_3, range_1)

        local ballisticchart = vgui.Create("DButton", tp)
        ballisticchart:SetSize(ARC9ScreenScale(200), ARC9ScreenScale(100))
        ballisticchart:SetPos(tp:GetWide()-ARC9ScreenScale(200), ARC9ScreenScale(0))
        ballisticchart:SetText("")
        ballisticchart.DoClick = function(self2)
            rollallhits(self, range_3, range_1)
        end
        ballisticchart.Paint = function(self2, w, h)
            if !IsValid(self) then return end

            local col = ARC9.GetHUDColor("bg")
            if self2:IsHovered() then
                self.CustomizeHints["customize.hint.select"] = "customize.hint.recalculate"
                col = ARC9.GetHUDColor("hi", 70)
            end

            surface.SetDrawColor(col)
            -- surface.DrawRect(0, 0, w, h)
            draw.NoTexture()
            surface.DrawPoly({{x = cornercut, y = h},{x = 0, y = h-cornercut}, {x = 0, y = cornercut},{x = cornercut, y = 0}, {x = w-cornercut, y = 0},{x = w, y = cornercut}, {x = w, y = h-cornercut}, {x = w-cornercut, y = h}})

            local s = w / 2
            local s2 = ARC9ScreenScale(10)

            local range_1_txt = self:RangeUnitize(range_1)
            local range_3_txt = self:RangeUnitize(range_3)

            surface.SetMaterial(bullseye)
            surface.SetDrawColor(ARC9.GetHUDColor("fg", 50))
            surface.DrawTexturedRect(0, 0, s, s)

            local r_1_x, r_1_y = self2:LocalToScreen(0, 0)

            render.SetScissorRect(r_1_x, r_1_y, r_1_x + s, r_1_y + s, true)

            for _, hit in ipairs(hits_1) do
                if self:GetValue("Num") > 1 then
                    surface.SetMaterial(mat_hit_dot)
                else
                    surface.SetMaterial(mat_hit)
                end
                surface.SetDrawColor(ARC9.GetHUDColor("fg"))
                surface.DrawTexturedRect((s / 2) + (hit.x * s) - (s2 / 2), (s / 2) + (hit.y * s) - (s2 / 2), s2, s2)
            end

            render.SetScissorRect(r_1_x, r_1_y, r_1_x + s, r_1_y + s, false)

            surface.SetFont("ARC9_10")
            -- local range_1_txtw = surface.GetTextSize(range_1_txt)

            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            surface.SetTextPos(ARC9ScreenScale(4), h - ARC9ScreenScale(16))
            surface.DrawText(range_1_txt)

            surface.SetMaterial(bullseye)
            surface.SetDrawColor(ARC9.GetHUDColor("fg", 50))
            surface.DrawTexturedRect(s, 0, s, s)

            render.SetScissorRect(r_1_x + s, r_1_y, r_1_x + (s * 2), r_1_y + s, true)

            for _, hit in ipairs(hits_3) do
                if self:GetValue("Num") > 1 then
                    surface.SetMaterial(mat_hit_dot)
                else
                    surface.SetMaterial(mat_hit)
                end
                surface.SetDrawColor(ARC9.GetHUDColor("fg"))
                surface.DrawTexturedRect(s + (s / 2) + (hit.x * s) - (s2 / 2), (s / 2) + (hit.y * s) - (s2 / 2), s2, s2)
            end

            render.SetScissorRect(r_1_x, r_1_y, r_1_x + s, r_1_y + s, false)

            surface.SetFont("ARC9_10")
            local range_3_txtw = surface.GetTextSize(range_3_txt)

            surface.SetTextPos(w - range_3_txtw - ARC9ScreenScale(2), h - ARC9ScreenScale(16))
            surface.DrawText(range_3_txt)

            local txt_corner = ARC9:GetPhrase("customize.bench.precision")
            surface.SetFont("ARC9_6")
            local tw = surface.GetTextSize(txt_corner)
            surface.SetTextPos((w - tw) / 2, h - ARC9ScreenScale(8))
            surface.DrawText(txt_corner)
        end
    end
end