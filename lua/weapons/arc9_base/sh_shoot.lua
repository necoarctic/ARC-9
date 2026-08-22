local cancelmults = ARC9.CancelMultipliers[engine.ActiveGamemode()] or ARC9.CancelMultipliers[1]

local swepGetProcessedValue = SWEP.GetProcessedValue
local swepGetValue = SWEP.GetValue
local infbreathconvar = GetConVar("arc9_breath_infinite")

local sp = game.SinglePlayer()

function SWEP:StillWaiting()
    local time = CurTime()

    if self:GetNextPrimaryFire() > time then return true end
    if self:GetNextSecondaryFire() > time then return true end
    if self:GetAnimLockTime() > time then return true end
    if self:GetCycleFinishTime() > time then return true end
    if self:GetPrimedAttack() then return true end
    if self:GetHolsterTime() > 0 then return true end

    return false
end

function SWEP:SprintLock()
    if self:GetSprintAmount() > 0 then return true end
    -- if self:GetTraversalSprintAmount() > 0 then retur    n true end
    -- if self:GetIsSprinting() then return true end
    if self:GetIsNearWall() then return true end

    return false
end

local dryfireSoundTab = {
    name = "dryfire",
    sound = "",
    level = 75,
    pitch = 100,
    volume = 1,
}

function SWEP:DryFire()
    local nthShot = self:GetNthShot()

    local delay = swepGetProcessedValue(self, "DryFireDelay", true)

    if delay then
        self:PlayAnimation("dryfire", 1, false)
        self:SetNextPrimaryFire(CurTime() + delay)
    else
        self:PlayAnimation("dryfire", 1, true)
    end
    self:SetBurstCount(0)
    self:SetNeedTriggerPress(true)

    if nthShot > 0 and swepGetProcessedValue(self, "DryFireSingleAction", true) then return end

    dryfireSoundTab.channel = ARC9.CHAN_FIDDLE
    dryfireSoundTab.sound = self:RandomChoice(swepGetProcessedValue(self, "DryFireSound", true))
    self:PlayTranslatedSound(dryfireSoundTab)

    self:SetNthShot(nthShot + 1)
end

local lsstr = "ShootSound"
local lsslr = "LayerSound"
local ldsstr = "DistantShootSound"

local sstrSilenced = "ShootSoundSilenced" -- made cuz it'll just pointless to concate.
local sslrSilenced = "LayerSoundSilenced"
local dsstrSilenced = "DistantShootSoundSilenced"

local soundtab1 = {
    name = "shootsound"
}

local soundtab2 = {
    name = "shootlayer"
}

local soundtab3 = {
    name = "shootdistant"
}

local soundtab4 = {
    name = "shootsoundindoor"
}

local soundtab5 = {
    name = "shootlayerindoor"
}

local soundtab6 = {
    name = "shootdistantindoor"
}

