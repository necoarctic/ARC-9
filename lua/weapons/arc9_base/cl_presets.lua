function SWEP:GetPresetBase()
    return self.SaveBase or self:GetClass()
end

function SWEP:GetPresets()
    local path = ARC9.PresetPath .. self:GetPresetBase() .. "/*.txt"

    local files = file.Find(path, "DATA")

    for i, k in pairs(files) do
        files[i] = string.sub(k, 1, string.len(k) - 4)
    end

    return files
end

function SWEP:WriteAttachmentTree(tree)
    if tree and tree.Installed then
        local tbl = {
            Installed = tree.Installed,
            ToggleNum = tree.ToggleNum or 1
        }

        local atttbl = ARC9.GetAttTable(tree.Installed)

        if atttbl.Attachments then
            tbl.SubAttachments = {}

            for i, k in pairs(atttbl.Attachments) do
                tbl.SubAttachments[i] = self:WriteAttachmentTree(tree.SubAttachments[i])
            end
        end

        return tbl
    else
        return {}
    end
end

function SWEP:DeletePreset(filename)
    if LocalPlayer() != self:GetOwner() then return end

    filename = ARC9.PresetPath .. self:GetPresetBase() .. "/" .. filename

    if file.Exists(filename .. ".txt", "DATA") then
        file.Delete(filename .. ".txt")
    end

    if file.Exists(filename .. "." .. ARC9.PresetIconFormat, "DATA") then
        file.Delete(filename .. "." .. ARC9.PresetIconFormat)
    end
end

function SWEP:IgnorePreset(filename)
    if LocalPlayer() != self:GetOwner() then return end

    filename = ARC9.PresetPath .. self:GetPresetBase() .. "/" .. filename

    if file.Exists(filename .. ".txt", "DATA") then
        file.Write(filename .. ".txt", "name=ignore\n")
    end
end

function SWEP:StripWeapon()
    for slot, slottbl in ipairs(self.Attachments) do
        slottbl.Installed = nil
        slottbl.SubAttachments = nil
    end

    self:PostModify()
end

function SWEP:ClearPreset()
    -- for slot, slottbl in ipairs(self.Attachments) do
    --     slottbl.Installed = nil
    --     slottbl.SubAttachments = nil
    -- end

    -- self:BuildSubAttachments(self.DefaultAttachments)

    -- self:PostModify()
    self:LoadPreset("default")
end

function SWEP:LoadPresetFromTable(tbl)
    self.Attachments = baseclass.Get(self:GetClass()).Attachments

    for slot, slottbl in ipairs(self.Attachments) do
        slottbl.Installed = nil
        slottbl.SubAttachments = nil
    end

    self:PruneAttachments()

    self:BuildSubAttachments(tbl)
    self:PostModify()
end

function SWEP:LoadPresetFromCode(str, standard)
    onlysave = onlysave or false

    local name, tblstr = self:SplitPresetContents(str)
    local tbl = self:ImportPresetCode(tblstr)

    if !tbl then return false end

    self:LoadPresetFromTable(tbl)

    if !standard then
        surface.PlaySound("arc9/preset_install.ogg")
    end

    self:SavePreset(name, false, standard and name, table.Copy(self.Attachments))

    return name or true
end

function SWEP:GetPresetName(preset)
    local filename = ARC9.PresetPath .. self:GetPresetBase() .. "/" .. preset .. ".txt"

    if !file.Exists(filename, "DATA") then return end

    local f = file.Open(filename, "r", "DATA")
    if !f then return end

    local str = f:Read()

    if string.sub(str, 1, 5) == "name=" then
        local strs = string.Split(str, "\n")
        f:Close()
        return string.sub(strs[1], 6)
    else
        f:Close()
        return preset
    end
end

function SWEP:GetPresetData(preset)
    local filename = ARC9.PresetPath .. self:GetPresetBase() .. "/" .. preset .. ".txt"

    if !file.Exists(filename, "DATA") then return end

    local f = file.Open(filename, "r", "DATA")
    if !f then return end

    local str = f:Read()

    local name = ""
    local code = ""

    if string.sub(str, 1, 5) == "name=" then
        local strs = string.Split(str, "\n")
        name = string.sub(strs[1], 6)
        code = strs[2]
    else
        name = preset
        code = str
    end

    local tbl = self:ImportPresetCode(code)
    local count = 0
    if tbl then count = self:GetAttCountFromTable(tbl) end

    f:Close()

    return name, count
end

local maxatts = GetConVar("arc9_atts_max")

function SWEP:GetAttCountFromTable(tbl)
    local count = 0
    for i, k in pairs(tbl) do
        if k.Installed then
            local atbl = ARC9.GetAttTable(k.Installed)
            if atbl and !atbl.Hidden and (maxatts:GetInt() >= 16 or !atbl.Free) then
                count = count + 1
            end
        end

        if k.SubAttachments then
            count = count + self:GetAttCountFromTable(k.SubAttachments)
        end
    end

    return count
