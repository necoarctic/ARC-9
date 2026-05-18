local conVars = {
    {
        name = "cruelty_reload",
        default = "0",
        client = true
    },
    {
        name = "cruelty_reload_april_fools",
        default = "0",
        client = true
    },
    {
        name = "allflash",
        default = "0",
        client = true
    },
    {
        name = "lod_distance",
        default = "1",
        client = true
    },
    {
        name = "truenames",
        default = "2",
        client = true,
        min = 0,
        max = 2,
    },
    {
        name = "truenames_default",
        default = "0",
        replicated = true,
        min = 0,
        max = 1,
    },
    {
        name = "truenames_enforced",
        default = "0",
        replicated = true,
        min = 0,
        max = 1,
    },
    {
        name = "cross_enable",
        default = "1",
        client = true
    },
    {
        name = "cross_r",
        default = "255",
        client = true
    },
    {
        name = "cross_g",
        default = "255",
        client = true
    },
    {
        name = "cross_b",
        default = "255",
        client = true
    },
    {
        name = "cross_a",
        default = "150",
        client = true
    },
    {
        name = "cross_size_mult",
        default = "1",
        client = true
    },
    {
        name = "cross_size_dot",
        default = "1",
        client = true
    },
    {
        name = "cross_size_prong",
        default = "1",
        client = true
    },
    {
        name = "cross_sgstyle",
        default = "2",
        client = true
    },
    {
        name = "reflex_r",
        default = "255",
        client = true
    },
    {
        name = "reflex_g",
        default = "0",
        client = true
    },
    {
        name = "reflex_b",
        default = "0",
        client = true
    },
    {
        name = "scope_r",
        default = "255",
        client = true
    },
    {
        name = "scope_g",
        default = "0",
        client = true
    },
    {
        name = "scope_b",
        default = "0",
        client = true
    },
    {
        name = "holiday_month",
        default = "0",
        replicated = true
    },
    {
        name = "holiday_day",
        default = "0",
        replicated = true
    },
    {
        name = "hud_color_r",
        default = "255",
        client = true
    },
    {
        name = "hud_color_g",
        default = "123",
        client = true
    },
    {
        name = "hud_color_b",
        default = "0",
        client = true
    },
    {
        --     name = "hud_darkmode",
        name = "hud_lightmode",
        default = "0",
        client = true
    },
    {
        name = "hud_holiday",
        default = "0",
        client = true
    },
    {
        name = "hud_showunowned",
        default = "1",
        client = true
    },
    {
        name = "language",
        default = "",
        client = true,
    },
    {
        name = "language_id",
        default = -1,
        client = true,
    },
    {
        name = "font",
        default = "",
        client = true,
    },
    {
        name = "font_addsize",
        default = "0",
        client = true,
    },
    {
        name = "hud_scale",
        default = "1",
        client = true,
    },
    {
        name = "hud_scalefake", -- FAKE
        default = "1",
        client = true,
    },
    {
        name = "hud_deadzonex",
        default = "0",
        client = true,
    },
    {
        name = "autosave",
        default = "1",
        client = true
    },
    {
        name = "fov",
        default = "0",
        client = true
    },
    {
        name = "controller",
        default = "0",
        client = true
    },
    -- {
        -- name = "controller_rumble",
        -- default = "1",
        -- client = true
    -- },
    {
        name = "controller_glyphset",
        default = "",
        client = true
    },
    {
        name = "modifiers",
        default = "",
        replicated = true,
    },
    {
        name = "mod_bodydamagecancel",
        default = "1",
        replicated = true
    },
    {
        name = "atts_nocustomize",
        default = "0",
        replicated = true
    },
    {
        name = "atts_anarchy",
        default = "0",
        replicated = true
    },
    {
        name = "free_atts",
        default = "1",
        replicated = true
    },
    {
        name = "atts_max",
        default = "100",
    },
    {
        name = "atts_lock",
        default = "0",
        replicated = true
    },
    {
        name = "atts_loseondie",
        default = "1",
    },
    {
        name = "atts_generate_entities",
        default = "0",
        replicated = true
    },
    {
        name = "npc_equality",
        default = "0",
    },
    {
        name = "npc_atts",
        default = "1",
    },
    {
        name = "ground_atts",
        default = "0",
    },
    {
        name = "npc_autoreplace",
        default = "0"
    },
    {
        name = "npc_blacklist",
        default = ""
    },
    {
        name = "npc_whitelist",
        default = ""
    },
    {
        name = "npc_give_weapons",
        default = "0"
    },
    {
        name = "npc_spread",
        default = "1"
    },
    {
        name = "replace_spawned",
        default = "0"
    },
    {
        name = "mod_penetration",
        default = "1",
        replicated = true
    },
    {
        name = "mod_freeaim",
        default = "0",
        replicated = true
    },
    {
        name = "mod_sway",
        default = "1",
        replicated = true
    },
    {
        name = "mod_overheat",
        default = "1",
        replicated = true
    },
    {
        name = "mod_peek",
        default = "1",
        replicated = true
    },
    {
        name = "never_ready",
        default = "0",
    },
    {
        name = "dev_always_ready",
        default = "0",
    },
    {
        name = "dev_benchgun",
        default = "0",
    },
    {
        name = "dev_greenscreen",
        default = "0",
    },
    {
        name = "dev_benchgun_custom",
        default = "",
    },
    {
        name = "dev_crosshair",
        default = "0",
    },
    {
        name = "center_bipod",
        default = "1",
        client = true,
    },
    {
        name = "center_reload_enable",
        default = "0",
        client = true,
    },
    {
        name = "center_reload",
        default = "0.25",
        client = true,
    },
    {
        name = "breath_hud",
        default = "1",
        client = true,
    },
    {
        name = "breath_pp",
        default = "1",
        client = true,
    },
    {
        name = "breath_sfx",
        default = "1",
        client = true,
    },
    {
        name = "breath_slowmo",
        default = "1",
        replicated = true
    },
    {
        name = "ricochet",
        default = "1",
        replicated = true
    },
    {
        name = "bullet_physics",
        default = "1",
        replicated = true
    },
    {
        name = "bullet_gravity",
        default = "1",
        replicated = true
    },
    {
        name = "bullet_physics_shotguns",
        default = "0",
        replicated = true
    },
    {
        name = "bullet_drag",
        default = "1",
        replicated = true
    },
    {
        name = "vm_bobstyle",
        default = "0",
        client = true,
    },
    {
        name = "vm_cambob",
        default = "1",
        client = true,
    },
    {
        name = "vm_cambobwalk",
        default = "0",
        client = true,
    },
    {
        name = "vm_cambobintensity",
        default = "0.75",
        client = true,
    },
    {
        name = "vm_addx",
        default = "0",
        client = true,
    },
    {
        name = "vm_addy",
        default = "0",
        client = true,
    },
    {
        name = "vm_addz",
        default = "0",
        client = true,
    },
    {
        name = "bullet_imaginary",
        default = "1",
        replicated = true
    },
    {
        name = "bullet_lifetime",
        default = "10",
        replicated = true
    },
    {
        name = "cheapscopes",
        default = "0"
    },
    {
        name = "compensate_sens",
        default = "1"
    },
    {
        name = "cust_blur",
        default = "0",
        client = true
    },
    {
        name = "cust_light",
        default = "0",
        client = true
    },
    {
        name = "cust_light_brightness",
        default = "1",
        client = true
    },
    {
        name = "cust_hints",
        default = "1",
        client = true
    },
    {
        name = "cust_exit_reset_sel",
        default = "0",
        client = true
    },
    {
        name = "cust_roll_unlock",
        default = "0",
        client = true
    },
    {
        name = "killfeed_enable",
        default = "1",
        client = true
    },
    {
        name = "killfeed_dynamic",
        default = "1",
        client = true
    },
    {
        name = "killfeed_colour",
        default = "1",
        client = true
    },
    {
        name = "hud_always",
        default = "0",
        client = true,
    },
    {
        name = "hud_compact",
        default = "0",
        client = true,
    },
    {
        name = "hud_arc9",
        default = "1",
        client = true,
    },
    {
        name = "hud_force_disable",
        default = "0",
        replicated = true,
    },
    {
        name = "infinite_ammo",
        default = "0",
        replicated = true
    },
    {
        name = "tpik",
        default = "1",
        client = true
    },
    {
        name = "tpik_others",
        default = "1",
        client = true
    },
    {
        name = "tpik_framerate_local",
        default = "60",
        client = true
    },
    {
        name = "tpik_framerate_others",
        default = "20",
        client = true
    },
    {
        name = "autoreload",
        default = "0",
        client = true
    },
    {
        name = "toggleads",
        default = "0",
        client = true,
        userinfo = true
    },
    {
        name = "crosshair_force",
        default = "0",
        replicated = true
    },
    {
        name = "crosshair_static",
        default = "0",
        replicated = false,
        client = true
    },
    {
        name = "crosshair_target",
        default = "0",
        client = true
    },
    {
        name = "thirdperson",
        default = "0",
        client = true
    },
    {
        name = "thirdperson_force",
        default = "0",
        replicated = true
    },
    {
        name = "cam_shoulder",
        default = "1",
        client = true
    },
    {
        name = "dev_irons_x",
        default = "0",
        client = true
    },
    {
        name = "dev_irons_y",
        default = "0",
        client = true
    },
    {
        name = "dev_irons_z",
        default = "0",
        client = true
    },
    {
        name = "dev_irons_pitch",
        default = "0",
        client = true
    },
    {
        name = "dev_irons_yaw",
        default = "0",
        client = true
    },
    {
        name = "dev_irons_roll",
        default = "0",
        client = true
    },
    {
        name = "dev_show_shield",
        default = "0",
        client = true
    },
    {
        name = "fx_rtblur",
        default = "0",
        client = true
    },
    -- {
    --     name = "fx_adsblur",
    --     default = "1",
    --     client = true
    -- },
    {
        name = "fx_reloadblur",
        default = "0",
        client = true
    },
    {
        name = "fx_animblur",
        default = "0",
        client = true
    },
    {
        name = "realrecoil",
        default = "1",
    },
    {
        name = "manualbolt",
        default = "0",
        client = true,
        userinfo = true
    },
    -- {
    --     name = "autolean",
    --     default = "1",
    --     client = true,
    -- },
    -- {
    --     name = "lean",
    --     default = "1",
    --     replicated = true
    -- },
    -- {
    --     name = "togglelean",
    --     default = "0",
    --     client = true,
    --     userinfo = true
    -- },
    {
        name = "togglepeek",
        default = "0",
        client = true,
    },
    {
        name = "togglebreath",
        default = "0",
        client = true,
    },
    {
        name = "eject_fx",
        default = "1",
        client = true
    },
    {
        name = "eject_time",
        default = "0",
        client = true
    },
    {
        name = "never_ready",
        default = "0",
        replicated = true
    },
    {
        name = "muzzle_light",
        default = "1",
        client = true
    },
    {
        name = "muzzle_others",
        default = "1",
        client = true
    },
    {
        name = "mod_damage",
        default = "1",
        replicated = true
    },
    {
        name = "mod_spread",
        default = "1",
        replicated = true
    },
    {
        name = "mod_dispersionspread",
        default = "1",
        replicated = true
    },
    {
        name = "mod_recoil",
        default = "1",
        replicated = true
    },
    {
        name = "mod_visualrecoil",
        default = "1",
        replicated = true
    },
    {
        name = "mod_adstime",
        default = "1",
        replicated = true
    },
    {
        name = "mod_sprinttime",
        default = "1",
        replicated = true
    },
    {
        name = "mod_damagerand",
        default = "1",
        replicated = true
    },
    {
        name = "mod_muzzlevelocity",
        default = "1",
        replicated = true
    },
    {
        name = "mod_rpm",
        default = "1",
        replicated = true
    },
    {
        name = "mod_headshotdamage",
        default = "1",
        replicated = true
    },
    {
        name = "mod_malfunction",
        default = "1",
        replicated = true
    },
    {
        name = "cust_tips",
        default = "1",
        client = true
    },
    {
        name = "precache_sounds_onfirsttake",
        default = "1",
        replicated = true
    },
    {
        name = "precache_allsounds_onstartup",
        default = "0",
        replicated = true
    },
    {
        name = "precache_attsmodels_onfirsttake",
        default = "0",
        replicated = true
    },
    {
        name = "precache_attsmodels_onstartup",
        default = "0",
        replicated = true
    },
    {
        name = "precache_wepmodels_onfirsttake",
        default = "0",
        replicated = true
    },
    {
        name = "precache_wepmodels_onstartup",
        default = "0",
        replicated = true
    },
    {
        name = "togglepeek_reset",
        default = "0",
        client = true,
    },
    {
        name = "recoilshake",
        default = "1",
    },
    {
        name = "equipment_generate_ammo",
        default = "1",
        replicated = true
    },
    {
        name = "mult_defaultammo",
        default = "2",
        replicated = true
    },
    {
        name = "mult_sens",
        default = "1",
        client = true
    },
    {
        name = "aimassist",
        default = "0",
        replicated = true,
    },
    {
        name = "aimassist_head",
        default = "0",
        replicated = true,
    },
    {
        name = "aimassist_cone",
        default = "5",
        replicated = true,
    },
    {
        name = "aimassist_intensity",
        default = "1",
        replicated = true,
    },
    -- {
        -- name = "aimassist_lockon",
        -- default = "0",
        -- replicated = true,
    -- },
    -- {
        -- name = "aimassist_lockon_cl",
        -- default = "1",
        -- client = true,
    -- },
    {
        name = "aimassist_cl",
        default = "1",
        client = true,
    },
    {
        name = "crosshair_peek",
        default = "1",
        client = true
    },
    {
        name = "aimassist_multsens",
        default = "0.75",
        client = true,
    },
    {
        name = "glyph_family_hud",
        default = "light",
        client = true,
    },
    {
        name = "glyph_family_cust",
        default = "light",
        client = true,
    },
    -- {
        -- name = "glyph_type",
        -- default = "xbox",
        -- client = true,
    -- },
    {
        name = "fx_rtvm",
        default = "0",
        client = true,
    },
    {
        name = "dev_show_affectors",
        default = "0",
    },
    {
        name = "dtap_sights",
        default = "0",
        client = true,
    },
    {
        name = "center_jam",
        default = "1",
        client = true,
    },
    {
        name = "center_firemode",
        default = "0",
        client = true,
    },
    {
        name = "center_firemode_time",
        default = "0.75",
        client = true,
    },
    {
        name = "center_overheat",
        default = "0",
        client = true,
    },
    {
        name = "center_overheat_dark",
        default = "0",
        client = true,
    },
    {
        name = "imperial",
        default = "0",
        client = true,
    },
    {
        name = "vm_camstrength",
        default = "1",
        client = true,
    },
    {
        name = "vm_camrollstrength",
        default = "1",
        client = true,
    },
    {
        name = "hud_hints",
        default = "1",
        client = true,
    },
    {
        name = "fx_inspectblur",
        default = "0",
        client = true
    },
    {
        name = "ignore_dx",
        default = "0",
        client = true
    },
    {
        name = "fancy_spawnmenu",
        default = "1",
        client = true
    },
    {
        name = "gradual_sens",
        default = "0",
        client = true
    },
    {
        name = "phystweak",
        default = "1",
    },
    {
        name = "atts_maxcamos",
        default = "3",
    },
    {
        name = "indoorsound",
        default = "1",
        replicated = true
    },
    {
        name = "drawprojectedlights",
        default = "1",
        client = true
    },
    {
        name = "fx_rt_shader",
        default = "1",
        client = true
    },
    {
        name = "fx_rt_alwaysdraw",
        default = "0",
        client = true
    },
    {
        name = "fx_rt_fxaa",
        default = "1",
        client = true
    },
    {
        name = "fx_twoeyeaiming",
        default = "1",
        client = true
    },
    {
        name = "fx_twoeyeaiming_max_alpha",
        default = "1",
        client = true
    },
    {
        name = "fx_twoeyeaiming_min_alpha",
        default = "0.376",
        client = true
    },
    {
        name = "fx_twoeyeaiming_start",
        default = "0.2",
        client = true
    },
    {
        name = "fx_twoeyeaiming_depth_prepass",
        default = "1",
        client = true
    },
    {
        name = "fx_twoeyeaiming_reload_fade_time",
        default = "0.12",
        client = true
    },
    {
        name = "fx_adsblur_new",
        default = "1",
        client = true
    },
    {
        name = "fx_adsblur_always",
        default = "0",
        client = true
    },
}

