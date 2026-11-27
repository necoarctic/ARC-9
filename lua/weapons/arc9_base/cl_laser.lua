local defaulttracemat = Material("arc9/laser2")
local defaultflaremat = Material("sprites/light_glow02_add", "mips smooth")
local lasercolorred = Color(255, 0, 0)
local lasercolor200 = Color(200, 200, 200)
local irlasercolor = Color(106, 255, 218)

local function checknvg(wpn)
    local lp = LocalPlayer()
    if lp.quadnodsonlight or lp:GetNWBool("nvg_on", false) then return true end -- arctic nvgs and mw nvgs
    if lp.EZarmor and lp.EZarmor.effects and lp.EZarmor.effects.nightVision then return true end -- jmod
    local sight = wpn:GetSight()
    if sight and wpn:GetSightAmount() > 0.8 and !wpn.Peeking and sight.atttbl and sight.atttbl.RTScopeNightVision then return true end

    return false
end


function SWEP:DrawLaser(pos, dir, atttbl, behav)
    behav = behav or false
    local strength = atttbl.LaserStrength or 1
    local flaremat = atttbl.LaserFlareMat or defaultflaremat
    local lasermat = atttbl.LaserTraceMat or defaulttracemat
    
    render.SetStencilEnable(false) -- no flashlights in laser beams

    local width = math.Rand(0.1, 0.5) * strength

    local nvgon
    if atttbl.LaserIR then
        nvgon = checknvg(self)
        if nvgon then
            width = width + 0.25
            strength = strength + 1
        end
    end

    if strength == 0 then return end

    local owner = self:GetOwner()

    local dist = 5000

    local tr = util.TraceLine({
        start = pos,
        endpos = pos + (dir * 15000),
        mask = MASK_SHOT,
        filter = owner
    })

    if tr.StartSolid then return end

    local hit = tr.Hit
    local hitpos = tr.HitPos

    if tr.HitSky then
        hit = false
        hitpos = pos + (dir * dist)
    end

    local truedist = math.min((tr.Fraction or 1) * 15000, dist)
    local fraction = truedist / dist

    local laspos = pos + (dir * truedist)

    if self.LaserAlwaysOnTargetInPeek and owner == LocalPlayer() then
        local sightamount = self:GetSightAmount()
        if sightamount > 0 and self.Peeking then

            local fuckingreloadprocessinfluence = 1 - self:GetReloadingProgress()

            local trrr = util.TraceLine({
                start = self:GetShootPos(),
                endpos = self:GetShootPos() + (self:GetShootDir():Forward() * 15000),
                mask = MASK_SHOT,
                filter = owner
            })

            local realhitpos = trrr.HitPos
            laspos = LerpVector(sightamount * fuckingreloadprocessinfluence, laspos, realhitpos)
            hitpos = LerpVector(sightamount * fuckingreloadprocessinfluence, hitpos, realhitpos)
        end
    end

    local color = atttbl.LaserColor or lasercolorred
	local colorplayer = !owner:IsNPC() and owner:GetWeaponColor():ToColor()

	if (atttbl.LaserColorPlayer or atttbl.LaserPlayerColor) then color = colorplayer or color end

    if nvgon and atttbl.LaserIR then
        color = irlasercolor
    end

    if !behav then
        render.SetMaterial(lasermat)
        render.DrawBeam(pos, laspos, width * 0.2, 0, fraction, lasercolor200)
        render.DrawBeam(pos, laspos, width, 0, fraction, color)
    end

    if hit then
        local rad = math.Rand(4, 6) * strength * math.max(fraction * 7, 1)
        local dotcolor = color
        local whitedotcolor = lasercolor200

        dotcolor.a = 255 - math.min(fraction * 30, 250)
        whitedotcolor.a = 255 - math.min(fraction * 25, 250)

        render.SetMaterial(flaremat)

        render.DrawSprite(hitpos, rad, rad, dotcolor)
        render.DrawSprite(hitpos, rad * 0.4, rad * 0.3, whitedotcolor)
    end
end

