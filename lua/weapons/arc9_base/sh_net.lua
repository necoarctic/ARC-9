function SWEP:SendWeapon(rec)
    net.Start("ARC9_networkweapon")
    net.WriteEntity(self)

    for i, k in pairs(self.Attachments or {}) do
        self:SendAttachmentTree(self.Attachments[i])
    end

    if SERVER then
        if rec then
            -- send to just this one person
            net.Send(rec)
        else
            net.Broadcast()
        end
    else
        net.SendToServer()
    end
end

function SWEP:SendAttachmentTree(tree)
    if tree and tree.Installed then
        local atttbl = ARC9.GetAttTable(tree.Installed) or {}
        local id = atttbl.ID or 0

        if !atttbl then
            net.WriteUInt(0, ARC9.Attachments_Bits)
            return
        end

        net.WriteUInt(id, ARC9.Attachments_Bits)

        tree.SubAttachments = tree.SubAttachments or {}

        if atttbl.ToggleStats then
            net.WriteUInt((tree.ToggleNum or 1) - 1, 8)
        end

        if atttbl.Attachments then
            for i, k in pairs(atttbl.Attachments) do
                self:SendAttachmentTree(tree.SubAttachments[i])
            end
        end
    else
        net.WriteUInt(0, ARC9.Attachments_Bits)
    end
end

function SWEP:CountAttsInTree(tree)
    local flattree = {}
    for _, i in pairs(tree) do
        table.Add(flattree, self:AttTreeToList(i))
    end

    local count = {}

    for _, i in pairs(flattree) do
        if i.Installed then
            local att = i.Installed
            local atttbl = ARC9.GetAttTable(att) or {}
            att = atttbl.InvAtt or att
            count[att] = (count[att] or 0) + 1
        end
    end

    return count
end

local arc9_atts_nocustomize = GetConVar("arc9_atts_nocustomize")
local arc9_atts_lock = GetConVar("arc9_atts_lock")
local arc9_npc_autoreplace = GetConVar("arc9_npc_autoreplace")
local arc9_replace_spawned = GetConVar("arc9_replace_spawned")

function SWEP:ReceiveWeapon()
    if SERVER and arc9_atts_nocustomize:GetBool() then return end

    local tbl = {}

    for i, k in pairs(self.Attachments or {}) do
        tbl[i] = self:ReceiveAttachmentTree()
    end

    if SERVER then

        if !self:ValidateInventoryForNewTree(tbl) then
            self:SendWeapon()
            return
        end

        if !arc9_atts_lock:GetBool() then
            local oldcount = self:CountAttsInTree(self.Attachments)
            local newcount = self:CountAttsInTree(tbl)

            for att, attc in pairs(newcount) do
                local atttbl = ARC9.GetAttTable(att)

                if atttbl.Free then continue end

                local has = oldcount[att] or 0
                local need = attc

                if has < need then
                    local diff = need - has

                    ARC9:PlayerTakeAtt(self:GetOwner(), att, diff)
                end
            end

            for att, attc in pairs(oldcount) do
                local atttbl = ARC9.GetAttTable(att)
                if !atttbl then ErrorNoHaltWithStack("The attachment trying to be installed doesn't exist. '" .. att .. "'") continue end
                if atttbl.Free then continue end

                local has = attc
                local need = newcount[att] or 0

                if has > need then
                    local diff = has - need

                    ARC9:PlayerGiveAtt(self:GetOwner(), att, diff)
                end
            end
        end

    end

    self:BuildSubAttachments(tbl)

    if CLIENT then
        self:DoInvalidateCache()
        self:PruneAttachments()
        self:KillModel()
        self:SetupModel(true)
        self:SetupModel(false)
        self:RefreshCustomizeMenu()
        
        self:CheckPPs()
    else
        self:DoInvalidateCache()
        self:PruneAttachments()
        self:FillIntegralSlots()
        self:SendWeapon()
        self:PostModify()

        ARC9:PlayerSendAttInv(self:GetOwner())
    end

    -- self:SetBaseSettings()
end

function SWEP:ReceiveAttachmentTree()
    local id = net.ReadUInt(ARC9.Attachments_Bits)
    local att = ARC9.Attachments_Index[id]

    local tree = {
        Installed = att,
        SubAttachments = {}
    }

    if !att then return tree end

    local atttbl = ARC9.GetAttTable(att)

    if !atttbl then return {} end

    if atttbl.ToggleStats then
        tree.ToggleNum = net.ReadUInt(8) + 1
    end

    if atttbl.Attachments then
        for i, k in pairs(atttbl.Attachments) do
            tree.SubAttachments[i] = self:ReceiveAttachmentTree()
        end
    end

    return tree
end