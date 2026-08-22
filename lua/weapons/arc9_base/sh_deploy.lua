
function SWEP:Deploy()
    local owner = self:GetOwner()

    if self:GetOwner():IsNPC() then
        return
    end
    owner:SetSaveValue("m_flNextAttack", 0)

    self:ClientDeploy()

    self:InvalidateCache()

    self:SetBaseSettings()

    self:SetNextPrimaryFire(0)
    self:SetNextSecondaryFire(0)
    self:SetAnimLockTime(0)
    self:SetLastMeleeTime(0)
    self:SetRecoilAmount(0)
    self:SetRecoilUp(0)
    self:SetRecoilSide(0)
    self:SetPrimedAttack(false)
    self:SetReloading(false)
    self:SetCycleFinishTime(0)
    self:SetRequestReload(false)
    self:SetEmptyReload(false)
    owner:SetCanZoom(false)
    self:SetHolster_Entity(NULL)
    self:SetHolsterTime(0)

    self:SetFreeAimAngle(Angle(0, 0, 0))
    self:SetLastAimAngle(Angle(0, 0, 0))

    if self:GetProcessedValue("AutoReload", true) then
        self:RestoreClip(math.huge)
    end


    self:SetBurstCount(0)
    self:SetSightAmount(0)
    self:SetCustomize(false)
    self:SetBreath(100)
    self:SetInspecting(false)
    self:SetLoadedRounds(self:Clip1())
    self:SetGrenadeRecovering(false)
    self:SetUBGL(false)
    
    self.StartedFixingJam = nil

    self:SetGrenadePrimed(false)
    self:SetBipod(false)
    self:SetTriggerDown(owner:KeyDown(IN_ATTACK))
    local holsteredtime = CurTime() - self:GetLastHolsterTime()
    self:ThinkHeat(holsteredtime)
    self:DoDeployAnimation()

    if self:GetValue("AnimDraw") then
        self:DoPlayerAnimationEvent(self:GetValue("AnimDraw"))
    end

    if game.SinglePlayer() then
        self:CallOnClient("RecalculateIKGunMotionOffset")
    end

    if SERVER then
        self:CreateShield()

        -- self:NetworkWeapon()
        self:SetTimer(0.25, function()
            self:SendWeapon()
        end)
        if IsValid(owner:GetHands()) then
            owner:GetHands():SetLightingOriginEntity(owner:GetViewModel())
        end
    end

    self:SetShouldHoldType(true)

    self:RunHook("Hook_Deploy")

    if self:LookupPoseParameter("sights") != -1 then self.HasSightsPoseparam = true end
    if self:LookupPoseParameter("firemode") != -1 then self.HasFiremodePoseparam = true end

	-- self.FMHintTimeP = self.FMHintTime or "N/A"
	
	-- self.FMHintTime = CurTime()
	-- print( " " )
	-- print( "DEPLOYED WEAPON" )
	-- print( "Cur. " .. string.format( "%.3f", self.FMHintTime ) )
	-- print( "Pre. " .. string.format( "%.3f", self.FMHintTimeP ) )
	
    return true
end

function SWEP:ClientDeploy()
    if SERVER then return end
    if self:GetOwner() != LocalPlayer() then return end

    if game.SinglePlayer() then
        self:CallOnClient("ClientDeploy")
    end

    if IsValid(self) then
        if self:LookupPoseParameter("sights") != -1 then self.HasSightsPoseparam = true end
        if self:LookupPoseParameter("firemode") != -1 then self.HasFiremodePoseparam = true end
    end
    
    self:DoFSetParams(0)

    gui.EnableScreenClicker(false)

    self:KillModel()
end

function SWEP:InitialDefaultClip()
    -- self:SetClip1(self:GetValue("ClipSize"))
    -- self:GetOwner():GiveAmmo(self:GetValue("ClipSize") * 2, self:GetValue("Ammo"))

        -- arccw code winning again
    local ammmmmo = self:GetValue("Ammo")
    if !ammmmmo then return end
    if engine.ActiveGamemode() == "darkrp" then return end -- DarkRP is god's second biggest mistake after gmod

    if self:GetOwner() and self:GetOwner():IsPlayer() then
        if self.ForceDefaultAmmo then
            self:GetOwner():GiveAmmo(self.ForceDefaultAmmo, ammmmmo)
        else
            self:GetOwner():GiveAmmo(math.Round(self:GetValue("ClipSize")) * GetConVar("arc9_mult_defaultammo"):GetInt(), ammmmmo)
        end
    end
