ARC9.PhysBullets = {}

ARC9.PhysBulletModels = ARC9.PhysBulletModels or {}
ARC9.PhysBulletModelsLookup = ARC9.PhysBulletModelsLookup or {}

if SERVER then
    util.AddNetworkString("arc9_physbulletmodels")

    net.Receive("arc9_physbulletmodels", function(len, ply)
        if !ply.ARC9_HASPHYSBULLETMODELS then
            ARC9:SendPhysBulletModels(ply)
            ply.ARC9_HASPHYSBULLETMODELS = true
        end
    end)

    function ARC9:SendPhysBulletModels(ply)
        net.Start("arc9_physbulletmodels")
        local t = ARC9.PhysBulletModels
        local count = #t

        net.WriteUInt(count, 8)
        for i=1, count do
            net.WriteString(t[i])
        end

        if ply then
            net.Send(ply)
        else
            net.Broadcast()
        end
    end
end

function ARC9:RegisterPhysBulletModel(model)
    model = string.lower(model)
    local count = #ARC9.PhysBulletModels

    if count >= 255 then return -1 end
    if ARC9.PhysBulletModelsLookup[model] then return ARC9.PhysBulletModelsLookup[model] end
    count = count+1

    ARC9.PhysBulletModels[count] = model
    ARC9.PhysBulletModelsLookup[model] = count

    return count
end

function ARC9:SendBullet(bullet, attacker)
    net.Start("ARC9_sendbullet", true)
    net.WriteVector(bullet.Pos)
    net.WriteAngle(bullet.Vel:Angle())
    net.WriteFloat(bullet.Vel:Length())
    net.WriteFloat(bullet.Travelled)
    net.WriteFloat(bullet.Drag)
    net.WriteFloat(bullet.Gravity)
    net.WriteBool(bullet.Indirect or false)
    net.WriteEntity(bullet.Weapon)
    net.WriteUInt(bullet.ModelIndex or 0, 8)

    if attacker and attacker:IsValid() and attacker:IsPlayer() and !game.SinglePlayer() then
        net.SendOmit(attacker)
    else
        if game.SinglePlayer() then
            net.WriteEntity(attacker)
        end
        net.Broadcast()
    end
end

function ARC9:ShootPhysBullet(wep, pos, vel, tbl, pred)
    pred = pred or false

    local physmdl = wep:GetProcessedValue("PhysBulletModel", true)
    local mdlindex = ARC9.PhysBulletModelsLookup[string.lower(physmdl or "")] or 0

    if physmdl and mdlindex == 0 then
        print("\nARC9 encountered unregistered PhysBulletModel '" .. physmdl .. "'!\nWe will register and refresh this model for all clients, but this is network-intensive!\n\nPlease tell the addon developer to register the model in a shared lua file like so: ARC9:RegisterPhysBulletModel(\"" .. physmdl .. "\")")
        mdlindex = ARC9:RegisterPhysBulletModel(physmdl)
        if SERVER then ARC9:SendPhysBulletModels() end
    end

    local bullet = {
        Penleft = wep:GetProcessedValue("Penetration"),
        Gravity = wep:GetProcessedValue("PhysBulletGravity", true),
        Pos = pos,
        Vel = vel,
        Drag = wep:GetProcessedValue("PhysBulletDrag", true),
        Travelled = 0,
        StartTime = CurTime(),
        Imaginary = false,
        Underwater = false,
        Weapon = wep,
        ModelIndex = mdlindex,
        Attacker = wep:GetOwner(),
        Filter = {wep:GetOwner()},
        Damaged = {},
        Dead = false,
        Color = wep:GetProcessedValue("TracerColor"),
        Fancy = wep:GetProcessedValue("FancyBullets"),
        Size = wep:GetProcessedValue("TracerSize"),
        Guidance = wep:GetProcessedValue("BulletGuidance", true),
        GuidanceAmount = wep:GetProcessedValue("BulletGuidanceAmount", true),
        Secondary = wep:GetUBGL(),
        Distance = wep:GetProcessedValue("Distance"),
        HullSize = wep:GetProcessedValue("HullSize"),
        FirstTimeProcessed = true
    }

    if tbl then
        for i, k in pairs(tbl) do
            bullet[i] = k
        end
    end

    if bit.band( util.PointContents( pos ), CONTENTS_WATER ) == CONTENTS_WATER then
        bullet.Underwater = true
    end

    wep:RunHook("HookP_ModifyNewBullet", bullet)
    if bullet.Dead then return end

    table.insert(ARC9.PhysBullets, bullet)

    if !game.SinglePlayer() then
        if CLIENT and mdlindex > 0 then
            local mdl = ARC9.PhysBulletModels[mdlindex]
            bullet.ClientModel = ClientsideModel(mdl, RENDERGROUP_OPAQUE)
            bullet.ClientModel:SetMoveType(MOVETYPE_NONE)

            table.insert(ARC9.CSModelPile, {Model = bullet.ClientModel, Weapon = wep})
        end

        if SERVER and !pred then
            ARC9:SendBullet(bullet, wep:GetOwner())
        end

        ARC9:ProgressPhysBullet(bullet, FrameTime())

        -- local owner = wep:GetOwner()
        -- if owner:IsPlayer() and (CLIENT or !owner:IsListenServerHost()) then
        --     -- local latency = engine.TickCount() - owner:GetCurrentCommand():TickCount()
        --     local ping = owner:Ping() / 1000
        --     local timestep = 0.2

        --     ping = math.min(ping, 0.25) -- can't let people cheat TOO hard

        --     while ping > 0 do
        --         ARC9:ProgressPhysBullet(bullet, timestep)
        --         ping = ping - timestep
        --     end
        -- end
    else
        if SERVER then
            -- ARC9:ProgressPhysBullet(bullet, FrameTime())

            ARC9:SendBullet(bullet, wep:GetOwner())
        end

        ARC9:ProgressPhysBullet(bullet, FrameTime())
    end
