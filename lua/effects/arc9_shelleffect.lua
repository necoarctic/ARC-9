EFFECT.Type = 1

EFFECT.Pitch = 100

EFFECT.Model = "models/shells/shell_57.mdl"

EFFECT.AlreadyPlayedSound = false
EFFECT.ShellTime = 0.5
EFFECT.SpawnTime = 0

EFFECT.VMContext = true

EFFECT.PCFs = {}

local arc9_eject_time = GetConVar("arc9_eject_time")
local arc9_eject_fx = GetConVar("arc9_eject_fx")

local FormatViewModelAttachment = ARC9.FormatViewModelAttachment

function EFFECT:Init(data)

    local att = data:GetAttachment()
    local ent = data:GetEntity()

    if !IsValid(ent) then self:Remove() return end
    local owner, lp = ent:GetOwner(), LocalPlayer()
    if !IsValid(owner) then self:Remove() return end

    if owner != lp or lp:ShouldDrawLocalPlayer() then
        mdl = (ent.WModel or {})[1] or ent
        self.VMContext = false
    else
        mdl = lp:GetViewModel()

        -- if ent:ShouldTPIK() then
        --     self.VMContext = false
        -- else
            table.insert(ent.ActiveEffects, self)
        -- end
    end

    if !IsValid(ent) then self:Remove() return end
    if !mdl or !IsValid(mdl) then self:Remove() return end
    if !mdl:GetAttachment(att) then self:Remove() return end

    local origin, ang = mdl:GetAttachment(att).Pos, mdl:GetAttachment(att).Ang

    if (lp:ShouldDrawLocalPlayer() or owner != lp) then
        wm = true
        self.VMContext = false
    end

    -- ang:RotateAroundAxis(ang:Up(), -90)

    -- ang:RotateAroundAxis(ang:Right(), (ent.ShellRotateAngle or Angle(0, 0, 0))[1])
    -- ang:RotateAroundAxis(ang:Up(), (ent.ShellRotateAngle or Angle(0, 0, 0))[2])
    -- ang:RotateAroundAxis(ang:Forward(), (ent.ShellRotateAngle or Angle(0, 0, 0))[3])

    local processedValue = ent.GetProcessedValue
    local model = processedValue(ent, "ShellModel", true)
    local material = processedValue(ent, "ShellMaterial", true)
    local scale = processedValue(ent, "ShellScale", true)
    local physbox = processedValue(ent, "ShellPhysBox", true)
    local pitch = processedValue(ent, "ShellPitch", true)
    local sounds = processedValue(ent, "ShellSounds", true)
    local soundsvolume = processedValue(ent, "ShellVolume", true)
    local smoke = processedValue(ent, "ShellSmoke", true)
    local rotate = processedValue(ent, "ShellAngleVelocity", true) or 1
    local velocity = processedValue(ent, "ShellVelocity", true) or math.Rand(1, 2)

    local index = data:GetFlags()

    if index != 0 then
        local shelldata = processedValue(ent, "ExtraShellModels", true)[index]

        if shelldata then
            model = shelldata.model or model
            material = shelldata.material or material
            scale = shelldata.scale or scale
            physbox = shelldata.physbox or physbox
            pitch = shelldata.pitch or pitch
            sounds = shelldata.sounds or sounds
            soundsvolume = shelldata.soundsvolume or soundsvolume
            if shelldata.smoke != nil then
                smoke = shelldata.smoke
            end
            velocity = shelldata.velocity or velocity
            if istable(velocity) then velocity = math.Rand(velocity[1], velocity[2]) end
        end
    end

    self.ShellTime = self.ShellTime + arc9_eject_time:GetFloat()

    local dir = ang:Forward()

    local correctang = processedValue(ent, "ShellCorrectAng", true) or angle_zero
    ang:RotateAroundAxis(ang:Forward(), 90 + correctang.p)
    ang:RotateAroundAxis(ang:Right(), correctang.y)
    ang:RotateAroundAxis(ang:Up(), correctang.r)
    
    if self.VMContext then origin = FormatViewModelAttachment(origin, false) end
    self:SetPos(origin)
    self:SetModel(model or "")
    self:SetMaterial(material or "")
    self:DrawShadow(true)
    self:SetAngles(ang)
    self:SetModelScale(scale or 1)

    if self.VMContext then self:SetNoDraw(true) end

    self.ShellPitch = pitch

    -- if !LocalPlayer():ShouldDrawLocalPlayer() and ent:GetOwner() == LocalPlayer() then
    --     self:SetNoDraw(true)
    -- end

    -- table.insert(ent.EjectedShells, self)

    self.Sounds = sounds or ARC9.ShellSoundsTable

	self.SoundsVolume = soundsvolume or 1

    local pb_z = physbox.z
    local pb_y = physbox.y
    local pb_x = physbox.x

    local mag = 150

    self:PhysicsInitBox(Vector(-pb_z,-pb_y,-pb_x), Vector(pb_z,pb_x,pb_y))

    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

    local phys = self:GetPhysicsObject()

    local plyvel = owner:GetAbsVelocity() * 1.1

    phys:Wake()
    phys:SetDamping(0, 0)
    phys:SetMass(1)
    phys:SetMaterial("gmod_silent")
    -- phys:SetMaterial("default_silent")

    phys:SetVelocity((dir * mag * velocity) + plyvel)

    phys:AddAngleVelocity(VectorRand() * 100 * rotate)
    phys:AddAngleVelocity((ang:Up() * 2500 * velocity / 0.75) * rotate)

    if owner:IsNPC() or !arc9_eject_fx:GetBool() then
        smoke = false
    end

    if smoke then
        local pcf = CreateParticleSystem(mdl, "port_smoke", PATTACH_POINT_FOLLOW, att)

        if IsValid(pcf) then
            pcf:StartEmission()
        end

        local smkpcf = CreateParticleSystem(self, "shellsmoke", PATTACH_ABSORIGIN_FOLLOW, 0)

        if IsValid(smkpcf) then
            smkpcf:StartEmission()
        end

        if self.VMContext then
            table.insert(ent.PCFs, pcf)
            table.insert(ent.PCFs, smkpcf)

            pcf:SetShouldDraw(false)
            smkpcf:SetShouldDraw(false)
        end
    end

    self.SpawnTime = CurTime()
