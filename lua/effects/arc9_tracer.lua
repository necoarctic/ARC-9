EFFECT.StartPos = Vector(0, 0, 0)
EFFECT.EndPos = Vector(0, 0, 0)
EFFECT.StartTime = 0
EFFECT.LifeTime = 0.2
EFFECT.LifeTime2 = 0.2
EFFECT.DieTime = 0
EFFECT.Color = Color(255, 255, 255)
EFFECT.Speed = 15000
EFFECT.Size = 1

local head = Material("effects/whiteflare")
local tracer = Material("arc9/tracer")
--local smoke = Material("effects/smoke")
local smoke = Material("effects/fas_smoke_beam")
local smoker, smoked = Color(155, 155, 155, 155), Color(155, 155, 155, 0)

function EFFECT:Init(data)
    local hit = data:GetOrigin()
    local wep = data:GetEntity()

    if !IsValid(wep) then return end
    if !wep.ARC9 then return end

    local speed = data:GetScale()
    -- local start = !ARC9.RTScopeRender and (wep.GetTracerOrigin and wep:GetTracerOrigin()) or data:GetStart()
    local viewsetup = render.GetViewSetup()
    local fucky = viewsetup and viewsetup.fovviewmodel and viewsetup.fovviewmodel > 10
    local start = fucky and (wep.GetTracerOrigin and wep:GetTracerOrigin()) or data:GetStart() + Vector(0, 0, -20)

    local diff = hit - start
    self.Dir = diff:GetNormalized()
    local hitt = util.QuickTrace(hit, self.Dir)

    self.EndPos = hitt.HitPos
    if hitt.HitSky then
        hit = start + self.Dir * 32768
        self.EndPos = hit
    end

    if speed > 0 then
        self.Speed = speed
    end

    self.LifeTime = (hit - start):Length() / self.Speed
    self.StartTime = UnPredictedCurTime()
    self.DieTime = UnPredictedCurTime() + math.max(self.LifeTime, self.LifeTime2)

    self.StartPos = start

    self.Weapon = wep

    -- Sometimes it freaks out and, I dunno, gets invalid
    if wep.GetProcessedValue then
        self.Color = wep:GetProcessedValue("TracerColor", true)

        self.Size = wep:GetProcessedValue("TracerSize", true)
    end
end

function EFFECT:Think()
    return self.DieTime > UnPredictedCurTime()
end

local Lerp = Lerp
local function LerpColor(d, col1, col2)
    local r = Lerp(d, col1.r, col2.r)
    local g = Lerp(d, col1.g, col2.g)
    local b = Lerp(d, col1.b, col2.b)
    local a = Lerp(d, col1.a, col2.a)
    return Color(r, g, b, a)
end

function EFFECT:Render()
    if self.Cancelled or (IsValid(self.Weapon) and self.Weapon.TracerCancelled) then self.Cancelled = true return end
    if !self.Dir then self.Cancelled = true return end
    local d = (UnPredictedCurTime() - self.StartTime) / self.LifeTime
    local d2 = (UnPredictedCurTime() - self.StartTime) / self.LifeTime2
    local startpos = self.StartPos + (d * 0.1 * (self.EndPos - self.StartPos))
    local endpos = self.StartPos + (d * (self.EndPos - self.StartPos))
    local size = self.Size * math.Clamp(math.log(EyePos():DistToSqr(endpos) - math.pow(256, 2)), 0, math.huge)

    -- debugoverlay.Axis( startpos, Angle(), 16, 0, true )
    -- debugoverlay.Axis( endpos, Angle(), 16, 0, true )
    -- debugoverlay.Line( startpos, endpos, 0.1, color_white, true )
    
    local col = self.Color --LerpColor(d, self.Color, Color(0, 0, 0, 0))
    local col2 = LerpColor(d2, smoker, smoked)

    local vel = self.Dir * self.Speed - LocalPlayer():GetVelocity()
    local dot = math.abs(EyeAngles():Forward():Dot(vel:GetNormalized()))
    --dot = math.Clamp(((dot * dot) - 0.25) * 5, 0, 1)
    local headsize = size * dot * 2
    render.SetMaterial(head)
    render.DrawSprite(endpos, headsize, headsize, col)

    local tail = (self.Dir * math.min(self.Speed / 25, 512, (endpos - startpos):Length() - 64))
    render.SetMaterial(tracer)
    render.DrawBeam(endpos, endpos - tail, size * 0.75, 1, 0, col)

    render.SetMaterial(smoke)
    render.DrawBeam( endpos - tail, startpos, size * d2, 0, 1, col2)
end
