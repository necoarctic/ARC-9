
local pistolammotypes = {
    ["pistol"] = true,
    ["357"] = true
}

local rpgammotypes = {
    ["rpg_round"] = true,
    ["smg1_grenade"] = true,
    ["grenade"] = true
}

local sniperammotypes = {
    ["SniperRound"] = true,
    ["SniperPenetratedRound"] = true
}

function ARC9.GuessWeaponType(swep)
    if swep.ARC9WeaponCategory then return swep.ARC9WeaponCategory end

    if swep.NotAWeapon or swep.Throwable then
        return ARC9.WEAPON_MISC
    elseif swep.PrimaryBash then
        return ARC9.WEAPON_MELEE
    elseif swep.ShootEnt or rpgammotypes[swep.Ammo] then
        return ARC9.WEAPON_RPG
    elseif (swep.Num or 1) > 1 or swep.Ammo == "Buckshot" then
        return ARC9.WEAPON_SHOTGUN
    elseif sniperammotypes[swep.Ammo] then
        return ARC9.WEAPON_SNIPER
    end

    local bestfiremode = 1

    for _, mode in ipairs(swep.Firemodes or {}) do
        if mode.Mode != 1 and mode.Mode != 0 then
            bestfiremode = mode.Mode
            break
        end
    end

    if bestfiremode == 1 then
        if pistolammotypes[swep.Ammo] then
            return ARC9.WEAPON_PISTOL
        else
            return ARC9.WEAPON_SNIPER
        end
    else
        if pistolammotypes[swep.Ammo] then
            return ARC9.WEAPON_SMG
        else
            return ARC9.WEAPON_AR
        end
    end

    return ARC9.WEAPON_MISC
end

ARC9.WeaponClasses = {}

function ARC9.PopulateWeaponClasses()
    for _, wep in ipairs(weapons.GetList()) do
        if weapons.IsBasedOn(wep.ClassName, "arc9_base") then
            if wep.NotForNPCs then continue end
            if wep.AdminOnly then continue end
            local weptype = ARC9.GuessWeaponType(wep)
            ARC9.WeaponClasses[weptype] = ARC9.WeaponClasses[weptype] or {}
            table.insert(ARC9.WeaponClasses[weptype], wep.ClassName)
        end
    end
end

ARC9.PopulateWeaponClasses()

hook.Add("InitPostEntity", "ARC9_PopulateWeaponClasses", ARC9.PopulateWeaponClasses)

local arc9_npc_autoreplace = GetConVar("arc9_npc_autoreplace")
local arc9_replace_spawned = GetConVar("arc9_replace_spawned")

function ARC9.ReplaceSpawnedWeapon(ent)
    if CLIENT then return end

    if !(ent:IsNPC() or ent:IsWeapon()) then return end

    -- print("tried to replcae", ent, CurTime())

    local fuckingtimer = (CurTime() < 5 and -0.1 or 0)

    if ent:IsNPC() then
        if !arc9_npc_autoreplace:GetBool() then return end
        timer.Simple(0.1 + fuckingtimer, function()
            if !ent:IsValid() then return end
            local cap = ent:CapabilitiesGet()

            if bit.band(cap, CAP_USE_WEAPONS) != CAP_USE_WEAPONS then return end

            local class

            if IsValid(ent:GetActiveWeapon()) then
                class = ent:GetActiveWeapon():GetClass()
            end

            if !class then return end

            if ARC9.HL2Replacements[class] then
                local weptbl = ARC9.HL2Replacements[class]
                local wepcategory = table.Random(weptbl)
                local wepclass = table.Random(ARC9.GetWeaponClasses(wepcategory))

                if wepclass then
                    ent:Give(wepclass)
                end
            end
        end)
    elseif ent:IsWeapon() then
        if !arc9_replace_spawned:GetBool() then return end
        timer.Simple(0.1 + fuckingtimer, function()
            if !ent:IsValid() then return end
            if IsValid(ent:GetOwner()) then return end
            if ent.ARC9 then return end

            local class = ent:GetClass()

            if ARC9.HL2Replacements[class] then
                local weptbl = ARC9.HL2Replacements[class]
                local wepcategory = table.Random(weptbl)
                local wepclass = table.Random(ARC9.GetWeaponClasses(wepcategory))

                if wepclass then
                    local wpnent = ents.Create(wepclass)
                    wpnent:SetPos(ent:GetPos())
                    wpnent:SetAngles(ent:GetAngles())

                    -- wpnent:NoOwner_Initialize()

                    wpnent:Spawn()

                    timer.Simple(0, function()
                        if !ent:IsValid() then return end
                        wpnent:OnDrop(true)
                        ent:Remove()
                    end)
                end
            end
        end)
    end