ARC9.ConVarData = {}

local prefix = "arc9_"

local torevertlist_cl = {}
local torevertlist_sv = {}

for _, var in pairs(conVars) do
    local convar_name = prefix .. var.name

    if var.client and CLIENT then
        table.insert(torevertlist_cl, convar_name)
        CreateClientConVar(convar_name, var.default, true, var.userinfo)
    else
        local flags = FCVAR_ARCHIVE
        if var.replicated then
            flags = flags + FCVAR_REPLICATED
        end
        if var.userinfo then
            flags = flags + FCVAR_USERINFO
        end
        table.insert(torevertlist_sv, convar_name)
        CreateConVar(convar_name, var.default, flags, var.helptext, var.min, var.max)
    end

    ARC9.ConVarData[convar_name] = var
end

if CLIENT then
    concommand.Add("arc9_settings_reset_client", function()
        for _, var in pairs(torevertlist_cl) do
            RunConsoleCommand(var, GetConVar(var):GetDefault()) -- :Revert() wont work!!!!!!!!! ghhh
        end
    end, nil, "Reset all client ARC9 settings.")
end

concommand.Add("arc9_settings_reset_server", function()
    for _, var in pairs(torevertlist_sv) do
        GetConVar(var):Revert()
    end
end, nil, "Reset all server ARC9 settings.")

