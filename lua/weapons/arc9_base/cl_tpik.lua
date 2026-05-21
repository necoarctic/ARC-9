-- third person inverse kinematics
-- optimizations & tweening by Onge.org

local arc9_tpik = GetConVar("arc9_tpik")
local arc9_tpik_others = GetConVar("arc9_tpik_others")
local arc9_tpik_framerate_you = GetConVar("arc9_tpik_framerate_local")
local arc9_tpik_framerate_notyou = GetConVar("arc9_tpik_framerate_others")

-- Onge : Add TPIK helper bone compatibility patch and API
local arc9_tpik_helper_bone_patch = GetConVar("arc9_tpik_helper_bone_patch") or
    CreateClientConVar("arc9_tpik_helper_bone_patch", "1", true, false, "", 0, 1)
local arc9_tpik_helper_bone_include_fingers = GetConVar("arc9_tpik_helper_bone_include_fingers") or
    CreateClientConVar("arc9_tpik_helper_bone_include_fingers", "0", true, false, "", 0, 1)
local arc9_tpik_helper_bone_cache_offsets = GetConVar("arc9_tpik_helper_bone_cache_offsets") or
    CreateClientConVar("arc9_tpik_helper_bone_cache_offsets", "1", true, false, "", 0, 1)
local arc9_tpik_helper_bone_force_full_fps = GetConVar("arc9_tpik_helper_bone_force_full_fps") or
    CreateClientConVar("arc9_tpik_helper_bone_force_full_fps", "1", true, false, "", 0, 1)
local arc9_tpik_helper_bone_debug = GetConVar("arc9_tpik_helper_bone_debug") or
    CreateClientConVar("arc9_tpik_helper_bone_debug", "0", true, false, "", 0, 1)
local arc9_tpik_native_pose_layers = GetConVar("arc9_tpik_native_pose_layers") or
    CreateClientConVar("arc9_tpik_native_pose_layers", "1", true, false, "", 0, 1)
local arc9_tpik_native_advanced_bones = GetConVar("arc9_tpik_native_advanced_bones") or
    CreateClientConVar("arc9_tpik_native_advanced_bones", "1", true, false, "", 0, 1)
local arc9_tpik_native_advanced_child_mode = GetConVar("arc9_tpik_native_advanced_child_mode") or
    CreateClientConVar("arc9_tpik_native_advanced_child_mode", "2", true, false, "", 0, 2)
local arc9_tpik_native_layer_speed = GetConVar("arc9_tpik_native_layer_speed") or
    CreateClientConVar("arc9_tpik_native_layer_speed", "14", true, false, "", 1, 60)
local TPIKHelperBonePatchRuntimeDisabled = false

local activeposvector = Vector(-1, -1, 1)
local peekvector = Vector(0, 2, 4)
local someangforsights = Angle(3, -3, -8)
local nearwallpos = Vector(1, 0, 18)
local nearwallang = Angle(-70, 0, 0)

local PlayerReanimsOffsets = {
    default = {
        passive = { Pos = Vector(-8, -1, -3) },
        normal = { Pos = Vector(-8, -1, 0) },
        crouch = { Pos = Vector(-3, 0, 2) },
        customization = { Pos = Vector(-5, 0, -5) }
    },

    csgo = {
        crouch = { Pos = Vector(-2, -3, 1) },
        revolver = { Pos = Vector(4.5, -3, -6) },
    },

    l4d = {
        passive = { Pos = Vector(-4, -1, -1) },
        normal = { Pos = Vector(-7, -1, 0) },
        crouch = { Pos = Vector(-5, 0, 1) },
        revolver = { Pos = Vector(3, -1, 1) },
    },

    payday2 = {
        active = { Pos = Vector(-1, -2, 0) },
        passive = { Pos = Vector(-2, 1, 2) },
        normal = { Pos = Vector(-7, 1, 0) },
        crouch = { Pos = Vector(-1, 0, 1) },
        revolver = { Pos = Vector(3.6, 2, 1) },
    },
}

local playeranimset = "default"

local xdrlist = { -- idk what else mods have custom anims
    ["3267580122"] = "payday2",
    ["2916762576"] = "l4d",
    ["2261825706"] = "csgo",
}

for _, addon in pairs(engine.GetAddons()) do
    if addon.mounted and xdrlist[tostring(addon.wsid)] then
        playeranimset = xdrlist[tostring(addon.wsid)]
    end
end

local function HasCustomOffset(holdtype)
    local animsetlocal = playeranimset
    if ! PlayerReanimsOffsets[animsetlocal] or ! PlayerReanimsOffsets[animsetlocal][holdtype] then
        animsetlocal =
        "default"
    end

    if PlayerReanimsOffsets[animsetlocal] then
        return PlayerReanimsOffsets[animsetlocal][holdtype]
    end

    return false
end

local function GetCustomOffset(holdtype)
    return HasCustomOffset(holdtype) and HasCustomOffset(holdtype).Pos
end

local ENTITY = FindMetaTable("Entity")
local entityGetBoneMatrix = ENTITY.GetBoneMatrix
local entitySetBoneMatrix = ENTITY.SetBoneMatrix

local forcednotpik = ARC9.NoTPIK
local Lerp = Lerp

local TPIKBoneIndexCache = setmetatable({}, { __mode = "k" })
local TPIKHeadChildCountCache = setmetatable({}, { __mode = "k" })

local function GetCachedBoneIndex(ent, boneName)
    if not IsValid(ent) or not boneName then return nil end
    local mdl = ent:GetModel() or ""
    local cache = TPIKBoneIndexCache[ent]
    if not cache or cache.mdl ~= mdl then
        cache = { mdl = mdl, bones = {} }
        TPIKBoneIndexCache[ent] = cache
    end

    local cached = cache.bones[boneName]
    if cached ~= nil then
        return cached ~= false and cached or nil
    end

    local idx = ent:LookupBone(boneName)
    cache.bones[boneName] = idx or false
    return idx
end

