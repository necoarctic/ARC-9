AddCSLuaFile()

ENT.Type                     = "anim"
ENT.Base                     = "base_entity"
ENT.RenderGroup              = RENDERGROUP_OPAQUE

ENT.PrintName                = "Dropped Magazine"
ENT.Category                 = ""

ENT.Spawnable                = false
ENT.Model                    = ""
ENT.FadeTime = 5

ENT.ImpactSounds = {
    "player/pl_shell1.wav",
    "player/pl_shell2.wav",
    "player/pl_shell3.wav"
}

function ENT:Initialize()
    self:SetModel(self.Model)

    if SERVER then
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

        self:PhysWake()

        local phys = self:GetPhysicsObject()
        if !phys:IsValid() then
            self:PhysicsInitBox(Vector(-1, -1, -1), Vector(1, 1, 1))
        end
    end

    self.SpawnTime = CurTime()
end

function ENT:PhysicsCollide(colData, collider)
    if colData.DeltaTime < 0.5 then return end

    local tbl = self.ImpactSounds
    tbl.BaseClass = nil

    local snd = ""

    if tbl then
        snd = table.Random(tbl)
    end
    
    if snd then
        self:EmitSound(snd)
    end
end

function ENT:Think()
    if !self.SpawnTime then
        self.SpawnTime = CurTime()
    end

    if (self.SpawnTime + self.FadeTime) <= CurTime() then

        self:SetRenderFX( kRenderFxFadeFast )

        if (self.SpawnTime + self.FadeTime + 1) <= CurTime() then

            if IsValid(self:GetPhysicsObject()) then
                self:GetPhysicsObject():EnableMotion(false)
            end

            if SERVER then
                if (self.SpawnTime + self.FadeTime + 1.5) <= CurTime() then
                    self:Remove()
                    return
                end
            end
        end
    end
end

function ENT:Draw(flags)
    self:DrawModel(flags)
end