end

hook.Add("OnEntityCreated", "ARC9_ReplaceSpawnedWeapons", ARC9.ReplaceSpawnedWeapon)

local arc9_npc_blacklist = GetConVar("arc9_npc_blacklist")
local arc9_npc_whitelist = GetConVar("arc9_npc_whitelist")

function ARC9.WeaponIsAllowed(class)
    local blacklist = arc9_npc_blacklist:GetString()
    local whitelist = arc9_npc_whitelist:GetString()

    if whitelist == "" then
        -- Check blacklist

        local blacklist_tbl = {}

        for _, v in ipairs(string.Explode(" ", blacklist)) do
            blacklist_tbl[v] = true
        end

        if blacklist_tbl[class] then
            return false
        end

        return true
    else
        -- Check whitelist

        local whitelist_tbl = {}

        for _, v in ipairs(string.Explode(" ", whitelist)) do
            whitelist_tbl[v] = true
        end

        if whitelist_tbl[class] then
            return true
        end

        return false
    end
end

function ARC9.GetWeaponClasses(weptype)
    local weptbl = ARC9.WeaponClasses[weptype]
    local wepclasses = {}

    if weptbl then
        for _, class in ipairs(weptbl) do
            if ARC9.WeaponIsAllowed(class) then
                table.insert(wepclasses, class)
            end
        end
    end

    return wepclasses
end

ARC9.RandomizeQueue = {}

function ARC9.TryRandomize()
    for _, wpn in ipairs(ARC9.RandomizeQueue) do
        if IsValid(wpn) then
            wpn:RollRandomAtts(wpn.Attachments)

            wpn:PruneAttachments()
            wpn:PostModify()
            wpn:SendWeapon()
        end
    end

    ARC9.RandomizeQueue = {}
end

hook.Add("Think", "ARC9_Think_TryRandomize", ARC9.TryRandomize)

local arc9_free_atts = GetConVar("arc9_free_atts")

local function randomizaegun(wpn)
    if !arc9_free_atts:GetBool() then return end
    wpn:SetNoPresets(true)

    timer.Simple(0.1, function()
        if !IsValid(wpn) then return end
        if wpn.NextRandomize and wpn.NextRandomize > CurTime() then return end
        wpn.NextRandomize = CurTime() + 0.2
    
        wpn:QueueForRandomize()
        timer.Simple(0.2, function() 
            if !IsValid(wpn) then return end
            wpn:PruneAttachments()
            wpn:PostModify()
            wpn:SendWeapon()
        end)
    end)
end

 -- shit from base game but for presets
