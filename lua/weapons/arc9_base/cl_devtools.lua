local DevMode = false

local devselectedatt = 0
local devoffsetmode = false
local selectedbonename = "None"

SWEP.devlockeddrag = false

function SWEP:DevStuffMenu()
    print("Developers developers developers developers developers developers developers developers developers developers developers developers developers ")


    if IsValid(self.DevFrame) then self.DevFrame:Remove() self.DevFrame = nil end

    local DevFrame = vgui.Create("DFrame")
    DevFrame:SetPos(ScrW() - 1015, ScrH() - 315)
    DevFrame:SetSize(1000, 300)
    DevFrame:SetTitle("Dev stuff")
    DevFrame:SetVisible(true)
    DevFrame:SetDraggable(true)
    DevFrame:ShowCloseButton(true)
    DevFrame:MakePopup()
    DevFrame:SetKeyboardInputEnabled(false)

    self.DevFrame = DevFrame

    local LockDragToggle = DevFrame:Add("DCheckBoxLabel")
    LockDragToggle:SetPos(400, 273)
    LockDragToggle:SetText("Lock dragging")
    LockDragToggle.OnChange = function(non, val)
        self.devlockeddrag = val
    end


    local function makecoolslider(y, min, max, text, dec, func)
        local itis = vgui.Create("DNumSlider", DevFrame)
        itis:SetPos(10, y)
        itis:SetSize(1000, 50)
        itis:SetText(text)
        itis:SetMin(min)
        itis:SetMax(max)
        itis:SetDecimals(dec)

        itis.OnValueChanged = func

        return itis
    end

    local SliderX = makecoolslider(30, -25, 25, "X", 3, function(no, value) self:PostModify(true) if devoffsetmode then devselectedatt.Icon_Offset.x = value else devselectedatt.Pos.x = value end end)
    local SliderY = makecoolslider(60, -25, 25, "Y", 3, function(no, value) self:PostModify(true) if devoffsetmode then devselectedatt.Icon_Offset.y = value else devselectedatt.Pos.y = value end end)
    local SliderZ = makecoolslider(90, -25, 25, "Z", 3, function(no, value) self:PostModify(true) if devoffsetmode then devselectedatt.Icon_Offset.z = value else devselectedatt.Pos.z = value end end)

    local SliderPitch = makecoolslider(130, -180, 180, "P", 0, function(no, value) self:PostModify(true) devselectedatt.Ang.p = value end)
    local SliderYaw = makecoolslider(160, -180, 180, "Y", 0, function(no, value) self:PostModify(true) devselectedatt.Ang.y = value end)
    local SliderRoll = makecoolslider(190, -180, 180, "R", 0, function(no, value) self:PostModify(true) devselectedatt.Ang.r = value end)

    local OffsetModeToggle = DevFrame:Add("DCheckBoxLabel")
    OffsetModeToggle:SetPos(200, 273)
    OffsetModeToggle:SetText("Icon offset mode")
    OffsetModeToggle.OnChange = function(non, val)
        devoffsetmode = val

        if val then
            if !devselectedatt.Icon_Offset then devselectedatt.Icon_Offset = Vector() end

            SliderX:SetValue(devselectedatt.Icon_Offset.x)
            SliderY:SetValue(devselectedatt.Icon_Offset.y)
            SliderZ:SetValue(devselectedatt.Icon_Offset.z)
        else
            SliderX:SetValue(devselectedatt.Pos.x)
            SliderY:SetValue(devselectedatt.Pos.y)
            SliderZ:SetValue(devselectedatt.Pos.z)
        end
    end

    local AttSelector = vgui.Create("DComboBox", DevFrame)
    AttSelector:SetPos(15, 300-30)
    AttSelector:SetSize(150, 20)
    AttSelector:SetValue("Select att")
    for i, slot in ipairs(self:GetSubSlotList()) do
        AttSelector:AddChoice(i .. " - " .. slot .PrintName)
    end

    AttSelector.OnSelect = function(no, index, value)
        print(value .. " was selected")
        devselectedatt = self:GetSubSlotList()[tonumber(value[1] .. value[2])]

        if devoffsetmode then
            SliderX:SetValue(devselectedatt.Icon_Offset.x)
            SliderY:SetValue(devselectedatt.Icon_Offset.y)
            SliderZ:SetValue(devselectedatt.Icon_Offset.z)

            SliderX:SetMin(devselectedatt.Icon_Offset.x-5)
            SliderX:SetMax(devselectedatt.Icon_Offset.x+5)
            SliderY:SetMin(devselectedatt.Icon_Offset.y-5)
            SliderY:SetMax(devselectedatt.Icon_Offset.y+5)
            SliderZ:SetMin(devselectedatt.Icon_Offset.z-5)
            SliderZ:SetMax(devselectedatt.Icon_Offset.z+5)
        else
            SliderX:SetValue(devselectedatt.Pos.x)
            SliderY:SetValue(devselectedatt.Pos.y)
            SliderZ:SetValue(devselectedatt.Pos.z)

            SliderX:SetMin(devselectedatt.Pos.x-3)
            SliderX:SetMax(devselectedatt.Pos.x+3)
            SliderY:SetMin(devselectedatt.Pos.y-10)
            SliderY:SetMax(devselectedatt.Pos.y+10)
            SliderZ:SetMin(devselectedatt.Pos.z-8)
            SliderZ:SetMax(devselectedatt.Pos.z+8)
        end

        SliderPitch:SetValue(devselectedatt.Ang.p)
        SliderYaw:SetValue(devselectedatt.Ang.y)
        SliderRoll:SetValue(devselectedatt.Ang.r)
    end

    local function ExportAtt()
        if !devselectedatt.Icon_Offset then devselectedatt.Icon_Offset = Vector() end
        return string.format("Pos = Vector(%s, %s, %s),\nAng = Angle(%s, %s, %s),\nIcon_Offset = Vector(%s, %s, %s),", math.Round(devselectedatt.Pos.x, 3), math.Round(devselectedatt.Pos.y, 3), math.Round(devselectedatt.Pos.z, 3), math.Round(devselectedatt.Ang.p), math.Round(devselectedatt.Ang.y), math.Round(devselectedatt.Ang.r), math.Round(devselectedatt.Icon_Offset.x, 3), math.Round(devselectedatt.Icon_Offset.y, 3), math.Round(devselectedatt.Icon_Offset.z, 3))
    end

    local ConsoleButton = vgui.Create("DButton", DevFrame)
    ConsoleButton:SetText("To console")
    ConsoleButton:SetPos(640, 260)
    ConsoleButton:SetSize(100, 30)
    ConsoleButton.DoClick = function()
        print("---------\n\n")
        print(ExportAtt())
        print("\n\n---------")
    end

    local ClipboardButton = vgui.Create("DButton", DevFrame)
    ClipboardButton:SetText("To clipboard")
    ClipboardButton:SetPos(760, 260)
    ClipboardButton:SetSize(100, 30)
    ClipboardButton.DoClick = function()
        SetClipboardText(ExportAtt())
    end

    local ResetButton = vgui.Create("DButton", DevFrame)
    ResetButton:SetText("Reload atts")
    ResetButton:SetPos(880, 260)
    ResetButton:SetSize(100, 30)
    ResetButton.DoClick = function()
        RunConsoleCommand("arc9_reloadatts")
        timer.Simple(0, function() self:PostModify(true) end)
    end


    -- local AppList = vgui.Create("DListView", DevFrame)
    -- AppList:Dock(FILL)
    -- AppList:SetMultiSelect(false)
    -- AppList:AddColumn("Bone")

    -- local vm = self:GetVM()
    -- if !vm then return end

    -- for i = 0, (vm:GetBoneCount() - 1) do
    --     AppList:AddLine(vm:GetBoneName(i))
    -- end

    -- AppList.OnRowSelected = function(lst, index, pnl)
    --     print("Selected " .. pnl:GetColumnText(1) .. " at index " .. index)
    --     selectedbone = index
    --     selectedbonename = pnl:GetColumnText(1)
    -- end
