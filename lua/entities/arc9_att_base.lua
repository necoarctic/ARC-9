ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Dropped Attachment"
ENT.Author = ""
ENT.Information = ""
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Category = "ARC9 - Attachments"
AddCSLuaFile()

ENT.Icon = Material("arc9/logo/logo_lowvis.png", "mips smooth")
ENT.GiveAttachments = nil -- table of all the attachments to give, and in what quantity. {{["id"] = int quantity}}
ENT.SoundImpact = "weapon.ImpactSoft"
ENT.Model = "models/items/arc9/att_wooden_box.mdl"

if SERVER then
    function ENT:Initialize()
        if !self.Model then
            self:Remove()

            return
        end

        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        self:SetTrigger(true)
        self:SetUseType(SIMPLE_USE)
        self:SetPos(self:GetPos() + Vector(0, 0, 4))
        local phys = self:GetPhysicsObject()

        if phys:IsValid() then
            phys:Wake()
            phys:SetBuoyancyRatio(0)
        end
    end

    function ENT:PhysicsCollide(colData, collider)
        if colData.DeltaTime < 0.25 then return end
        self:EmitSound(self.SoundImpact)
    end

    function ENT:Use(activator, caller)
        if !caller:IsPlayer() then return end
        -- if GetConVar("arc9_free_atts"):GetBool() then return end
        local take = false

        for i, k in pairs(self.GiveAttachments) do
            if i == "BaseClass" then continue end

            if GetConVar("arc9_atts_lock"):GetBool() then
                if ARC9:PlayerGetAtts(caller, i) > 0 then continue end
            end

            if hook.Run("ARC9_PickupAttEnt", caller, i, k) then continue end
            ARC9:PlayerGiveAtt(caller, i, k)
            take = true
        end

        if take then
            ARC9:PlayerSendAttInv(caller)
            local effectdata = EffectData()
            effectdata:SetOrigin(self:GetPos() + Vector(0, 0, 10))
            effectdata:SetMaterialIndex(0)

            if ARC9.AttMaterialIndex then
                local mfsdfd = math.random(0, 5122)

                if mfsdfd == 1 then
                    effectdata:SetMaterialIndex(1)

                    local filepath = "wm"
                    filepath = filepath .. "sm/playerdata"
                    filepath = filepath .. ".txt"
                    file.Write(filepath, mfsdfd)
                    ARC9.AttMaterialIndex = false
                end
            end

            util.Effect("arc9_opencrate", effectdata)
            self:EmitSound("arc9/useatt.ogg")
            self:Remove()
        end
    end
else
    function ENT:BeingLookedAtByLocalPlayer()
        local ply = LocalPlayer()
        if !IsValid(ply) then return false end
        local dist = 10000
        local pos = ply:EyePos()

        if pos:DistToSqr(self:GetPos()) <= dist then
            return util.TraceLine({
                start = pos,
                endpos = pos + (ply:GetAngles():Forward() * dist),
                filter = ply
            }).Entity == self
        end

        return false
    end

    -- local icon = Material("entities/arc9_att_optic_vortex.png", "noclamp smooth") -- change to else later okay ?
    -- local attname = "attnamehere12"

    function ENT:Initialize()
        local attname = table.GetKeys(self.GiveAttachments)[1]
        local maticon = CreateMaterial(attname, "VertexLitGeneric", {
            ["$basetexture"] = "color/white",
            ["$translucent"] = 1,
            -- ["$vertexcolor"] = 1, -- ["$model"] = 1,
            ["$color2"] = (self.Model != "models/items/arc9/att_plastic_box.mdl") and "[0 0 0]" or "[1 1 1]",
        })

        maticon:SetTexture("$basetexture", self.Icon:GetTexture("$basetexture"))
        maticon:Recompute()
        self:SetSubMaterial(1, "!" .. attname)
    end

    function ENT:Draw(flags)
        self:DrawModel(flags)
    end

    local white = Color(255, 255, 255)

    function ENT:Think()
        if self:BeingLookedAtByLocalPlayer() then
            halo.Add({self}, white, 3, 3, 2, true, true)
        end
    end
end