function SWEP:DoShootSounds()
    if swepGetValue(self, "NoShootSoundAfterFirstShot") and self:GetNthShot() > 0 then return end

    local pvar = swepGetProcessedValue(self, "ShootPitchVariation", true)
    local pvrand = math.Rand(-pvar, pvar) -- util.SharedRandom("ARC9_sshoot", -pvar, pvar) -- who gives a shit??? plus it broke af
    local randomChoice = self.RandomChoice

    local sstr = lsstr
    local sslr = lsslr
    local dsstr = ldsstr

    local indoor = self:GetIndoor()

    local indoormix = 1 - indoor
    local havedistant = swepGetProcessedValue(self, dsstr, true)

    if swepGetProcessedValue(self, "Silencer", true) and !self:GetUBGL() then
        if swepGetProcessedValue(self, sstrSilenced, true) then
            sstr = sstrSilenced
        end
        if swepGetProcessedValue(self, sslrSilenced, true) then
            sslr = sslrSilenced
        end
        if havedistant and swepGetProcessedValue(self, dsstrSilenced, true) then
            dsstr = dsstrSilenced
        end
    end

    do
        local burstCountZero = self:GetBurstCount() == 0
        local sstrFirst = "First" .. sstr
        local dsstrFirst = "First" .. dsstr

        if burstCountZero and swepGetProcessedValue(self, sstrFirst, true) then
            sstr = sstrFirst
        end

        if havedistant and burstCountZero and swepGetProcessedValue(self, dsstrFirst, true) then
            dsstr = dsstrFirst
        end
    end

    local ss = randomChoice(self, swepGetProcessedValue(self, sstr, true))
    local sl = randomChoice(self, swepGetProcessedValue(self, sslr, true))
    local dss

    if havedistant then
        dss = randomChoice(self, swepGetProcessedValue(self, dsstr, true))
    end

    local svolume, spitch, svolumeactual = swepGetProcessedValue(self, "ShootVolume", true), swepGetProcessedValue(self, "ShootPitch", true) + pvrand, swepGetProcessedValue(self, "ShootVolumeActual", true) or 1
    local dvolume, dpitch, dvolumeactual

    if havedistant then
        dvolume, dpitch, dvolumeactual = math.min(149, (swepGetProcessedValue(self, "DistantShootVolume", true) or svolume) * 2), (swepGetProcessedValue(self, "DistantShootPitch", true) or spitch) + pvrand, swepGetProcessedValue(self, "DistantShootVolumeActual", true) or svolumeactual or 1
    end

    local volumeMix = svolumeactual * indoormix

    local hardcutoff = self.IndoorSoundHardCutoff and self.IndoorSoundHardCutoffRatio < indoor

    if hardcutoff then
        indoormix = 0
        indoor = 1
    elseif self.IndoorSoundHardCutoff then
        indoormix = 1
        indoor = 0
    end

    local playTranslatedSound = self.PlayTranslatedSound
    if indoormix > 0 then

        -- doing this cuz it uses only 1 cached table and it works way faster
        do
            soundtab1.sound = ss or ""
            soundtab1.level = svolume
            soundtab1.pitch = spitch
            soundtab1.volume = self.ShootSoundIndoor and volumeMix or 1
            soundtab1.channel = ARC9.CHAN_WEAPON
            -- soundtab1.networktoeveryone = true
        end

        playTranslatedSound(self, soundtab1)

        do
            soundtab2.sound = sl or ""
            soundtab2.level = svolume
            soundtab2.pitch = spitch
            soundtab2.volume = self.LayerSoundIndoor and volumeMix or 1
            soundtab2.channel = ARC9.CHAN_LAYER + 4
            -- soundtab2.networktoeveryone = true
        end

        playTranslatedSound(self, soundtab2)

        if havedistant then
            do
                soundtab3.sound = dss or ""
                soundtab3.level = dvolume
                soundtab3.pitch = dpitch
                soundtab3.volume = dvolume * indoormix
                soundtab3.channel = ARC9.CHAN_DISTANT
                soundtab3.networktoeveryone = true
            end

            playTranslatedSound(self, soundtab3)
        end
    end

    if indoor > 0 then
        local ssIN = randomChoice(self, swepGetProcessedValue(self, sstr .. "Indoor", true))
        local slIN = randomChoice(self, swepGetProcessedValue(self, sslr .. "Indoor", true))
        local dssIN = havedistant and randomChoice(self, swepGetProcessedValue(self, dsstr .. "Indoor", true))
        local indoorVolumeMix = svolumeactual * indoor


        do
            soundtab4.sound = ssIN or ""
            soundtab4.level = svolume
            soundtab4.pitch = spitch
            soundtab4.volume = indoorVolumeMix
            soundtab4.channel = ARC9.CHAN_INDOOR
            -- soundtab4.networktoeveryone = true
        end

        playTranslatedSound(self, soundtab4)

        do
            soundtab5.sound = slIN or ""
            soundtab5.level = svolume
            soundtab5.pitch = spitch
            soundtab5.volume = indoorVolumeMix
            soundtab5.channel = ARC9.CHAN_INDOOR + 7
            -- soundtab5.networktoeveryone = true
        end

        playTranslatedSound(self, soundtab5)

        if havedistant then
            do
                soundtab6.sound = dssIN or ""
                soundtab6.level = dvolume
                soundtab6.pitch = dpitch
                soundtab6.volume = dvolume * indoor
                soundtab6.channel = ARC9.CHAN_INDOORDISTANT
                soundtab6.networktoeveryone = true
            end

            playTranslatedSound(self, soundtab6)
        end
    end

    self:StartLoop()
end

function SWEP:PrimaryAttack()
    if self.NotAWeapon then return end

    local owner = self:GetOwner()

    if owner:IsNPC() then
        self:NPC_PrimaryAttack()
        return
    end

    if swepGetProcessedValue(self,"Throwable", true) then
        return
    end

    if swepGetProcessedValue(self,"PrimaryBash", true) then
        return
    end

    if swepGetProcessedValue(self,"UBGLInsteadOfSights", true) then
        self:ToggleUBGL(false)
    end

    if self:GetSafe() then
        self:ToggleSafety(false)
        self:SetNeedTriggerPress(true)
        return
    end

    if self:GetNeedTriggerPress() then return end

    if self:GetNeedsCycle() then return end


    if self:GetCustomize() then return end

    if swepGetProcessedValue(self,"Bash", true) and owner:KeyDown(IN_USE) and !self:GetInSights() then
        if self:GetIsSprinting() and !self.ShootWhileSprint then return end
        self:MeleeAttack()
        self:SetNeedTriggerPress(true)
        return
    end

    if self:SprintLock() then return end

    local nthShot = self:GetNthShot()

    if self:HasAmmoInClip() then
        if swepGetProcessedValue(self,"TriggerDelay") then
            local primedAttack = self:GetPrimedAttack()
            local time = CurTime()

            if self:GetBurstCount() == 0 and !primedAttack and !self:StillWaiting() then
                self:SetTriggerDelay(time + swepGetProcessedValue(self,"TriggerDelayTime"))
                local isEmpty = self:Clip1() == swepGetProcessedValue(self, "AmmoPerShot")
                local anim = "trigger"

                if swepGetProcessedValue(self,"Akimbo", true) then
                    if swepGetProcessedValue(self, "AkimboBoth", true) then
                        anim = "trigger_both"
                    elseif nthShot % 2 == 0 then
                        anim = "trigger_right"
                    else
                        anim = "trigger_left"
                    end
                end

                if swepGetProcessedValue(self,"TriggerStartFireAnim", true) then
                        if swepGetProcessedValue(self,"Akimbo", true) then
                            if swepGetProcessedValue(self, "AkimboBoth", true) then
                                anim = "fire_both"
                            elseif nthShot % 2 == 0 then
                                anim = "fire_right"
                            else
                                anim = "fire_left"
                            end
                        else anim = "fire"
                    end
                end
                if self:HasAnimation(anim .. "_empty", true) and isEmpty then
                    anim = anim .. "_empty"
                end
                self:PlayAnimation(anim)
                self:SetPrimedAttack(true)
                return
            elseif primedAttack and (self:GetTriggerDelay() <= time and (!swepGetProcessedValue(self, "TriggerDelayReleaseToFire", true) or !owner:KeyDown(IN_ATTACK))) then
                self:SetPrimedAttack(false)
            end
        end
    elseif !swepGetProcessedValue(self,"TriggerDelay") or !swepGetProcessedValue(self, "TriggerDelayReleaseToFire", true) or !owner:KeyDown(IN_ATTACK) then
        self:SetPrimedAttack(false)
    end

    if self:GetReloading() then
        self:SetEndReload(true)
    end

    self:DoPrimaryAttack()

    if self.RecentMelee then
        self.RecentMelee = nil
    end