end

local devplaybackmult = 1
local devplaybackcycle = 0

function SWEP:DevStuffAnims()
    
    if IsValid(self.DevFrame) then self.DevFrame:Remove() self.DevFrame = nil end

    local DevFrame = vgui.Create("DFrame")
    DevFrame:SetPos(ScrW()/2-(ScrW()-200)/2, 50)
    DevFrame:SetSize(ScrW()-200, 300)
    DevFrame:SetTitle("ARC9 Animation table editor - Singleplayer only; <bind / \"cancelselect; pause\"> ; then call as <arc9_dev_toggleanimsmenu; cancelselect> ; press / multiple times to make anim play. Fack rubat for making escape take priority over everything.")
    DevFrame:SetVisible(true)
    DevFrame:SetDraggable(true)
    DevFrame:ShowCloseButton(true)
    DevFrame:MakePopup()
    DevFrame:SetKeyboardInputEnabled(false)


    self.DevFrame = DevFrame


    ----


    local Controls = DevFrame:Add("Panel")
    Controls:SetTall(20)
    Controls:Dock(BOTTOM)
    Controls:DockMargin(0, 8, 0, 4)
    Controls:MoveToBack()

    local AnimTrack = Controls:Add("DSlider")
    AnimTrack:Dock(FILL)
    AnimTrack:SetNotches(100)
    AnimTrack:SetTrapInside(true)
    AnimTrack:SetLockY(0.5)

    local SeqSelector = Controls:Add("DComboBox")
    SeqSelector:SetValue( "VM sequence" )
    SeqSelector:Dock(LEFT)
    SeqSelector:SetWide(128)

    SeqSelector.OnSelect = function(_, _, value)
        print("------\nHi you need to double press (with a little delay) escape key to apply anim")
        self:GetVM():SendViewModelMatchingSequence(self:GetVM():LookupSequence(value))
    end

    for k, v in ipairs(self:GetVM():GetSequenceList()) do
        SeqSelector:AddChoice(v)

        if v == self:GetVM():GetSequenceName(self:GetVM():GetSequence()) then
            SeqSelector:ChooseOptionID(k)
        end
    end

    local AnimPlay = Controls:Add("DImageButton")
    AnimPlay:SetImage("icon16/control_pause_blue.png")
    AnimPlay:SetStretchToFit(false)
    AnimPlay:SetPaintBackground(true)
    AnimPlay:SetIsToggle(true)
    AnimPlay:SetToggle(false)
    AnimPlay:Dock(LEFT)
    AnimPlay:SetWide(32)

    local PlaybackSpeedMultEntry = Controls:Add("DTextEntry")
    PlaybackSpeedMultEntry:SetPaintBackground(true)
    PlaybackSpeedMultEntry:Dock(RIGHT)
    PlaybackSpeedMultEntry:SetWide(64)
    PlaybackSpeedMultEntry:SetPlaceholderText("Speed mult")
    PlaybackSpeedMultEntry:SetNumeric(true)
    PlaybackSpeedMultEntry.OnEnter = function(no)
        devplaybackmult = no:GetValue()
    end

    local CurFrame = Controls:Add("DLabel")
    CurFrame:Dock(LEFT)
    CurFrame:SetWide(64)
    CurFrame:SetText("  " .. 0)


    ----

    local Animations = DevFrame:Add("Panel")
    Animations:SetTall(20)
    Animations:Dock(TOP)
    Animations:DockMargin(ScrW()/2.5, 0, ScrW()/2.5, 4)
    Animations:MoveToBack()

    local AnimSelector = Animations:Add("DComboBox")
    AnimSelector:SetValue("Select animation")
    AnimSelector:Dock(FILL)


    for k, v in pairs(self.Animations) do
        AnimSelector:AddChoice(k)
        AnimSelector:ChooseOptionID(1)
    end

    local AddAnimButton = Animations:Add("DImageButton")
    AddAnimButton:SetImage( "icon16/add.png" )
    AddAnimButton:SetSize( 20, 20 )
    AddAnimButton:Dock(RIGHT)
    AddAnimButton.DoClick = function()
        Derma_StringRequest("New animation", "What would you call it?", "", function(text) print("Added new anim to table: " .. text) end, nil, "Add")
    end


    ----

    local EditorPanel = DevFrame:Add("DPropertySheet")
    EditorPanel:Dock(FILL)

    EditorPanelEventTable = EditorPanel:Add("DPanel")
    -- EditorPanelEventTable.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 128, 255 ) ) end

    local Keyframes = EditorPanelEventTable:Add("DHorizontalScroller")
    Keyframes:Dock( FILL )
    Keyframes:SetOverlap( -8 )

    local KeyframesCount = 0

    local function makekf(time, path, pitch, volume)
        KeyframesCount = KeyframesCount + 1

        Keyframes[KeyframesCount] = Keyframes:Add("DFrame") -- dpanel maybe
        Keyframes[KeyframesCount]:SetDraggable(false)
        Keyframes[KeyframesCount]:ShowCloseButton(false)
        Keyframes[KeyframesCount]:SetWidth(128)

        Keyframes[KeyframesCount].TimeLabel = Keyframes[KeyframesCount]:Add("DLabel")
        Keyframes[KeyframesCount].TimeLabel:SetPos( 15, 25 )
        Keyframes[KeyframesCount].TimeLabel:SetText("Time")

        Keyframes[KeyframesCount].Time = Keyframes[KeyframesCount]:Add("DTextEntry")
        Keyframes[KeyframesCount].Time:SetPos(55, 25)
        Keyframes[KeyframesCount].Time:SetPlaceholderText("Time")
        Keyframes[KeyframesCount].Time:SetNumeric(true)
        Keyframes[KeyframesCount].Time:SetValue(time)

        Keyframes[KeyframesCount].SndLabel = Keyframes[KeyframesCount]:Add("DLabel")
        Keyframes[KeyframesCount].SndLabel:SetPos(15, 45)
        Keyframes[KeyframesCount].SndLabel:SetText("Sound path")

        Keyframes[KeyframesCount].Snd = Keyframes[KeyframesCount]:Add("DTextEntry")
        Keyframes[KeyframesCount].Snd:SetPos(4, 65)
        Keyframes[KeyframesCount].Snd:SetWidth(120)
        Keyframes[KeyframesCount].Snd:SetPlaceholderText("garrysmod/content_downloaded.wav")
        Keyframes[KeyframesCount].Snd:SetText(path)

        Keyframes[KeyframesCount].PitchWangLabel = Keyframes[KeyframesCount]:Add("DLabel")
        Keyframes[KeyframesCount].PitchWangLabel:SetPos( 15, 95 )
        Keyframes[KeyframesCount].PitchWangLabel:SetText("Pitch")

        Keyframes[KeyframesCount].PitchWang = Keyframes[KeyframesCount]:Add("DNumberWang")
        Keyframes[KeyframesCount].PitchWang:SetPos(55, 95)
        Keyframes[KeyframesCount].PitchWang:SetMin(0.5)
        Keyframes[KeyframesCount].PitchWang:SetValue(pitch)
        Keyframes[KeyframesCount].PitchWang:SetMax(1.5)
        Keyframes[KeyframesCount].PitchWang:SetInterval(0.05)

        Keyframes[KeyframesCount].VolumeWangLabel = Keyframes[KeyframesCount]:Add("DLabel")
        Keyframes[KeyframesCount].VolumeWangLabel:SetPos( 15, 120 )
        Keyframes[KeyframesCount].VolumeWangLabel:SetText("Volume")

        Keyframes[KeyframesCount].VolumeWang = Keyframes[KeyframesCount]:Add("DNumberWang")
        Keyframes[KeyframesCount].VolumeWang:SetPos(55, 120)
        Keyframes[KeyframesCount].VolumeWang:SetMin(0)
        Keyframes[KeyframesCount].VolumeWang:SetValue(volume)
        Keyframes[KeyframesCount].VolumeWang:SetMax(2)
        Keyframes[KeyframesCount].VolumeWang:SetInterval(0.05)

        Keyframes[KeyframesCount].DeleteButton = Keyframes[KeyframesCount]:Add("DButton")
        Keyframes[KeyframesCount].DeleteButton:SetText("Delete")
        Keyframes[KeyframesCount].DeleteButton:SetHeight(16)
        Keyframes[KeyframesCount].DeleteButton:Dock(BOTTOM)

        local nameexloded = string.Explode("/", path)

        Keyframes[KeyframesCount]:SetTitle(nameexloded[#nameexloded]) -- KeyframesCount .. ": " ..

        Keyframes:AddPanel(Keyframes[KeyframesCount])
    end

    -- makekf(0.1, "wawa/hi.wav", 1, 1)

    local function makekfsforanim(animname)
        Keyframes:Remove()
        Keyframes = EditorPanelEventTable:Add("DHorizontalScroller") -- resetting
        Keyframes:Dock( FILL )
        Keyframes:SetOverlap( -8 )

        local et = self.Animations[animname].EventTable

        if et then -- we will clear and just add a plus button if no eventtable
            for k, v in ipairs(et) do
                if not v.s then continue end
                makekf(v.t, tostring(v.s), v.p or 1, v.v or 1)
            end
        end

        Keyframes.KeyframesAdd = Keyframes:Add("DButton")
        Keyframes.KeyframesAdd:SetText("+")
        Keyframes.KeyframesAdd:SetWidth(64)
        Keyframes:AddPanel(Keyframes.KeyframesAdd)
    end

    AnimSelector.OnSelect = function(_, _, value)
        print("------\nSelected "..value)
        makekfsforanim(value)
    end


    EditorPanel:AddSheet( "Event Table editor", EditorPanelEventTable)

    EditorPanelIKTable = EditorPanel:Add("DPanel")
    -- EditorPanelEventTable.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 128, 255 ) ) end
    EditorPanel:AddSheet( "LHIK/RHIK editor", EditorPanelIKTable)

    EditorPanelGeneral = EditorPanel:Add("DPanel")
    -- EditorPanelEventTable.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 128, 255 ) ) end
    EditorPanel:AddSheet( "Parameters", EditorPanelGeneral)

    Controls.Think = function(no)
        local vm = self:GetVM()
        local length = vm:SequenceDuration(vm:GetSequence()) * devplaybackmult

        if AnimTrack:GetDragging() then
            devplaybackcycle = AnimTrack:GetSlideX()
            AnimPlay:SetToggle(false)
        elseif AnimPlay:GetToggle() then
            devplaybackcycle = RealTime()/length%1
        end

        vm:SetCycle(devplaybackcycle)
        AnimTrack:SetSlideX(devplaybackcycle)

        local cursec = math.Round(length*devplaybackcycle/devplaybackmult, 2)
        local curfrac = math.Round(devplaybackcycle, 2)
        CurFrame:SetText("   " .. cursec .. " / ".. curfrac)
    end
