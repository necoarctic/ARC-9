local tick = 0

-- Avoid using this system - it breaks prediction.
function SWEP:InitTimers()
    self.ActiveTimers = {} -- { { time, id, func } }
end

function SWEP:SetTimer(time, callback, id)
    if !IsFirstTimePredicted() then return end
    table.insert(self.ActiveTimers, {time + CurTime(), id or "", callback})
end

function SWEP:TimerExists(id)
    for _, v in pairs(self.ActiveTimers) do
        if v[2] == id then return true end
    end

    return false
end

function SWEP:KillTimer(id)
    local keeptimers = {}

    for _, v in pairs(self.ActiveTimers) do
        if v[2] != id then
            table.insert(keeptimers, v)
        end
    end

    self.ActiveTimers = keeptimers
end

function SWEP:KillSoundTable()
    if !IsFirstTimePredicted() then return end
    local keeptimers = {}

    for _, v in ipairs(self.ActiveTimers or {}) do
        if string.sub(v[2] or "", 1, 10) != "soundtable" then
            table.insert(keeptimers, v)
        end
    end

    self.ActiveTimers = keeptimers
end

function SWEP:KillTimers()
    self.ActiveTimers = {}
end

function SWEP:ProcessTimers()
    local keeptimers = {}
    local UCT = CurTime()

    if !self.ActiveTimers then
        self:InitTimers()
    end

    for _, v in pairs(self.ActiveTimers) do
        if v[1] <= UCT then
            v[3]()
        else
            table.insert(keeptimers, v)
        end
    end

    self.ActiveTimers = keeptimers
end

SWEP.SoundTableBodygroups = {}
SWEP.SoundTablePoseParams = {}

function SWEP:PlaySoundTable(soundtable, mult)
    if !IsFirstTimePredicted() then return end
    local owner = self:GetOwner()
    mult = mult

    self:KillSoundTable()

    for i, v in pairs(soundtable) do
        local ttime

        if v.t then
            ttime = v.t * mult
        else
            continue
        end

        if ttime < 0 then continue end
        if !(IsValid(self) and IsValid(owner)) then continue end

        local thatfunc = function()
            if v.s then
                local volem = v.v_sighted and Lerp(self:GetSightAmount(), v.v or 1, v.v_sighted) or (v.v or 1) 
                local soundtab = {
                    name = "soundtable",
                    sound = self:RandomChoice(v.s or ""),
                    level = v.l or 75,
                    pitch = v.p or 100,
                    volume = volem,
                    channel = v.c or CHAN_AUTO,
                    dsp = v.dsp,
                    flags = v.fl,
                }

                self:PlayTranslatedSound(soundtab)
                if volem > 1 then self:PlayTranslatedSound(soundtab) end -- louder bitch
            end

            if v.ind then
                self.SoundTableBodygroups[v.ind] = v.bg or nil
            end

            if v.shelleject then
                local index = 0
                local num = 1

                if isnumber(v.shelleject) then
                    index = v.shelleject

                    if index > 1000 then
                        index = self:Clip1() >= (index - 1000) and 1 or 0
                    end
                elseif istable(v.shelleject) then
                    index = v.shelleject.index
                    if v.shelleject.upto then
                        num = self:GetLastLoadedRounds() >= v.shelleject.upto and (v.shelleject.num or 1) or 0
                    else
                        num = v.shelleject.num
                    end
                end

                for j = 1, (num == "clip" and self:GetLastLoadedRounds()) or num do
                    self:DoEject(index, v.att)
                end
            end

            if v.e then
                local fx = EffectData()
                fx:SetMagnitude(v.mag or 1)
                fx:SetAttachment(v.att or 1)
                fx:SetEntity(self)

                util.Effect(v.e, fx)
            end

            if v.hide != nil then
                self:SetHideBoneIndex(v.hide)
            end

            if v.ppi != nil then
                self:SetPoseParameterIndex(v.ppi)
            end

            if game.SinglePlayer() and SERVER then
                if (v.v1 or v.v2 or v.vt) then
                    net.Start("ARC9_AnimRumble")
                    net.WriteUInt(v.v1 or 0, 16)
                    net.WriteUInt(v.v2 or 0, 16)
                    net.WriteFloat(v.vt or 0.1)
                    net.Send(self:GetOwner())
                end
            elseif !game.SinglePlayer() and CLIENT then
                SInputAnimRumble(v.v1 or 0, v.v2 or 0, v.vt or 0.1)
            end
        end
    
        if ttime <= 0 and v.s then
            thatfunc()
        else
            self:SetTimer(ttime, thatfunc, "soundtable_" .. tostring(i))
        end
    end