function ARC9_CCGiveSWEP_Preset( ply, command, arguments )
	if !IsValid( ply ) then return end
	if arguments[1] == nil then return end
	if !ply:Alive() then return end
	local swep = list.Get( "Weapon" )[ arguments[1] ]
	if swep == nil then return end
	local isAdmin = ply:IsAdmin() or game.SinglePlayer()
	if ( !swep.Spawnable && !isAdmin ) or ( swep.AdminOnly && !isAdmin ) then
		return
	end
	if !gamemode.Call( "PlayerGiveSWEP", ply, arguments[1], swep ) then return end

    if ply:HasWeapon( swep.ClassName ) then
        local wpn = ply:GetWeapon( swep.ClassName )
        if IsValid(wpn) then
            if arguments[2] == "default" then
                wpn:SetNoPresets(true)
                wpn:CallOnClient("LoadPreset", "default")
            elseif arguments[2] == "random" then
                randomizaegun(wpn)
            elseif isstring(arguments[2]) then
                wpn:SetNoPresets(true)
                wpn:CallOnClient("LoadPreset", arguments[2])
            end
            
            wpn:PostModify()
            -- wpn:DoDeployAnimation()
            timer.Simple(0.05, function() if IsValid(wpn) then wpn:DoDeployAnimation() end end)
        end
    else
		MsgAll( "Giving " .. ply:Nick() .. " a " .. swep.ClassName .. "\n" )
		local wpn = ply:Give( swep.ClassName )

        if arguments[2] == "default" then
            wpn:SetNoPresets(true)
        elseif arguments[2] == "random" then
            randomizaegun(wpn)
        elseif isstring(arguments[2]) then
            wpn:SetNoPresets(true)
            timer.Simple(0.1, function() if IsValid(wpn) then wpn:CallOnClient("LoadPreset", arguments[2]) end end)
        end
    end
    
	ply:SelectWeapon( swep.ClassName )
end

concommand.Add( "arc9_giveswep_preset", ARC9_CCGiveSWEP_Preset)

local function DecompressTableRecursive(tbl)
    local result = {}
    for _, v in ipairs(tbl) do
        if v.i then table.insert(result, v.i) end

        if v.s then
            local meow = DecompressTableRecursive(v.s)
            for _, v in ipairs(meow) do
                table.insert(result, v)
            end
        end
    end

    return result
end

function ARC9.GetAttsFromPreset(str)
    if !isstring(str) then return end
    if str[1] != "[" then return end
    if !string.find(str, "]X") then return end
    local str = string.Split(str, "]")[2]
    if !str then return end
    str = util.Base64Decode(str)
    str = util.Decompress(str)
    if !str then return end
    local tbl = util.JSONToTable(str)
    if !tbl then return end

    return DecompressTableRecursive(tbl)
end

-- ARC9:GetAttsFromPreset("[Preset 2]XQAAAQC9AgAAAAAAAAA9iIIiM7tuo1AtT00OeFDsU2rlYJ15CM1C4pyg6ls7Gg9expmQG5gXj4GqT1XacITxrYsY+oWxjHN8ZzKelhGqulG2Y6+l86baKrDfKcWkDMIUN/+zvfGCM5EJZjrJWBxx6SlJn+Rx47DpboY4S/RtkHrae9OxfcUVENmKG4+Xm80gPlBnSARnHQuemMIzoD31JWcDEO4LtGTQhZisXzWTmh9idUs7Ouq28cPErJcrrR4AGPtGjIuLCG8b+oDmGvWIjQxdN1I8xxMLaujnfYqdJTRsPAc6H4hzjw/rRf5Q7d4HJXOopyKd4vDGaOQx1sC1X+lMd/aOWJW62mGFFgLV/XWGTqXK0fyehDYhgkqDGOHm4ubqcfk03UFxojv2Rw==")

function ARC9.GiveAttsFromList(ply, tbl)
    local take = false

    for i, k in pairs(tbl) do
        -- if GetConVar("arc9_atts_lock"):GetBool() then
            if ARC9:PlayerGetAtts(ply, k) > 0 then continue end
        -- end

        if hook.Run("ARC9_PickupAttEnt", ply, k, 1) then continue end
        ARC9:PlayerGiveAtt(ply, k, 1)
        take = true
    end

    if take then ARC9:PlayerSendAttInv(ply) end
end