end

concommand.Add("arc9_dev_togglemenu", function(ply, cmd, args)

    -- add here check for sv_cheats 1 or/and admin

    local wep = ply:GetActiveWeapon()

    if wep.ARC9 then
        DevMode = !DevMode
        if DevMode then ply:GetActiveWeapon():DevStuffMenu() elseif IsValid(wep.DevFrame) then wep.DevFrame:Close() end
    end
end)

concommand.Add("arc9_dev_toggleanimsmenu", function(ply, cmd, args)

    -- add here check for sv_cheats 1 or/and admin

    local wep = ply:GetActiveWeapon()

    if wep.ARC9 then
        -- DevMode = !DevMode
        ply:GetActiveWeapon():DevStuffAnims()
    end
end)

local gaA = 0
local function GetFOVAcc(deg)
    cam.Start3D()
    local lool = (EyePos() + EyeAngles():Forward() + (deg * EyeAngles():Up())):ToScreen()
    cam.End3D()
    local gau = (ScrH() / 2) - lool.y
    gaA = math.Approach(gaA, gau, (ScrH() / 2) * FrameTime() * 2)

    return gaA
end

local gaA2 = 0
local function GetFOVAcc2(deg)
    cam.Start3D()
    local lool = (EyePos() + EyeAngles():Forward() + (deg * EyeAngles():Up())):ToScreen()
    cam.End3D()
    local gau = (ScrH() / 2) - lool.y
    gaA2 = math.Approach(gaA2, gau, (ScrH() / 2) * FrameTime() * 2)

    return gaA2