end

if CLIENT then

    net.Receive("arc9_sendbullet", function(len, ply)
        local pos = net.ReadVector()
        local ang = net.ReadAngle()
        local vel = net.ReadFloat()
        local trav = net.ReadFloat()
        local drag = net.ReadFloat()
        local grav = net.ReadFloat()
        local indirect = net.ReadBool()
        local weapon = net.ReadEntity()
        local modelindex = net.ReadUInt(8)
        local ent = nil

        if game.SinglePlayer() then
            ent = net.ReadEntity()
        else
            ent = weapon:IsValid() and weapon:GetOwner()
        end

        if !IsValid(weapon) then return end
        if !weapon.ARC9 then return end

        local bullet = {
            Pos = pos,
            Vel = ang:Forward() * vel,
            Travelled = trav or 0,
            StartTime = CurTime(),
            Imaginary = false,
            Underwater = false,
            Indirect = indirect,
            Dead = false,
            Damaged = {},
            Drag = drag,
            Attacker = ent,
            Gravity = grav,
            Weapon = weapon,
            ModelIndex = modelindex,
            Color = weapon:GetProcessedValue("TracerColor"),
            Fancy = weapon:GetProcessedValue("FancyBullets"),
            Size = weapon:GetProcessedValue("TracerSize"),
            Filter = {ent},
            Guidance = weapon:GetProcessedValue("BulletGuidance", true),
            GuidanceAmount = weapon:GetProcessedValue("BulletGuidanceAmount", true),
            GuidanceTarget = weapon:GetLockOnTarget(),
            Invisible = false,
            Secondary = weapon:GetUBGL(),
            Distance = weapon:GetProcessedValue("Distance"),
            HullSize = weapon:GetProcessedValue("HullSize"),
        }

        if !weapon:ShouldTracer() then
            bullet.Invisible = true
        end

        if bit.band( util.PointContents( pos ), CONTENTS_WATER ) == CONTENTS_WATER then
            bullet.Underwater = true
        end

        if modelindex > 0 then
            local mdl = ARC9.PhysBulletModels[modelindex]
            bullet.ClientModel = ClientsideModel(mdl, RENDERGROUP_OPAQUE)
            bullet.ClientModel:SetMoveType(MOVETYPE_NONE)
            table.insert(ARC9.CSModelPile, {Model = bullet.ClientModel, Weapon = weapon})
        end

        table.insert(ARC9.PhysBullets, bullet)
    end)

    net.Receive("arc9_physbulletmodels", function()
        ARC9.PhysBulletModels = {}
        local count = net.ReadUInt(8)
        for i = 1, count do
            ARC9.PhysBulletModels[i] = net.ReadString()
            ARC9.PhysBulletModelsLookup[ARC9.PhysBulletModels[i]] = i
        end
    end)

    hook.Add("InitPostEntity", "ARC9_RetrievePhysBulletModels", function()
        net.Start("arc9_physbulletmodels")
        net.SendToServer()
    end)

end

function ARC9:DoPhysBullets()
    local i=1
    local tab = ARC9.PhysBullets
    local frameTime = FrameTime()
    while true do
        local v = tab[i]
        if not v then break end

        ARC9:ProgressPhysBullet(v, frameTime)

        if v.Dead then
            table.remove(tab, i)
        else
            i = i+1
        end
    end