end

local v0 = Vector(0, 0, 0)
local v1 = Vector(1, 1, 1)
local a0 = Angle(0, 0, 0)

function SWEP:ClientHolster()
    if SERVER then return end

    if game.SinglePlayer() then
        self:CallOnClient("ClientHolster")
    end

    self:KillModel()

    local vm = self:GetVM()

    vm:SetSubMaterial()
    vm:SetMaterial()

    for i = 0, vm:GetBoneCount() do
        vm:ManipulateBoneScale(i, v1)
        vm:ManipulateBoneAngles(i, a0)
        vm:ManipulateBonePosition(i, v0)
    end
end

function SWEP:Holster(wep)
    -- May cause issues? But will fix HL2 weapons playing a wrong animation on ARC9 holster
    if !IsValid(self) then return end
    local vm = self:GetVM()
    if !IsValid(vm) then return end
    if game.SinglePlayer() and CLIENT then vm:ResetSequenceInfo() return end

    local owner = self:GetOwner()

    if CLIENT and owner != LocalPlayer() then return end

    if owner:IsNPC() then
        return
    end

    if self:GetReloading() then
        self:CancelReload()
    end

    self:SetCustomize(false)

    if self:GetHolsterTime() > CurTime() then return false end

    if self.NoHolsterOnPrimed and self:GetGrenadePrimed() then return false end

    if self:GetGrenadeRecovering() then -- insta holster if grenade recovering
        self:SetHolsterTime(CurTime())
        self:SetHolster_Entity(wep)

        if SERVER and self:GetProcessedValue("Disposable", true) and self:Clip1() == 0 and self:Ammo1() == 0 and !IsValid(self:GetDetonatorEntity()) then
            self:Remove()
        end
        self:SetLastHolsterTime(CurTime())

        return true 
    end

    if (self:GetHolsterTime() != 0 and self:GetHolsterTime() <= CurTime()) or !IsValid(wep) then
        -- Do the final holster request
        -- Picking up props try to switch to NULL, by the way
        self:SetHolsterTime(0)
        self:SetHolster_Entity(NULL)

        self:KillTimers()
        owner:SetFOV(0, 0)
        owner:SetCanZoom(true)
        self:EndLoop()

        self:ClientHolster()

        if game.SinglePlayer() then
            game.SetTimeScale(1)
        end

        -- if self.SetBreathDSP then
        --     self:GetOwner():SetDSP(0)
        --     self.SetBreathDSP = false
        -- end

        self:RunHook("Hook_Holster")

        if SERVER then
            self:KillShield()
        end

        if SERVER and self:GetProcessedValue("Disposable", true) and self:Clip1() == 0 and self:Ammo1() == 0 and !IsValid(self:GetDetonatorEntity()) then
            self:Remove()
        end

        self:SetLastHolsterTime(CurTime())

        return true
    else
        -- Prepare the holster and set up the timer
        self:KillTimer("ejectat")
        self:SetHolster_Entity(wep)
        if self.QuickSwapTo and wep.SetDoAFastDraw then wep:SetDoAFastDraw(true) end
        if wep.QuickSwapTo then self:SetDoAFastDraw(true) end
        
        local fastdraw = self:GetDoAFastDraw()
        local specialholsterlogic = self:RunHook("Hook_SpecialHolsterLogic")
        if !specialholsterlogic then
            local has_quickholster = self:HasAnimation("holster_quick")
            local holster_animation = self:RunHook("Hook_SelectHolsterAnimation") or (wep.QuickSwapTo and has_quickholster and "holster_quick") or "holster"
            if self:HasAnimation(holster_animation) then
                local holster_mult = fastdraw and !has_quickholster and .75 or 1
                local t, minprogress = self:PlayAnimation(holster_animation, self:GetProcessedValue("DeployTime", true, 1) * holster_mult, true, true)
                self:SetHolsterTime(CurTime() + t * minprogress)
            else
                self:SetHolsterTime(CurTime() + (self:GetProcessedValue("DeployTime", true, 1)))
            end
        end

        local animdrwa = self:GetValue("AnimDraw")

        if animdrwa then
            self:DoPlayerAnimationEvent(animdrwa)
        end

        self:SetInSights(false)
        self:ToggleUBGL(false)
        self:SetCycleFinishTime(0)
    end