function ARC9.ShouldNetworkConVar(ply, cvar)
    if !ARC9.ConVarData[cvar] then return end
    if game.SinglePlayer() or ply:IsListenServerHost() then return false end

    if ARC9.ConVarData[cvar].client then return false end

    return true
end

if SERVER then
    util.AddNetworkString("ARC9_InvalidateAll")
    util.AddNetworkString("ARC9_InvalidateAll_ToClients")
    util.AddNetworkString("arc9_setconvar")
    util.AddNetworkString("arc9_svattcount")

    net.Receive("arc9_setconvar", function(len, ply)
        if !ply:IsAdmin() then return end
        local cvar = net.ReadString()
        if !ARC9.ShouldNetworkConVar(ply, cvar) then return end
        local val = net.ReadString()
        GetConVar(cvar):SetString(val)
        print(ply:GetName() .. " set '" .. cvar .. "' to '" .. val .. "'.")
    end)

    net.Receive("ARC9_InvalidateAll", function(len, ply)
        if ply:IsAdmin() then
            ARC9.InvalidateAll()
            net.Start("ARC9_InvalidateAll_ToClients")
            net.Broadcast()
        end
    end)
else
    net.Receive("ARC9_InvalidateAll_ToClients", function(len, ply)
        ARC9.InvalidateAll()
    end)
