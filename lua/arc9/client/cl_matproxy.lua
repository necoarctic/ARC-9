matproxy.Add({
    name = "CustomCamo",
    init = function( self, mat, values )
        -- Store the name of the variable we want to set
        self.DetailResult = values.camotexture
        self.ScaleResult = values.camoscale
        self.BlendResult = values.blend

        if self.DetailResult then
            self.DefaultTexture = mat:GetTexture(self.DetailResult)
        end

        if self.ScaleResult then
            self.DefaultScale = mat:GetFloat(self.ScaleResult)
        end

        if self.BlendResult then
            self.DefaultBlend = mat:GetFloat(self.BlendResult)
        end
    end,
    bind = function( self, mat, ent )
        if self.DetailResult and ent.CustomCamoTexture then
            -- mat:SetString(self.DetailResult, self.CustomCamoTexture)
            mat:SetTexture(self.DetailResult, ent.CustomCamoTexture)
            self.ShouldRecomputeIfSet = true
        elseif self.DetailResult then
            self.DefaultTexture = nil
            if !self.DefaultTexture then
                mat:SetUndefined(self.DetailResult)
                if self.ShouldRecomputeIfSet then
                    mat:Recompute()
                    self.ShouldRecomputeIfSet = false
                end
            else
                mat:SetTexture(self.DetailResult, self.DefaultTexture)
            end
        end

        if self.ScaleResult and ent.CustomCamoScale then
            mat:SetFloat(self.ScaleResult, ent.CustomCamoScale)
            self.ShouldRecomputeIfSet = true
        elseif self.ScaleResult then
            if self.DefaultScale then
                mat:SetFloat(self.ScaleResult, self.DefaultScale)
            else
                mat:SetUndefined(self.ScaleResult)
                if self.ShouldRecomputeIfSet then
                    mat:Recompute()
                    self.ShouldRecomputeIfSet = false
                end
            end
        end

        if self.BlendResult and ent.CustomCamoBlend then
            mat:SetFloat(self.BlendResult, ent.CustomCamoBlend)
            self.ShouldRecomputeIfSet = true
        elseif self.BlendResult then
            if self.DefaultBlend then
                mat:SetFloat(self.BlendResult, self.DefaultBlend)
            else
                mat:SetUndefined(self.DefaultBlend)
                if self.ShouldRecomputeIfSet then
                    mat:Recompute()
                    self.ShouldRecomputeIfSet = false
                end
            end
        end

    end
})





--[[ 
    Advanced camo usage:


    "$detailblendmode" "4"
    "$detailblendfactor" "0.5"
    "$detailscale" "1.0"

    "$detailangle" 90.0
    "$attname" eft_ak12_stock_tube

    ...

    "Arc9CustomCamoAdvanced" 
        {
            "camoTexture" $detail
            "camoScale" $detailscale
            "camoAngle" $detailangle
            "camoBlendMode" $detailblendmode
            "camoBlendFactor" $detailblendfactor
            "phonk" $phongboost
            "color" "[0.99 0.99 0.99]"
        }

        "TextureTransform"
        {
            "rotateVar" "$detailangle"
            "resultVar" "$detailtexturetransform"
        }
        
]]--

