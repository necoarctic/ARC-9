ARC9.CamoOptionDefs = ARC9.CamoOptionDefs or {}
ARC9.CamoOptionDefaults = ARC9.CamoOptionDefaults or {}

local savefile = "arc9_camo_options.json"

if !ARC9.CamoOptionValues then
    ARC9.CamoOptionValues = util.JSONToTable(file.Read(savefile, "DATA") or "") or {}
end

local function buildDefaultOptions(mat)
    local opts = {
        { type = "color", name = "Tint", param = "$color2" },
        { type = "slider", name = "Opacity", param = "$alpha", min = 0, max = 1, decimals = 2 },
    }

    if mat:GetFloat("$arc9_scrollrate") then
        table.insert(opts, { type = "slider", name = "Scroll Speed", param = "$arc9_scrollrate", min = 0, max = 2, decimals = 2 })
    end

    return opts
end

local function readMaterialValue(mat, opt)
    if opt.type == "color" then
        local v = mat:GetVector(opt.param)
        if !v then return opt.default or Color(255, 255, 255) end
        return Color(math.Clamp(v.x * 255, 0, 255), math.Clamp(v.y * 255, 0, 255), math.Clamp(v.z * 255, 0, 255))
    end

    if opt.type == "bool" then
        local v = mat:GetFloat(opt.param)
        if v == nil then return !!opt.default end
        return v != 0
    end

    return mat:GetFloat(opt.param) or opt.default or opt.min or 0
end

local function writeMaterialValue(mat, opt, value)
    if opt.type == "color" then
        mat:SetVector(opt.param, Vector((value.r or 255) / 255, (value.g or 255) / 255, (value.b or 255) / 255))
    elseif opt.type == "bool" then
        mat:SetFloat(opt.param, value and 1 or 0)
    else
        mat:SetFloat(opt.param, tonumber(value) or 0)
    end
end

function ARC9.GetCamoOptions(matpath)
    return ARC9.CamoOptionDefs[matpath]
end

function ARC9.GetCamoOptionDefault(matpath, param)
    local defaults = ARC9.CamoOptionDefaults[matpath]
    return defaults and defaults[param]
end

function ARC9.GetCamoOptionValue(matpath, param)
    local saved = ARC9.CamoOptionValues[matpath]
    local v = saved and saved[param]
    if v != nil then
        if istable(v) then return Color(v.r or 255, v.g or 255, v.b or 255) end
        return v
    end
    return ARC9.GetCamoOptionDefault(matpath, param)
end

function ARC9.SaveCamoOptions()
    timer.Create("ARC9_SaveCamoOptions", 0.5, 1, function()
        file.Write(savefile, util.TableToJSON(ARC9.CamoOptionValues))
    end)
end

function ARC9.ApplyCamoOptions(matpath)
    local opts = ARC9.CamoOptionDefs[matpath]
    if !opts then return end

    local mat = Material(matpath)
    if mat:IsError() then return end

    for _, opt in ipairs(opts) do
        local v = ARC9.GetCamoOptionValue(matpath, opt.param)
        if v != nil then writeMaterialValue(mat, opt, v) end
    end
end

function ARC9.SetCamoOptionValue(matpath, param, value, nosave)
    local opts = ARC9.CamoOptionDefs[matpath]
    if !opts then return end

    local opt
    for _, o in ipairs(opts) do
        if o.param == param then opt = o break end
    end
    if !opt then return end

    if opt.type == "color" then
        value = { r = math.Round(value.r), g = math.Round(value.g), b = math.Round(value.b) }
    elseif opt.type == "bool" then
        value = !!value
    else
        value = math.Clamp(tonumber(value) or 0, opt.min or -math.huge, opt.max or math.huge)
    end

    ARC9.CamoOptionValues[matpath] = ARC9.CamoOptionValues[matpath] or {}
    ARC9.CamoOptionValues[matpath][param] = value

    writeMaterialValue(Material(matpath), opt, value)

    if !nosave then ARC9.SaveCamoOptions() end
end

function ARC9.ResetCamoOptions(matpath)
    ARC9.CamoOptionValues[matpath] = nil
    ARC9.ApplyCamoOptions(matpath)
    ARC9.SaveCamoOptions()
end

function ARC9.RegisterCamoOptions(atttbl)
    local matpath = atttbl.CustomCamoOverlay
    if !isstring(matpath) then return end
    if atttbl.CustomCamoOptions == false then return end

    local mat = Material(matpath)
    if mat:IsError() then return end

    local opts = {}
    for _, opt in ipairs(atttbl.CustomCamoOptions or buildDefaultOptions(mat)) do
        if !isstring(opt.param) then continue end
        local o = table.Copy(opt)
        if o.type != "color" and o.type != "bool" then o.type = "slider" end
        o.name = o.name or o.param
        if o.type == "slider" then
            o.min = o.min or 0
            o.max = o.max or 1
            o.decimals = o.decimals or 2
        end
        table.insert(opts, o)
    end

    if #opts == 0 then return end

    if !ARC9.CamoOptionDefaults[matpath] then
        local defaults = {}
        for _, opt in ipairs(opts) do
            defaults[opt.param] = readMaterialValue(mat, opt)
        end
        ARC9.CamoOptionDefaults[matpath] = defaults
    else
        for _, opt in ipairs(opts) do
            if ARC9.CamoOptionDefaults[matpath][opt.param] == nil then
                ARC9.CamoOptionDefaults[matpath][opt.param] = readMaterialValue(mat, opt)
            end
        end
    end

    ARC9.CamoOptionDefs[matpath] = opts
    ARC9.ApplyCamoOptions(matpath)
end

for _, atttbl in pairs(ARC9.Attachments or {}) do
    ARC9.RegisterCamoOptions(atttbl)
end

function ARC9.GetWeaponCamoOptions(wep)
    local matpath = wep:GetProcessedValue("CustomCamoOverlay", true)
    if !isstring(matpath) then return end
    local opts = ARC9.CamoOptionDefs[matpath]
    if !opts then return end
    return matpath, opts
end

local function getCamoPrintName(wep, matpath)
    for _, slottbl in ipairs(wep:GetSubSlotList()) do
        if !slottbl.Installed then continue end
        local atttbl = ARC9.GetAttTable(slottbl.Installed)
        if atttbl and atttbl.CustomCamoOverlay == matpath then
            return ARC9:GetPhraseForAtt(slottbl.Installed, "PrintName") or atttbl.PrintName or slottbl.Installed
        end
    end
    return matpath
end

ARC9.RegisterCustomizeTab("camo", {
    title = "customize.panel.camo",
    order = 100,
    condition = function(wep) return ARC9.GetWeaponCamoOptions(wep) != nil end,
    options = function(wep)
        local matpath, opts = ARC9.GetWeaponCamoOptions(wep)
        if !matpath then return end

        local spec = {
            title = getCamoPrintName(wep, matpath),
            note = "customize.camo.note",
            onReset = function() ARC9.ResetCamoOptions(matpath) end,
            options = {},
        }

        for _, opt in ipairs(opts) do
            table.insert(spec.options, {
                type = opt.type,
                name = opt.name,
                min = opt.min,
                max = opt.max,
                decimals = opt.decimals,
                get = function() return ARC9.GetCamoOptionValue(matpath, opt.param) end,
                set = function(value, final) ARC9.SetCamoOptionValue(matpath, opt.param, value, !final) end,
            })
        end

        return spec
    end,
})