end

function ARC9.InvalidateAll()
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and ent:IsWeapon() and ent.ARC9 then
            ent:PostModify(true)
        end
    end
end

if CLIENT then

    local debounce = {}
    function ARC9.NetworkConVar(cvar, value)
        if !ARC9.ShouldNetworkConVar(LocalPlayer(), cvar) then return end
        if !LocalPlayer():IsAdmin() then return end
        if (debounce[cvar] or 0) > CurTime() then return end

        net.Start("arc9_setconvar")
            net.WriteString(cvar)
            net.WriteString(value)
        net.SendToServer()
        debounce[cvar] = CurTime() + 0.1
    end

local function menu_arc9_settings(panel)
    local butt = panel:Button("Open settings panel!", "arc9_settings_open")
    butt:SetText("Open ARC9 Settings")
    butt:SetPos(20, 50)
    butt:SetSize(300, 50)
    -- panel:ControlHelp( "\nAccess the ARC9 settings by pressing this button without having to equip a weapon!" )
end

local function menu_client_controller(panel)
    -- panel:AddControl( "header", { description = "Replace key names with controller glyphs." } )
    -- panel:CheckBox("Activate Controller Mode", "arc9_controller")
    -- panel:ControlHelp( "Activate controller-focused features in ARC9.\n- Keys are replaced with their bindnames.\n- JUMP and USE are used as Select and Deselect, respectively." )
    -- panel:ControlHelp( "Activate a controller-friendly mode for ARC9.\n- JUMP, RELOAD and USE can be used to Select, Deselect and\nRandomly Select attachments.\n\nController glyphs can be customized down below!" )
    -- panel:CheckBox("Controller Rumble w/ SInput", "arc9_controller_rumble")
    -- panel:ControlHelp( "Use Fesiug's SInput to interact with ARC9.\nFound at github.com/Fesiug/gmod-sinput" )

    local presetss = panel:ToolPresets( "arc9controller", { arc9_controller_glyphset = "" } )

    local listview = vgui.Create("DListView", panel)
    listview:SetSize( 99, 200 )
    panel:AddItem( listview )
    listview:SetMultiSelect( true )
    listview:AddColumn( ARC9:GetPhrase("spawnmenu.controller.input") )
    listview:AddColumn( ARC9:GetPhrase("spawnmenu.controller.output") )

    local tex_inp = vgui.Create( "DTextEntry", panel )
    local tex_out = vgui.Create( "DTextEntry", panel )
    -- panel:ControlHelp( "Glyph to show." )
    -- panel:ControlHelp( "Double-click to copy into text fields" )
    panel:AddItem( tex_inp )
    -- panel:ControlHelp( "Glyph or keyboard icon to be replaced.\nInputs are case-sensitive!" )
    panel:AddItem( tex_out )
    tex_inp:SetPlaceholderText( ARC9:GetPhrase("spawnmenu.controller.glyphreplace") )
    tex_out:SetPlaceholderText( ARC9:GetPhrase("spawnmenu.controller.glyphappear") )

    local but_add = vgui.Create( "DButton", panel )
    local but_rem = vgui.Create( "DButton", panel )
    local but_upd = vgui.Create( "DButton", panel )
    but_upd:Hide()
    local but_app = vgui.Create( "DButton", panel )
    but_app:Hide()
    panel:AddItem( but_add )
    panel:AddItem( but_rem )
    panel:AddItem( but_upd )
    panel:AddItem( but_app )
    but_add:SetText( ARC9:GetPhrase("spawnmenu.controller.addapply") )
    but_rem:SetText( ARC9:GetPhrase("spawnmenu.controller.remove") )
    but_upd:SetText("Restore From Memory")
    but_app:SetText("Apply")

    function listview:DoDoubleClick( lineID, line )
        tex_inp:SetValue( line:GetColumnText( 1 ) )
        tex_out:SetValue( line:GetColumnText( 2 ) )
    end

    function listview:OnRowRightClick( lineID, line )
        local menu = DermaMenu()
        menu:AddOption( "Copy", function() tex_inp:SetValue( line:GetColumnText( 1 ) ) tex_out:SetValue( line:GetColumnText( 2 ) ) end ):SetIcon( "icon16/page_copy.png" )
        menu:AddOption( "Remove", function() listview:RemoveLine( lineID ) but_app:DoClick() end ):SetIcon( "icon16/cross.png" )
        menu:Open()
    end

    function but_add:DoClick()
        local inp, out = string.Trim(tex_inp:GetValue()), string.Trim(tex_out:GetValue())
        if inp == "" then return end
        if out == "" then return end
        local worked = false
        for index, line in ipairs( listview:GetLines() ) do
            if line:GetColumnText( 1 ) == inp then
                line:SetColumnText( 2, out )
                worked = true
                break
            end
        end
        if !worked then
            listview:AddLine( inp, out )
        end
        but_app:DoClick()
    end

    function but_rem:DoClick()
        for i, v in pairs(listview:GetSelected()) do
            listview:RemoveLine( v:GetID() )
        end
        but_app:DoClick()
    end

    function but_upd:DoClick()
        listview:Clear()

        local config = GetConVar("arc9_controller_glyphset"):GetString()
        config = string.Split( config, "\\n" )
        for i, v in ipairs(config) do
            local swig = string.Split( v, "\\t" )
            if swig[1] == "" then continue end
            listview:AddLine( swig[1], swig[2] )
        end
    end

    function but_app:DoClick()
        local toapply = ""
        local order = 1
        for k, line in pairs( listview:GetLines() ) do
            if order != 1 then toapply = toapply .. "\\n" end
            toapply = toapply .. line:GetValue( 1 ) .. "\\t" .. line:GetValue( 2 )
            order = order + 1
        end
        RunConsoleCommand("arc9_controller_glyphset", toapply)
    end


    local matselect_filter = vgui.Create( "DComboBox", panel )
    panel:AddItem( matselect_filter )
    matselect_filter:AddChoice( ARC9:GetPhrase("spawnmenu.controller.displayall"), "" )
    matselect_filter:AddChoice( "\"Shared\"", "shared_" )
    matselect_filter:AddChoice( "PlayStation", "ps" )
    matselect_filter:AddChoice( "Xbox", "xbox" )
    matselect_filter:AddChoice( "Steam Controller", "sc_" )
    matselect_filter:AddChoice( "Steam Deck", "sd_" )
    matselect_filter:AddChoice( "Nintendo Switch", "switchpro_" )

    -- matselect_filter:AddChoice( "Refresh", "" )
    -- matselect_filter:AddChoice( "! Mouse !", "mouse" )
    -- matselect_filter:AddChoice( "Amazon Luna", "AmazonLuna/" )
    -- matselect_filter:AddChoice( "Ouya", "Ouya/" )
    -- matselect_filter:AddChoice( "PlayStation 3", "PS3/" )
    -- matselect_filter:AddChoice( "PlayStation 4", "PS4/" )
    -- matselect_filter:AddChoice( "PlayStation 5", "PS5/" )
    -- matselect_filter:AddChoice( "PlayStation Vita", "PSVita/" )
    -- matselect_filter:AddChoice( "Google Stadia", "GoogleStadia/" )
    -- matselect_filter:AddChoice( "Steam Controller", "Steam/" )
    -- matselect_filter:AddChoice( "Steam Deck", "SteamDeck/" )
    -- matselect_filter:AddChoice( "Nintendo Switch", "Switch/" )
    -- matselect_filter:AddChoice( "Nintendo Wii U", "WiiU/" )
    -- matselect_filter:AddChoice( "Xbox 360", "Xbox360/" )
    -- matselect_filter:AddChoice( "Xbox One", "XboxOne/" )
    -- matselect_filter:AddChoice( "Xbox Series X|S", "XboxSeries/" )
    matselect_filter:SetValue( ARC9:GetPhrase("spawnmenu.controller.filter") )

    local matselect = ""
    local function GenerateMatSelect()
        matselect = vgui.Create( "MatSelect", panel )
        Derma_Hook( matselect.List, "Paint", "Paint", "Panel" )
            function matselect:AddMaterial( label, value )
                local Mat = vgui.Create( "DImageButton", self )
                Mat:SetOnViewMaterial( value, "models/wireframe" )
                Mat.AutoSize = false
                Mat.Value = value
                Mat:SetSize( self.ItemWidth, self.ItemHeight )
                Mat:SetTooltip( label )

                -- Run a console command when the Icon is clicked
                Mat.DoClick = function( button )
                    self.OutputPanel:SetValue( label )
                end

                -- Add the Icon us
                self.List:AddItem( Mat )
                table.insert( self.Controls, Mat )

                self:InvalidateLayout()

            end
        panel:AddItem( matselect )

        for k, v in SortedPairs( ARC9.CTRL_Exists ) do
            local sel, seldata = matselect_filter:GetSelected()
            if string.find( k, seldata or "" ) then
                matselect:AddMaterial( k, "arc9/" .. ARC9.GlyphFamilyHUD() .. k .. ".png" )
            end
        end

        matselect:SetAutoHeight( true )
        matselect:SetItemWidth( 0.1875 * 0.66 )
        matselect:SetItemHeight( 0.1875 * 0.66 )

        matselect.InputPanel = tex_inp
        matselect.OutputPanel = tex_out
    end
    GenerateMatSelect()
    but_upd:DoClick()

    function matselect_filter:OnSelect()
        matselect:Remove()
        GenerateMatSelect()
    end

    presetss.OnSelect = function( self, index, value, data )
        if !data then return end
        for k, v in pairs( data ) do
            RunConsoleCommand( k, v )
        end

        timer.Simple(0.1, function()
            but_upd:DoClick()
        end)
	end