end

hook.Add("Think", "ARC9_DoPhysBullets", ARC9.DoPhysBullets)

local function indim(vec, maxdim)
    if math.abs(vec.x) > maxdim or math.abs(vec.y) > maxdim or math.abs(vec.z) > maxdim then
        return false
    else
        return true
    end
end

local bulletGravity = GetConVar("ARC9_bullet_gravity")
local bulletDrag = GetConVar("ARC9_bullet_drag")
local bulletImaginary = GetConVar("ARC9_bullet_imaginary")
local bulletLifetime = GetConVar("ARC9_bullet_lifetime")
local traceResultTab = {}
local traceTab = {
    output = traceResultTab
}
local fireBullets = {
    Tracer = 0,
    Damage = 0
}
local fireBullets2 = {
    Spread = vector_origin,
    Tracer = 0,
    Num = 1
}

function ARC9:ProgressPhysBullet(bullet, timestep)
    timestep = timestep or FrameTime()

    if bullet.Dead then return end

    local oldpos = bullet.Pos
    local oldvel = bullet.Vel

    local attacker = bullet.Attacker
    local weapon = bullet.Weapon

    if !IsValid(attacker) then bullet.Dead = true return end

    local dir = bullet.Vel:GetNormalized()
    local spd = bullet.Vel:Length() * timestep

    local drag = bullet.Drag * spd * spd * 6.666666666666667e-06
    local gravity = timestep * bulletGravity:GetFloat() * (bullet.Gravity or 1) * 600

    -- if !IsValid(attacker) then
    --     bullet.Dead = true
    --     return
    -- end

    if !IsValid(weapon) then
        bullet.Dead = true
        return
    end

    if bullet.Fancy then
        weapon:RunHook("HookP_ModifyBullet", bullet)

        if bullet.Dead then return end
    end

    if bullet.Underwater then
        drag = drag * 3
    end

    drag = drag * bulletDrag:GetFloat()

    if spd <= 0.001 then bullet.Dead = true return end

    local newpos = oldpos + (oldvel * timestep)
    local newvel = oldvel - (dir * drag)

    newvel[3] = newvel[3] - gravity

    if bullet.Imaginary then
        -- the bullet has exited the map, but will continue being visible.
        bullet.Pos = newpos
        bullet.Vel = newvel
        bullet.Travelled = bullet.Travelled + spd

        if CLIENT and !bulletImaginary:GetBool() then
            bullet.Dead = true
        end
    else
        if isPlayer and !attacker.ARC9_LAGCOMP then
            attacker:LagCompensation(true)
            attacker.ARC9_LAGCOMP = true
        end


        traceTab.start = oldpos
        traceTab.endpos = newpos
        traceTab.filter = bullet.Filter
        traceTab.mask = MASK_SHOT

        if bullet.HullSize > 0 then
            local s = bullet.HullSize / 2
            traceTab.mins = Vector(-s, -s, -s)
            traceTab.maxs = Vector(s, s, s)
            util.TraceHull(traceTab)
        else
            util.TraceLine(traceTab)
        end

        local tr = traceResultTab

        if isPlayer then
            attacker:LagCompensation(false)
            attacker.ARC9_LAGCOMP = false
        end

        -- if ARC9.Dev(2) then
        --     if SERVER then
        --         debugoverlay.Line(oldpos, tr.HitPos, 5, Color(100,100,255), true)
        --     else
        --         debugoverlay.Line(oldpos, tr.HitPos, 5, Color(255,200,100), true)
        --     end
        -- end

        if tr.HitSky then
            if CLIENT and bulletImaginary:GetBool() then
                bullet.Imaginary = true
            else
                bullet.Dead = true
            end

            bullet.Pos = newpos
            bullet.Vel = newvel
            bullet.Travelled = bullet.Travelled + spd

            if SERVER then
                bullet.Dead = true
            end
        elseif tr.Hit then
            bullet.Travelled = bullet.Travelled + (oldpos - tr.HitPos):Length()
            bullet.Pos = tr.HitPos
            -- if we're the client, we'll get the bullet back when it exits.

            if isPlayer and !attacker.ARC9_LAGCOMP then
                attacker:LagCompensation(true) -- Sometimes this line is called before the first lag compensation finishes, somehow.
                attacker.ARC9_LAGCOMP = true
            end

            -- if ARC9.Dev(2) then
            --     if SERVER then
            --         debugoverlay.Cross(tr.HitPos, 5, 5, Color(100,100,255), true)
            --     else
            --         debugoverlay.Cross(tr.HitPos, 5, 5, Color(255,200,100), true)
            --     end
            -- end

            local eid = tr.Entity:EntIndex()

            if CLIENT then
                -- do an impact effect and forget about it
                if !game.SinglePlayer() and !ARC9.IsPointOutOfBounds(oldpos) then
                    fireBullets.Src = oldpos
                    fireBullets.Dir = dir
                    fireBullets.Distance = spd + 16

                    fireBullets.IgnoreEntity = bullet.Attacker

                    attacker:FireBullets(fireBullets)
                end
                if IsValid(bullet.ClientModel) then
                    local t = weapon:GetProcessedValue("PhysBulletModelStick", true) or 0
                    if t > 0 then
                        local entity = tr.Entity

                        local bone = entity:TranslatePhysBoneToBone(tr.PhysicsBone) or entity:GetHitBoxBone(tr.HitBox, entity:GetHitboxSet())
                        local matrix = entity:GetBoneMatrix(bone or 0)
                        if bone and matrix then
                            local pos = matrix:GetTranslation()
                            local ang = matrix:GetAngles()
                            bullet.ClientModel:FollowBone(entity, bone)
                            local n_pos, n_ang = WorldToLocal(tr.HitPos, tr.Normal:Angle(), pos, ang)
                            bullet.ClientModel:SetLocalPos(n_pos)
                            bullet.ClientModel:SetLocalAngles(n_ang)
                        else
                            bullet.ClientModel:SetPos(bullet.Pos)
                            bullet.ClientModel:SetAngles(bullet.Vel:Angle())
                            bullet.ClientModel:SetParent(entity)
                        end
                    end
                    SafeRemoveEntityDelayed(bullet.ClientModel, t)
                end

                if IsValid(weapon) then
                    weapon:RunHook("Hook_PhysBulletImpact", {tr = tr, bullet = bullet})
                end

                bullet.Dead = true
            elseif SERVER then
                bullet.Damaged[eid] = true
                bullet.Dead = true

                if IsValid(bullet.Attacker) and IsValid(weapon) and !ARC9.IsPointOutOfBounds(oldpos) then

                    if !game.SinglePlayer() and !bullet.FirstTimeProcessed then
                        SuppressHostEvents(bullet.Attacker)
                    end

                    fireBullets2.Damage = weapon:GetProcessedValue("DamageMax")
                    fireBullets2.Force = weapon:GetProcessedValue("ImpactForce") / (weapon:GetProcessedValue("Num", true) or 1)
                    fireBullets2.Dir = bullet.Vel:GetNormalized()
                    fireBullets2.Src = oldpos
                    fireBullets2.Spread = vector_origin
                    fireBullets2.Callback = function(att, btr, dmg)
                        local range = bullet.Travelled

                        weapon.Penned = 0
                        weapon:AfterShotFunction(btr, dmg, range, bullet.Penleft, bullet.Damaged, bullet.Secondary)
                    end

                    bullet.Attacker:FireBullets(fireBullets2)

                    if !game.SinglePlayer() and !bullet.FirstTimeProcessed then
                        SuppressHostEvents()
                    end
                end
            end

            if isPlayer and attacker.ARC9_LAGCOMP then
                attacker:LagCompensation(false)
                attacker.ARC9_LAGCOMP = false
            end
        else
            -- bullet did not impact anything
            -- break glass in the way
            -- if CLIENT or game.SinglePlayer() then
            --     bullet.Attacker:FireBullets({
            --         Src = oldpos,
            --         Dir = dir,
            --         Distance = spd * 5,
            --         -- Distance = 10000,
            --         Tracer = 0,
            --         Damage = 0,
            --         IgnoreEntity = bullet.Attacker
            --     })
            -- end

            bullet.Pos = tr.HitPos
            bullet.Vel = newvel
            bullet.Travelled = bullet.Travelled + spd

            if CLIENT or game.SinglePlayer() then
                local utr = {}
                if bullet.Underwater then
                    if bit.band( util.PointContents( tr.HitPos ), CONTENTS_WATER ) != CONTENTS_WATER then

                        traceTab.start = tr.HitPos
                        traceTab.endpos = oldpos
                        traceTab.filter = bullet.Attacker
                        traceTab.mask = MASK_WATER
                        traceTab.output = utr

                        util.TraceLine(traceTab)


                        traceTab.output = traceResultTab

                        if utr.Hit then
                            local fx = EffectData()
                            fx:SetOrigin(utr.HitPos)
                            fx:SetScale(5)
                            fx:SetFlags(0)
                            util.Effect("gunshotsplash", fx, true)
                        end

                        bullet.Underwater = false
                    end
                else
                    if bit.band( util.PointContents( tr.HitPos ), CONTENTS_WATER ) == CONTENTS_WATER then
                        traceTab.start = oldpos
                        traceTab.endpos = tr.HitPos
                        traceTab.filter = bullet.Attacker
                        traceTab.mask = MASK_WATER
                        traceTab.output = utr

                        util.TraceLine(traceTab)

                        traceTab.output = traceResultTab

                        if utr.Hit then
                            local fx = EffectData()
                            fx:SetOrigin(utr.HitPos)
                            fx:SetScale(5)
                            fx:SetFlags(0)
                            util.Effect("gunshotsplash", fx, true)
                        end

                        bullet.Underwater = true
                    end
                end
            end
        end
    end

    if bullet.Guidance and IsValid(bullet.GuidanceTarget) then
        local tgt_point = bullet.GuidanceTarget:GetPos()

        tgt_point:Sub(oldpos)
        tgt_point:Normalize()
        tgt_point:Mul(timestep)
        tgt_point:Mul(bullet.GuidanceAmount or 15000)

     --   local tgt_dir = (tgt_point - oldpos):GetNormalized()

        -- needs work

        bullet.Vel:Add(tgt_point)

        local bdir = bullet.Vel:Forward()
        local vel = bullet.Vel:Length()

        vel = math.Clamp(vel, 0, bullet.GuidanceAmount)

        bullet.Vel = bdir * vel
    end

    local MaxDimensions = 65536
    local WorldDimensions = 16384

    if bullet.Travelled > bullet.Distance then
        bullet.Dead = true
    end

    if bullet.StartTime <= (CurTime() - bulletLifetime:GetFloat()) then
        bullet.Dead = true
    elseif !indim(bullet.Pos, MaxDimensions) then
        bullet.Dead = true
    elseif !indim(bullet.Pos, WorldDimensions) then
        bullet.Imaginary = true
    end

    bullet.FirstTimeProcessed = false