local function GetCachedHeadChildCount(ply, headIndex)
    if not IsValid(ply) or not headIndex then return 99 end
    local mdl = ply:GetModel() or ""
    local cache = TPIKHeadChildCountCache[ply]
    if not cache or cache.mdl ~= mdl or cache.headIndex ~= headIndex then
        local children = ply:GetChildBones(headIndex)
        cache = { mdl = mdl, headIndex = headIndex, count = children and #children or 0 }
        TPIKHeadChildCountCache[ply] = cache
    end
    return cache.count or 0
end


local cached_children = {}

local function recursive_get_children(ent, bone, bones, endbone) -- evil recursive children hack (works only one time for each model)
    local bone = isstring(bone) and GetCachedBoneIndex(ent, bone) or bone

    if not bone or isstring(bone) or bone == -1 then return end

    local children = ent:GetChildBones(bone)
    if #children > 0 then
        local id
        for i = 1, #children do
            id = children[i]
            if id == endbone then continue end
            recursive_get_children(ent, id, bones, endbone)
            table.insert(bones, id)
        end
    end
end

local function get_children(ent, bone, endbone)
    local mdl = ent:GetModel() or ""
    local modelCache = cached_children[mdl]
    if not modelCache then
        modelCache = {}
        cached_children[mdl] = modelCache
    end

    local key = tostring(bone) .. ":" .. tostring(endbone or "")
    local cached = modelCache[key]
    if cached then return cached end -- cache that shit or else...........

    local bones = {}
    recursive_get_children(ent, bone, bones, endbone)
    modelCache[key] = bones

    return bones
end

local function bone_apply_matrix(ent, bone, new_matrix, endbone)
    local bone = isstring(bone) and ent:LookupBone(bone) or bone

    if not bone or isstring(bone) or bone == -1 then return end

    local matrix = entityGetBoneMatrix(ent, bone)
    if not matrix then return end
    local inv_matrix = matrix:GetInverse()
    if not inv_matrix then return end

    local children = get_children(ent, bone, endbone)

    local translate = (new_matrix * inv_matrix)
    local id
    for i = 1, #children do
        id = children[i]
        local mat = entityGetBoneMatrix(ent, id)
        if not mat then continue end
        local moved = translate * mat
        entitySetBoneMatrix(ent, id, moved) -- WTF
        ent:SetBonePosition(id, moved:GetTranslation(), moved:GetAngles())
    end

    entitySetBoneMatrix(ent, bone, new_matrix)
    ent:SetBonePosition(bone, new_matrix:GetTranslation(), new_matrix:GetAngles())
end


local TPIKHelperBoneCache = setmetatable({}, { __mode = "k" })
local TPIKHelperBoneIndexCache = setmetatable({}, { __mode = "k" })

local function GetHelperCachedBoneIndex(ent, boneName)
    if not IsValid(ent) or not boneName then return nil end
    local mdl = ent:GetModel() or ""
    local entCache = TPIKHelperBoneIndexCache[ent]
    if not entCache or entCache.mdl ~= mdl then
        entCache = { mdl = mdl, bones = {} }
        TPIKHelperBoneIndexCache[ent] = entCache
    end

    local cached = entCache.bones[boneName]
    if cached ~= nil then
        return cached ~= false and cached or nil
    end

    local idx = ent.LookupBone and ent:LookupBone(boneName) or nil
    entCache.bones[boneName] = idx or false
    return idx
end

local function DisableHelperBonePatchAfterError(err)
    print("[ARC9 TPIK] Native helper-bone patch disabled for this session after runtime error: " .. tostring(err))
    TPIKHelperBonePatchRuntimeDisabled = true
end

local CORE_ARM_BONES = {
    ["ValveBiped.Bip01_L_UpperArm"] = true,
    ["ValveBiped.Bip01_L_Forearm"] = true,
    ["ValveBiped.Bip01_L_Hand"] = true,
    ["ValveBiped.Bip01_R_UpperArm"] = true,
    ["ValveBiped.Bip01_R_Forearm"] = true,
    ["ValveBiped.Bip01_R_Hand"] = true
}

local CORE_STOP_CHILD = {
    ["ValveBiped.Bip01_L_UpperArm"] = "ValveBiped.Bip01_L_Forearm",
    ["ValveBiped.Bip01_L_Forearm"] = "ValveBiped.Bip01_L_Hand",
    ["ValveBiped.Bip01_R_UpperArm"] = "ValveBiped.Bip01_R_Forearm",
    ["ValveBiped.Bip01_R_Forearm"] = "ValveBiped.Bip01_R_Hand"
}

local function IsValveBipedBoneName(name)
    return isstring(name) and name:StartWith("ValveBiped.")
end

local function IsFingerBoneName(name)
    local lname = string.lower(tostring(name or ""))
    return lname:find("finger", 1, true) or lname:find("thumb", 1, true)
end

local function IsCoreArmBoneIndex(ply, idx)
    if not idx or idx < 0 then return false end
    return CORE_ARM_BONES[ply:GetBoneName(idx) or ""] == true
end

local function FindNearestDrivenArmParent(ply, idx)
    local parent = ply:GetBoneParent(idx)
    while parent and parent >= 0 do
        if IsCoreArmBoneIndex(ply, parent) then
            return parent
        end
        parent = ply:GetBoneParent(parent)
    end
    return nil
end

local function GetHelperDescendants(ply, rootIdx)
    local out = {}

    local function walk(parentIdx)
        local children = ply:GetChildBones(parentIdx) or {}
        for _, childIdx in ipairs(children) do
            local childName = ply:GetBoneName(childIdx) or ""
            if not IsValveBipedBoneName(childName) then
                out[#out + 1] = childIdx
                walk(childIdx)
            end
        end
    end

    walk(rootIdx)
    return out
end

local function BuildTPIKHelperBoneCache(ply)
    if not IsValid(ply) then return nil end
    local model = ply:GetModel() or ""
    local includeFingers = arc9_tpik_helper_bone_include_fingers and arc9_tpik_helper_bone_include_fingers:GetBool()
    local cacheKey = model .. ":fingers=" .. tostring(includeFingers)
    local cached = TPIKHelperBoneCache[ply]
    if cached and cached.cacheKey == cacheKey then return cached end

    local entries = {}
    local seen = {}

    local function addHelperRoot(childIdx, childName, rootName, driverIdx)
        if seen[childIdx] then return end
        seen[childIdx] = true

        local parentMat = entityGetBoneMatrix(ply, driverIdx)
        local childMat = entityGetBoneMatrix(ply, childIdx)
        local localMat = nil
        if parentMat and childMat then
            local invParent = Matrix(parentMat)
            invParent:Invert()
            localMat = invParent * childMat
        end

        entries[#entries + 1] = {
            idx = childIdx,
            name = childName,
            root = rootName,
            parent = driverIdx,
            driverName = ply:GetBoneName(driverIdx) or "",
            descendants = GetHelperDescendants(ply, childIdx),
            cachedLocalMat = localMat
        }
    end

    local function addSubtree(rootName)
        local rootIdx = GetHelperCachedBoneIndex(ply, rootName)
        if not rootIdx then return end
        local stopName = CORE_STOP_CHILD[rootName]
        local stopIdx = stopName and GetHelperCachedBoneIndex(ply, stopName) or nil

        local function walk(parentIdx, insideHelper)
            local children = ply:GetChildBones(parentIdx) or {}
            for _, childIdx in ipairs(children) do
                if childIdx ~= stopIdx then
                    local childName = ply:GetBoneName(childIdx) or ""
                    local isValve = IsValveBipedBoneName(childName)
                    local isFinger = IsFingerBoneName(childName)
                    local driverIdx = FindNearestDrivenArmParent(ply, childIdx)
                    local isAllowed = driverIdx and not isValve and (includeFingers or not isFinger)

                    if isAllowed and not insideHelper then
                        addHelperRoot(childIdx, childName, rootName, driverIdx)
                        walk(childIdx, true)
                    else
                        walk(childIdx, insideHelper or (isAllowed and true or false))
                    end
                end
            end
        end

        walk(rootIdx, false)
    end

    addSubtree("ValveBiped.Bip01_L_UpperArm")
    addSubtree("ValveBiped.Bip01_L_Forearm")
    addSubtree("ValveBiped.Bip01_L_Hand")
    addSubtree("ValveBiped.Bip01_R_UpperArm")
    addSubtree("ValveBiped.Bip01_R_Forearm")
    addSubtree("ValveBiped.Bip01_R_Hand")

    cached = { cacheKey = cacheKey, model = model, entries = entries }
    TPIKHelperBoneCache[ply] = cached

    if arc9_tpik_helper_bone_debug and arc9_tpik_helper_bone_debug:GetBool() then
        print("[ARC9 TPIK] Native helper-root patch detected " .. tostring(#entries) .. " helper roots on " .. model)
        for _, entry in ipairs(entries) do
            print("  - " ..
                tostring(entry.name) ..
                " driven by " ..
                tostring(entry.driverName) ..
                " under " .. tostring(entry.root) .. " children=" .. tostring(#(entry.descendants or {})))
        end
    end

    return cached
end

local function TPIKHelperHasCachedRoots(ply)
    if TPIKHelperBonePatchRuntimeDisabled then return false end
    if not IsValid(ply) then return false end
    if arc9_tpik_helper_bone_patch and not arc9_tpik_helper_bone_patch:GetBool() then return false end

    local cache = TPIKHelperBoneCache[ply]
    if not cache or not cache.entries or #cache.entries <= 0 then return false end
    return cache.model == (ply:GetModel() or "")
end

local function CaptureTPIKHelperBoneLocals(ply)
    if TPIKHelperBonePatchRuntimeDisabled then return nil end
    if not IsValid(ply) then return nil end
    if arc9_tpik_helper_bone_patch and not arc9_tpik_helper_bone_patch:GetBool() then return nil end

    local cache = BuildTPIKHelperBoneCache(ply)
    if not cache or not cache.entries or #cache.entries <= 0 then return nil end

    if arc9_tpik_helper_bone_cache_offsets and arc9_tpik_helper_bone_cache_offsets:GetBool() then
        return cache.entries
    end

    local captured = {}
    for _, entry in ipairs(cache.entries) do
        local idx = entry.idx
        local parentIdx = entry.parent

        if parentIdx and parentIdx >= 0 then
            local childMat = entityGetBoneMatrix(ply, idx)
            local parentMat = entityGetBoneMatrix(ply, parentIdx)
            if childMat and parentMat then
                local invParent = Matrix(parentMat)
                invParent:Invert()
                captured[#captured + 1] = {
                    idx = idx,
                    parent = parentIdx,
                    localMat = invParent * childMat,
                    cachedLocalMat = invParent * childMat,
                    name = entry.name,
                    driverName = entry.driverName,
                    descendants = entry.descendants
                }
            end
        end
    end

    return captured
end

local function ApplyTPIKHelperBoneLocals(ply, captured)
    if not captured or not IsValid(ply) then return end

    for _, entry in ipairs(captured) do
        local parentMat = entityGetBoneMatrix(ply, entry.parent)
        local localMat = entry.localMat or entry.cachedLocalMat
        if parentMat and localMat then
            local newMat = parentMat * localMat
            local oldMat = entityGetBoneMatrix(ply, entry.idx)
            if oldMat and entry.descendants and #entry.descendants > 0 then
                local invOld = Matrix(oldMat)
                invOld:Invert()
                local delta = newMat * invOld

                for _, childIdx in ipairs(entry.descendants) do
                    local childMat = entityGetBoneMatrix(ply, childIdx)
                    if childMat then
                        local moved = delta * childMat
                        entitySetBoneMatrix(ply, childIdx, moved)
                        ply:SetBonePosition(childIdx, moved:GetTranslation(), moved:GetAngles())
                    end
                end
            end

            entitySetBoneMatrix(ply, entry.idx, newMat)
            ply:SetBonePosition(entry.idx, newMat:GetTranslation(), newMat:GetAngles())
        end
    end
end

ARC9.TPIK = ARC9.TPIK or {}
ARC9.TPIK.NativeHelperBones = true
ARC9.TPIK.HelperHasCachedRoots = TPIKHelperHasCachedRoots
ARC9.TPIK.CaptureHelperBoneLocals = CaptureTPIKHelperBoneLocals
ARC9.TPIK.ApplyHelperBoneLocals = ApplyTPIKHelperBoneLocals


-- native TPIK extension API
local function TPIKAPI_CallBool(wep, method, default)
    if not IsValid(wep) or not isfunction(wep[method]) then return default end
    local ok, value = pcall(wep[method], wep)
    if not ok then return default end
    return value
end

local function TPIKAPI_CallValue(wep, method, default)
    if not IsValid(wep) or not isfunction(wep[method]) then return default end
    local ok, value = pcall(wep[method], wep)
    if not ok then return default end
    return value
end

local function TPIKAPI_GetTemporaryOverride(wep)
    if not IsValid(wep) then return nil end
    local data = wep.ARC9_TPIKTemporaryIKOverride
    if not istable(data) then return nil end
    if data.expires and data.expires > 0 and data.expires < CurTime() then
        wep.ARC9_TPIKTemporaryIKOverride = nil
        return nil
    end
    return data
end

local function TPIKAPI_GetCurrentArmState(wep)
    if not IsValid(wep) then return nil end
    return {
        weapon = wep,
        owner = isfunction(wep.GetOwner) and wep:GetOwner() or nil,
        holdtype = isfunction(wep.GetHoldType) and wep:GetHoldType() or nil,
        safe = TPIKAPI_CallBool(wep, "GetSafe", false),
        sprinting = TPIKAPI_CallBool(wep, "GetIsSprinting", false),
        sprintAmount = TPIKAPI_CallValue(wep, "GetSprintAmount", 0) or 0,
        sprintDelta = TPIKAPI_CallValue(wep, "GetSprintDelta", 0) or 0,
        sightAmount = TPIKAPI_CallValue(wep, "GetSightAmount", 0) or 0,
        reloading = TPIKAPI_CallBool(wep, "GetReloading", false),
        inspecting = TPIKAPI_CallBool(wep, "GetInspecting", false),
        noTPIK = wep.NoTPIK or wep.GetProcessedValue and wep:GetProcessedValue("NoTPIK", true) or false,
        lastWasSprinting = TPIKAPI_CallBool(wep, "GetLastWasSprinting", false),
        temporaryOverride = TPIKAPI_GetTemporaryOverride(wep)
    }
end

local function TPIKAPI_GetIKTargets(wep)
    if not IsValid(wep) then return nil end
    return wep.ARC9_TPIKLastIKTargets
end

local function TPIKAPI_SetTemporaryIKOverride(wep, data, duration)
    if not IsValid(wep) then return false end
    if data == nil then
        wep.ARC9_TPIKTemporaryIKOverride = nil
        return true
    end
    if not istable(data) then return false end
    local copy = table.Copy(data)
    if duration and duration > 0 then
        copy.expires = CurTime() + duration
    elseif copy.duration and copy.duration > 0 and not copy.expires then
        copy.expires = CurTime() + copy.duration
    end
    wep.ARC9_TPIKTemporaryIKOverride = copy
    return true
end

local function TPIKAPI_SuppressHandIK(wep, left, right, duration)
    return TPIKAPI_SetTemporaryIKOverride(wep, {
        suppressLeftHand = left == true,
        suppressRightHand = right == true
    }, duration or 0)
end

local function TPIKAPI_GetSafeModeState(wep)
    if not IsValid(wep) then return nil end
    return {
        safe = TPIKAPI_CallBool(wep, "GetSafe", false),
        cantSafety = wep.GetProcessedValue and wep:GetProcessedValue("CantSafety", true) or wep.CantSafety,
        firemode = TPIKAPI_CallValue(wep, "GetFiremode", nil),
        firemodeName = wep.GetFiremodeName and wep:GetFiremodeName() or nil
    }
end

local function TPIKAPI_GetSprintState(wep)
    if not IsValid(wep) then return nil end
    return {
        sprinting = TPIKAPI_CallBool(wep, "GetIsSprinting", false),
        amount = TPIKAPI_CallValue(wep, "GetSprintAmount", 0) or 0,
        delta = TPIKAPI_CallValue(wep, "GetSprintDelta", 0) or 0,
        lastWasSprinting = TPIKAPI_CallBool(wep, "GetLastWasSprinting", false),
        sprintLock = wep.SprintLock and wep:SprintLock() or false,
        shootWhileSprint = wep.GetProcessedValue and wep:GetProcessedValue("ShootWhileSprint", true) or
            wep.ShootWhileSprint,
        oneHandedSprint = wep.GetProcessedValue and wep:GetProcessedValue("OneHandedSprint", true) or wep
            .OneHandedSprint
    }
end

local TPIKNativeLayerBoneIndexCache = setmetatable({}, { __mode = "k" })
local TPIKNativeLayerChildCache = {}

local function NativeLayerCopyVec(v)
    if isvector(v) then return Vector(v.x, v.y, v.z) end
    if istable(v) then return Vector(tonumber(v.x) or tonumber(v[1]) or 0, tonumber(v.y) or tonumber(v[2]) or 0, tonumber(v.z) or tonumber(v[3]) or 0) end
    return Vector(0, 0, 0)
end

local function NativeLayerCopyAng(a)
    if isangle(a) then return Angle(a.p, a.y, a.r) end
    if istable(a) then return Angle(tonumber(a.p) or tonumber(a[1]) or 0, tonumber(a.y) or tonumber(a[2]) or 0, tonumber(a.r) or tonumber(a[3]) or 0) end
    return Angle(0, 0, 0)
end

local function NativeLayerIsZeroVec(v)
    return (not v) or (math.abs(v.x or 0) + math.abs(v.y or 0) + math.abs(v.z or 0) < 0.0001)
end

local function NativeLayerIsZeroAng(a)
    return (not a) or (math.abs(a.p or 0) + math.abs(a.y or 0) + math.abs(a.r or 0) < 0.0001)
end

local function NativeLayerGetBoneIndex(ent, boneName)
    if not IsValid(ent) or not boneName then return nil end
    if isnumber(boneName) then return boneName end

    local mdl = ent:GetModel() or ""
    local entCache = TPIKNativeLayerBoneIndexCache[ent]
    if not entCache or entCache.mdl ~= mdl then
        entCache = { mdl = mdl, bones = {} }
        TPIKNativeLayerBoneIndexCache[ent] = entCache
    end

    local cached = entCache.bones[boneName]
    if cached ~= nil then return cached ~= false and cached or nil end

    local idx = ent.LookupBone and ent:LookupBone(boneName) or nil
    entCache.bones[boneName] = idx or false
    return idx
end

local function NativeLayerRecursiveChildren(ent, bone, out)
    local children = ent:GetChildBones(bone)
    if not children then return end
    for i = 1, #children do
        local child = children[i]
        out[#out + 1] = child
        NativeLayerRecursiveChildren(ent, child, out)
    end
end

local function NativeLayerGetChildren(ent, bone, mode)
    mode = tonumber(mode) or 2
    if mode <= 0 then return nil end

    local mdl = ent:GetModel() or ""
    local modelCache = TPIKNativeLayerChildCache[mdl]
    if not modelCache then
        modelCache = {}
        TPIKNativeLayerChildCache[mdl] = modelCache
    end

    local key = tostring(bone) .. ":" .. tostring(mode)
    local cached = modelCache[key]
    if cached then return cached end

    local children = {}
    local direct = ent:GetChildBones(bone) or {}
    if mode == 1 then
        for i = 1, #direct do children[#children + 1] = direct[i] end
    else
        NativeLayerRecursiveChildren(ent, bone, children)
    end

    modelCache[key] = children
    return children
end

local function NativeLayerMoveBoneWithChildren(ent, bone, newMatrix, childMode)
    if not IsValid(ent) or not bone or bone < 0 or not newMatrix then return end

    local oldMatrix = entityGetBoneMatrix(ent, bone)
    if not oldMatrix then return end

    local inv = oldMatrix:GetInverse()
    if not inv then return end

    local delta = newMatrix * inv
    local children = NativeLayerGetChildren(ent, bone, childMode)
    if children then
        for i = 1, #children do
            local child = children[i]
            local mat = entityGetBoneMatrix(ent, child)
            if mat then
                local moved = delta * mat
                entitySetBoneMatrix(ent, child, moved)
                ent:SetBonePosition(child, moved:GetTranslation(), moved:GetAngles())
            end
        end
    end

    entitySetBoneMatrix(ent, bone, newMatrix)
    ent:SetBonePosition(bone, newMatrix:GetTranslation(), newMatrix:GetAngles())
end

local function NativeLayerNormalizeBoneEntry(entry)
    if not istable(entry) then return nil end
    local boneName = entry.bone or entry.name or entry.Bone or entry.BoneName or entry[1]
    if not boneName then return nil end
    return {
        bone = boneName,
        pos = NativeLayerCopyVec(entry.pos or entry.Pos or entry.position or entry.Position or entry[2]),
        ang = NativeLayerCopyAng(entry.ang or entry.Ang or entry.angle or entry.Angle or entry.rot or entry.Rot or entry[3]),
        weight = tonumber(entry.weight or entry.Weight or entry.w) or 1,
        childMode = entry.childMode or entry.ChildMode
    }
end

local function NativeLayerCollectAdvancedBones(layer)
    if not istable(layer) then return nil end
    local src = layer.advancedBones or layer.AdvancedBones or layer.bones or layer.Bones
    if not istable(src) then return nil end

    local out = {}
    for key, value in pairs(src) do
        local entry
        if isstring(key) and istable(value) then
            entry = table.Copy(value)
            entry.bone = entry.bone or key
        elseif istable(value) then
            entry = value
        end

        local normalized = NativeLayerNormalizeBoneEntry(entry)
        if normalized then out[#out + 1] = normalized end
    end

    return out
end

local function NativeLayerEnsureStore(wep)
    if not IsValid(wep) then return nil end
    wep.ARC9_TPIKPoseLayers = wep.ARC9_TPIKPoseLayers or {}
    return wep.ARC9_TPIKPoseLayers
end

local function TPIKAPI_AddPoseLayer(wep, id, data)
    if not IsValid(wep) or id == nil or not istable(data) then return false end
    local layers = NativeLayerEnsureStore(wep)
    if not layers then return false end

    local key = tostring(id)
    local layer = table.Copy(data)
    layer.id = key
    layer.weight = tonumber(layer.weight or layer.Weight) or 1
    layer.targetWeight = tonumber(layer.targetWeight or layer.TargetWeight) or layer.weight
    layer.currentWeight = tonumber(layer.currentWeight or layer.CurrentWeight) or 0
    layer.speed = tonumber(layer.speed or layer.Speed) or (arc9_tpik_native_layer_speed and arc9_tpik_native_layer_speed:GetFloat() or 14)
    layer.removeWhenZero = layer.removeWhenZero == true
    layers[key] = layer
    return true
end

local function TPIKAPI_RemovePoseLayer(wep, id, fadeTime)
    if not IsValid(wep) or id == nil or not istable(wep.ARC9_TPIKPoseLayers) then return false end
    local layer = wep.ARC9_TPIKPoseLayers[tostring(id)]
    if not layer then return false end

    if fadeTime and fadeTime > 0 then
        layer.targetWeight = 0
        layer.speed = math.max(1 / fadeTime, 1)
        layer.removeWhenZero = true
    else
        wep.ARC9_TPIKPoseLayers[tostring(id)] = nil
    end

    return true
end

local function TPIKAPI_SetPoseLayerWeight(wep, id, weight, speed)
    if not IsValid(wep) or id == nil then return false end
    local layers = NativeLayerEnsureStore(wep)
    local key = tostring(id)
    local layer = layers[key]
    if not layer then
        layer = { id = key, currentWeight = 0, targetWeight = tonumber(weight) or 0, weight = tonumber(weight) or 0 }
        layers[key] = layer
    end
    layer.targetWeight = math.Clamp(tonumber(weight) or 0, 0, 1)
    layer.weight = layer.targetWeight
    if speed then layer.speed = tonumber(speed) or layer.speed end
    return true
end

local function TPIKAPI_ClearPoseLayers(wep)
    if not IsValid(wep) then return false end
    wep.ARC9_TPIKPoseLayers = nil
    return true
end

local function TPIKAPI_GetPoseLayers(wep)
    if not IsValid(wep) then return nil end
    return wep.ARC9_TPIKPoseLayers
end

local function NativeLayerBlendWeight(layer, dt)
    local target = math.Clamp(tonumber(layer.targetWeight or layer.weight) or 0, 0, 1)
    local current = tonumber(layer.currentWeight) or 0
    local speed = tonumber(layer.speed) or (arc9_tpik_native_layer_speed and arc9_tpik_native_layer_speed:GetFloat() or 14)
    local alpha = math.Clamp((dt or FrameTime()) * speed, 0, 1)
    current = Lerp(alpha, current, target)
    if math.abs(current - target) < 0.001 then current = target end
    layer.currentWeight = current
    return current
end

local function NativeLayerAddBone(accum, bone, pos, ang, weight, childMode)
    if not bone or weight <= 0 then return end
    local item = accum[bone]
    if not item then
        item = { pos = Vector(0, 0, 0), ang = Angle(0, 0, 0), weight = 0, childMode = childMode }
        accum[bone] = item
    end

    item.pos:Add(pos * weight)
    item.ang.p = item.ang.p + (ang.p or 0) * weight
    item.ang.y = item.ang.y + (ang.y or 0) * weight
    item.ang.r = item.ang.r + (ang.r or 0) * weight
    item.weight = item.weight + weight
    item.childMode = childMode or item.childMode
end

local function TPIKAPI_ApplyNativePoseLayers(wep, ply, wm, targets)
    if not arc9_tpik_native_pose_layers or not arc9_tpik_native_pose_layers:GetBool() then return end
    if not arc9_tpik_native_advanced_bones or not arc9_tpik_native_advanced_bones:GetBool() then return end
    if not IsValid(wep) or not IsValid(ply) or not istable(wep.ARC9_TPIKPoseLayers) then return end

    local dt = FrameTime()
    local accum = {}
    local remove = nil

    for id, layer in pairs(wep.ARC9_TPIKPoseLayers) do
        if not istable(layer) then continue end
        local w = NativeLayerBlendWeight(layer, dt)
        if layer.removeWhenZero and w <= 0 then
            remove = remove or {}
            remove[#remove + 1] = id
            continue
        end
        if w <= 0 then continue end

        local bones = NativeLayerCollectAdvancedBones(layer)
        if not bones then continue end
        for i = 1, #bones do
            local b = bones[i]
            local bw = math.Clamp((tonumber(b.weight) or 1) * w, 0, 1)
            NativeLayerAddBone(accum, b.bone, b.pos, b.ang, bw, b.childMode or layer.childMode)
        end
    end

    if remove then
        for i = 1, #remove do wep.ARC9_TPIKPoseLayers[remove[i]] = nil end
    end

    local defaultChildMode = arc9_tpik_native_advanced_child_mode and arc9_tpik_native_advanced_child_mode:GetInt() or 2
    for boneName, item in pairs(accum) do
        if item.weight <= 0 then continue end
        local bone = NativeLayerGetBoneIndex(ply, boneName)
        if not bone then continue end

        local base = entityGetBoneMatrix(ply, bone)
        if not base then continue end

        local pos = item.pos
        local ang = item.ang
        if item.weight > 1 then
            pos = pos / item.weight
            ang = Angle(ang.p / item.weight, ang.y / item.weight, ang.r / item.weight)
        end

        if NativeLayerIsZeroVec(pos) and NativeLayerIsZeroAng(ang) then continue end

        local offset = Matrix()
        offset:SetTranslation(pos)
        offset:SetAngles(ang)

        local final = base * offset
        NativeLayerMoveBoneWithChildren(ply, bone, final, tonumber(item.childMode) or defaultChildMode)
    end
end

ARC9.TPIK.NativeExtensionPoints = true
ARC9.TPIK.GetTemporaryIKOverride = TPIKAPI_GetTemporaryIKOverride
ARC9.TPIK.GetCurrentArmState = TPIKAPI_GetCurrentArmState
ARC9.TPIK.GetIKTargets = TPIKAPI_GetIKTargets
ARC9.TPIK.SetTemporaryIKOverride = TPIKAPI_SetTemporaryIKOverride
ARC9.TPIK.SuppressHandIK = TPIKAPI_SuppressHandIK
ARC9.TPIK.GetSafeModeState = TPIKAPI_GetSafeModeState
ARC9.TPIK.GetSprintState = TPIKAPI_GetSprintState
ARC9.TPIK.AddPoseLayer = TPIKAPI_AddPoseLayer
ARC9.TPIK.RemovePoseLayer = TPIKAPI_RemovePoseLayer
ARC9.TPIK.SetPoseLayerWeight = TPIKAPI_SetPoseLayerWeight
ARC9.TPIK.ClearPoseLayers = TPIKAPI_ClearPoseLayers
ARC9.TPIK.GetPoseLayers = TPIKAPI_GetPoseLayers
ARC9.TPIK.ApplyNativePoseLayers = TPIKAPI_ApplyNativePoseLayers
ARC9.TPIK.NativePoseLayers = true


local function SetTPIKOffset(self, wm, owner, lp)
    local pos, ang = Vector(self.WorldModelOffset.TPIKPos or self.WorldModelOffset.Pos),
        Angle(self.WorldModelOffset.TPIKAng or self.WorldModelOffset.Ang) -- how come you don't have tpikpos in 2025
    local sightdelta = self:GetSightAmount()

    if self.WorldModelOffset.TPIKPosAlternative and self:GetValue("TPIKAlternativePos") then
        pos = Vector(self.WorldModelOffset.TPIKPosAlternative)
    end

    if self.WorldModelOffset.TPIKPosSightOffset then
        if sightdelta > 0 then -- sight offset
            local sightdelta2 = math.ease.InOutCubic(sightdelta)
            pos:Add(self.WorldModelOffset.TPIKPosSightOffset * sightdelta2)
            ang:Add(someangforsights * math.sin(3.1415926 * math.ease.InOutSine(sightdelta)))
        end

        if self.WorldModelOffset.TPIKPosReloadOffset then
            local fuckingreloadprocessinfluence = self:GetReloadingProgress()
            if fuckingreloadprocessinfluence > 0 then
                pos:Add(self.WorldModelOffset.TPIKPosReloadOffset * fuckingreloadprocessinfluence)
                ang:Add(self.WorldModelOffset.TPIKAngReloadOffset * fuckingreloadprocessinfluence)
            end
        end
    end

    local ht = self:GetHoldType()

    if ! DynamicHeightTwo then -- Dynamic height 2 breaks crouching 👍
        local viewOffsetZ = owner:GetViewOffset().z
        local crouchdelta = math.Clamp(
            (viewOffsetZ - owner:GetCurrentViewOffset().z) / (viewOffsetZ - owner:GetViewOffsetDucked().z), 0, 1)
        if ht == "revolver" then
            crouchdelta = crouchdelta * -2
        elseif ht == "ar2" or ht == "smg" then
            crouchdelta = crouchdelta * -1
        end
        if owner.IsProne and owner:IsProne() then crouchdelta = 1 end
        if HasCustomOffset("crouch") then pos:Add(GetCustomOffset("crouch") * crouchdelta) end
    end

    do -- holdtype offsets
        self.TPIKSmoothPassiveHoldType = Lerp(FrameTime() * 1, self.TPIKSmoothPassiveHoldType or 0,
            ht == "passive" and 1 or 0)
        pos:Add(GetCustomOffset("passive") * self.TPIKSmoothPassiveHoldType)
        self.TPIKSmoothNormalHoldType = Lerp(FrameTime() * 1, self.TPIKSmoothNormalHoldType or 0,
            ht == "normal" and 1 or 0)
        pos:Add(GetCustomOffset("normal") * self.TPIKSmoothNormalHoldType)

        if self.WorldModelOffset.TPIKHolsterOffset then
            pos:Add(self.WorldModelOffset.TPIKHolsterOffset *
                math.max(self.TPIKSmoothPassiveHoldType, self.TPIKSmoothNormalHoldType))
        end

        if HasCustomOffset("revolver") then
            self.TPIKSmoothRevolverHoldType = Lerp(FrameTime() * 1, self.TPIKSmoothRevolverHoldType or 0,
                ht == "revolver" and 1 or 0)
            pos:Add(GetCustomOffset("revolver") * self.TPIKSmoothRevolverHoldType)
        end

        if HasCustomOffset("active") then pos:Add(GetCustomOffset("active")) end
    end

    do -- nearwalling
        local nearwalldelta = self:GetNearWallAmount()

        if nearwalldelta > 0 and ht != "passive" and ht != "normal" then
            nearwalldelta = math.ease.InOutQuad(nearwalldelta) - self.CustomizeDelta
            pos:Add(nearwallpos * nearwalldelta)
            ang:Add(nearwallang * nearwalldelta)
        end
    end

    if ! self.NoTPIKVMPos then -- and ht != "passive"
        if self.CustomizeDelta == 0 then
            -- if lp == owner then -- old
            --     pos:Sub(self.ViewModelPos * activeposvector)
            --     ang:Add(Angle(self.ViewModelAng.p, -self.ViewModelAng.y, self.ViewModelAng.r))
            -- else
            local apos = Vector(self.ActivePos.y, -self.ActivePos.x, self.ActivePos.z) * activeposvector
            pos:Sub(apos)


            if sightdelta > 0 then -- fake sights
                local sightdelta2 = math.ease.InOutCubic(sightdelta)
                local ispos = Vector(self.IronSights.Pos.x * -0.1, self.IronSights.Pos.y * 0.4,
                    self.IronSights.Pos.z * 1.5)
                pos:Sub(ispos * sightdelta2)
                ang:Add(someangforsights * math.sin(3.1415926 * math.ease.InOutSine(sightdelta)))
            end
            -- end
        else
            pos:Add(GetCustomOffset("customization") * self.CustomizeDelta)
        end
    end

    if lp == owner then -- peeking is clientside
        self.PeekingSmooth = Lerp(FrameTime() * 2, self.PeekingSmooth or 0, self.Peeking and 1 or 0)
        if self.PeekingSmooth > 0.1 then
            pos:Add(peekvector * sightdelta * self.PeekingSmooth)
            ang:Add(self.PeekAng * sightdelta * self.PeekingSmooth)
        end

        if self.EFTErgo then -- only eft cuz this is not ideal
            -- visual recoil, cuz we don't add vm pos anymore
            local vrp, vra = self:GetVisualRecoilPos(), self:GetVisualRecoilAng() * 2.5
            self.TPIKSmoothRecoilPos = LerpVector(FrameTime() * 1, self.TPIKSmoothRecoilPos or vrp,
                Vector(-vrp.y, vrp.x, vrp.z * -10))
            self.TPIKSmoothRecoilAng = LerpVector(FrameTime() * 1, self.TPIKSmoothRecoilAng or vra, vra)
            pos:Sub(self.TPIKSmoothRecoilPos)
            ang:Add(Angle(-self.TPIKSmoothRecoilAng.x, self.TPIKSmoothRecoilAng.y, self.TPIKSmoothRecoilAng.z))
        end
    end

    wm.slottbl.Pos = pos
    wm.slottbl.Ang = ang
end

function SWEP:ShouldTPIK()
    if self.NoTPIK or forcednotpik then return end
    local owner = self:GetOwner()
    local lp = LocalPlayer()

    if render.GetDXLevel() < 90 then return end
    if ! owner:IsPlayer() then return end
    if owner:IsPlayingTaunt() then return end
    if owner:InVehicle() and ! owner:GetAllowWeaponsInVehicle() then return end
    if owner.ARC9_HoldingProp then return end
    if ! self.MirrorVMWM then return end
    if self:ShouldLOD() == 2 then return end
    -- if self:GetSafe() then return end
    -- if self:GetBlindFireAmount() > 0 then return false end
    -- if lp == owner and !owner:ShouldDrawLocalPlayer() then return end -- it's going to fix the mirrors and this shit get run anyway
    -- if !arc9_tpik:GetBool() then return false end

    local should = false

    if lp != owner then
        should = arc9_tpik:GetBool() and arc9_tpik_others:GetBool()
    else
        should = arc9_tpik:GetBool()
    end

    if self:RunHook("Hook_BlockTPIK") then should = false end

    local wm = self:GetWM()
    if IsValid(wm) and wm.slottbl then
        if ! should then
            wm.slottbl.Pos = self.WorldModelOffset.Pos
            wm.slottbl.Ang = self.WorldModelOffset.Ang
        else
            SetTPIKOffset(self, wm, owner, lp)
        end
    end

    return should
end

SWEP.TPIKCache = {}
SWEP.LastTPIKTime = 0

local cachelastcycle = 0 -- probably bad

local function TPIKIKTweenAlpha(speed)
    speed = math.Clamp(speed * 1.5, 1, 60)
    local ft = RealFrameTime()
    return math.Clamp(1 - math.exp(-speed * ft), 0, 1)
end

local TPIK_EPS = 0.0001

local function TPIKVecAlmostEqual(a, b)
    return a and b
        and math.abs(a.x - b.x) <= TPIK_EPS
        and math.abs(a.y - b.y) <= TPIK_EPS
        and math.abs(a.z - b.z) <= TPIK_EPS
end

local function TPIKAngAlmostEqual(a, b)
    return a and b
        and math.abs(a.p - b.p) <= TPIK_EPS
        and math.abs(a.y - b.y) <= TPIK_EPS
        and math.abs(a.r - b.r) <= TPIK_EPS
end

local function TPIKCopyVec(dst, src)
    dst.x = src.x
    dst.y = src.y
    dst.z = src.z
    return dst
end

local function TPIKCopyAng(dst, src)
    dst.p = src.p
    dst.y = src.y
    dst.r = src.r
    return dst
end

local function TPIKTweenVec(self, key, target, alpha)
    local tweenCache = self.TPIKIKTweenCache or {}
    self.TPIKIKTweenCache = tweenCache
    local cache = tweenCache
    local cache = self.TPIKIKTweenCache
    local current = cache[key]

    if not current then
        current = Vector(target.x, target.y, target.z)
        cache[key] = current
        return current
    end

    -- If the cached output is already the same as the target, do nothing.
    -- This avoids pointless LerpVector allocations on frames where the IK target did not change.
    if TPIKVecAlmostEqual(current, target) then return current end

    if alpha >= 1 then
        return TPIKCopyVec(current, target)
    end

    current.x = current.x + (target.x - current.x) * alpha
    current.y = current.y + (target.y - current.y) * alpha
    current.z = current.z + (target.z - current.z) * alpha

    -- if TPIKVecAlmostEqual(current, target) then
    --     return TPIKCopyVec(current, target)
    -- end

    return current
end

local function TPIKTweenAng(self, key, target, alpha)
    if not target then return target end
    local tweenCache = self.TPIKIKTweenCache or {}
    self.TPIKIKTweenCache = tweenCache
    local cache = tweenCache
    local current = cache[key]

    if not current then
        current = Angle(target.p, target.y, target.r)
        cache[key] = current
        return current
    end

    -- Same as vectors: skip smoothing work when the cached output already reached the target.
    if TPIKAngAlmostEqual(current, target) then return current end

    if alpha >= 1 then
        return TPIKCopyAng(current, target)
    end

    current.p = current.p + math.AngleDifference(target.p, current.p) * alpha
    current.y = current.y + math.AngleDifference(target.y, current.y) * alpha
    current.r = current.r + math.AngleDifference(target.r, current.r) * alpha

    -- if TPIKAngAlmostEqual(current, target) then
    --     return TPIKCopyAng(current, target)
    -- end

    return current
end


-- local headcontrol = {"ValveBiped.Bip01_Neck1", "ValveBiped.Bip01_Head1"}

function SWEP:DoTPIK()
    local wm = self:GetWM()

    if ! IsValid(wm) then return end

    local everythingfucked = false

    if wm:GetPos():IsZero() and self.wmnormalpos then -- VERY STUPID BUT SetupModel() on wm makes wm go to 0 0 0 BUT ONLY ON CERTAIN PLAYERMODELS???????
        wm:SetPos(self.wmnormalpos)
        wm:SetAngles(self.wmnormalang)
        everythingfucked = true
    else
        self.wmnormalpos = wm:GetPos()
        self.wmnormalang = wm:GetAngles()
    end

    if ! self:ShouldTPIK() then
        if cachelastcycle > 0 then
            wm:SetCycle(0)
            cachelastcycle = 0
        end
        return
    end

    local ply = self:GetOwner()

    local tpikdelay = 0

    local lod

    if ply == LocalPlayer() then
        local localtpiktime = math.Clamp(arc9_tpik_framerate_you:GetInt() or 60, 10, 150)
        tpikdelay = 1 / localtpiktime
    else
        local dist = EyePos():DistToSqr(ply:GetPos())
        local convartpiktime = math.Clamp(arc9_tpik_framerate_notyou:GetInt() or 20, 5, 150)
        tpikdelay = 1 / convartpiktime

        lod = self:ShouldLOD()

        if lod == 1 then
            tpikdelay = math.max(0.05, tpikdelay) -- max 20 fps if lodding
        elseif lod == 1.5 then
            tpikdelay = math.max(0.1, tpikdelay)
        end
    end

    local shouldfulltpik = true

    if self.LastTPIKTime + tpikdelay > CurTime() then
        shouldfulltpik = false
    end

    if not shouldfulltpik
        and arc9_tpik_helper_bone_force_full_fps
        and arc9_tpik_helper_bone_force_full_fps:GetBool()
        and TPIKHelperHasCachedRoots(ply) then
        shouldfulltpik = true
    end

    local tpikTweenAlpha = TPIKIKTweenAlpha(1 / tpikdelay)

    local nolefthand = false

    local htype = self:GetHoldType()

    local preResult = hook.Run("ARC9_TPIK_PreSolve", self, ply, wm, {
        holdtype = htype,
        shouldFullTPIK = shouldfulltpik,
        tpikDelay = tpikdelay,
        lod = lod
    })
    if preResult == true then return end

    if ! self.TPIKforcelefthand and ! self.NotAWeapon and ! (self:GetReloading() and ! self.TPIKforcenoreload) and (htype == "slam" or htype == "magic" or htype == "pistol" or htype == "normal" or self.TPIKnolefthand) then
        nolefthand = true
    end

    if ply:IsTyping() then nolefthand = true end
    if ply:GetNW2Int("CurrentCustomGesture", 0) > 0 then nolefthand = true end -- custom thing

    local tpikOverride = TPIKAPI_GetTemporaryOverride(self)
    local tpikNoRightHand = false
    if tpikOverride then
        if tpikOverride.forceLeftHand == true then nolefthand = false end
        if tpikOverride.noLeftHand ~= nil then nolefthand = tpikOverride.noLeftHand == true end
        if tpikOverride.suppressLeftHand == true then nolefthand = true end
        tpikNoRightHand = tpikOverride.noRightHand == true or tpikOverride.suppressRightHand == true
    end

    hook.Run("ARC9_TPIK_StateReady", self, ply, wm, {
        holdtype = htype,
        noLeftHand = nolefthand,
        noRightHand = tpikNoRightHand,
        override = tpikOverride
    })

    if shouldfulltpik or self:StillWaiting() then
        wm:SetupBones()

        local time = self:GetSequenceCycle()
        local seq = self:GetSequenceIndex()

        local seqCache = self.TPIKSequenceCache
        local wmModel = wm:GetModel() or ""
        if not seqCache or seqCache.model ~= wmModel then
            seqCache = {
                model = wmModel,
                idle = wm:LookupSequence("idle"),
                draw = wm:LookupSequence("draw"),
                holster = wm:LookupSequence("holster")
            }
            self.TPIKSequenceCache = seqCache
        end

        if self:GetSequenceProxy() != 0 then seq = seqCache.idle end                    -- lhik ubgls fix

        if self.TPIKNoSprintAnim and self:GetIsSprinting() then seq = seqCache.idle end -- no sprint anim in tpik (less ugly)
        if (htype == "normal" or htype == "passive") and (seq == seqCache.draw or seq == seqCache.holster) then
            seq =
                seqCache.idle
        end -- no draw/holster with some holdtypes. bad code but whatever.

        wm:SetSequence(seq)

        wm:SetCycle(time)
        cachelastcycle = time

        wm:InvalidateBoneCache()
    end

    self:SetFiremodePose(true)

    if !everythingfucked then self:DoRHIK(true) end

    ply:SetupBones()

    local tpikHelperCapturedLocals = nil
    if not TPIKHelperBonePatchRuntimeDisabled then
        local ok, capturedOrErr = pcall(CaptureTPIKHelperBoneLocals, ply)
        if ok then
            tpikHelperCapturedLocals = capturedOrErr
        else
            DisableHelperBonePatchAfterError(capturedOrErr)
        end
    end

    local bones = ARC9.TPIKBones

    if nolefthand then
        bones = ARC9.RHIKHandBones
    end

    if lod == 1.5 then -- hackkkkk
        bones = ARC9.LHIKHandBones
    end

    local ply_spine_index = GetCachedBoneIndex(ply, "ValveBiped.Bip01_Spine4")
    if ! ply_spine_index then return end
    local ply_spine_matrix = entityGetBoneMatrix(ply, ply_spine_index)
    local wmpos = ply_spine_matrix:GetTranslation()

    -- local headcam = self:GetCameraControl(wm)
    -- if IsValid(headcam) then
    --     for _, bone in ipairs(headcontrol) do
    --         local ply_boneindex = GetCachedBoneIndex(ply, bone)
    --         if !ply_boneindex then continue end
    --         local ply_bonematrix = entityGetBoneMatrix(ply, ply_boneindex)
    --         if !ply_bonematrix then continue end

    --         local boneang = ply_bonematrix:GetAngles()
    --         boneang:Add(headcam)

    --         ply_bonematrix:SetAngles(boneang)

    --         entitySetBoneMatrix(ply, ply_boneindex, ply_bonematrix)
    --     end
    -- end

    local sightdelta = self:GetSightAmount()
    -- local reloadprogress = math.max(0, self:GetReloadingProgress() - sightdelta)
    self.TPIKReloadProgressSmooth = Lerp(FrameTime() * 10, self.TPIKReloadProgressSmooth or 0,
        self:GetReloading() and 1 - sightdelta or 0)

    if sightdelta > 0 or self.TPIKReloadProgressSmooth > 0.12 then
        local ply_boneindex = GetCachedBoneIndex(ply, "ValveBiped.Bip01_Head1")
        if ply_boneindex then
            if GetCachedHeadChildCount(ply, ply_boneindex) < 2 then -- dont move if more than 1 child bone on head
                local ply_bonematrix = entityGetBoneMatrix(ply, ply_boneindex)
                if ply_bonematrix then
                    local boneang = ply_bonematrix:GetAngles()

                    boneang:Add(Angle(5, -15, 15) * sightdelta + Angle(9, -5, -2) * self.TPIKReloadProgressSmooth)

                    ply_bonematrix:SetAngles(boneang)

                    entitySetBoneMatrix(ply, ply_boneindex, ply_bonematrix)
                end
            end
        end
    end

    for _, bone in ipairs(bones) do
        local wm_boneindex = GetCachedBoneIndex(wm, bone)
        if ! wm_boneindex then continue end
        local wm_bonematrix = entityGetBoneMatrix(wm, wm_boneindex)
        if ! wm_bonematrix then continue end

        local ply_boneindex = GetCachedBoneIndex(ply, bone)
        if ! ply_boneindex then continue end
        local ply_bonematrix = entityGetBoneMatrix(ply, ply_boneindex)
        if ! ply_bonematrix then continue end

        local bonepos = wm_bonematrix:GetTranslation()
        local boneang = wm_bonematrix:GetAngles()

        bonepos.x = math.Clamp(bonepos.x, wmpos.x - 38, wmpos.x + 38) -- clamping if something gone wrong so no stretching (or animator is fleshy)
        bonepos.y = math.Clamp(bonepos.y, wmpos.y - 38, wmpos.y + 38)
        bonepos.z = math.Clamp(bonepos.z, wmpos.z - 38, wmpos.z + 38)

        ply_bonematrix:SetTranslation(bonepos)
        ply_bonematrix:SetAngles(boneang)

        entitySetBoneMatrix(ply, ply_boneindex, ply_bonematrix)
        ply:SetBonePosition(ply_boneindex, bonepos, boneang)
    end

    local ply_l_upperarm_index = GetCachedBoneIndex(ply, "ValveBiped.Bip01_L_UpperArm")
    local ply_r_upperarm_index = GetCachedBoneIndex(ply, "ValveBiped.Bip01_R_UpperArm")
    local ply_l_forearm_index = GetCachedBoneIndex(ply, "ValveBiped.Bip01_L_Forearm")
    local ply_r_forearm_index = GetCachedBoneIndex(ply, "ValveBiped.Bip01_R_Forearm")
    local ply_l_hand_index = GetCachedBoneIndex(ply, "ValveBiped.Bip01_L_Hand")
    local ply_r_hand_index = GetCachedBoneIndex(ply, "ValveBiped.Bip01_R_Hand")

    if ! ply_l_upperarm_index then return end
    if ! ply_r_upperarm_index then return end
    if ! ply_l_forearm_index then return end
    if ! ply_r_forearm_index then return end
    if ! ply_l_hand_index then return end
    if ! ply_r_hand_index then return end

    local ply_r_upperarm_matrix = entityGetBoneMatrix(ply, ply_r_upperarm_index)
    local ply_r_forearm_matrix = entityGetBoneMatrix(ply, ply_r_forearm_index)
    local ply_r_hand_matrix = entityGetBoneMatrix(ply, ply_r_hand_index)

    local boneLengthCache = self.TPIKBoneLengthCache
    local plyModel = ply:GetModel() or ""
    if not boneLengthCache or boneLengthCache.model ~= plyModel or boneLengthCache.forearmIndex ~= ply_l_forearm_index then
        local limblength = ply:BoneLength(ply_l_forearm_index)
        if ! limblength or limblength == 0 then limblength = 12 end
        boneLengthCache = { model = plyModel, forearmIndex = ply_l_forearm_index, length = limblength }
        self.TPIKBoneLengthCache = boneLengthCache
    end

    local limblength = boneLengthCache.length or 12
    local r_upperarm_length = limblength
    local r_forearm_length = limblength
    local l_upperarm_length = limblength
    local l_forearm_length = limblength

    local ply_r_upperarm_pos, ply_r_forearm_pos, ply_r_upperarm_angle, ply_r_forearm_angle

    local eyeahg = ply:EyeAngles()

    if htype == "passive" or htype == "normal" then -- passive holdtype doesn't follow eyeang
        eyeahg.y = eyeahg.y - (ply:GetPoseParameter("aim_yaw") or 0) * 160 + 80 or 0
    end

    if shouldfulltpik or ! (self.TPIKCache.r_upperarm_pos and self.TPIKCache.r_forearm_pos and self.TPIKCache.ply_r_upperarm_angle and self.TPIKCache.ply_r_forearm_angle) then
        ply_r_upperarm_pos, ply_r_forearm_pos, ply_r_upperarm_angle, ply_r_forearm_angle = self:Solve2PartIK(
            ply_r_upperarm_matrix:GetTranslation(), ply_r_hand_matrix:GetTranslation(), r_upperarm_length,
            r_forearm_length,
            -1.3, eyeahg)
        self.LastTPIKTime = CurTime()

        self.TPIKCache.r_upperarm_pos, self.TPIKCache.ply_r_upperarm_angle = WorldToLocal(ply_r_upperarm_pos,
            ply_r_upperarm_angle, ply_r_upperarm_matrix:GetTranslation(), ply_r_upperarm_matrix:GetAngles())
        self.TPIKCache.r_forearm_pos, self.TPIKCache.ply_r_forearm_angle = WorldToLocal(ply_r_forearm_pos,
            ply_r_forearm_angle, ply_r_upperarm_matrix:GetTranslation(), ply_r_upperarm_matrix:GetAngles())
    end

    local rUpperPos = TPIKTweenVec(self, "r_upperarm_pos", self.TPIKCache.r_upperarm_pos, tpikTweenAlpha)
    local rUpperAng = TPIKTweenAng(self, "r_upperarm_ang", self.TPIKCache.ply_r_upperarm_angle, tpikTweenAlpha)
    local rForePos = TPIKTweenVec(self, "r_forearm_pos", self.TPIKCache.r_forearm_pos, tpikTweenAlpha)
    local rForeAng = TPIKTweenAng(self, "r_forearm_ang", self.TPIKCache.ply_r_forearm_angle, tpikTweenAlpha)

    ply_r_upperarm_pos, ply_r_upperarm_angle = LocalToWorld(rUpperPos, rUpperAng, ply_r_upperarm_matrix:GetTranslation(),
        ply_r_upperarm_matrix:GetAngles())
    ply_r_forearm_pos, ply_r_forearm_angle = LocalToWorld(rForePos, rForeAng, ply_r_upperarm_matrix:GetTranslation(),
        ply_r_upperarm_matrix:GetAngles())

    -- play rain world!!!

    -- if ARC9.Dev(2) then
    -- debugoverlay.Line(ply_r_upperarm_matrix:GetTranslation(), ply_r_upperarm_pos, 0.1)
    -- debugoverlay.Line(ply_r_upperarm_pos, ply_r_forearm_pos, 0.1)
    -- debugoverlay.Line(ply_r_forearm_pos, ply_r_hand_matrix:GetTranslation(), 0.1)
    -- end

    ply_r_upperarm_matrix:SetAngles(ply_r_upperarm_angle)
    ply_r_forearm_matrix:SetTranslation(ply_r_upperarm_pos)
    ply_r_forearm_matrix:SetAngles(ply_r_forearm_angle)
    ply_r_hand_matrix:SetTranslation(ply_r_forearm_pos) -- weird shit with left hand??? idk cant figure, here's a bandaid

    self.ARC9_TPIKLastIKTargets = {
        owner = ply,
        weapon = self,
        holdtype = htype,
        right = {
            upperarm = { index = ply_r_upperarm_index, matrix = Matrix(ply_r_upperarm_matrix) },
            forearm = { index = ply_r_forearm_index, matrix = Matrix(ply_r_forearm_matrix) },
            hand = { index = ply_r_hand_index, matrix = Matrix(ply_r_hand_matrix) }
        }
    }

    if not tpikNoRightHand then
        bone_apply_matrix(ply, ply_r_upperarm_index, ply_r_upperarm_matrix, ply_r_forearm_index)
        bone_apply_matrix(ply, ply_r_forearm_index, ply_r_forearm_matrix, ply_r_hand_index)
        bone_apply_matrix(ply, ply_r_hand_index, ply_r_hand_matrix)
    end

    if nolefthand then
        if tpikHelperCapturedLocals then
            local ok, err = pcall(ApplyTPIKHelperBoneLocals, ply, tpikHelperCapturedLocals)
            if not ok then DisableHelperBonePatchAfterError(err) end
        end
        TPIKAPI_ApplyNativePoseLayers(self, ply, wm, self.ARC9_TPIKLastIKTargets)
        hook.Run("ARC9_TPIK_PostSolve", self, ply, wm, self.ARC9_TPIKLastIKTargets)
        return
    end

    local ply_l_upperarm_matrix = entityGetBoneMatrix(ply, ply_l_upperarm_index)
    local ply_l_forearm_matrix = entityGetBoneMatrix(ply, ply_l_forearm_index)
    local ply_l_hand_matrix = entityGetBoneMatrix(ply, ply_l_hand_index)

    -- local ply_r_upperarm_pos = ply:LocalToWorld(self.TPIKCache.r_upperarm_pos)
    -- local ply_r_forearm_pos = ply:LocalToWorld(self.TPIKCache.r_forearm_pos)

    -- if shouldfulltpik then
    --     ply_r_upperarm_pos, ply_r_forearm_pos = self:Solve2PartIK(ply_r_upperarm_matrix:GetTranslation(), ply_r_hand_matrix:GetTranslation(), r_upperarm_length, r_forearm_length, -35)
    --     self.LastTPIKTime = CurTime()

    --     self.TPIKCache.r_upperarm_pos = ply:WorldToLocal(ply_r_upperarm_pos)
    --     self.TPIKCache.r_forearm_pos = ply:WorldToLocal(ply_r_forearm_pos)
    -- end

    local ply_l_upperarm_pos, ply_l_forearm_pos, ply_l_upperarm_angle, ply_l_forearm_angle

    if shouldfulltpik or ! (self.TPIKCache.l_upperarm_pos and self.TPIKCache.l_forearm_pos and self.TPIKCache.ply_l_upperarm_angle and self.TPIKCache.ply_l_forearm_angle) then
        ply_l_upperarm_pos, ply_l_forearm_pos, ply_l_upperarm_angle, ply_l_forearm_angle = self:Solve2PartIK(
            ply_l_upperarm_matrix:GetTranslation(), ply_l_hand_matrix:GetTranslation(), l_upperarm_length,
            l_forearm_length,
            1, eyeahg)

        self.LastTPIKTime = CurTime()
        self.TPIKCache.l_upperarm_pos, self.TPIKCache.ply_l_upperarm_angle = WorldToLocal(ply_l_upperarm_pos,
            ply_l_upperarm_angle, ply_l_upperarm_matrix:GetTranslation(), ply_l_upperarm_matrix:GetAngles())
        self.TPIKCache.l_forearm_pos, self.TPIKCache.ply_l_forearm_angle = WorldToLocal(ply_l_forearm_pos,
            ply_l_forearm_angle, ply_l_upperarm_matrix:GetTranslation(), ply_l_upperarm_matrix:GetAngles())
    end

    local lUpperPos = TPIKTweenVec(self, "l_upperarm_pos", self.TPIKCache.l_upperarm_pos, tpikTweenAlpha)
    local lUpperAng = TPIKTweenAng(self, "l_upperarm_ang", self.TPIKCache.ply_l_upperarm_angle, tpikTweenAlpha)
    local lForePos = TPIKTweenVec(self, "l_forearm_pos", self.TPIKCache.l_forearm_pos, tpikTweenAlpha)
    local lForeAng = TPIKTweenAng(self, "l_forearm_ang", self.TPIKCache.ply_l_forearm_angle, tpikTweenAlpha)

    ply_l_upperarm_pos, ply_l_upperarm_angle = LocalToWorld(lUpperPos, lUpperAng, ply_l_upperarm_matrix:GetTranslation(),
        ply_l_upperarm_matrix:GetAngles())
    ply_l_forearm_pos, ply_l_forearm_angle = LocalToWorld(lForePos, lForeAng, ply_l_upperarm_matrix:GetTranslation(),
        ply_l_upperarm_matrix:GetAngles())

    ply_l_upperarm_matrix:SetAngles(ply_l_upperarm_angle)
    ply_l_forearm_matrix:SetTranslation(ply_l_upperarm_pos)
    ply_l_forearm_matrix:SetAngles(ply_l_forearm_angle)
    ply_l_hand_matrix:SetTranslation(ply_l_forearm_pos)

    if self.ARC9_TPIKLastIKTargets then
        self.ARC9_TPIKLastIKTargets.left = {
            upperarm = { index = ply_l_upperarm_index, matrix = Matrix(ply_l_upperarm_matrix) },
            forearm = { index = ply_l_forearm_index, matrix = Matrix(ply_l_forearm_matrix) },
            hand = { index = ply_l_hand_index, matrix = Matrix(ply_l_hand_matrix) }
        }
    end

    bone_apply_matrix(ply, ply_l_upperarm_index, ply_l_upperarm_matrix, ply_l_forearm_index)
    bone_apply_matrix(ply, ply_l_forearm_index, ply_l_forearm_matrix, ply_l_hand_index)
    bone_apply_matrix(ply, ply_l_hand_index, ply_l_hand_matrix)

    if tpikHelperCapturedLocals then
        local ok, err = pcall(ApplyTPIKHelperBoneLocals, ply, tpikHelperCapturedLocals)
        if not ok then DisableHelperBonePatchAfterError(err) end
    end

    TPIKAPI_ApplyNativePoseLayers(self, ply, wm, self.ARC9_TPIKLastIKTargets)
    hook.Run("ARC9_TPIK_PostSolve", self, ply, wm, self.ARC9_TPIKLastIKTargets)
end