end

c1 = {
    ["DamageMax"] = true,
    ["DamageMin"] = true,
    ["DamageRand"] = true,
    ["RangeMin"] = true,
    ["RangeMax"] = true,
    ["Distance"] = true,
    ["Num"] = true,
    ["Penetration"] = true,
    ["RicochetAngleMax"] = true,
    ["RicochetChance"] = true,
    ["ArmorPiercing"] = true,
    ["ShootEntForce"] = true,
    ["PhysBulletMuzzleVelocity"] = true,
    ["PhysBulletDrag"] = true,
    ["PhysBulletGravity"] = true,
    ["ChamberSize"] = true,
    ["ClipSize"] = true,
    ["SupplyLimit"] = true,
    ["SecondarySupplyLimit"] = true,
    ["AmmoPerShot"] = true,
    ["ManualActionChamber"] = true,
    ["TriggerDelay"] = true,
    ["RPM"] = true,
    ["PushBackForce"] = true,
    ["PostBurstDelay"] = true,
    ["Recoil"] = true,
    ["RecoilPatternDrift"] = true,
    ["RecoilUp"] = true,
    ["RecoilSide"] = true,
    ["RecoilRandomUp"] = true,
    ["RecoilRandomSide"] = true,
    ["RecoilDissipationRate"] = true,
    ["RecoilResetTime"] = true,
    ["RecoilAutoControl"] = true,
    ["RecoilKick"] = true,
    ["Spread"] = true,
    ["DispersionSpread"] = true,
    ["FreeAimRadius"] = true,
    ["Sway"] = true,
    ["AimDownSightsTime"] = true,
    ["SprintToFireTime"] = true,
    ["ReloadTime"] = true,
    ["DeployTime"] = true,
    ["CycleTime"] = true,
    ["FixTime"] = true,
    ["OverheatTime"] = true,
    ["Speed"] = true,
    ["BashDamage"] = true,
    ["BashRange"] = true,
    ["BashLungeRange"] = true,
    ["HeatPerShot"] = true,
    ["HeatCapacity"] = true,
    ["HeatDissipation"] = true,
    ["ShootVolume"] = true,
    ["AlwaysPhysBullet"] = true,
    ["NeverPhysBullet"] = true,
    ["InfiniteAmmo"] = true,
    ["BottomlessClip"] = true,
    ["ShotgunReload"] = true,
    ["HybridReload"] = true,
    ["ManualAction"] = true,
    ["CanFireUnderwater"] = true,
    ["AutoReload"] = true,
    ["AutoBurst"] = true,
    ["RunawayBurst"] = true,
    ["ShootWhileSprint"] = true,
    ["Bash"] = true,
    ["Overheat"] = true,
    ["Malfunction"] = true,
    ["MalfunctionMeanShotsToFail"] = true,
    ["MalfunctionWait"] = true,
    ["Bipod"] = true,
    ["NoFlash"] = true,
    ["BulletGuidance"] = true,
    ["BulletGuidanceAmount"] = true,
    ["ExplosionDamage"] = true,
    ["ExplosionRadius"] = true,
    -- ["CanLean"] = true,
    ["HoldBreathTime"] = true,
    ["RestoreBreathTime"] = true,
    ["SlamFire"] = true,
    ["TriggerDelay"] = true,
    ["TriggerDelayTime"] = true,
    ["TriggerDelayRepeat"] = true,
    ["HeadshotDamage"] = true,
    ["ChestDamage"] = true,
    ["StomachDamage"] = true,
    ["ArmDamage"] = true,
    ["LegDamage"] = true,
    ["VisualRecoil"] = true,
    ["VisualRecoilUp"] = true,
    ["VisualRecoilSide"] = true,
    ["VisualRecoilRoll"] = true,
    ["VisualRecoilPunch"] = true,
    ["BreathHoldTime"] = true,
    ["BashSpeed"] = true,
}

