AddCSLuaFile()

ENT.Type 				= "anim"
ENT.Base 				= "base_entity"
ENT.PrintName 			= "Base Grenade"

ENT.Spawnable 			= false
ENT.CollisionGroup = COLLISION_GROUP_PROJECTILE
ENT.RenderGroup 	    = RENDERGROUP_OPAQUE

ENT.Model = "models/weapons/w_npcnade.mdl"
ENT.SmokeTrail = false
ENT.SmokeTrailMat = "trails/smoke"
ENT.SmokeTrailSize = 6
ENT.SmokeTrailTime = 0.5
ENT.Flare = false

ENT.PhysBoxSize = nil -- Vector(1, 1, 1)
ENT.SphereSize = nil -- number
ENT.PhysMat = "grenade"
ENT.TruePhys = false

ENT.Drag = true
ENT.Gravity = true
ENT.Mass = 5
ENT.DragCoefficient = 0.25
ENT.Boost = 0
ENT.Lift = 0

ENT.Damage = 150
ENT.Radius = 300
ENT.ImpactDamage = 10
ENT.ExplodeOnImpact = false
ENT.LifeTime = 3

ENT.Scorch = true
ENT.ExplosionEffect = "explosion"
ENT.BounceSound = nil
ENT.BounceSounds = nil -- {}

if SERVER then
    function ENT:Initialize()
        self:SetModel(self.Model)
        if self.PhysBoxSize then
            self:PhysicsInitBox(-self.PhysBoxSize, self.PhysBoxSize)
        elseif self.SphereSize then
            self:PhysicsInitSphere(self.SphereSize, self.PhysMat)
        else
            self:PhysicsInit(SOLID_VPHYSICS)
            self:SetSolid(SOLID_VPHYSICS)
        end

        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            phys:Wake()
            phys:EnableDrag(self.Drag)
            phys:SetDragCoefficient(self.DragCoefficient)
            phys:EnableGravity(self.Gravity)
            phys:SetMass(self.Mass)
            phys:SetBuoyancyRatio(0.4)
        end

        if self.SmokeTrail then
            util.SpriteTrail(self, 0, Color( 255 , 255 , 255 ), false, self.SmokeTrailSize, 0, self.SmokeTrailTime, 1 / self.SmokeTrailSize * 0.5, self.SmokeTrailMat)
        end

        self.SpawnTime = CurTime()
    end


    function ENT:Think()
        if self.Defused then return end

        if self.LifeTime > 0 and self.SpawnTime + self.LifeTime < CurTime() then
            self:Detonate()
            return
        end
    end

    function ENT:PhysicsCollide(data)
        if data.Speed > 100 then
            local tgt = data.HitEntity

            if IsValid(tgt) and (self.NextHit or 0) < CurTime() and self.ImpactDamage > 0 then
                self.NextHit = CurTime() + 0.1
                local dmginfo = DamageInfo()
                dmginfo:SetDamageType(DMG_CRUSH)
                dmginfo:SetDamage(self.ImpactDamage)
                if IsValid(self:GetOwner()) then dmginfo:SetAttacker(self:GetOwner()) end
                dmginfo:SetInflictor(self)
                dmginfo:SetDamageForce(data.OurOldVelocity)
                tgt:TakeDamageInfo(dmginfo)

                if (IsValid(tgt) and (tgt:IsNPC() or tgt:IsPlayer() or tgt:IsNextBot()) and tgt:Health() <= 0) or (not tgt:IsWorld() and not IsValid(tgt)) or string.find(tgt:GetClass(), "breakable") then
                    local pos, ang, vel = self:GetPos(), self:GetAngles(), data.OurOldVelocity
                    timer.Simple(0, function()
                        if IsValid(self) then
                            self:SetAngles(ang)
                            self:SetPos(pos)
                            self:GetPhysicsObject():SetVelocityInstantaneous(vel)
                        end
                    end)
                end
            end

            if data.DeltaTime > 0.1 then
                if self.BounceSounds then
                    self:EmitSound(self.BounceSounds[math.random(1, #self.BounceSounds)], 75)
                else
                    self:EmitSound(self.BounceSound, 75)
                end
            end
        end

        if self.ExplodeOnImpact then
            self.HitPos = data.HitPos
            self.HitVelocity = data.OurOldVelocity
            self:Detonate()
        end
    end

    function ENT:OnRemove()
    end


    function ENT:Detonate()
        if not self:IsValid() then return end
        if self.Defused then return end
        local effectdata = EffectData()
            effectdata:SetOrigin( self:GetPos() )

        if self:WaterLevel() > 0 then
            util.Effect( "WaterSurfaceExplosion", effectdata )
        else
            util.Effect( self.ExplosionEffect, effectdata)
        end

        util.BlastDamage(self, IsValid(self:GetOwner()) and self:GetOwner() or self, self:GetPos(), self.Radius, self.DamageOverride or self.Damage)

        if SERVER then
            local dir = self.HitVelocity or self:GetVelocity()

            if self.Boost <= 0 then
                dir = Vector(0, 0, -1)
            end

            self:FireBullets({
                Attacker = self,
                Damage = 0,
                Tracer = 0,
                Distance = 256,
                Dir = dir,
                Src = self:GetPos(),
                Callback = function(att, tr, dmg)
                    if self.Scorch then
                        util.Decal("Scorch", tr.StartPos, tr.HitPos - (tr.HitNormal * 16), self)
                    end
                end
            })
        end
        self.Defused = true

        SafeRemoveEntityDelayed(self, self.SmokeTrailTime)
        self:SetRenderMode(RENDERMODE_NONE)
        self:SetMoveType(MOVETYPE_NONE)
        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    end
else
    function ENT:Draw(flags)
        self:DrawModel(flags)
    end
end