end

local head = Material("particle/fire")
local tracer = Material("arc9/tracer")

local col = Color(255, 225, 200)

function ARC9.DrawPhysBullets(inrt)
    cam.Start3D()
    for _, i in ipairs(ARC9.PhysBullets) do
        if i.Invisible then continue end

        local pos = i.Pos

        local speedvec = i.Vel:GetNormalized()
        local vec = speedvec
        local shoulddraw = true

        if IsValid(i.Weapon) then
            shoulddraw = i.Weapon:RunHook("HookC_DrawBullet", i)

            local fromvec = -(i.Weapon:GetTracerOrigin() - pos):GetNormalized()

            local d = math.min(i.Travelled / 1024, 1)
            if i.Indirect then
                d = 1
            end

            vec = LerpVector(d, fromvec, speedvec)
        end

        if !shoulddraw then continue end
        if i.Travelled <= (i.ModelIndex == 0 and 512 or 64) then continue end

        if i.ModelIndex != 0 then
            if IsValid(i.ClientModel) then
                i.ClientModel:SetPos(pos)
                i.ClientModel:SetAngles(i.Vel:Angle())
                --i.ClientModel:DrawModel()
            end
            continue
        end

        local size = 1
        size = size * math.log(EyePos():DistToSqr(pos) - (inrt and 400000 or 200000))
        size = math.Clamp(size, 0, math.huge)
        size = size * i.Size

        local headsize = size
        headsize = headsize * math.min(EyePos():DistToSqr(pos) / math.pow(2500, 2), 1)

        local vel = i.Vel - LocalPlayer():GetVelocity()
        local dot = EyeAngles():Forward():Dot(vel:GetNormalized())
        dot = math.abs(dot)
        dot = math.Clamp(((dot * dot) - 0.5) * 5, 0, 1)

        headsize = headsize * dot * 2
        -- size = size * (1 - dot)
        -- cam.Start3D()

        local col = i.Color or col
        render.SetMaterial(head)
        render.DrawSprite(pos, headsize, headsize, col)

        render.SetMaterial(tracer)

        local t = vec:GetNormalized()
        t:Mul(math.min(vel:Length() * 0.5, math.min(512, i.Travelled - 64)))

        local tail = t
        render.DrawBeam(pos, pos - tail, size * 0.75, 1, 0, col)
        -- cam.End3D()
    end
    cam.End3D()
end

hook.Add("PreDrawEffects", "ARC9_DrawPhysBullets", ARC9.DrawPhysBullets)

hook.Add("PostCleanupMap", "ARC9_CleanPhysBullets", function()
    ARC9.PhysBullets = {}
end)