c2 = {
    [""] = true,
    ["Mult"] = true,
    ["Add"] = true,
    ["Override"] = true,
}

c3 = {
    [""] = true,
    ["True"] = true,
    ["Silenced"] = true,
    ["UBGL"] = true,
    ["MidAir"] = true,
    ["Crouch"] = true,
    ["FirstShot"] = true,
    ["Empty"] = true,
    ["EvenShot"] = true,
    ["OddShot"] = true,
    ["EvenReload"] = true,
    ["OddReload"] = true,
    ["Sights"] = true,
    ["HipFire"] = true,
    ["Shooting"] = true,
    ["Recoil"] = true,
    ["Move"] = true,
}

local function menu_server_modifiers(panel)
    local presetss = panel:ToolPresets( "arc9modifiers", { arc9_modifiers = "" } )

    panel:AddControl( "header", { description = ARC9.GetPhrase and ARC9:GetPhrase("spawnmenu.supermod.info") or "Add ANY modifier with ANY special conditions." } )
    local listview = vgui.Create("DListView", panel)
    listview:SetSize( 99, 200 )
    panel:AddItem( listview )
    listview:SetMultiSelect( true )
    listview:AddColumn( ARC9.GetPhrase and ARC9:GetPhrase("spawnmenu.supermod.stat") or "Stat" )
    listview:AddColumn( ARC9.GetPhrase and ARC9:GetPhrase("spawnmenu.supermod.modifier") or "Modifier" )

    local tex_inp = vgui.Create( "DTextEntry", panel )
    local tex_out = vgui.Create( "DTextEntry", panel )
    -- panel:ControlHelp( "Double-click to copy into text fields" )

    local com_1 = vgui.Create( "DComboBox", panel )
    local com_2 = vgui.Create( "DComboBox", panel )
    local com_3 = vgui.Create( "DComboBox", panel )
    -- tex_inp:SetPlaceholderText("Alternatively, type which stat manually you'd like to modify here.")
    panel:AddItem( com_1 )
    panel:ControlHelp( ARC9.GetPhrase and ARC9:GetPhrase("spawnmenu.supermod.selectstat") or "Select a stat to modify" )
    panel:AddItem( com_2 )
    panel:ControlHelp( ARC9.GetPhrase and ARC9:GetPhrase("spawnmenu.supermod.selectmod") or "Add a modification type; Not all stats have these" )
    panel:AddItem( com_3 )
    panel:ControlHelp( ARC9.GetPhrase and ARC9:GetPhrase("spawnmenu.supermod.selectspec") or "Add a special condition, such as when crouching" )

    panel:ControlHelp( "" )
    panel:AddItem( tex_inp )
    tex_inp:SetPlaceholderText( ARC9.GetPhrase and ARC9:GetPhrase("spawnmenu.supermod.result") or "Result appears here" )

    panel:AddItem( tex_out )
    tex_out:SetPlaceholderText( ARC9.GetPhrase and ARC9:GetPhrase("spawnmenu.supermod.selectval") or "Write a numerical value, or \"true\" / \"false\"" )

    function listview:DoDoubleClick( lineID, line )
        tex_inp:SetValue( line:GetColumnText( 1 ) )
        tex_out:SetValue( line:GetColumnText( 2 ) )
    end

    for i, v in pairs(c1) do
        com_1:AddChoice( i )
    end
    for i, v in pairs(c2) do
        com_2:AddChoice( i )
    end
    for i, v in pairs(c3) do
        com_3:AddChoice( i )
    end

    com_1.OnSelect = function( self, index, value )
        tex_inp:SetValue( ( com_1:GetValue() or "" ) .. ( com_2:GetValue() or "" ) .. ( com_3:GetValue() or "" ) )
    end

    com_2.OnSelect = function( self, index, value )
        tex_inp:SetValue( ( com_1:GetValue() or "" ) .. ( com_2:GetValue() or "" ) .. ( com_3:GetValue() or "" ) )
    end

    com_3.OnSelect = function( self, index, value )
        tex_inp:SetValue( ( com_1:GetValue() or "" ) .. ( com_2:GetValue() or "" ) .. ( com_3:GetValue() or "" ) )
    end

    local but_add = vgui.Create( "DButton", panel )
    local but_rem = vgui.Create( "DButton", panel )
    local but_upd = vgui.Create( "DButton", panel )
    but_upd:Hide()
    local but_app = vgui.Create( "DButton", panel )
    but_app:Hide()
    panel:AddItem( but_add )
    panel:AddItem( but_rem )
    panel:AddItem( but_upd )
    panel:AddItem( but_app )
    but_add:SetText( ARC9.GetPhrase and ARC9:GetPhrase("spawnmenu.controller.addapply") or "Add & Apply" )
    but_rem:SetText( ARC9.GetPhrase and ARC9:GetPhrase("spawnmenu.controller.remove") or "Remove Selected" )
    but_upd:SetText("Restore From Memory")
    but_app:SetText("Apply")

    panel:ControlHelp( "" )

    if ARC9.GetPhrase then
        panel:ControlHelp( ARC9.GetPhrase and ARC9:GetPhrase("spawnmenu.supermod.examples") )
    else
        panel:ControlHelp( "Examples:" )
        panel:ControlHelp( "∟ Overheat | true - Disables overheating" )
        panel:ControlHelp( "∟ BottomlessClip | true - Enables Bottomless Clip" )
        panel:ControlHelp( "∟ RecoilMultCrouch | 0.1 - Lowers recoil to 10% when crouching" )
        panel:ControlHelp( "∟ RPMMultOddShot | 0.5 - Every other shot shoots at half RPM" )
    end

    function listview:OnRowRightClick( lineID, line )
        local menu = DermaMenu()
        menu:AddOption( "Copy", function() tex_inp:SetValue( line:GetColumnText( 1 ) ) tex_out:SetValue( line:GetColumnText( 2 ) ) end ):SetIcon( "icon16/page_copy.png" )
        menu:AddOption( "Remove", function() listview:RemoveLine( lineID ) but_app:DoClick() end ):SetIcon( "icon16/cross.png" )
        menu:Open()
    end

    function but_add:DoClick()
        local inp, out = string.Trim(tex_inp:GetValue()), string.Trim(tex_out:GetValue())
        if inp == "" then return end
        if out == "" then return end
        local worked = false
        for index, line in ipairs( listview:GetLines() ) do
            if line:GetColumnText( 1 ) == inp then
                line:SetColumnText( 2, out )
                worked = true
                break
            end
        end
        if !worked then
            listview:AddLine( inp, out )
        end
        but_app:DoClick()
    end

    function but_rem:DoClick()
        for i, v in pairs(listview:GetSelected()) do
            listview:RemoveLine( v:GetID() )
        end
        but_app:DoClick()
    end

    function but_upd:DoClick()
        listview:Clear()

        local config = GetConVar("arc9_modifiers"):GetString()
        config = string.Split( config, "\\n" )
        for i, v in ipairs(config) do
            local swig = string.Split( v, "\\t" )
            if swig[1] == "" then continue end
            listview:AddLine( swig[1], swig[2] )
        end
    end
    but_upd:DoClick()

    function but_app:DoClick()
        local toapply = ""
        local order = 1
        for k, line in pairs( listview:GetLines() ) do
            if order != 1 then toapply = toapply .. "\\n" end
            toapply = toapply .. line:GetValue( 1 ) .. "\\t" .. line:GetValue( 2 )
            order = order + 1
        end
        RunConsoleCommand("arc9_modifiers", toapply)
        RunConsoleCommand("arc9_modifiers_invalidateall")
    end

    presetss.OnSelect = function( self, index, value, data )
        if !data then return end
        for k, v in pairs( data ) do
            RunConsoleCommand( k, v )
        end

        timer.Simple(0.1, function()
            but_upd:DoClick()
            RunConsoleCommand("arc9_modifiers_invalidateall")
        end)
	end