matproxy.Add({
    name = "Arc9CustomCamoAdvanced",
    init = function( self, mat, values )
        -- Store the name of the variable we want to set
        self.DetailResult = values.camotexture or ""
        self.PhongResult = values.phonk or ""
        self.ScaleResult = values.camoscale
        self.AngleResult = values.camoangle
        self.BlendModeResult = values.camoblendmode
        self.BlendFactorResult = values.camoblendfactor
        self.AttName = mat:GetString("$attname") or values.attname or ""
        if self.PhongResult then self.DefaultPhong = mat:GetFloat(self.PhongResult) end
        if self.ScaleResult then self.DefaultScale = mat:GetFloat(self.ScaleResult) end
        if self.AngleResult then self.DefaultAngle = mat:GetFloat(self.AngleResult) end
        if self.BlendFactorResult then self.DefaultFactor = mat:GetFloat(self.BlendFactorResult) end

        if self.DetailResult then self.DefaultTexture = mat:GetTexture(self.DetailResult) end
    end,
    bind = function( self, mat, ent )
        local wep, camo, camotex, camoscale, camorotate

        if IsValid(ent) then
            if ent.weapon and ent.weapon.ARC9 then
                wep = ent.weapon
            else
                local owner = ent:GetOwner()
                if IsValid(owner) then
                    local weapon = owner:GetActiveWeapon()
                    if IsValid(weapon) then wep = weapon end
                end
            end

            if wep then
                local maybeadress = ent.slottbl and ent.slottbl.Address
                camo = wep.GetAdvancedCamo and wep:GetAdvancedCamo(self.AttName, maybeadress)
                if camo and !camo.Texture then camo = nil end
                if !camo and ent.CustomCamoTexture and wep.AdvancedCamoCache == false then camo = { Texture = ent.CustomCamoTexture } end -- fallback if regular camo slot exists
            end
        end

        if camo and camo.Texture and self.DetailResult then
            -- mat:SetString(self.DetailResult, camo)
            mat:SetTexture(self.DetailResult, camo.Texture)
            -- if self.PhongResult then mat:SetFloat(self.PhongResult, 0.6) end
            if self.PhongResult then 
                mat:SetFloat(self.PhongResult, (self.DefaultPhong or 1) * (camo.PhongMult or 0.1)) 
                if camo.PhongMult and camo.PhongMult <= 0.1 then ent.PhongMultSoLowerEnvmapPls = true end
            end
            if self.ScaleResult then mat:SetFloat(self.ScaleResult, (self.DefaultScale or 1) * (camo.Scale or 1)) end
            if self.AngleResult then mat:SetFloat(self.AngleResult, (self.DefaultAngle or 0) + (camo.Rotate or 0)) end
            if self.BlendModeResult then mat:SetFloat(self.BlendModeResult, camo.BlendMode or 4) end
            if self.BlendFactorResult then mat:SetFloat(self.BlendFactorResult, (self.DefaultFactor or 1) * (camo.Factor or 0.5)) end
            
            self.ShouldRecomputeIfSet = true
        elseif self.DetailResult then
            self.DefaultTexture = nil
            if !self.DefaultTexture then
                mat:SetUndefined(self.DetailResult)
                mat:SetFloat(self.PhongResult, self.DefaultPhong)
                ent.PhongMultSoLowerEnvmapPls = nil
                if self.ShouldRecomputeIfSet then
                    mat:Recompute()
                    self.ShouldRecomputeIfSet = false
                end
            else
                mat:SetTexture(self.DetailResult, self.DefaultTexture)

                if self.PhongResult then mat:SetFloat(self.PhongResult, self.DefaultPhong or 0) ent.PhongMultSoLowerEnvmapPls = nil end
                if self.ScaleResult then mat:SetFloat(self.ScaleResult, self.DefaultScale or 0) end
                if self.AngleResult then mat:SetFloat(self.AngleResult, self.DefaultAngle or 0) end
                if self.BlendModeResult then mat:SetFloat(self.BlendModeResult, 4) end
                if self.BlendFactorResult then mat:SetFloat(self.BlendFactorResult, self.DefaultFactor or 0) end
            end
        end
    end
})

matproxy.Add({
    name = "ARC9_Heat",
    init = function( self, mat, values )
        self.BlendResult = values.blend
    end,

    bind = function( self, mat, ent )
        if IsValid(ent) and IsValid(ent.weapon) then ent = ent.weapon end

        if IsValid(ent) and IsValid(ent:GetOwner()) and IsValid(ent:GetOwner():GetActiveWeapon()) then
            local weapon = ent:GetOwner():GetActiveWeapon()
            if weapon and weapon.ARC9 and weapon:GetProcessedValue("Overheat", true) then
                mat:SetFloat(self.BlendResult, (math.ease.InExpo(weapon:GetHeatAmount() / weapon:GetProcessedValue("HeatCapacity", true))) * 2)
            end
        else
            mat:SetFloat(self.BlendResult, 0)
        end
    end
})