-- When a player picks up a weapon they already own,
-- transfer the ground weapon's attachments to the player's inventory.
local function ExtractInstalledAtts(slots, result)
    result = result or {}
    for _, slot in pairs(slots or {}) do
        if slot.Installed then
            table.insert(result, slot.Installed)
            if slot.SubAttachments then
                ExtractInstalledAtts(slot.SubAttachments, result)
            end
        end
    end
    return result
end

hook.Add("PlayerCanPickupWeapon", "ARC9_PickupAttachmentTransfer", function(ply, wep)
    if !wep.ARC9 then return end
    if arc9_free_atts:GetBool() then return end
    if !ply:HasWeapon(wep:GetClass()) then return end

    local atts = ExtractInstalledAtts(wep.Attachments)

    if #atts > 0 then
        ARC9.GiveAttsFromList(ply, atts)
    end
end)

function ARC9.SendPreset(ply, classname, preset)
    if !ply:IsPlayer() or !isstring(classname) or !isstring(preset) then return end
	local swep = list.Get( "Weapon" )[classname]
	if swep == nil then return end

    if !arc9_free_atts:GetBool() then
        local atts = ARC9.GetAttsFromPreset(preset)
        if !atts then return end

        ARC9.GiveAttsFromList(ply, atts)
    end

    preset = string.Split(preset, "]")[2]

    -- now giving gun
    
    if ply:HasWeapon(classname) then
        local wpn = ply:GetWeapon(classname)
        if IsValid(wpn) then
            wpn:SetNoPresets(true)

            net.Start("arc9_sendpreset")
            net.WriteEntity(wpn)
            net.WriteString(preset)
            net.Send(ply)

            wpn:PostModify()
        end
    else
		MsgAll( "Giving " .. ply:Nick() .. " a " .. classname .. "\n" )
		local wpn = ply:Give(classname)

        wpn:SetNoPresets(true)
        timer.Simple(0.1, function() 
            if IsValid(wpn) then
                net.Start("arc9_sendpreset")
                net.WriteEntity(wpn)
                net.WriteString(preset)
                net.Send(ply)
            end 
        end)
    end

	ply:SelectWeapon( swep.ClassName )
end

-- ARC9.SendPreset(Entity(1), "arc9_eft_rsass", "[Preset 2]XQAAAQC9AgAAAAAAAAA9iIIiM7tuo1AtT00OeFDsU2rlYJ15CM1C4pyg6ls7Gg9expmQG5gXj4GqT1XacITxrYsY+oWxjHN8ZzKelhGqulG2Y6+l86baKrDfKcWkDMIUN/+zvfGCM5EJZjrJWBxx6SlJn+Rx47DpboY4S/RtkHrae9OxfcUVENmKG4+Xm80gPlBnSARnHQuemMIzoD31JWcDEO4LtGTQhZisXzWTmh9idUs7Ouq28cPErJcrrR4AGPtGjIuLCG8b+oDmGvWIjQxdN1I8xxMLaujnfYqdJTRsPAc6H4hzjw/rRf5Q7d4HJXOopyKd4vDGaOQx1sC1X+lMd/aOWJW62mGFFgLV/XWGTqXK0fyehDYhgkqDGOHm4ubqcfk03UFxojv2Rw==")
-- ARC9.SendPreset(Entity(1), "arc9_eft_m700", "[Preset 1]XQAAAQCvAQAAAAAAAAA9iIIiM7tuo1AtT00OeFD3P42TD+08avjoYHpU/BZfxwQM8rdOlla2f+XoSkE2NBtqIXN79G346bvwhWZOuddA/f+Loec9PIRhl8RVSTCB1d8eR8NB6NO2IxEih9CKHt7gfleJOAlytQwZyBUv12c74ho4Ep+0MRJBZvwX3oq8XoWLkzaIMz5CVwJwHLewTitrAs/1ARlFHcs5NkGJOxK3G7QpRObiwMezh7gfucelLViMcLyo83xROOWLMolioSNCdl5Ars67hBJ5W2qzPxll")