end

function SWEP:DoPrimaryAttack()

    if self.FireInterruptInspect and self:GetInspecting() then self:CancelInspect() end
    if self:StillWaiting() then return end
    if self.NoFireDuringSighting and (self:GetInSights() and self:GetSightAmount() < 0.8 or false) then return end

    local currentFiremode = self:GetCurrentFiremode()
    local burstCount = self:GetBurstCount()

    if currentFiremode > 0 and burstCount >= currentFiremode then return end

    local clip = self:GetLoadedClip()

    if swepGetProcessedValue(self,"BottomlessClip", true) then
        self:RestoreClip(math.huge)
    end

    if !self:HasAmmoInClip() then
        if self:GetUBGL() and !swepGetProcessedValue(self,"UBGLInsteadOfSights", true) then
            if self:GetMaxClip2() < 2 then -- mytton doesn't like auto ubgl reload
                if self:CanReload() then
                    self:Reload()
                else
                    self:ToggleUBGL(false)
                    self:SetNeedTriggerPress(true)
                    self:ExitSights()
                end
            end

            return
        else
            self:DryFire()
            return
        end
    end

    if !swepGetProcessedValue(self,"CanFireUnderwater", true) and bit.band(util.PointContents(self:GetShootPos()), CONTENTS_WATER) == CONTENTS_WATER then
        self:DryFire()
        return
    end

    self:SetBaseSettings()

    if self:RunHook("HookP_BlockFire") then return end

    if self:GetJammed() or self:GetHeatLockout() then
        self:DryFire()
        return
    end

    self:RunHook("Hook_PrimaryAttack")

    self:SetEmptyReload(false)
    self:TakeAmmo()

    local triggerStartFireAnim = swepGetProcessedValue(self,"TriggerStartFireAnim", true)
    local nthShot = self:GetNthShot()

    if swepGetProcessedValue(self,"DoFireAnimation", true) and !triggerStartFireAnim then
        local anim = "fire"

        if swepGetProcessedValue(self,"Akimbo", true) then
            if swepGetProcessedValue(self, "AkimboBoth", true) then
                anim = "fire_both"
            elseif nthShot % 2 == 0 then
                anim = "fire_right"
            else
                anim = "fire_left"
            end
        end

        local banim = anim

        if !self.SuppressCumulativeShoot then
            for i = 1, burstCount + 1 do
                if self:HasAnimation(anim .. "_" .. i, true) then
                    banim = anim .. "_" .. i
                end
            end
        end

        self:PlayAnimation(banim, 1, false)
    end

    local clip1 = self:Clip1()

    self:SetLoadedRounds(clip1)

    local manualaction = swepGetProcessedValue(self,"ManualAction", true)

    if !swepGetProcessedValue(self,"NoShellEject", true) and !(manualaction and !swepGetProcessedValue(self,"ManualActionEjectAnyway", true)) then
        local ejectdelay = swepGetProcessedValue(self,"EjectDelay", true)

        if ejectdelay == 0 then
            self:DoEject()
        else
            self:SetTimer(ejectdelay, function()
                self:DoEject()
            end)
        end
    end

    self:SetAfterShot(true)

    self:DoShootSounds()

    self:DoPlayerAnimationEvent(swepGetProcessedValue(self,"AnimShoot", true))

    local delay = 60 / swepGetProcessedValue(self, "RPM")
    local time = CurTime()

    local curatt = self:GetNextPrimaryFire()
    local diff = time - curatt

    if diff > engine.TickInterval() or diff < 0 then
        curatt = time
    end

    self:SetNextPrimaryFire(curatt + delay)

    self:SetNthShot(nthShot + 1)

    self:DoEffects()


    if self:HoldingBreath() and !infbreathconvar:GetBool() then
        local d = 100 / math.max(1, swepGetProcessedValue(self, "HoldBreathTime", true))
        local breathtake = math.Clamp(delay * d * 3, 1, 10)
        if manualaction then
            breathtake = d
        end
        self:SetBreath(math.max(0, self:GetBreath() - breathtake))
    end

    -- ewww
    if swepGetProcessedValue(self, "AkimboBoth", true) then
        self:SetNthShot(nthShot + 2)
        self:DoEffects()
        if !swepGetProcessedValue(self,"NoShellEject", true) and !(manualaction and !swepGetProcessedValue(self,"ManualActionEjectAnyway", true)) then
            local ejectdelay = swepGetProcessedValue(self,"EjectDelay", true)
            if ejectdelay == 0 then
                self:DoEject()
            else
                self:SetTimer(ejectdelay, function()
                    self:DoEject()
                end)
            end
        end
    end

    if sp then
        if SERVER then
            self:CallOnClient("SInputRumble")
        end
    else
        if CLIENT then
            self:SInputRumble()
        end
    end

    local spread = swepGetProcessedValue(self,"Spread")

    spread = math.Max(spread, 0)

    local shopos, shoang = self:GetShootPos()

    if IsValid(self:GetLockOnTarget()) and self:GetLockedOn() and swepGetProcessedValue(self,"LockOnAutoaim", true) then
        sa = (self:GetLockOnTarget():EyePos() - shopos):Angle()
    end

    self:DoProjectileAttack(shopos, shoang, spread)

    self:ApplyRecoil()
    self:DoVisualRecoil()

    if burstCount == 0 and currentFiremode > 1 and swepGetProcessedValue(self,"RunawayBurst", true) then
        if !swepGetProcessedValue(self,"AutoBurst", true) then
            self:SetNeedTriggerPress(true)
        end
    end

    if manualaction then
        nthShot = nthShot + 1
        if clip1 > 0 or !swepGetProcessedValue(self,"ManualActionNoLastCycle", true) then
            if nthShot % swepGetProcessedValue(self,"ManualActionChamber", true) == 0 then
                self:SetNeedsCycle(true)
            end
        end
    end
    -- print("shot = " .. nthShot)

    if currentFiremode == 1 or clip == 0 then
        self:SetNeedTriggerPress(true)
    end

    self:DoHeat()

    if !self:GetUBGL() then
        if !manualaction or manualaction and !self.MalfunctionCycle then
            self:RollJam()
        end
    end

    if clip1 == 0 then
        self:SetNthShot(0)
    end

    if swepGetProcessedValue(self,"TriggerDelayRepeat", true) and self:GetOwner():KeyDown(IN_ATTACK) and currentFiremode != 1 then
        self:SetTriggerDelay(time + swepGetProcessedValue(self,"TriggerDelayTime"))
        if triggerStartFireAnim then
            self:PlayAnimation("fire")
        else
            self:PlayAnimation("trigger")
        end
        self:SetPrimedAttack(true)
    end

    self:SetBurstCount(burstCount + 1)