end

local arc9_atts_nocustomize = GetConVar("arc9_atts_nocustomize")
local arc9_autosave = GetConVar("arc9_autosave")

function SWEP:LoadPreset(filename)
    if arc9_atts_nocustomize:GetBool() then return end
    if LocalPlayer() != self:GetOwner() then return end

    filename = filename or "autosave"

    if filename == "autosave" then
        if !arc9_autosave:GetBool() then return end
    end

    filename = ARC9.PresetPath .. self:GetPresetBase() .. "/" .. filename .. ".txt"

    if !file.Exists(filename, "DATA") then return end

    local f = file.Open(filename, "r", "DATA")
    if !f then return end

    local str = f:Read()

    if str[1] == "{" then
        self:LoadPresetFromTable(util.JSONToTable(str))
    elseif string.sub(str, 1, 5) == "name=" then
        -- first line is name second line is data
        local strs = string.Split(str, "\n")
        self:LoadPresetFromTable(self:ImportPresetCode(strs[2]))
    else
        self:LoadPresetFromTable(self:ImportPresetCode(str))
    end

    if self.CustomizeHUD and self.CustomizeHUD.lowerpanel then
        timer.Simple(0, function()
            if !IsValid(self) then return end
            self:CreateHUD_Bottom()
        end)
    end

    f:Close()
end

local ratio = ScrW() / ScrH()
local pr_h = 256
local pr_w = 256 * ratio

if ScrH() > 1100 then pr_h = pr_h * 2 pr_w = pr_w * 2 end

local cammat = GetRenderTarget("arc9_cammat_", pr_w, pr_h, false)

SWEP.PresetCapture = nil

function SWEP:SavePreset(presetname, nooverride, forcedname, capturetree)
    presetname = presetname or "autosave"

    local str = self:GeneratePresetExportCode()

    local filename = ARC9.PresetPath .. self:GetPresetBase() .. "/" .. os.time()

    if forcedname then filename = ARC9.PresetPath .. self:GetPresetBase() .. "/" .. forcedname end

    if presetname == "autosave" then
        filename =  ARC9.PresetPath .. self:GetPresetBase() .. "/autosave"
    elseif presetname == "default" then
        filename =  ARC9.PresetPath .. self:GetPresetBase() .. "/default"
    end

    if nooverride and file.Exists(filename .. ".txt", "DATA") then return end

    file.CreateDir(ARC9.PresetPath .. self:GetPresetBase())
    local f = file.Open(filename .. ".txt", "w", "DATA")

    if !f then return end

    f:Write("name=" .. presetname .. "\n" .. str)
    f:Close()

    if presetname != "autosave" then
        timer.Simple(0.1, function()
            if !IsValid(self) then return end

            if !capturetree then
                self:DoPresetCapture(filename)
                return
            else
                self:BuildSubAttachments(capturetree)
            end
            
            self:DoInvalidateCache()
            self:DoPresetCapture(filename)
        end)
    end
end

local arc9_killfeed_colour = GetConVar("arc9_killfeed_colour")
local matshiny = Material("models/shiny")

local colormodifyicontabll = {
	[ "$pp_colour_addr" ] = 0,
	[ "$pp_colour_addg" ] = 0,
	[ "$pp_colour_addb" ] = 0,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] = 1.4,
	[ "$pp_colour_colour" ] = 1.7,
	[ "$pp_colour_mulr" ] = 0,
	[ "$pp_colour_mulg" ] = 0,
	[ "$pp_colour_mulb" ] = 0
}