end

function EFFECT:PhysicsCollide(colData)
    if self.AlreadyPlayedSound then return end
    local phys = self:GetPhysicsObject()
    phys:SetVelocityInstantaneous(colData.HitNormal * -150)
    self:StopSound("Default.ImpactHard")

    self.VMContext = false
    self:SetNoDraw(false)

    sound.Play(self.Sounds[math.random(#self.Sounds)], self:GetPos(), 75, self.ShellPitch, self.SoundsVolume, CHAN_WEAPON)

    self.AlreadyPlayedSound = true
end

function EFFECT:Think()
    local vel = self:GetVelocity():Length()
    if vel > 20 then self.SpawnTime = CurTime() end
    if vel < 5 and self.VMContext then self.VMContext = false self:SetNoDraw(false) end

    self:StopSound("Default.ScrapeRough")

    if (self.SpawnTime + self.ShellTime) <= CurTime() then
        if !IsValid(self) then return end
        self:SetRenderFX( kRenderFxFadeFast )
        if (self.SpawnTime + self.ShellTime + 0.25) <= CurTime() then
            if !IsValid(self:GetPhysicsObject()) then return end
            self:GetPhysicsObject():EnableMotion(false)
            if (self.SpawnTime + self.ShellTime + 0.5) <= CurTime() then
                self:Remove()
                return
            end
        end
    end
    return true
end

function EFFECT:Render()
    if !IsValid(self) then return end

    self:DrawModel()
end

function EFFECT:DrawTranslucent()
    if !IsValid(self) then return end

    self:DrawModel()
end