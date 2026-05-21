AddCSLuaFile()

ENT.Type                     = "anim"
ENT.Base                     = "base_entity"
ENT.RenderGroup              = RENDERGROUP_OPAQUE

ENT.PrintName                = "Ammo Pickup"
ENT.Category                 = "ARC9 - Ammo"

ENT.Spawnable                = true
ENT.Model                    = "models/items/arc9/ammo_pistol_box.mdl"
ENT.ModelOptions = nil

ENT.InfiniteUse = false
ENT.OpeningAnim = false
ENT.NextUse = 0
ENT.Open = false

ENT.Supply = 1

function ENT:Initialize()
    local model = self.Model

    if self.ModelOptions then
        model = table.Random(self.ModelOptions)
    end

    self:SetModel(model)

    if SERVER then

        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        self:SetUseType(CONTINUOUS_USE)
        self:PhysWake()

        self:SetTrigger(true) -- Enables Touch() to be called even when not colliding
        self:UseTriggerBounds(true, 24)
    end
end

local function ClampedGiveAmmo(ply, ammo, amt, clamp)
    local count = ply:GetAmmoCount(ammo)

    if count >= clamp then
        return false
    elseif count + amt > clamp then
        amt = math.max(clamp - count, 0)
    end

    ply:GiveAmmo(amt, ammo)

    return true
end

function ENT:ApplyAmmo(ply)
    if self.NextUse > CurTime() then return end

    local wpn = ply:GetActiveWeapon()

    local ammotype = wpn:GetPrimaryAmmoType()
    local clipsize = wpn:GetMaxClip1()
    local supplyamount = clipsize * self.Supply
    local max = clipsize * 6

    local t2

    if wpn.ARC9 then
        ammotype = wpn:GetProcessedValue("Ammo")
        clipsize = wpn:GetProcessedValue("ClipSize")
        max = wpn:GetProcessedValue("SupplyLimit") * clipsize

        if max <= 0 then
            max = 1
        end

        if wpn:GetProcessedValue("UBGL") then
            local ammotype2 = wpn:GetProcessedValue("UBGLAmmo")
            local clipsize2 = wpn:GetProcessedValue("UBGLClipSize")
            local supplyamount2 = clipsize2 * 1
            local max2 = clipsize2 * wpn:GetProcessedValue("SecondarySupplyLimit")

            t2 = ClampedGiveAmmo(ply, ammotype2, supplyamount2, max2)
        end
    end

    local t = ClampedGiveAmmo(ply, ammotype, supplyamount, max)

    if t or t2 then
        if self.OpeningAnim and !self.Open then
            local seq = self:LookupSequence("open")
            self:ResetSequence(seq)
            self:EmitSound("items/ammocrate_open.wav")

            self.Open = true
        end

        self.NextUse = CurTime() + 1

        if !self.InfiniteUse then
            self:Remove()
        end
    end
end

ENT.CollisionSoundsHard = {
    "physics/cardboard/cardboard_box_impact_hard1.wav",
    "physics/cardboard/cardboard_box_impact_hard2.wav",
    "physics/cardboard/cardboard_box_impact_hard3.wav",
    "physics/cardboard/cardboard_box_impact_hard4.wav",
    "physics/cardboard/cardboard_box_impact_hard5.wav",
    "physics/cardboard/cardboard_box_impact_hard6.wav",
    "physics/cardboard/cardboard_box_impact_hard7.wav",
}

ENT.CollisionSoundsSoft = {
    "physics/cardboard/cardboard_box_impact_soft1.wav",
    "physics/cardboard/cardboard_box_impact_soft2.wav",
    "physics/cardboard/cardboard_box_impact_soft3.wav",
    "physics/cardboard/cardboard_box_impact_soft4.wav",
    "physics/cardboard/cardboard_box_impact_soft5.wav",
    "physics/cardboard/cardboard_box_impact_soft6.wav",
    "physics/cardboard/cardboard_box_impact_soft7.wav",
}

function ENT:PhysicsCollide(data)
    if data.DeltaTime < 0.1 then return end

    if data.Speed > 25 then
        self:EmitSound(self.CollisionSoundsHard[math.random(#self.CollisionSoundsHard)])
    else
        self:EmitSound(self.CollisionSoundsSoft[math.random(#self.CollisionSoundsSoft)])
    end
end

if SERVER then

    function ENT:Use(ply)
        if !ply:IsPlayer() then return end
        self:ApplyAmmo(ply)
    end

    function ENT:Think()
        if self.Open and (self.NextUse + 0.1) < CurTime() then
            local seq = self:LookupSequence("close")
            self:ResetSequence(seq)
            self:EmitSound("items/ammocrate_close.wav")

            self.Open = false
        end

        self:NextThink(CurTime())
        return true
    end

    function ENT:Touch(ply)
        if !ply:IsPlayer() then return end
        self:ApplyAmmo(ply)
    end

elseif CLIENT then
    
    function ENT:Draw(flags)
        self:DrawModel(flags)
    end

end