function SWEP:DrawLasers(wm, behav)
    local owner = self:GetOwner()
    if !wm and !IsValid(owner) then return end
    if !wm and owner:IsNPC() then return end
    local lp = LocalPlayer()
    if wm and owner == lp and self.LastWMDrawn != FrameNumber() then return end
    if wm and owner == lp and !lp:ShouldDrawLocalPlayer() then return end

    local mdl = self.VModel

    if wm then
        mdl = self.WModel
    end

    if !mdl then
        self:KillModel()
        self:SetupModel(wm)

        mdl = self.VModel

        if wm then
            mdl = self.WModel
        end

        if !mdl then return end -- still not valid?? 
    end

    local wmnotdrawn = wm and self.LastWMDrawn != FrameNumber() and owner != lp
    local nvgon = checknvg(self)

    for _, model in ipairs(mdl) do
        local slottbl = model.slottbl
        local atttbl = self:GetFinalAttTable(slottbl)

        if atttbl.Laser then
            local pos, ang = self:GetAttachmentPos(slottbl, wm, false)
            if wmnotdrawn then pos, ang = owner:EyePos(), owner:EyeAngles() end

            model:SetPos(pos)
            model:SetAngles(ang)

            local a
            if wmnotdrawn then
                a = {
                    Pos = pos,
                    Ang = ang
                }
                
                a.Ang:RotateAroundAxis(a.Ang:Up(), -90)
            elseif atttbl.LaserAttachment then
                a = model:GetAttachment(atttbl.LaserAttachment)
            else
                a = {
                    Pos = model:GetPos(),
                    Ang = model:GetAngles()
                }

                a.Ang:RotateAroundAxis(a.Ang:Up(), -90)
            end

            if !a then return end

            local lasercorrectionangle = model.LaserCorrectionAngle
            local lasang = a.Ang

            if lasercorrectionangle then
                local up, right, forward = lasang:Up(), lasang:Right(), lasang:Forward()

                lasang:RotateAroundAxis(up, lasercorrectionangle.p)
                lasang:RotateAroundAxis(right, lasercorrectionangle.y)
                lasang:RotateAroundAxis(forward, lasercorrectionangle.r)
            end

            if self.LaserCorrectBySightAng and self:GetInSights() then
                local sight = self:GetSight()
                if sight and sight.Ang then
                    local up, right, forward = lasang:Up(), lasang:Right(), lasang:Forward()

                    lasang:RotateAroundAxis(up, sight.Ang.y)
                    lasang:RotateAroundAxis(right, sight.Ang.p)
                    -- lasang:RotateAroundAxis(forward, sight.Ang.r)
                end
            end

            local LaserCorrectIdle = self.LaserCorrectIdle

            if LaserCorrectIdle and owner == LocalPlayer() then
                LaserCorrectIdle = LaserCorrectIdle * (1 - (math.max(self.CustomizeDelta, self:GetSightAmount())))

                local vm = self:GetVM()
                local bone = slottbl.Bone

                if bone and IsValid(vm) then
                    local boneindex = vm:LookupBone(bone)
                    local bonemat = vm:GetBoneMatrix(boneindex)
                    if bonemat then
                        local bang = bonemat:GetAngles()

                        local up, right, forward = bang:Up(), bang:Right(), bang:Forward()
                        lasang:RotateAroundAxis(forward, -LaserCorrectIdle.p)
                        lasang:RotateAroundAxis(right, LaserCorrectIdle.y)
                        lasang:RotateAroundAxis(up, LaserCorrectIdle.r)
                    end
                end
            end

			local color = atttbl.LaserColor or lasercolorred
			local colorplayer = !owner:IsNPC() and owner:GetWeaponColor():ToColor()

			if (atttbl.LaserColorPlayer or atttbl.LaserPlayerColor) then color = colorplayer or color end

            local flaresize = 0.075
            if atttbl.LaserIR then
                flaresize = 0
                if nvgon then flaresize = 0.2 color = irlasercolor end
            end
			
            self:DrawLightFlare(a.Pos, lasang, color, flaresize, !wm, false, -lasang:Right())

            if !wm or owner == lp or wm and owner:IsNPC() then
                if behav then
                    self:DrawLaser(a.Pos, self:GetShootDir():Forward(), atttbl, behav)
                else
                    self:DrawLaser(a.Pos, -lasang:Right(), atttbl, behav)
                end
            else
                self:DrawLaser(a.Pos, -lasang:Right(), atttbl, behav)
            end
        end
    end
end