function SWEP:DoPresetCapture(filename, foricon)
    if !IsValid(self) then return end

    local colorrr = arc9_killfeed_colour:GetBool()

    ARC9.PresetCam = true
    render.PushRenderTarget(cammat)

    render.SetColorMaterial()
    render.DrawScreenQuad()
    render.Clear(0, 0, 0, 0, true, true)

    local ref = 64

    render.UpdateScreenEffectTexture()
    render.ClearStencil()
    render.SetStencilEnable(true)
    render.SetStencilCompareFunction(STENCIL_ALWAYS)
    render.SetStencilPassOperation(STENCIL_REPLACE)
    render.SetStencilFailOperation(STENCIL_KEEP)
    render.SetStencilZFailOperation(STENCIL_KEEP)
    render.SetStencilWriteMask(255)
    render.SetStencilTestMask(255)

    render.SetStencilReferenceValue(ref)

    render.SetWriteDepthToDestAlpha(true)
    render.OverrideAlphaWriteEnable(true, true)


    -- local ppos, pang = EyePos(), EyeAngles()
    local campos, camang = Vector(0, 0, 0), Angle(0, 0, 0)
    local custpos, custang = self:GetProcessedValue("CustomizePos", true), self:GetProcessedValue("CustomizeAng", true)
    custpos = custpos + self.CustomizeSnapshotPos
    custang = custang + self.CustomizeSnapshotAng
    local pos, ang = Vector(0, 0, 1), Angle(0, 0, 0)

    pos = pos + (camang:Right() * custpos[1])
    pos = pos + (camang:Forward() * custpos[2])
    pos = pos + (camang:Up() * custpos[3])

    ang:RotateAroundAxis(camang:Up(), custang[1])
    ang:RotateAroundAxis(camang:Right(), custang[2])
    ang:RotateAroundAxis(camang:Forward(), custang[3])

    -- camang = self.LastViewModelAng or EyeAngles()
    -- campos = self.LastViewModelPos or EyePos()

    -- camang:RotateAroundAxis(camang:Up(), -custang.p)
    -- camang:RotateAroundAxis(camang:Right(), -custang.y)
    -- camang:RotateAroundAxis(camang:Forward(), -custang.r)

    -- campos = campos + camang:Right() * -custpos.x
    -- campos = campos + camang:Forward() * -custpos.y
    -- campos = campos + camang:Up() * -custpos.z
    local scrrw, scrrh = ScrW(), ScrH()
    if scrrw/scrrh > 1.8 then -- ultrawide fix
        cam.Start3D(campos, camang, self:GetProcessedValue("CustomizeSnapshotFOV"), (scrrw-scrrh*1.77777777)*0.5, 0, scrrh*1.77777777, scrrh, 1, 1024)
    else
        cam.Start3D(campos, camang, self:GetProcessedValue("CustomizeSnapshotFOV"), 0, 0, scrrw, scrrh, 1, 1024)
    end

    render.ClearDepth()

    render.SuppressEngineLighting(true)
    render.SetWriteDepthToDestAlpha(false)

    self:SetupModel(true, 0, true)

    -- local mdl = self.CModel[1]

    -- local anim = self:TranslateAnimation("idle")
    -- local ae = self:GetAnimationEntry(anim)
    -- local seq = mdl:LookupSequence(self:RandomChoice(ae.Source))

    -- mdl:ResetSequence(seq)
    -- mdl:SetPoseParameter("sights", 1)

    -- mdl:SetupBones()
    -- mdl:InvalidateBoneCache()

    render.SetBlend(1)
    render.SetColorModulation(1, 1, 1)
    render.MaterialOverride(matshiny)

    render.OverrideColorWriteEnable(true, false)
    -- self:GetVM():DrawModel()
    self:DrawCustomModel(true, pos + Vector(0.5, -0.5, -0.5), ang)
    render.OverrideColorWriteEnable(false, false)

    render.BlurRenderTarget(cammat, 6, 6, 2)

    render.MaterialOverride(matshiny)
    self:DrawCustomModel(true, pos, ang)

    render.MaterialOverride()
    
    if colorrr then
        -- render.SetWriteDepthToDestAlpha( false  )
        -- render.OverrideBlend( true, BLEND_ONE, BLEND_ZERO, BLENDFUNC_ADD, BLEND_ZERO, BLEND_ONE, BLENDFUNC_ADD )

        self:DrawCustomModel(true, pos, ang)

        render.MaterialOverride()
        -- render.SetWriteDepthToDestAlpha( false )
        self:DrawCustomModel(true, pos, ang)
    end

    DrawSharpen(0.3, 1)
    DrawColorModify(colormodifyicontabll)

    self:KillModel(true)
    render.OverrideBlend( false )
    render.SuppressEngineLighting(false)

    cam.End3D()

    ARC9.PresetCam = false

    render.SetStencilEnable(false)

    -- render.RenderView({
    --     x = 0,
    --     y = 0,
    --     w = preset_res,
    --     h = preset_res,
    --     origin = EyePos(),
    --     angles = EyeAngles(),
    --     fov = 90,
    --     dopostprocess = false,
    --     drawhud = false,
    --     drawmonitors = false,
    --     drawviewmodel = true
    -- })

    local x = (pr_w - pr_h) / 2

    local data = render.Capture( {
        -- format = ARC9.PresetIconFormat,
        format = "png",
        x = x,
        y = 0,
        w = pr_h,
        h = pr_h
    } )

    file.CreateDir(ARC9.PresetPath .. self:GetPresetBase())
    file.Write(filename .. "." .. ARC9.PresetIconFormat, data)
    -- file.Write(ARC9.PresetPath .. self:GetPresetBase() .. "/icon.png", "DATA")

    render.PopRenderTarget()

    self.AutoSelectIcon = Material("data/" .. filename .. "." .. ARC9.PresetIconFormat, "smooth")
    self.InvalidateSelectIcon = false