end

if SERVER then
    util.AddNetworkString("ARC9_AnimRumble")
    if game.SinglePlayer() then
        util.AddNetworkString("ARC9_SP_FOV")
    end
end

ARC9.Ease = {
    ["InBack"]       = 1,
    ["InBounce"]     = 2,
    ["InCirc"]       = 3,
    ["InCubic"]      = 4,
    ["InElastic"]    = 5,
    ["InExpo"]       = 6,
    ["InOutBack"]    = 7,
    ["InOutBounce"]  = 8,
    ["InOutCirc"]    = 9,
    ["InOutCubic"]   = 10,
    ["InOutElastic"] = 11,
    ["InOutExpo"]    = 12,
    ["InOutQuad"]    = 13,
    ["InOutQuart"]   = 14,
    ["InOutQuint"]   = 15,
    ["InOutSine"]    = 16,
    ["InQuad"]       = 17,
    ["InQuart"]      = 18,
    ["InQuint"]      = 19,
    ["InSine"]       = 20,
    ["OutBack"]      = 21,
    ["OutBounce"]    = 22,
    ["OutCirc"]      = 23,
    ["OutCubic"]     = 24,
    ["OutElastic"]   = 25,
    ["OutExpo"]      = 26,
    ["OutQuad"]      = 27,
    ["OutQuart"]     = 28,
    ["OutQuint"]     = 29,
    ["OutSine"]      = 30,
}

ARC9.EaseToFunc = {
    [1] = math.ease.InBack,
    [2] = math.ease.InBounce,
    [3] = math.ease.InCirc,
    [4] = math.ease.InCubic,
    [5] = math.ease.InElastic,
    [6] = math.ease.InExpo,
    [7] = math.ease.InOutBack,
    [8] = math.ease.InOutBounce,
    [9] = math.ease.InOutCirc,
    [10] = math.ease.InOutCubic,
    [11] = math.ease.InOutElastic,
    [12] = math.ease.InOutExpo,
    [13] = math.ease.InOutQuad,
    [14] = math.ease.InOutQuart,
    [15] = math.ease.InOutQuint,
    [16] = math.ease.InOutSine,
    [17] = math.ease.InQuad,
    [18] = math.ease.InQuart,
    [19] = math.ease.InQuint,
    [20] = math.ease.InSine,
    [21] = math.ease.OutBack,
    [22] = math.ease.OutBounce,
    [23] = math.ease.OutCirc,
    [24] = math.ease.OutCubic,
    [25] = math.ease.OutElastic,
    [26] = math.ease.OutExpo,
    [27] = math.ease.OutQuad,
    [28] = math.ease.OutQuart,
    [29] = math.ease.OutQuint,
    [30] = math.ease.OutSine,
}

if CLIENT then
    net.Receive("ARC9_SP_FOV", function()
        local wpn = net.ReadEntity()
        local v1 = net.ReadFloat()
        local v2 = net.ReadFloat()
        local v3 = net.ReadFloat()
        local v4 = ARC9.EaseToFunc[net.ReadUInt(5)]
        local v5 = ARC9.EaseToFunc[net.ReadUInt(5)]
        wpn:CreateFOVEvent( v1, v2, v3, v4, v5 )
    end)

    local cl_rumble = GetConVar("arc9_controller_rumble")

    net.Receive("ARC9_AnimRumble", function()
        local v1 = net.ReadUInt(16)
        local v2 = net.ReadUInt(16)
        local vt = net.ReadFloat()
        SInputAnimRumble(v1 or 0, v2 or 0, vt or 0.1)
    end)

    function SInputAnimRumble(v1, v2, vt)
        if !sinput then return false end
        if !cl_rumble:GetBool() then return false end

        local P1 = sinput.GetControllerForGamepadIndex(0)
        sinput.TriggerVibration(P1, v1, v2)
        timer.Remove("SInput_ARC9_AnimRumble")

        timer.Create("SInput_ARC9_AnimRumble", vt, 1, function()
            sinput.TriggerVibration(P1, 0, 0)
        end)
    end
end

function SWEP:CancelSoundTable()
    for _, t in pairs(self.ActiveTimers) do
        if isstring(t[2]) and string.sub(t[2], 1, 10) == "soundtable" then
            self:KillTimer(t[2])
        end
    end
end