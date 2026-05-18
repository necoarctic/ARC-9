local cvEnable = GetConVar("arc9_fx_twoeyeaiming")
local cvMax = GetConVar("arc9_fx_twoeyeaiming_max_alpha")
local cvMin = GetConVar("arc9_fx_twoeyeaiming_min_alpha")
local cvStart = GetConVar("arc9_fx_twoeyeaiming_start")
local cvDepth = GetConVar("arc9_fx_twoeyeaiming_depth_prepass")
local cvReload = GetConVar("arc9_fx_twoeyeaiming_reload_fade_time")

local BACKUP_FADE_TIME = 0.08

local function refreshConVars()
    cvEnable = cvEnable or GetConVar("arc9_fx_twoeyeaiming")
    cvMax = cvMax or GetConVar("arc9_fx_twoeyeaiming_max_alpha")
    cvMin = cvMin or GetConVar("arc9_fx_twoeyeaiming_min_alpha")
    cvStart = cvStart or GetConVar("arc9_fx_twoeyeaiming_start")
    cvDepth = cvDepth or GetConVar("arc9_fx_twoeyeaiming_depth_prepass")
    cvReload = cvReload or GetConVar("arc9_fx_twoeyeaiming_reload_fade_time")
end

local function currentFrame()
    if FrameNumber then return FrameNumber() end

    return math.floor(RealTime() / math.max(FrameTime(), 0.001))
end

local function alpha01(cv)
    if !cv then return 1 end

    local v = cv:GetFloat()

    if v > 1 then
        v = v / 255
    end

    return math.Clamp(v, 0, 1)
end

local function validFadeModel(mdl)
    return IsValid(mdl) and !mdl.NoDraw and !mdl.IsAnimationProxy and !mdl.charmparent
end

local function reloading(wep)
    if wep.GetReloading then
        return wep:GetReloading() == true
    end

    return wep:GetNWBool("Reloading", false) == true
end

local function secIron(sight)
    local orig = sight.OriginalSightTable or {}
    local extra = sight.ExtraSightData or {}

    return sight.IsIronSight
        or orig.IsIronSight
        or extra.IsIronSight
end

local function disassoc(sight)
    local orig = sight.OriginalSightTable or {}
    local extra = sight.ExtraSightData or {}

    return sight.Disassociate
        or orig.Disassociate
        or extra.Disassociate
end

local function holo(sight)
    local att = sight.atttbl or {}
    local orig = sight.OriginalSightTable or {}
    local extra = sight.ExtraSightData or {}

    return att.HoloSight
        or orig.HoloSight
        or extra.HoloSight
        or att.RTCollimator
        or orig.RTCollimator
        or extra.RTCollimator
end

local function backup(sight)
    return disassoc(sight) and !holo(sight)
end

local function sightSlot(wep, sight)
    local slot = sight.slottbl

    if !istable(slot) and wep.GetActiveSightSlotTable then
        slot = wep:GetActiveSightSlotTable()
    end

    return istable(slot) and slot or nil
end

local function canFade(wep)
    refreshConVars()

    if !cvEnable or !cvEnable:GetBool() then return false end
    if wep.Peeking then return false end
    if wep.GetCustomize and wep:GetCustomize() then return false end
    if wep.GetUBGL and wep:GetUBGL() then return false end

    local sight = wep:GetSight()
    if !istable(sight) or sight.BaseSight then return false end
    if secIron(sight) then return false end

    local slot = sightSlot(wep, sight)
    if !slot then return false end

    return true, sight, slot
end

local function modelMatchesSight(model, sight, slot)
    if !validFadeModel(model) then return false end
    if slot.VModel == model then return true end

    local addr = slot.Address
    local mslot = model.slottbl

    if mslot == slot then return true end
    if addr and istable(mslot) and mslot.Address == addr then return true end

    local satt = sight.atttbl or {}
    local matt = model.atttbl or {}

    if slot.Installed and istable(mslot) and mslot.Installed == slot.Installed then return true end
    if satt.ID and matt.ID == satt.ID then return true end

    return false
end

function SWEP:GetTwoEyeAimingTargetAlpha()
    refreshConVars()

    local amt = math.Clamp(self:GetSightAmount() or 0, 0, 1)
    local start = math.Clamp(cvStart and cvStart:GetFloat() or 0.2, 0, 0.95)
    local frac = math.Clamp((amt - start) / (1 - start), 0, 1)
    local hi = alpha01(cvMax)
    local lo = math.Clamp(alpha01(cvMin), 0, hi)

    return math.Clamp(Lerp(frac, hi, lo), 0, 1)
end

function SWEP:UpdateTwoEyeAiming()
    local frame = currentFrame()
    if self.ARC9TwoEyeAimingFrame == frame then return end
    self.ARC9TwoEyeAimingFrame = frame

    self.ARC9TwoEyeAimingAlpha = 1
    self.ARC9TwoEyeAimingSight = nil
    self.ARC9TwoEyeAimingSlot = nil

    local ok, sight, slot = canFade(self)
    if !ok then return end

    local reloadTarget = reloading(self) and 0 or 1
    local reloadTime = math.max(cvReload and cvReload:GetFloat() or 0.12, 0.01)
    self.ARC9TwoEyeAimingReload = math.Approach(self.ARC9TwoEyeAimingReload or reloadTarget, reloadTarget, FrameTime() / reloadTime)

    local backupTarget = backup(sight) and 0 or 1
    self.ARC9TwoEyeAimingBackup = math.Approach(self.ARC9TwoEyeAimingBackup or backupTarget, backupTarget, FrameTime() / BACKUP_FADE_TIME)

    local alpha = Lerp(math.min(self.ARC9TwoEyeAimingReload, self.ARC9TwoEyeAimingBackup), 1, self:GetTwoEyeAimingTargetAlpha())
    if alpha >= 1 then return end

    self.ARC9TwoEyeAimingAlpha = alpha
    self.ARC9TwoEyeAimingSight = sight
    self.ARC9TwoEyeAimingSlot = slot
end

function SWEP:GetTwoEyeAimingAlpha(model)
    self:UpdateTwoEyeAiming()

    local alpha = self.ARC9TwoEyeAimingAlpha or 1
    if alpha >= 1 then return 1 end
    if !modelMatchesSight(model, self.ARC9TwoEyeAimingSight or {}, self.ARC9TwoEyeAimingSlot or {}) then return 1 end

    return alpha
end

function SWEP:DrawModelTwoEyeAiming(model, flags, alpha, depthPrepass)
    refreshConVars()

    local blend = render.GetBlend and render.GetBlend() or 1

    if blend <= 0.01 then
        model:DrawModel(flags)
        return
    end

    if depthPrepass and cvDepth and cvDepth:GetBool() and render.OverrideColorWriteEnable then
        render.SetBlend(1)
        render.OverrideColorWriteEnable(true, false)
        model:DrawModel(flags)
        render.OverrideColorWriteEnable(false, false)
    end

    render.SetBlend(alpha * blend)
    model:DrawModel(flags)
    render.SetBlend(blend)
end