end

if CLIENT then
    local cl_rumble = GetConVar("arc9_controller_rumble")

    function SWEP:SInputRumble()
        if !sinput then return false end
        if !cl_rumble:GetBool() then return false end

        local P1 = sinput.GetControllerForGamepadIndex(0)

        sinput.TriggerVibration(P1, self.RumbleHeavy, self.RumbleLight)
        sinput.SetLEDColor(P1, 255, 255, 255, false)

        timer.Remove( "SInput_ARC9_Rumble" )
        timer.Create( "SInput_ARC9_Rumble", self.RumbleDuration, 1, function()
            sinput.TriggerVibration(P1, 0, 0)
            sinput.SetLEDColor(P1, 255, 255, 255, true)
        end )
    end
end

local function CalcSpreadDir(seed, ang, spread)
    local ang2 = Angle(ang)

    local a = util.SharedRandom("arc9_physbullet", 0, 360, seed)
    local angleRand = Angle(math.sin(a), math.cos(a), 0)
    angleRand:Mul(spread * util.SharedRandom("arc9_physbullet2", 0, 45, seed) * 1.4142135623730)

    ang2:Add(angleRand)

    return ang2:Forward()
end

local bulletPhysics = GetConVar("arc9_bullet_physics")
local bulletPhysicsshotguns = GetConVar("arc9_bullet_physics_shotguns")
local fireBullets = {}
local black = Color(0,0,0) -- if anything, let's just safe ourselves.
local minphysrange = 750

function SWEP:SPCancelTracer() self.TracerCancelled = true end
function SWEP:SPAddTracer() self.TracerCancelled = false end

function SWEP:ShootPhysBulletBinding(pos, ang, spread, bullettbl, numm)
    if SERVER or (CLIENT and IsFirstTimePredicted()) then
        if swepGetProcessedValue(self, "UseDispersion", true) then
            local seed = 1337 + self:EntIndex() + engine.TickCount()
            local a = util.SharedRandom("arc9_physbullet3", 0, 360, seed)
            local angleRand = Angle(math.sin(a), math.cos(a), 0)
            angleRand:Mul(math.max(0, swepGetProcessedValue(self, "DispersionSpread")) * util.SharedRandom("arc9_physbullet4", 0, 45, seed) * 1.4142135623730)
            ang:Add(angleRand)
        end

        for i = 1, numm do
            local vec = CalcSpreadDir(i + self:EntIndex() + engine.TickCount(), ang, spread)
            vec:Mul(swepGetProcessedValue(self, "PhysBulletMuzzleVelocity", true))

            ARC9:ShootPhysBullet(self, pos, vec, bullettbl, true)
        end
    end
end