end

concommand.Add( "arc9_modifiers_invalidateall", function( ply, cmd, args )
    if IsValid(ply) and ply:IsAdmin() then
        net.Start("ARC9_InvalidateAll") net.SendToServer()
    end
end )

local clientmenus_ti = {
    {
        text = "ARC9 Settings", func = menu_arc9_settings
    },
    -- {
    --     text = "Client", func = menu_client_ti
    -- },
    -- {
    --     text = "Client - Customization", func = menu_client_customization
    -- },
    -- {
        -- text = "Controller Mode", func = menu_client_controller
    -- },
    -- {
    --     text = "Client - Crosshair", func = menu_client_crosshair
    -- },
    -- {
    --     text = "Client - Optics", func = menu_client_optics
    -- },
    -- {
    --     text = "Server", func = menu_server_ti
    -- },
    -- {
    --     text = "Server - Attachments", func = menu_server_attachments
    -- },
    -- {
    --     text = "Server - Ballistics", func = menu_server_ballistics
    -- },
    {
        text = "Super Modifiers", func = menu_server_modifiers
    },
}

hook.Add("PopulateToolMenu", "ARC9_MenuOptions", function()
    for smenu, data in pairs(clientmenus_ti) do
        spawnmenu.AddToolMenuOption("Options", "ARC9", "ARC9_" .. tostring(smenu), data.text, "", "", data.func)
    end
end)