end

surface.CreateFont( "ARC9_DevCrosshair", {
    font = ARC9:GetFont(),
    size = 32,
    weight = 0,
    antialias = true,
    extended = true, -- Required for non-latin fonts
} )

function SWEP:DevStuffCrosshair()
    if self:GetCustomize() then return end
    local time = CurTime()

    local owner = self:GetOwner()
    local x2, y2 = ScrW() / 2, ScrH() / 2

    local sp, sa = self:GetShootPos()
    local endpos = sp + (sa:Forward() * 4000)

    cam.Start3D()
    local toscreen = endpos:ToScreen()
    if EyePos():DistToSqr(owner:EyePos()) > 16 then
        local tr = util.TraceLine({
            start = sp,
            endpos = endpos,
            mask = MASK_SHOT,
            filter = owner
        })

        toscreen = tr.HitPos:ToScreen()
    end
    x, y = toscreen.x, toscreen.y
    cam.End3D()

    local tr_range = util.TraceLine({
        start = sp,
        endpos = sp + sa:Forward() * 50000,
        mask = MASK_SHOT,
        filter = owner
    })
    local dist = (tr_range.HitPos - sp):Length()

    local freeaim_val = GetConVar("arc9_mod_freeaim"):GetBool() and self:GetProcessedValue("FreeAimRadius") or 0
    -- local freeaim = ScreenScale(freeaim_val * math.pi * 1.4)
    -- surface.DrawCircle(x2, y2, freeaim, 255, 255, 0, 100)

    if freeaim_val > 0 then
        local len = Lerp(freeaim_val / 4, 0, 16)
        surface.SetDrawColor(255, 255, 0, 255)
        surface.DrawLine(x2, y2 - len, x2, y2 + len)
        surface.DrawLine(x2 - len, y2, x2 + len, y2)

        surface.SetDrawColor(255, 255, 255, 100)
        surface.DrawLine(x, y, x2, y2)
    end

    local len = 256
    surface.SetDrawColor(255, 50, 50, 200)
    surface.DrawLine(x, y - len + 24, x, y + len - 48)
    surface.DrawLine(x - len, y, x + len, y)

    local spread_val = math.max(0, self:GetProcessedValue("Spread"))
    local spread = GetFOVAcc(spread_val)
    surface.DrawCircle(x, y, spread, 255, 255, 255, 255)
    surface.DrawCircle(x, y, spread + 0.5, 255, 255, 255, 100)

    local range_txt = math.Round(dist * ARC9.HUToM, 1) .. "m"
    local range2_txt = math.Round(self:GetDamageDeltaAtRange(dist) * 100) .. "%"
    if self:GetProcessedValue("SweetSpot", true) then
        range2_txt = range2_txt .. " | " .. math.Round(self:GetSweetSpotDeltaAtRange(dist) * 100) .. "% (SweetSpot)"
    end

    local aa_txt = "AIM ASSIST (%s%% INTENSITY)"
    -- local aa_txt = "AIM ASSIST (%.2f)"
    local aa_text = string.format(aa_txt, math.Clamp( math.Round(100 - self:GetDamageDeltaAtRange(dist) * 200), 1, 100))

    local function animationtype()
        local text = "ANIMATION"
        local function animname(anim)
            return string.find(self:GetIKAnimation() or "", anim)
        end

        if animname("reload") then text = "RELOAD" end
        if animname("dryfire") then text = "DRYFIRE" end

        return text
    end

    local state_txt = "READY"
    local state2_txt = ""
    if self:GetHolsterTime() > 0 then
        state_txt = "HOLSTER"
        state2_txt = string.format("%dms", (self:GetHolsterTime() - time)*1000)
    elseif self:GetNextPrimaryFire() > time then
        state_txt = "FIRE"
        state2_txt = string.format("%.0fms", (self:GetNextPrimaryFire() - time)*1000)
    elseif self:GetNextSecondaryFire() > time then
        state_txt = "ALTFIRE"
        state2_txt = string.format("%dms", (self:GetNextSecondaryFire() - time)*1000)
    elseif self:GetPrimedAttack() then
        state_txt = "TRIGGER"
        state2_txt = string.format("%dms", math.max(0, self:GetTriggerDelay() - time)*1000)
    elseif self:GetAnimLockTime() > time then
        state_txt = animationtype()
        state2_txt = string.format("%dms", (self:GetAnimLockTime() - time)*1000)
    elseif self:GetNeedsCycle() then
        state_txt = "CYCLING"
        if self:GetCycleFinishTime() == 0 then
            state2_txt = "waiting..."
        else
            state2_txt = string.format("%dms", (self:GetCycleFinishTime() - time)*1000)
        end
    elseif self:GetSprintAmount() > 0 then
        state_txt = "SPRINT"
        state2_txt = string.format("%d%%", self:GetSprintAmount() * 100)
    elseif self:GetSightAmount() > 0 then
        state_txt = "SIGHT"
        state2_txt = string.format("%d%%", self:GetSightAmount() * 100)
    elseif self:GetGrenadePrimed() then
        state_txt = "PRIMED"
        local pt = time - self:GetGrenadePrimedTime()
        state2_txt = string.format("%.2f | %d%%", self:GetProcessedValue("FuseTimer") - pt, math.Clamp(pt / self:GetProcessedValue("ThrowChargeTime"), 0, 1) * 100)
    end

    local recoil_txt = "Recoil: " .. tostring(math.Round(math.min(self:GetProcessedValue("UseVisualRecoil") and math.huge or self:GetProcessedValue("RecoilModifierCap"), self:GetRecoilAmount()), 2))
    local spread_txt = "Cone: " .. math.Round(spread_val, 5)
    local sway_txt = string.format("%.2f", self:GetFreeSwayAmount()) .. " Sway"
    local num = math.floor(self:GetProcessedValue("Num"))
    local damage_txt = math.Round(self:GetDamageAtRange(dist)) .. (num > 1 and ("×" .. tostring(num)) or "") .. " DMG"

    local function activeaffectors()
    -- Which stat additives are currently active, for example "Moving", "Airborne", "Sight", etc.
        local text = ""
        local ENTITY = FindMetaTable("Entity")
        local PLAYER = FindMetaTable("Player")
        local playerCrouching = PLAYER.Crouching
        local playerGetWalkSpeed = PLAYER.GetWalkSpeed
        local playerSprinting = PLAYER.IsSprinting
        local entityOwner = ENTITY.GetOwner
        local entityOnGround = ENTITY.OnGround
        local entityIsValid = ENTITY.IsValid
        local entityGetMoveType = ENTITY.GetMoveType
        local entityIsPlayer = ENTITY.IsPlayer
        local entityGetAbsVelocity = ENTITY.GetAbsVelocity
        local WEAPON = FindMetaTable("Weapon")
        local weaponClip1 = WEAPON.Clip1
        local weaponClip2 = WEAPON.Clip2
        local weaponGetNextPrimaryFire = WEAPON.GetNextPrimaryFire
        local arcGetValue = self.GetValue
        local vectorLength = FindMetaTable("Vector").Length
        local ubgl = self.dt.UBGL
        local sightAmount = self.dt.SightAmount

        if not ownerIsNPC and entityIsValid(owner) then
            local ownerOnGround = entityOnGround(owner)

            if not ownerOnGround or entityGetMoveType(owner) == MOVETYPE_NOCLIP then
                text = text .. " MidAir"
            end

            if ownerOnGround and playerCrouching(owner) then
                text = text .. " Crouch"
            end

            if ownerOnGround and playerSprinting(owner) and !self:StillWaiting() then
                text = text .. " Sprint"
            end
        end

        if self.dt.Reloading then
            text = text .. " Reload"
        end

        if self.dt.BurstCount == 0 then
            text = text .. " FirstShot"
        end

        if self.dt.GrenadeTossing then
            text = text .. " Toss"
        end

        if weaponClip1(self) == 0 then
            text = text .. " Empty"
        end

        if not ubgl and arcGetValue(self, "Silencer") then
            text = text .. " Silenced"
        end

        if ubgl then
            text = text .. " UBGL"

            if weaponClip2(self) == 0 then
                text = text .. " EmptyUBGL"
            end
        end

        if self.dt.NthShot % 2 == 0 then
            text = text .. " EvenShot"
        else
            text = text .. " OddShot"
        end

        if self.dt.NthReload % 2 == 0 then
            text = text .. " EvenReload"
        else
            text = text .. " OddReload"
        end

        if self.dt.Bipod then
            text = text .. " Bipod"
        end

        if sightAmount >= 1 then
            text = text .. " Sights"
        else
            text = text .. " HipFire"
        end

        local getlastmeleetime = self.dt.LastMeleeTime
        if getlastmeleetime < CurTime() then
            local pft = CurTime() - getlastmeleetime
            local d = pft / (arcGetValue(self, "PreBashTime") + arcGetValue(self, "PostBashTime"))
            d = 1 - math.Clamp(d, 0, 1)

            if d > 0 then
                text = text .. " Melee"
            end
        end


        local spd = self.PV_Move
        local maxspd = entityIsPlayer(owner) and playerGetWalkSpeed(owner) or 250

        spd = math.min(vectorLength(entityGetAbsVelocity(owner)), maxspd) / maxspd
        self.PV_Move = spd

        if spd > 0 then
            text = text .. " Move"
        end

        return text
    end

    surface.SetFont("ARC9_DevCrosshair")
    local sway_w = surface.GetTextSize(sway_txt)
    local damage_w = surface.GetTextSize(damage_txt)
    local state_w = surface.GetTextSize(state_txt)
    local state2_w = surface.GetTextSize(state2_txt)
    local range_w = surface.GetTextSize(range_txt)
    local range2_w = surface.GetTextSize(range2_txt)
    local aa_w = surface.GetTextSize(aa_txt)

    local affectortext = "Active Affectors:" .. activeaffectors()
    local affectorcon = GetConVar("arc9_dev_show_affectors"):GetBool()

    surface.SetTextColor(0, 0, 0, 255)

    surface.SetTextPos(x - len + 2, y + 2)
    surface.DrawText(recoil_txt)
    surface.SetTextPos(x - len + 2, y - 34 + 2)
    surface.DrawText(spread_txt)
    surface.SetTextPos(x + len - sway_w + 2, y - 34 + 2)
    surface.DrawText(sway_txt)
    surface.SetTextPos(x + len - damage_w + 2, y + 2)
    surface.DrawText(damage_txt)
    surface.SetTextPos(x - state_w / 2 + 2, y + len - 40 + 2)
    surface.DrawText(state_txt)
    surface.SetTextPos(x - state2_w / 2 + 2, y + len - 8 + 2)
    surface.DrawText(state2_txt)
    surface.SetTextPos(x - range_w / 2 + 2, y - len - 40 + 2)
    surface.DrawText(range_txt)
    surface.SetTextPos(x - range2_w / 2 + 2, y - len - 12 + 2)
    surface.DrawText(range2_txt)
    surface.SetTextPos(x - aa_w / 2 + 2, y - len - 62 + 2)
    if owner.ARC9_AATarget != nil and GetConVar("arc9_crosshair_target"):GetBool() then
        surface.DrawText(aa_text)
    end

    surface.SetTextPos(x + 5, y - 240)
    if affectorcon then
        surface.DrawText(affectortext)
    end

    surface.SetTextColor(255, 255, 255, 255)

    surface.SetTextPos(x - len, y)
    surface.DrawText(recoil_txt)
    surface.SetTextPos(x - len, y - 34)
    surface.DrawText(spread_txt)
    surface.SetTextPos(x + len - sway_w, y - 34)
    surface.DrawText(sway_txt)
    surface.SetTextPos(x + len - damage_w, y)
    surface.DrawText(damage_txt)
    surface.SetTextPos(x - state_w / 2, y + len - 40)
    surface.DrawText(state_txt)
    surface.SetTextPos(x - state2_w / 2, y + len - 8)
    surface.DrawText(state2_txt)
    surface.SetTextPos(x - range_w / 2, y - len - 40)
    surface.DrawText(range_txt)
    surface.SetTextPos(x - range2_w / 2, y - len - 12)
    surface.DrawText(range2_txt)
    surface.SetTextPos(x - range2_w / 2, y - len - 12)
    surface.DrawText(range2_txt)
    surface.SetTextPos(x - aa_w / 2, y - len - 62)
    if owner.ARC9_AATarget != nil and GetConVar("arc9_crosshair_target"):GetBool() then
        surface.DrawText(aa_text)
    end

    surface.SetTextPos(x + 5 - 2, y - 240 - 2)
    if affectorcon then
        surface.DrawText(affectortext)
    end

    surface.SetTextPos(x + 5, y - 240 + 40 + 2)
    surface.SetTextColor(0, 0, 0, 255)
    surface.DrawText( "Mouse Sens: " .. string.format("%d%%", self:AdjustMouseSensitivity() * 100 ))

    surface.SetTextPos(x + 5 - 2, y - 240 + 40)
    surface.SetTextColor(255, 255, 255, 255)
    surface.DrawText( "Mouse Sens: " .. string.format("%d%%", self:AdjustMouseSensitivity() * 100 ))

    -- if self:GetReloading() then
        -- surface.SetTextPos(x + 5, y - 200 + 40 + 2)
        -- surface.SetTextColor(0, 0, 0, 255)
        -- surface.DrawText( "Is Reloading!" )

        -- surface.SetTextPos(x + 5 - 2, y - 200 + 40)
        -- surface.SetTextColor(255, 255, 255, 255)
        -- surface.DrawText( "Is Reloading!" )
    -- end

    local sgspread_txt = ""
    if self:GetProcessedValue("UseDispersion") then
        local sgspread_val = math.max(0, self:GetProcessedValue("DispersionSpread"))
        local sgspread = GetFOVAcc2(sgspread_val)
        surface.DrawCircle(x, y, sgspread, 255, 255, 0, 255)
        surface.DrawCircle(x, y, sgspread + 0.5, 255, 255, 0, 100)

        sgspread_txt = self:GetProcessedValue("UseDispersion") and "SG Cone: " .. math.Round(sgspread_val, 5) or ""

        surface.SetTextColor(0, 0, 0, 255)
        surface.SetTextPos(x - len + 2, y - 64 + 2)
        surface.DrawText(sgspread_txt)
        surface.SetTextColor(255, 255, 255, 255)
        surface.SetTextPos(x - len, y - 64)
        surface.DrawText(sgspread_txt)
    end
end