function SWEP:DoProjectileAttack(pos, ang, spread)
    if swepGetProcessedValue(self, "ShootEnt", true) then
        self:ShootRocket()
    else
        local shouldtracer = self:ShouldTracer()

        local bullettbl = {}

        if !shouldtracer then
            bullettbl.Color = black
        end

        local tr = 0

        if shouldtracer then
            tr = 1
        end

        bullettbl.Size = swepGetProcessedValue(self, "TracerSize", true)

        local ang2 = Angle(ang)
        local numm = swepGetProcessedValue(self, "Num")
        if numm > 0 then
            local owner = self:GetOwner()
            local ownernpc = IsValid(owner) and owner:IsNPC() -- no physbullets for npcs they dont deserve that

            local alwayphys = swepGetProcessedValue(self, "AlwaysPhysBullet", true)
            local shouldphys = (alwayphys or (bulletPhysics:GetBool() and !ownernpc)) and !(swepGetProcessedValue(self, "NeverPhysBullet", true) or (numm > 2 and !bulletPhysicsshotguns:GetBool()))

            if alwayphys then
                self:ShootPhysBulletBinding(pos, ang, spread, bullettbl, numm)
            else
                if owner:IsPlayer() then
                    owner:LagCompensation(true)
                end

                -- local tr = swepGetProcessedValue(self, "TracerNum")

                local veh = NULL

                if owner:IsPlayer() then
                    veh = owner:GetVehicle()
                end


                if swepGetProcessedValue(self, "UseDispersion", true) then
                    local seed = 1337 + self:EntIndex() + engine.TickCount()
                    local a = util.SharedRandom("arc9_physbullet3", 0, 360, seed)
                    local angleRand = Angle(math.sin(a), math.cos(a), 0)
                    angleRand:Mul(math.max(swepGetProcessedValue(self, "DispersionSpread"), 0) * util.SharedRandom("arc9_physbullet4", 0, 45, seed) * 1.4142135623730)
                    ang:Add(angleRand)
                end

                local distance = !shouldphys and swepGetProcessedValue(self, "Distance") or minphysrange
                local rangecheck = false
                self.TracerCancelled = false

                if sp and SERVER then self:CallOnClient("SPAddTracer") end

                fireBullets.Damage = 2 -- minimal perf hit, setting dmg in callback only if it actually hitted something
                fireBullets.Force = swepGetProcessedValue(self, "ImpactForce", true) / numm
                fireBullets.Tracer = tr
                fireBullets.TracerName = swepGetProcessedValue(self, "TracerEffect", true)
                fireBullets.Num = 1 -- fuck this bitch source engine loops they SUCK
                -- fireBullets.Dir = ang:Forward()
                fireBullets.Src = pos
                -- fireBullets.Spread = Vector(spread, spread, spread)
                fireBullets.Spread = Vector()
                fireBullets.HullSize = swepGetProcessedValue(self, "HullSize", true)
                fireBullets.IgnoreEntity = veh
                fireBullets.Distance = distance

                -- local amount = 0
                -- print("\nNEW ONE\n ")

                fireBullets.Callback = function(att, btr, dmg)
                    rangecheck = true -- callback only called if bullet hits something
                    local range = distance * btr.Fraction

                    local dmgnumbr = swepGetProcessedValue(self, "DamageMax", true)
                    dmg:SetDamage(dmgnumbr)

                    self.Penned = 0
                    self:AfterShotFunction(btr, dmg, range, swepGetProcessedValue(self, "Penetration", true), {})
                    
                    -- if ARC9.Dev(2) then
                    --     if SERVER then
                    --         amount = amount + 1
                    --         debugoverlay.Cross(btr.HitPos, 1, 5, Color(255, 0, 0), false)
                    --         debugoverlay.Text(btr.HitPos, "#" .. amount, 4, false)
                    --         print("#" .. amount, dmgnumbr/numm)
                    --     else
                    --         debugoverlay.Cross(btr.HitPos, 4, 5, Color(255, 255, 255), false)
                    --     end
                    -- end
                end

                for i = 1, numm do
                    fireBullets.Dir = CalcSpreadDir(i + self:EntIndex() + engine.TickCount(), ang, spread)

                    owner:FireBullets(fireBullets)
                end

                if owner:IsPlayer() then
                    owner:LagCompensation(false)
                end

                if shouldphys and !rangecheck then
                    if sp and SERVER then self:CallOnClient("SPCancelTracer") end
                    self.TracerCancelled = true
                    self:ShootPhysBulletBinding(pos, ang, spread, bullettbl, numm)
                end
            end
        end
    end
end

local runHook = {}
local bodyDamageCancel = GetConVar("arc9_mod_bodydamagecancel")
local arc9_npc_equality = GetConVar("arc9_npc_equality")

local soundTab2 = {
    name = "impact"
}