end

function SWEP:PruneUnnecessaryAttachmentDataRecursive(tbl)

    tbl.t = tbl.ToggleNum
    tbl.i = tbl.Installed
    tbl.s = tbl.SubAttachments

    for i, k in pairs(tbl) do
        if i != "i" and i != "s" and i != "t" and i != "ToggleNum" then
            tbl[i] = nil
        end
    end

    if table.Count(tbl.s or {}) > 0 then
        for i, k in pairs(tbl.s) do
            self:PruneUnnecessaryAttachmentDataRecursive(k)
        end
    else
        tbl.s = nil
    end

    tbl.BaseClass = nil
end

function SWEP:DecompressTableRecursive(tbl)
    for i, k in pairs(tbl) do
        if i == "i" then
            tbl["i"] = nil
            tbl["Installed"] = k
        elseif i == "s" then
            tbl["s"] = nil
            tbl["SubAttachments"] = k
        elseif i == "t" then
            tbl["t"] = nil
            tbl["ToggleNum"] = k
        end
    end

    if table.Count(tbl.SubAttachments or {}) > 0 then
        for i, k in pairs(tbl.SubAttachments) do
            self:DecompressTableRecursive(k)
        end
    end
end

function SWEP:GetPresetJSON()
    local newtbl = {}

    newtbl = table.Copy(self.Attachments)

    for i, k in pairs(newtbl) do
        self:PruneUnnecessaryAttachmentDataRecursive(k)
    end

    return util.TableToJSON(newtbl)
end

function SWEP:GeneratePresetExportCode()
    local str = self:GetPresetJSON()

    str = util.Compress(str)
    str = util.Base64Encode(str, true)

    return str
end

function SWEP:ImportPresetCode(str)
    if !str then return end
    str = util.Base64Decode(str)
    str = util.Decompress(str)

    if !str then return end

    local tbl = util.JSONToTable(str)

    if tbl then
        for i, k in pairs(tbl) do
            self:DecompressTableRecursive(k)
        end
    end

    return tbl
end

function SWEP:SplitPresetContents(str)
    if !isstring(str) then return end
    if str[1] != "[" then return end
    if !string.find(str, "]X") then return end
    local name = string.sub(string.Split(str, "]")[1], 2)
    local tbl = string.Split(str, "]")[2]

    return name, tbl
end

function SWEP:CreateStandardPresets()
    local newloaded

    if self.StandardPresets then
        for _, v in ipairs(self.StandardPresets) do
            local name = self:SplitPresetContents(v)
            if !name then continue end

            if file.Exists(ARC9.PresetPath .. self:GetPresetBase() .. "/" .. name .. ".txt", "DATA") then continue end

            if !self:LoadPresetFromCode(v, true) then print("Something gone wrong with standard preset!") continue end

            self:DoInvalidateCache()
            newloaded = true
        end

        if newloaded then
            self:LoadPreset("default")
        end
    end
end

local function deletefolder(path)
    local files, folders = file.Find(path .. "*", "DATA")
    for _, v in ipairs(files) do file.Delete(path .. v) end
    for _, v in ipairs(folders) do deletefolder(path .. v .. "/") end

    file.Delete(path)
end

concommand.Add("arc9_presets_clear", function(ply, command, arguments)
    if !IsValid(ply) then return end

    local weapon = ply:GetActiveWeapon()
    local arg = arguments[1]
    local hasgun = IsValid(weapon) and weapon.ARC9

	if arg == "all" or (arg == nil and !hasgun) then
        deletefolder(ARC9.PresetPath)
    elseif arg == nil then
        deletefolder(ARC9.PresetPath .. (weapon.SaveBase or weapon:GetClass()) .. "/")
        
        weapon:BuildSubAttachments(weapons.Get(weapon:GetClass()).Attachments) -- from original table
        weapon:ClientInitialize()

        timer.Simple(0.1, function() RunConsoleCommand( "arc9_giveswep_preset", arg, "default" ) end)
    elseif isstring(arg) then
        local weapon2 = weapons.Get(arg)
        if weapon2 then
            deletefolder(ARC9.PresetPath .. (weapon2.SaveBase or arg) .. "/")
            
            if ply:HasWeapon( arg ) then
                local weapon = ply:GetWeapon( arg )

                weapon:BuildSubAttachments(weapon2.Attachments) -- from original table
                weapon:ClientInitialize()

                timer.Simple(0.1, function() RunConsoleCommand( "arc9_giveswep_preset", arg, "default" ) end)
            end
        end
    end
end)

net.Receive("arc9_sendpreset", function(len)
    local wpn = net.ReadEntity()
    local preset = net.ReadString()
    
    if IsValid(wpn) and wpn.ARC9 then
        wpn:LoadPresetFromTable(wpn:ImportPresetCode(preset))
    end
end)