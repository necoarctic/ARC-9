
local Lerp = Lerp
local LerpVector = LerpVector

local function qerp(delta, a, b)
    local qdelta = -(delta ^ 2) + (delta * 2)
    qdelta = math.Clamp(qdelta, 0, 1)

    return Lerp(qdelta, a, b)
end

function SWEP:DoRHIK(wm)
    -- local vm = self:GetOwner():GetHands()
    local vm = self:GetVM()
    if wm then vm = self:GetWM() end
    if !IsValid(vm) then return end
    if !self.UseHands then return end
    vm:SetupBones()
    local lh_delta = 1
    local rh_delta = 1
    local hasonehandsprint = self:GetValue("OneHandedSprint")
    local hide_lh_d = 0
    local hide_rh_d = 0
    hide_lh_d = self.CustomizeDelta
    if hasonehandsprint then hide_lh_d = hide_lh_d + self:GetSprintAmount() end
    hide_rh_d = self.CustomizeDelta
    hide_lh_d = math.ease.InExpo(hide_lh_d)
    hide_rh_d = math.ease.InCubic(hide_rh_d)
    if ARC9.PresetCam then
        hide_lh_d = 1
        hide_rh_d = 1
    end
    local iktl = (self.Animations[self:GetIKAnimation() or ""] or {}).IKTimeLine
    local iket = self:GetIKTime()
    local iklt = math.Clamp((CurTime() - self:GetIKTimeLineStart()) / iket, 0, 1)

    if iktl then
        if self:GetProcessedValue("LHIK", true) then
            local next_stage_index

            for i, k in ipairs(iktl) do
                if !k or !k.t then continue end

                if k.t > iklt then
                    next_stage_index = i
                    break
                end
            end

            if next_stage_index then
                if next_stage_index == 1 then
                    -- we are on the first stage.
                    stage = {
                        t = 0,
                        lhik = 0
                    }

                    next_stage = iktl[next_stage_index]
                else
                    stage = iktl[next_stage_index - 1]
                    next_stage = iktl[next_stage_index]
                end
            else
                stage = iktl[#iktl]

                next_stage = {
                    t = iket,
                    lhik = iktl[#iktl].lhik
                }
            end

            local local_time = iklt
            local delta_time = next_stage.t - stage.t
            delta_time = (local_time - stage.t) / delta_time
            delta_time = math.ease.InOutQuart(delta_time)
            lh_delta = qerp(delta_time, stage.lhik or 0, next_stage.lhik or 0)
        end

        if self:GetProcessedValue("RHIK", true) then
            local next_stage_index

            for i, k in ipairs(iktl) do
                if !k or !k.t then continue end

                if k.t > iklt then
                    next_stage_index = i
                    break
                end
            end

            if next_stage_index then
                if next_stage_index == 1 then
                    -- we are on the first stage.
                    stage = {
                        t = 0,
                        rhik = 0
                    }

                    next_stage = iktl[next_stage_index]
                else
                    stage = iktl[next_stage_index - 1]
                    next_stage = iktl[next_stage_index]
                end
            else
                stage = iktl[#iktl]

                next_stage = {
                    t = iket,
                    rhik = iktl[#iktl].rhik
                }
            end

            local local_time = iklt
            local delta_time = next_stage.t - stage.t
            delta_time = (local_time - stage.t) / delta_time
            delta_time = math.ease.InOutQuart(delta_time)
            rh_delta = qerp(delta_time, stage.rhik or 0, next_stage.rhik or 0)
        end
    end

    local rhik_model = self.RHIKModel

    if wm then
        rhik_model = self.RHIKModelWM
    end

    if IsValid(rhik_model) then
        rhik_model:SetupBones()

        for _, bone in ipairs(ARC9.RHIKBones) do
            local vm_bone = vm:LookupBone(bone)
            local target_bone = rhik_model:LookupBone(bone)
            if !vm_bone or !target_bone then continue end
            local vm_bone_matrix = vm:GetBoneMatrix(vm_bone)
            local target_bone_matrix = rhik_model:GetBoneMatrix(target_bone)
            local lerped_pos = LerpVector(rh_delta, vm_bone_matrix:GetTranslation(), target_bone_matrix:GetTranslation())
            local lerped_ang = LerpAngle(rh_delta, vm_bone_matrix:GetAngles(), target_bone_matrix:GetAngles())
            local newtransform = Matrix()
            newtransform:SetTranslation(lerped_pos)
            newtransform:SetAngles(lerped_ang)
            local matrix = Matrix(newtransform)
            vm:SetBoneMatrix(vm_bone, matrix)
        end
    end

    local lhik_model = self.LHIKModel

    if wm then
        lhik_model = self.LHIKModelWM
    end

    if IsValid(lhik_model) then
        lhik_model:SetupBones()

        lh_delta = lh_delta - math.ease.OutExpo(hide_lh_d)

        for _, bone in ipairs(ARC9.LHIKBones) do
            local vm_bone = vm:LookupBone(bone)
            local target_bone = lhik_model:LookupBone(bone)
            if !vm_bone or !target_bone then continue end
            local vm_bone_matrix = vm:GetBoneMatrix(vm_bone)
            local target_bone_matrix = lhik_model:GetBoneMatrix(target_bone)
            local lerped_pos = LerpVector(lh_delta, vm_bone_matrix:GetTranslation(), target_bone_matrix:GetTranslation())
            local lerped_ang = LerpAngle(lh_delta, vm_bone_matrix:GetAngles(), target_bone_matrix:GetAngles())
            local newtransform = Matrix()
            newtransform:SetTranslation(lerped_pos)
            newtransform:SetAngles(lerped_ang)
            vm:SetBoneMatrix(vm_bone, newtransform)
        end
    end

    if wm then return end

    self:LHIKThirdArm()
    local enable_ik = false
    -- obsolete lol
    if enable_ik then
        local rupperarm, rforearm, rulna, rwrist, rhand = vm:LookupBone("ValveBiped.Bip01_R_UpperArm"), vm:LookupBone("ValveBiped.Bip01_R_Forearm"), vm:LookupBone("ValveBiped.Bip01_R_Ulna"), vm:LookupBone("ValveBiped.Bip01_R_Wrist"), vm:LookupBone("ValveBiped.Bip01_R_Hand")
        local lupperarm, lforearm, lulna, lwrist, lhand = vm:LookupBone("ValveBiped.Bip01_L_UpperArm"), vm:LookupBone("ValveBiped.Bip01_L_Forearm"), vm:LookupBone("ValveBiped.Bip01_L_Ulna"), vm:LookupBone("ValveBiped.Bip01_L_Wrist"), vm:LookupBone("ValveBiped.Bip01_L_Hand")
        local rupperarm_matrix, rhand_matrix = vm:GetBoneMatrix(rupperarm), vm:GetBoneMatrix(rhand)
        local lupperarm_matrix, lhand_matrix = vm:GetBoneMatrix(lupperarm), vm:GetBoneMatrix(lhand)
        local rforearm_matrix = vm:GetBoneMatrix(rforearm)
        local lforearm_matrix = vm:GetBoneMatrix(lforearm)
        local rarm_start, rhand_end = rupperarm_matrix:GetTranslation(), rhand_matrix:GetTranslation()
        local larm_start, lhand_end = lupperarm_matrix:GetTranslation(), lhand_matrix:GetTranslation()
        local rupperarm_length, rarm_length = 10, 10
        local lupperarm_length, larm_length = 10, 10
        -- local rupperarm_length, rarm_length = vm:BoneLength(rupperarm), vm:BoneLength(rforearm)
        -- if rupperarm_length > 15 or rarm_length > 15 or rupperarm_length < 5 or rarm_length < 5 then
        --     rupperarm_length = 8
        --     rarm_length = 8
        -- end
        -- local lupperarm_length, larm_length = vm:BoneLength(lupperarm), vm:BoneLength(lforearm)
        -- if lupperarm_length < 5 or larm_length < 5 then
        --     lupperarm_length = 8
        --     larm_length = 8
        -- end
        -- lupperarm_length = lupperarm_length + 2
        -- larm_length = larm_length + 2
        rupperarm_matrix, rhand_matrix = vm:GetBoneMatrix(rupperarm), vm:GetBoneMatrix(rhand)
        lupperarm_matrix, lhand_matrix = vm:GetBoneMatrix(lupperarm), vm:GetBoneMatrix(lhand)
        rarm_start = rupperarm_matrix:GetTranslation()
        -- rarm_start = EyePos() + (EyeAngles():Right() * 4) + (EyeAngles():Up() * -8) + (EyeAngles():Forward() * -1)
        larm_start = lupperarm_matrix:GetTranslation()
        -- larm_start = EyePos() + (EyeAngles():Right() * -6) + (EyeAngles():Up() * -8) + (EyeAngles():Forward() * -1)
        local rupperarm_position, rforearm_position = self:Solve2PartIK(rarm_start, rhand_end, rupperarm_length, rarm_length, -1, self:GetOwner():EyeAngles())
        local lupperarm_position, lforearm_position = self:Solve2PartIK(larm_start, lhand_end, lupperarm_length, larm_length, 1, self:GetOwner():EyeAngles())
        
        debugoverlay.Line(rarm_start, rupperarm_position, 0.1, color_white, true)
        debugoverlay.Line(rforearm_position, rupperarm_position, 0.1, color_white, true)
        debugoverlay.Line(rforearm_position, rhand_end, 0.1, color_white, true)
        debugoverlay.Line(larm_start, lupperarm_position, 0.1, color_white, true)
        debugoverlay.Line(lforearm_position, lupperarm_position, 0.1, color_white, true)
        debugoverlay.Line(lforearm_position, lhand_end, 0.1, color_white, true)

        -- rupperarm_matrix:SetTranslation(rupperarm_position)
        -- brought to you by: https://rubberduckdebugging.com/
        -- get one today!
        -- right
        if self:GetValue("RHIK") and enable_ik then
            local rupperarm_dir = (rupperarm_position - rupperarm_matrix:GetTranslation())
            local rupperarm_ang = rupperarm_dir:Angle()
            rupperarm_ang.r = 90 -- rupperarm_dir:Angle()
            rupperarm_matrix:SetAngles(rupperarm_ang)
            local rupperarm_norm = (rupperarm_position - rarm_start)
            rupperarm_norm:Normalize()
            rupperarm_matrix:SetTranslation(rarm_start - rupperarm_norm * 0)
            local rforearm_norm = (rforearm_position - rforearm_matrix:GetTranslation())
            rforearm_norm:Normalize()
            rforearm_matrix:SetTranslation(rupperarm_position + rforearm_norm * 0)
            local rforearm_dir = rhand_end - rupperarm_position
            local rforearm_ang = 90 -- rforearm_dir:Angle()
            rforearm_ang.r = rforearm_dir:Angle()
            rforearm_matrix:SetAngles(rforearm_ang)

            vm:SetBoneMatrix(rupperarm, rupperarm_matrix)
            vm:SetBoneMatrix(rforearm, rforearm_matrix)

            if rulna and rwrist then
                local rwrist_matrix = vm:GetBoneMatrix(rwrist)
                local rulna_matrix = vm:GetBoneMatrix(rulna)
                local rwrist_angle = (rwrist_matrix:GetTranslation() - rupperarm_position):Angle()
                rwrist_matrix:SetAngles(rwrist_angle)
                vm:SetBoneMatrix(rwrist, rwrist_matrix)
                -- rwrist_angle.r = rwrist_matrix:GetAngles().r + 90
                rulna_matrix:SetTranslation(rwrist_matrix:GetTranslation() - (rwrist_angle:Forward() * 0))
                rulna_matrix:SetAngles(rwrist_angle)
                vm:SetBoneMatrix(rulna, rulna_matrix)
            end
        end

        -- brought to you by: https://rubberduckdebugging.com/
        -- get one today!
        -- left
        if self:GetValue("LHIK") and enable_ik then
            local lupperarm_dir = (lupperarm_position - lupperarm_matrix:GetTranslation())
            local lupperarm_ang = lupperarm_dir:Angle()
            lupperarm_ang.r = -125 -- lupperarm_matrix:GetAngles().r
            lupperarm_matrix:SetAngles(lupperarm_ang)
            local lupperarm_norm = (lupperarm_position - larm_start)
            lupperarm_norm:Normalize()
            lupperarm_matrix:SetTranslation(larm_start - (lupperarm_norm * 0))
            local lforearm_norm = (lforearm_position - lforearm_matrix:GetTranslation())
            lforearm_norm:Normalize()
            lforearm_matrix:SetTranslation(lupperarm_position + (lforearm_norm * 0))
            local lforearm_dir = lhand_end - lupperarm_position
            local lforearm_ang = lforearm_dir:Angle()
            lforearm_ang.r = -90 -- lforearm_matrix:GetAngles().r
            lforearm_matrix:SetAngles(lforearm_ang)
            vm:SetBoneMatrix(lupperarm, lupperarm_matrix)
            vm:SetBoneMatrix(lforearm, lforearm_matrix)

            if lulna and lwrist then
                local lwrist_matrix = vm:GetBoneMatrix(lwrist)
                local lulna_matrix = vm:GetBoneMatrix(lulna)
                local lwrist_angle = (lwrist_matrix:GetTranslation() - lupperarm_position):Angle()
                lwrist_matrix:SetTranslation(lwrist_matrix:GetTranslation())
                lwrist_matrix:SetAngles(lwrist_angle)
                vm:SetBoneMatrix(lwrist, lwrist_matrix)
                -- lwrist_angle.r = lwrist_matrix:GetAngles().r + 90
                lulna_matrix:SetTranslation(lwrist_matrix:GetTranslation() - (lwrist_angle:Forward() * 0))
                lulna_matrix:SetAngles(lwrist_angle)
                vm:SetBoneMatrix(lulna, lulna_matrix)
            end
        end
    end

    if hide_lh_d > 0 then
        for _, bone in ipairs(ARC9.LHIKBones) do
            local vmbone = vm:LookupBone(bone)
            if !vmbone then continue end -- Happens when spectating someone prolly
            local vmtransform = vm:GetBoneMatrix(vmbone)
            if !vmtransform then continue end -- something very bad has happened
            local vm_pos = vmtransform:GetTranslation()
            local vm_ang = vmtransform:GetAngles()
            local newtransform = Matrix()

            if hasonehandsprint and hide_rh_d == 0 then
                newtransform:SetTranslation(LerpVector(hide_lh_d, vm_pos, vm_pos - (EyeAngles():Up() * 16) - (EyeAngles():Forward() * 9) - (EyeAngles():Right() * 12)))
            else
                newtransform:SetTranslation(LerpVector(hide_lh_d, vm_pos, vm_pos - (EyeAngles():Up() * 48) - (EyeAngles():Forward() * 16)))
            end

            newtransform:SetAngles(vm_ang)
            vm:SetBoneMatrix(vmbone, newtransform)
        end
    end

    if hide_rh_d > 0 then
        for _, bone in ipairs(ARC9.RHIKBones) do
            local vmbone = vm:LookupBone(bone)
            if !vmbone then continue end -- Happens when spectating someone prolly
            local vmtransform = vm:GetBoneMatrix(vmbone)
            if !vmtransform then continue end -- something very bad has happened
            local vm_pos = vmtransform:GetTranslation()
            local vm_ang = vmtransform:GetAngles()
            local newtransform = Matrix()
            newtransform:SetTranslation(LerpVector(hide_rh_d, vm_pos, vm_pos - (EyeAngles():Up() * 48) - (EyeAngles():Forward() * 16)))
            newtransform:SetAngles(vm_ang)
            vm:SetBoneMatrix(vmbone, newtransform)
        end
    end
end

function SWEP:RecalculateIKGunMotionOffset()
    local seqproxy = self:GetSequenceProxy()

    if seqproxy != 0 then
        local slottbl = self:LocateSlotFromAddress(seqproxy)
        local atttbl = self:GetFinalAttTable(slottbl)
        local qca = atttbl.IKGunMotionQCA

        local anim_mdl = slottbl.GunDriverModel

        if !anim_mdl then return end

        local oldseq = anim_mdl:GetSequence()
        local oldcycle = anim_mdl:GetCycle()
        anim_mdl:ResetSequence(0)
        anim_mdl:SetCycle(0)

        if !anim_mdl:GetAttachment(qca) then return end

        local idleattpos = anim_mdl:GetAttachment(qca).Pos
        local idleattang = anim_mdl:GetAttachment(qca).Ang

        self.IKGunMotionOffset = idleattpos
        self.IKGunMotionOffsetAngle = idleattang

        anim_mdl:ResetSequence(oldseq)
        anim_mdl:SetCycle(oldcycle)
    end
end

function SWEP:GunControllerRHIK(pos, ang)
    local seqproxy = self:GetSequenceProxy()

    if seqproxy != 0 then
        local slottbl = self:LocateSlotFromAddress(seqproxy)
        local atttbl = self:GetFinalAttTable(slottbl)
        local qca = atttbl.IKGunMotionQCA

        if !qca then return pos, ang end

        local anim_mdl = slottbl.GunDriverModel

        if !IsValid(anim_mdl) then return pos, ang end

        local refl_mdl = slottbl.ReflectDriverModel

        if !refl_mdl then return pos, ang end

        anim_mdl:SetPos(Vector(0, 0, 0))
        anim_mdl:SetAngles(Angle(0, 0, 0))

        refl_mdl:SetPos(Vector(0, 0, 0))
        refl_mdl:SetAngles(Angle(0, 0, 0))

        if !self.IKGunMotionOffset then
            self:RecalculateIKGunMotionOffset()
        end

        local getatt = anim_mdl:GetAttachment(qca)
        if !getatt then return pos, ang end
        local attpos, attang = getatt.Pos, getatt.Ang

        attang:Sub( self.IKGunMotionOffsetAngle )

        attpos = attpos - self.IKGunMotionOffset

        local r = attang.r
        attang.r = attang.p
        attang.p = -r
        attang.y = -attang.y

        local anchor = slottbl.Pos

        local bone = refl_mdl:LookupBone( slottbl.Bone )
        local bonp, bona = refl_mdl:GetBonePosition( bone )
        if bonp == refl_mdl:GetPos() then
            bonp = refl_mdl:GetBoneMatrix( bone ):GetTranslation()
            bona = refl_mdl:GetBoneMatrix( bone ):GetAngles()
        end

        if anchor and bonp then
            local offsx, offsy, offsz = anchor.x, anchor.y, anchor.z
            if atttbl.IKGunMotionAnchor then
                offsx = offsx + atttbl.IKGunMotionAnchor.x
                offsy = offsy + atttbl.IKGunMotionAnchor.y
                offsz = offsz + atttbl.IKGunMotionAnchor.z
            end

            anchor = ( bonp + ( (bona:Forward() * offsx) + (bona:Right() * offsy) + (bona:Up() * offsz) ) )

            if atttbl.IKGunMotionMultReal then
                attpos:Mul(atttbl.IKGunMotionMultReal)
            end

            if atttbl.IKGunMotionAngleMultReal then
                attang:Mul(atttbl.IKGunMotionAngleMultReal)
            end

            local rap_pos, rap_ang = self:RotateAroundPoint2(pos, ang, anchor, attpos, attang)

            rap_pos:Sub(pos)
            rap_ang:Sub(ang)

            self.IKGunMotionPos = rap_pos
            self.IKGunMotionAng = rap_ang

            pos:Add(rap_pos)
            ang:Add(rap_ang)
        end

        return pos, ang
    else
        return pos, ang
    end
end