end

local holsteranticrash = false

hook.Add("StartCommand", "ARC9_Holster", function(ply, ucmd)
    local wep = ply:GetActiveWeapon()

    if IsValid(wep) and wep.ARC9 then
        if wep:GetHolsterTime() != 0 and wep:GetHolsterTime() <= CurTime() then
            if IsValid(wep:GetHolster_Entity()) then
                wep:SetHolsterTime(-math.huge) -- Pretty much force it to work

                if !holsteranticrash then
                    holsteranticrash = true
                    ucmd:SelectWeapon(wep:GetHolster_Entity()) -- Call the final holster request
                    holsteranticrash = false
                end
            end
        end
    end
end)

local arc9_never_ready = GetConVar("arc9_never_ready")
local arc9_dev_always_ready = GetConVar("arc9_dev_always_ready")

function SWEP:DoDeployAnimation()
    if self.IsQuickGrenade then
        if self:HasAnimation("quicknade") or self:GetProcessedValue("Detonator", true) then self:QuicknadeDeploy() return end -- a real quicknade

        local owner = self:GetOwner() -- a fake one, this thing to holster after throwing
        self.WasThrownByBind = owner.ARC9QuickthrowPls
        owner.ARC9QuickthrowPls = nil
        
        owner.ARC9LastSelectedGrenade = self:GetClass()
    end

    if !arc9_never_ready:GetBool() and ((arc9_dev_always_ready:GetBool() and self:Clip1() > 0) or !self:GetReady()) and self:HasAnimation("ready") then
        local t, min = self:PlayAnimation("ready", self:GetProcessedValue("DeployTime", true, 1), true)

        self:SetReadyTime(CurTime() + (t * min))
        self:SetReady(true)
    else
        if self:GetDoAFastDraw() then
            local has_fastdraw = self:HasAnimation("draw_quick")
            local draw_anim = has_fastdraw and "draw_quick" or "draw"
            local draw_mult = has_fastdraw and 1 or .75
            self:PlayAnimation(draw_anim, self:GetProcessedValue("DeployTime", true, 1) * draw_mult, true)
        else
            self:PlayAnimation("draw", self:GetProcessedValue("DeployTime", true, 1), true)
        end
        self:SetDoAFastDraw(false)
        self:SetReady(true)
    end
    
    if game.SinglePlayer() then
        self:CallOnClient("ClientDeploy")
    end
end

function SWEP:QuicknadeDeploy()
    local owner = self:GetOwner()
    self.ViewModelPos = Vector(0, 0, 0)
    self.ViewModelAng = Angle(0, 0, 0)

    owner.ARC9LastSelectedGrenade = self:GetClass()

    local WasDrawnByBind = owner:KeyDown(IN_GRENADE1) or owner.ARC9QuickthrowPls
    owner.ARC9QuickthrowPls = nil 
    
    local anim, det = "draw", self:GetProcessedValue("Detonator", true) and IsValid(self:GetDetonatorEntity())
    if WasDrawnByBind and self:HasAnimation("quicknade") then anim = "quicknade" end
    if det then anim = self:HasAnimation(anim .. "_detonator") and anim .. "_detonator" or self:HasAnimation("draw_detonator") and "draw_detonator" or "draw" end

    if WasDrawnByBind then
        self.WasThrownByBind = true
        self:PlayAnimation(anim, 1, true)

        if !det then
            self:SetGrenadePrimed(true)
            self:SetGrenadePrimedTime(CurTime())
            self:SetGrenadeTossing(owner:KeyDown(IN_ATTACK2))
        else
            self:TouchOff()
        end
    else
        self:PlayAnimation(anim, self:GetProcessedValue("DeployTime", true, 1), true)
        self:SetReady(true)
    end
end