function SWEP:AfterShotFunction(tr, dmg, range, penleft, alreadypenned, secondary)
    if !IsFirstTimePredicted() and !sp then return end

    local lastsecondary = self:GetUBGL()

    self:SetUBGL(secondary)

    dmg:SetDamageType(swepGetProcessedValue(self, "DamageType", true) or DMG_BULLET)

    local dmgv = self:GetDamageAtRange(range)
    local dmgvoriginal = dmgv

    runHook.tr = tr
    runHook.dmg = dmg
    runHook.range = range
    runHook.penleft = penleft
    runHook.alreadypenned = alreadypenned
    runHook.dmgv = dmgv

    self:RunHook("Hook_BulletImpact", runHook)

    -- Penetration
    local pen = swepGetProcessedValue(self, "Penetration", true)
    local pendeltaval = swepGetProcessedValue(self, "PenetrationDelta", true)
    if pen > 0 then
        local pendelta = penleft / pen
        pendelta = Lerp(pendelta, pendeltaval, 1) -- it arleady clamps inside
        dmgv = dmgv * pendelta
    end

    -- NPC damage nerf
    local owner = self:GetOwner()
    if owner:IsNPC() and !arc9_npc_equality:GetBool() then
        dmgv = dmgv * 0.25
    end

    -- Limb multipliers
    local traceEntity = tr.Entity
    local hitGroup = tr.HitGroup

    if !ARC9.NoBodyPartsDamageMults then
        local bodydamage = swepGetProcessedValue(self, "BodyDamageMults", true)

        if bodydamage[hitGroup] then
            dmgv = dmgv * bodydamage[hitGroup]
        end
        if hitGroup == HITGROUP_HEAD then
            dmgv = dmgv * swepGetProcessedValue(self, "HeadshotDamage", true)
        elseif hitGroup == HITGROUP_CHEST then
            dmgv = dmgv * swepGetProcessedValue(self, "ChestDamage", true)
        elseif hitGroup == HITGROUP_STOMACH then
            dmgv = dmgv * swepGetProcessedValue(self, "StomachDamage", true)
        elseif hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM then
            dmgv = dmgv * swepGetProcessedValue(self, "ArmDamage", true)
        elseif hitGroup == HITGROUP_LEFTLEG or hitGroup == HITGROUP_RIGHTLEG then
            dmgv = dmgv * swepGetProcessedValue(self, "LegDamage", true)
        end
    end

    -- Armor piercing (done after weapon's limb multipliers but BEFORE body damage cancel)
    local ap = math.Clamp(swepGetProcessedValue(self, "ArmorPiercing", true), 0, 1)
    if ap > 0 and !alreadypenned[traceEntity] then
        if traceEntity:GetClass() == "npc_helicopter" then
            local apdmg = DamageInfo()
            apdmg:SetDamagePosition(tr.HitPos)
            apdmg:SetDamage(dmgv * ap)
            apdmg:SetDamageType(DMG_AIRBOAT)
            apdmg:SetInflictor(self)
            apdmg:SetAttacker(owner)

            if traceEntity.TakeDamageInfo then traceEntity:TakeDamageInfo(apdmg) end
        elseif traceEntity:GetClass() == "npc_gunship" or traceEntity:GetClass() == "npc_strider" then
            local apdmg = DamageInfo()
            apdmg:SetDamage(dmgv * ap)
            apdmg:SetDamageType(DMG_BLAST)
            apdmg:SetInflictor(self)
            apdmg:SetAttacker(owner)

            if traceEntity.TakeDamageInfo then traceEntity:TakeDamageInfo(apdmg) end
        elseif traceEntity:IsPlayer() then
            if !ARC9.NoArmorPiercing then -- dumbass
                local apdmg = math.ceil(dmgv * ap)
                -- Delay health removal so that we can confirm the damage actually applied before removing health
                dmg:SetDamageCustom(ARC9.DMG_CUST_AP)
                traceEntity.ARC9APDamage = apdmg
                -- traceEntity:SetHealth(traceEntity:Health() - apdmg)
                dmgv = math.max(1, dmgv - apdmg)
            else
                ARC9.LastArmorPiercedPlayer = traceEntity
                ARC9.LastArmorPierceValue = ap
                ARC9.LastArmorPiercedTime = CurTime()

                traceEntity.ARC9APPower = pen
                traceEntity.ARC9APDelta = pendeltaval
                traceEntity.ARC9APRangeMult = dmgvoriginal / swepGetProcessedValue(self, "DamageMax", true)
            end
        end
    end

    -- Cancel out sandbox/ttt limb damage multipliers. Done last since AP damage does not go through this
    -- Lambda Players call ScalePlayerDamage and cancel out hitgroup damage... except on the head
    if bodyDamageCancel:GetBool() and cancelmults[hitGroup] and (!traceEntity.IsLambdaPlayer or hitgroup == HITGROUP_HEAD) then
        dmgv = dmgv / cancelmults[hitGroup]
    end

    dmg:SetDamage(dmgv)

    local hitPos = tr.HitPos
    local hitNormal = tr.HitNormal

    if swepGetProcessedValue(self, "ImpactDecal", true) then
        util.Decal(swepGetProcessedValue(self, "ImpactDecal", true), tr.StartPos, hitPos - (hitNormal * 2), owner)
    end

    if swepGetProcessedValue(self, "ImpactEffect", true) then
        local fx = EffectData()
        fx:SetOrigin(hitPos)
        fx:SetNormal(hitNormal)
        util.Effect(swepGetProcessedValue(self, "ImpactEffect", true), fx, true)
    end

    if swepGetProcessedValue(self, "ImpactSound", true) then
        soundTab2.sound = swepGetProcessedValue(self, "ImpactSound", true)

        soundTab2 = self:RunHook("HookP_TranslateSound", soundTab2) or soundTab2

        sound.Play(soundTab2.sound, hitPos, soundTab2.level, soundTab2.pitch, soundTab2.volume)
    end

    if swepGetProcessedValue(self, "ExplosionDamage") > 0 then
        util.BlastDamage(self, IsValid(owner) and owner or self, hitPos, swepGetProcessedValue(self, "ExplosionRadius", true), swepGetProcessedValue(self, "ExplosionDamage"))
    end

    if swepGetProcessedValue(self, "ExplosionEffect", true) then
        local fx = EffectData()
        fx:SetOrigin(hitPos)
        fx:SetNormal(hitNormal)
        fx:SetAngles(tr.HitNormal:Angle())

        if bit.band(util.PointContents(hitPos), CONTENTS_WATER) == CONTENTS_WATER then
            util.Effect("WaterSurfaceExplosion", fx, true)
        else
            util.Effect(swepGetProcessedValue(self, "ExplosionEffect", true), fx, true)
        end
    end

    if traceEntity and alreadypenned[traceEntity] then
        dmg:SetDamage(0)
    elseif traceEntity then
        alreadypenned[traceEntity] = true
    end

    self:Penetrate(table.Copy(tr), range, penleft, alreadypenned)

    self:SetUBGL(lastsecondary)
end

function SWEP:ShouldTracer()
    local tracerNum = swepGetProcessedValue(self, "TracerNum", true)

    if tracerNum <= 0 then return false end

    local shouldtracer = self:GetNthShot() % tracerNum == 0

    if self:Clip1() <= swepGetProcessedValue(self, "TracerFinalMag", true) then
        shouldtracer = true
    end

    return shouldtracer
end

function SWEP:GetDamageDeltaAtRange(range)
    local d = 1

    local r_min = swepGetProcessedValue(self, "RangeMin", true)
    local r_max = swepGetProcessedValue(self, "RangeMax", true)

    if range <= r_min then
        d = 0
    elseif range >= r_max then
        d = 1
    else
        d = (range - r_min) / (r_max - r_min)
    end

    if swepGetProcessedValue(self, "CurvedDamageScaling", true) then
        d = math.cos((d + 1) * math.pi) / 2 + 0.5
    end

    return d
end

function SWEP:GetSweetSpotDeltaAtRange(range)
    if !swepGetProcessedValue(self, "SweetSpot", true) then return 0 end

    local ss_range = swepGetProcessedValue(self, "SweetSpotRange", true)
    local ss_width = swepGetProcessedValue(self, "SweetSpotWidth", true)
    local ss_peak = swepGetProcessedValue(self, "SweetSpotPeak", true)
    local ss_size = ss_width + ss_peak

    if range <= ss_range + ss_size / 2 and range >= ss_range - ss_size / 2 then
        if range <= ss_range + ss_peak / 2 and range >= ss_range - ss_peak / 2 then
            return 1
        else
            local f = 0
            if range > ss_range then
                f = 1 - math.Clamp(math.abs((ss_range + ss_peak / 2) - range) / (ss_width / 2), 0, 1)
            else
                f = 1 - math.Clamp(math.abs((ss_range - ss_peak / 2) - range) / (ss_width / 2), 0, 1)
            end
            if swepGetProcessedValue(self, "CurvedDamageScaling", true) then
                f = math.cos((f + 1) * math.pi) / 2 + 0.5
            end
            return f
        end
    end

    return 0
end

local damageAtRangeHook = {}
local emptyTable = {}
local dmgmodcvar = GetConVar("arc9_mod_damage") -- stats handled in sh_0_stats, but dmg lookuptable is table so we doing this here

function SWEP:GetDamageAtRange(range)
    local damagelut = swepGetProcessedValue(self, "DamageLookupTable", true)

    local dmgMin = swepGetProcessedValue(self, "DamageMin")

    local num = swepGetProcessedValue(self, "Num")
    if num <= 0 then
        return 0 -- avoid divide-by-zero
    end

    local dmgv = dmgMin

    if damagelut then
        local stupidmult = dmgmodcvar:GetFloat()

        for i, tbl in ipairs(damagelut) do
            if range < tbl[1] then
                if swepGetProcessedValue(self, "CurvedDamageScaling", true) and i > 1 then
                    local tbl2 = damagelut[i - 1]
                    dmgv = Lerp(1 - math.Clamp((tbl[1] - range) / (tbl[1] - tbl2[1]), 0, 1), tbl2[2] * stupidmult, tbl[2] * stupidmult)
                else
                    dmgv = tbl[2] * stupidmult
                end
                break
            end
        end

        -- dmgv = dmgv * dmgmodcvar:GetFloat()
    else
        local d = self:GetDamageDeltaAtRange(range)
        dmgv = Lerp(d, swepGetProcessedValue(self, "DamageMax"), dmgMin)
        dmgv = swepGetProcessedValue(self, "Damage", nil, dmgv)
    end

    local sweetspot_d = self:GetSweetSpotDeltaAtRange(range)
    if sweetspot_d > 0 then
        dmgv = Lerp(sweetspot_d, dmgv, swepGetProcessedValue(self, "SweetSpotDamage", true) * dmgmodcvar:GetFloat())
    end

    if swepGetProcessedValue(self, "DistributeDamage", true) then
        dmgv = dmgv / num
    elseif swepGetProcessedValue(self, "NormalizeNumDamage", true) then
        dmgv = dmgv / (num / self.Num)
    end

    damageAtRangeHook.dmg = dmgv
    damageAtRangeHook.range = range
    damageAtRangeHook.d = d

    local data = self:RunHook("Hook_GetDamageAtRange", damageAtRangeHook) or emptyTable

    dmgv = data.dmg or dmgv

    return dmgv
end

function SWEP:GetShootPos()
    local owner = self:GetOwner()

    if !IsValid(owner) then return Vector(), Angle() end

    if SERVER and owner:IsNPC() then
        return owner:GetShootPos()
    end

    local pos = owner:EyePos()
    local ang = self:GetShootDir()
    local rightVec = owner:EyeAngles():Right()
    local shootposoffset = swepGetProcessedValue(self, "ShootPosOffset", true)
    local angRight = ang:Right()
    local angForward = ang:Forward()
    local angUp = ang:Up()

    angRight:Mul(shootposoffset[1])
    angForward:Mul(shootposoffset[2])
    angUp:Mul(shootposoffset[3])

    pos:Add(angRight)
    pos:Add(angForward)
    pos:Add(angUp)

    pos, ang = self:GetRecoilOffset(pos, ang)

    return pos, ang
end

function SWEP:GetShootPositionVFIRE()
        local muzz_qca = self:GetQCAMuzzle()
        local ent = self:GetVM() -- Default to viewmodel
        if self:GetOwner():ShouldDrawLocalPlayer() or !CLIENT then
            ent = self -- Use worldmodel for others/server
        end
        local ft_qca = ent:GetAttachment(muzz_qca)
        return ft_qca and ft_qca.Pos or self:GetShootPos()
    end

function SWEP:GetShootDir(quick)
    local owner = self:GetOwner()
    if !owner:IsValid() then return self:GetAngles() end
    local dir = owner:EyeAngles()
    local shootangoffset = swepGetProcessedValue(self, "ShootAngOffset", !quick)

    dir:RotateAroundAxis(dir:Right(), shootangoffset[1])
    dir:RotateAroundAxis(dir:Up(), shootangoffset[2])
    dir:RotateAroundAxis(dir:Forward(), shootangoffset[3])

    dir:Add(self:GetFreeAimOffset())

    local fswayang = self:GetFreeSwayAngles()

    if fswayang then dir:Add(fswayang) end

    if self.InertiaEnabled then dir:Add(self:GetInertiaSwayAngles()) end

    return dir
end

function SWEP:ShootRocket()
    if CLIENT then return end

    local owner = self:GetOwner()
    local src = self:GetShootPos()
    local dir = self:GetShootDir(true)
    local num = swepGetProcessedValue(self, "Num")
    local ent = swepGetProcessedValue(self, "ShootEnt", true)
    local spread

    if ent == "vfire_ball" and vFireInstalled then
        local life = math.Rand(4, 8) * (swepGetProcessedValue(self, "ShootLife") or 2.15)
        local forward = dir:Forward()
        local vel = forward * math.Rand(900, 1000)
        local feedCarry = math.Rand(3, 8) * (swepGetProcessedValue(self, "ShootFeed") or 1)
        local forwardBoost = math.Rand(20, 40)
        local tr = owner:GetEyeTrace()
        if tr.Fraction < 0.001245 then
            forwardBoost = 1
        end
        local spawnPos = src + (forward * forwardBoost)
        CreateVFireBall(life, feedCarry, spawnPos, vel, owner)
        -- Return here so the standard entity spawner does not run
        return
    end

    if owner:IsNPC() then
        -- spread = self:GetNPCBulletSpread()
        -- spread = self:GetNPCSpread()
        spread = 0.03
    else
        spread = swepGetProcessedValue(self, "Spread")
    end

    spread = math.max(spread, 0)

    for i = 1, num do
        local dispersion = Angle(math.Rand(-1, 1), math.Rand(-1, 1), 0)
        dispersion:Mul(spread * 36)
        dispersion:Add(dir)
        local rocket = ents.Create(ent)
        if !IsValid(rocket) then return end

        rocket:SetOwner(owner)
        rocket:SetPos(src)
        rocket:SetAngles(dispersion)
        rocket:Spawn()
        rocket.Owner = owner
        rocket.Weapon = self

        rocket.ShootEntData = table.Copy(swepGetProcessedValue(self, "ShootEntData", true) or {})
        rocket.ShootEntData.Target = IsValid(self:GetLockOnTarget()) and self:GetLockedOn() and self:GetLockOnTarget()
        rocket.ShootEntData = self:RunHook("Hook_GetShootEntData", rocket.ShootEntData)
        rocket.ARC9Projectile = true

        if swepGetProcessedValue(self, "Detonator", true) then
            self:SetDetonatorEntity(rocket)
        end

        rocket:SetPhysicsAttacker(self:GetOwner(), 600)

        local phys = rocket:GetPhysicsObject()

        if phys:IsValid() then
            local vec = dispersion:Forward()
            vec:Mul(swepGetProcessedValue(self, "ShootEntForce"))

            phys:AddVelocity(vec)
            if swepGetProcessedValue(self, "ShootEntInheritPlayerVelocity", true) then
                phys:AddVelocity(owner:GetVelocity())
            end
        end
    end
end

function SWEP:FireAnimationEvent( pos, ang, event, options )
    return true
end

hook.Add("PostEntityTakeDamage", "ARC9_AP", function(ent, dmginfo, took)
    -- AP health removal only triggers if entity actually took damage. Avoids situation where you strip health from godmode players etc.
    if dmginfo:GetDamage() > 0 and took and bit.band(dmginfo:GetDamageCustom(), ARC9.DMG_CUST_AP) != 0 and ent:Health() > 0 and (ent.ARC9APDamage or 0) > 0 then
        ent:SetHealth(ent:Health() - ent.ARC9APDamage)
        if ent:Health() <= 0 then
            -- Apply damage again since setting health doesn't kill a player/npc
            -- This won't cause an infinite loop cause AP flag is removed
            dmginfo:SetDamageCustom(bit.band(dmginfo:GetDamageCustom(), bit.bnot(ARC9.DMG_CUST_AP)))
            dmginfo:SetDamage(-ent:Health() + 1)
            ent:TakeDamageInfo(dmginfo)
        end
        ent.ARC9APDamage = nil
    end
end)