local lastPos = Vector()
local lastValue = 0

-- hyperoptimization +1000 fps
local lerp = Lerp
local ENTITY = FindMetaTable("Entity")
local entityGetPos = ENTITY.GetPos
local renderGetLightColor = render.GetLightColor
local vectorIsEqualTol = FindMetaTable("Vector").IsEqualTol
local mathmin = math.min

matproxy.Add( {
	name = "Arc9EnvMapTint",
	
	init = function(self, mat, values)
		local color = {1, 1, 1} 

		if (values.color != nil) then
			color = string.Explode(" ", string.Replace(string.Replace(values.color, "[", ""), "]", ""))
		end

		self.min = values.min or 0
		self.max = values.max or 1
		self.color = Vector(color[1], color[2], color[3])
        
		--mat:SetTexture("$envmap", values.envmap or "arc9/shared/envmaps/specularity_50")
		if (values.envmap != "env_cubemap") then
		   mat:SetTexture("$envmap", values.envmap or "arc9/shared/envmaps/specularity_50")
		else
		   mat:SetString("$envmap", "env_cubemap")
		end
	end,

	bind = function(self, mat, ent)
		if !IsValid(ent) then return end
        local getpos = entityGetPos(ent)
		if !vectorIsEqualTol(lastPos, getpos, 1) then
			local c = renderGetLightColor(getpos)
			lastValue = (c.x * 0.2126) + (c.y * 0.7152) + (c.z * 0.0722)
			lastValue = mathmin(lastValue * 2, 1)
			lastPos = getpos
		end
		ent.m_Arc9EnvMapTint = lerp(10 * RealFrameTime(), ent.m_Arc9EnvMapTint || 0, lastValue)
        if ent.PhongMultSoLowerEnvmapPls then ent.m_Arc9EnvMapTint = ent.m_Arc9EnvMapTint * 0.3 end
		mat:SetVector("$envmaptint", self.color * lerp(ent.m_Arc9EnvMapTint, self.min, self.max))
	end
})

----- Add this to your VMT to fix garbage/shitty reflection

    -- "Proxies"
    -- {
        -- "Arc9EnvMapTint"
        -- {
            -- "specularity" "0.5"
            -- "min" "0"
            -- "max" "0.2" // Change this if its too bright in game
        -- }
    -- }
-- }


matproxy.Add({
    name = "arc9_scope_alpha",
    init = function(self, mat, values)
        -- self.ResultTo = values.resultvar

		local color = {1, 1, 1} 

		if (values.color != nil) then
			color = string.Explode(" ", string.Replace(string.Replace(values.color, "[", ""), "]", ""))
		end

		self.min = values.min or 0
		self.max = values.max or 1
		self.minfresnel = values.minfresnel or 0
		self.maxfresnel = values.maxfresnel or 0.17
		self.color = Vector(color[1], color[2], color[3])
    end,
    bind = function(self, mat, ent)
        local ply = LocalPlayer()

        if IsValid(ply) then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) and weapon.ARC9 then
                local sa = weapon:GetSightAmount()
                local amt = 1 - sa * 0.25
                
                if !IsValid(ent) then return end
                local getpos = entityGetPos(ent)
                if !vectorIsEqualTol(lastPos, getpos, 1) then
                    local c = renderGetLightColor(getpos)
                    lastValue = (c.x * 0.2126) + (c.y * 0.7152) + (c.z * 0.0722)
                    lastValue = mathmin(lastValue * 2, 1)
                    lastPos = getpos
                end
                ent.m_Arc9EnvMapTint = lerp(10 * RealFrameTime(), ent.m_Arc9EnvMapTint || 0, lastValue)
                mat:SetVector("$envmaptint", self.color * lerp(ent.m_Arc9EnvMapTint * amt, self.min, self.max))
                
                mat:SetFloat("$envmapfresnel", lerp(sa, self.maxfresnel, self.minfresnel))
            end
            
        end
   end
})