local function opensupermodifers()
    local frame = vgui.Create( "DFrame" )
    frame:SetPos( 10, 30 )
    frame:SetSize( 0.16 * ScrW(), 0.7 * ScrH() )
    frame:SetTitle( ARC9:GetPhrase("spawnmenu.settings") )
    frame:MakePopup()
    frame:Center()

    local scroller = vgui.Create( "DScrollPanel", frame )
    scroller:Dock( FILL )

    local cpanle = vgui.Create( "ControlPanel", frame )
    cpanle:SetName( ARC9:GetPhrase("settings.server.gameplay.supermod.title") )
    cpanle:Dock( FILL )
    menu_server_modifiers(cpanle)
end

local function opencontroller()
    local frame = vgui.Create( "DFrame" )
    frame:SetPos( 10, 30 )
    frame:SetSize( 0.2 * ScrW(), ScrH() * 0.9 )
    frame:SetTitle( ARC9:GetPhrase("spawnmenu.settings") )
    frame:MakePopup()
    frame:Center()

    local scroller = vgui.Create( "DScrollPanel", frame )
    scroller:Dock( FILL )

    local cpanle = vgui.Create( "ControlPanel", scroller )
    cpanle:SetName( ARC9:GetPhrase("settings.gameplay.controllerglyphs.title") )
    cpanle:Dock( FILL )
    menu_client_controller(cpanle)
end

concommand.Add("arc9_settings_supermodifiers", opensupermodifers)
concommand.Add("arc9_settings_controller", opencontroller)

end
