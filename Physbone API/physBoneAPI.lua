-- Physbone 2.0 pre-release 2 By ChloeSpacedOut <3
-- Some funny additions made by Superpowers04 :3
local physBone = {
	-- DO NOT ENABLE THIS UNLESS YOU KNOW WHAT YOU'RE DOING, THIS APPENDS THE INDEX OF THE PHYSBONE TO IT'S NAME IF THERE'S A DUPLICATE AND CAN CAUSE ISSUES
	allowDuplicates=false,
	children={},index={}}
local physBoneIndex = physBone.index
local boneID = 0
local lastDeltaTime,lasterDeltaTime,lastestDeltaTime,lastDelta = 1,1,1,1
local physBonePresets = {}
local debugMode = false

-- Physbone metatable
local physBoneBase = {
	setRotMod =
		function(self,data)
			self.rotMod = data
			if host:isHost() and self.path.PB_Debug_Direction then
				self.path.PB_Debug_Direction:setRot(-data)
			end
			return self
		end,
	getRotMod =
		function(self)
			return self.upsideDown
		end,
	setMass =
		function(self,data)
			self.mass = data
			return self
		end,
	getMass =
		function(self)
			return self.mass
		end,
	setGravity =
		function(self,data)
			self.gravity = data
			return self
		end,
	getGravity =
		function(self)
			return self.gravity
		end,
	setSpringForce =
		function(self,data)
			self.springForce = data
			return self
		end,
	getSpringForce =
		function(self)
			return self.springForce
		end,
	setEquilibrium =
		function(self,data)
			self.equilibrium = data
			if host:isHost() and self.path.PB_Debug_SpringForce then
				local springForceGroup = self.path.PB_Debug_SpringForce
				local pivot = springForceGroup:getPivot()
				local mat = matrices.mat4()
				mat:scale(1,self.springForce/50,1)
					:translate(-pivot)
					:rotate(0,0,data.x+90)
					:rotate(0,data.y,0)
					:translate(pivot)
				springForceGroup:setMatrix(mat)
			end
			return self
		end,
	getEquilibrium =
		function(self)
			return self.equilibrium
		end,
	setAirResistance =
		function(self,data)
			self.airResistance = data
			return self
		end,
	getAirResistance =
		function(self)
			return self.airResistance
		end,
	setSimSpeed =
		function(self,data)
			self.simSpeed = data
			return self
		end,
	getSimSpeed =
		function(self)
			return self.simSpeed
		end,
	setForce =
		function(self,data)
			self.force = data
			return self
		end,
	getForce =
		function(self)
			return self.force
		end,
	setVecMod =
		function(self,data)
			self.vecMod = data
			return self
		end,
	getVecMod =
		function(self)
			return self.vecMod
		end,
	updateWithPreset = 
		function(self,presetID)
			assert(presetID,'error making physBone: your preset can not be nil')
			local preset = type(presetID) == "table" and presetID or physBonePresets[presetID]
			assert(preset,'error making physBone: preset "'..tostring(presetID)..'" does not exist')
			for k,v in pairs {"rotMod","mass","gravity","airResistance","simSpeed","equilibrium","springForce","force","vecMod"} do
				if preset[v] then
					local funct = "set"..string.upper(string.sub(v,0,1))..string.sub(v,2,-1)
					self[funct](self,preset[v])
				end
			end
			return self
		end,
	remove =
		function(self)
			local path = self.path
			local ID = self.ID
			boneID = 0
			local newIndex = {}
			for k,v in pairs(physBoneIndex) do
				if v ~= ID then
					boneID = boneID + 1
					newIndex[boneID] = v
				end
			end
			physBoneIndex = newIndex
			physBone[ID] = nil
			for k,v in pairs(path:getChildren()) do
				v:setRot(v:getRot())
			end
			path:setRot(0,0,0)
		end
}
local physBoneMT = {__index=physBoneBase}

-- Internal Function: Returns physbone metatable from set values
physBone.newPhysBoneFromValues = function(self,path,rotMod,mass,gravity,airResistance,simSpeed,equilibrium,springForce,force,vecMod,id,name)
	if(self ~= physBone) then
		-- Literally just offsets everything so self is used as the base 
		path,rotMod,mass,gravity,airResistance,simSpeed,equilibrium,springForce,force,vecMod,id,name = self,path,rotMod,mass,gravity,airResistance,simSpeed,equilibrium,springForce,force,vecMod,id,name
	end
	assert(user:isLoaded(),'error making physBone: attempt to create part before entity init')
	assert(path,'error making physBone: part is null!')
	local ID = name or path:getName()
	local pos = path:partToWorldMatrix():apply()
	return setmetatable({
		index=nil,
		ID = ID,
		path = path,
		pos = pos,
		lastPos = pos:copy(),
		rotMod = rotMod,
		mass = mass,
		gravity = gravity,
		airResistance = airResistance,
		simSpeed = simSpeed,
		equilibrium = equilibrium,
		springForce = springForce,
		force = force,
		vecMod = vecMod
	},physBoneMT)
end

-- Internal Function: Creates a physbone based on the provided metatable
physBone.addPhysBone = function(self,part,index)
	if self ~= physBone then
		index,part=part,index
	end
	assert(part,'error making physBone: part is null!')

	local ID = part.ID
	if(index == nil) then
		boneID = boneID + 1
		index = boneID
	end
	assert(not physBoneIndex[index],'error adding physBone: a physBone with index "'..index..'" already exists')
	physBoneIndex[index] = ID
	part.index = index
	physBone[ID] = part
	return part
end

-- Creates a new physBone
physBone.newPhysBone = function(self,part,physBonePreset)
	if self ~= physBone then
		physBonePreset,part=part,self
	end
	assert(part,'error making physBone: part is null!')
	local ID = part:getName()

	if(physBone.allowDuplicates and physBone[ID]) then
			ID = ID..boneID+1
	end
	assert(not physBone[ID],'error making physBone: this physBone "'..ID..'" already exists')
	assert(physBonePreset,'error making physBone: your preset can not be nil')
	local preset = type(physBonePreset) == "table" and physBonePreset or physBonePresets[physBonePreset]
	assert(preset,'error making physBone: preset "'..tostring(physBonePreset)..'" does not exist')
	part:setRot(0,90,0)
	local p = physBone:addPhysBone(
		physBone.newPhysBoneFromValues(part,preset.rotMod,preset.mass,preset.gravity,preset.airResistance,preset.simSpeed,preset.equilibrium,preset.springForce,preset.force,preset.vecMod,boneID,ID)
	)
	if host:isHost() then
		physBone.addDebugParts(part,preset)
	end
	return p
end

-- Returns your physBone
physBone.getPhysBone = function(self,part)
	if self ~= physBone then
		part = self
	end
	assert(part,'cannot get physBone: part is null!')
	local ID = self:getName()
	assert(physBone[ID],('cannot get physBone: this part does not have a physBone'))
	return physBone[ID]
end

-- Creates a new or sets the value of an existing preset
physBone.setPreset = function(self,ID,rotMod,mass,gravity,airResistance,simSpeed,equilibrium,springForce,force,vecMod)
	local presetCache = {}
	local references = {rotMod = rotMod, mass = mass, gravity = gravity, airResistance = airResistance, simSpeed = simSpeed, equilibrium = equilibrium, springForce = springForce, force = force, vecMod = vecMod}
	local fallbacks = {rotMod = vec(0,0,0), mass = 1, gravity = -9.81, airResistance = 0.1, simSpeed = 1, equilibrium = vec(0,0), springForce = 0, force = vec(0,0,0), vecMod = vec(1,1,1)}
	for valID, fallbackVal in pairs(fallbacks) do
		presetVal = references[valID]
		if presetVal then
			presetCache[valID] = presetVal
		else
			presetCache[valID] = fallbackVal
		end
	end
	physBonePresets[ID] = presetCache
end

-- Removes an existing preset
physBone.removePreset = function(self,ID)
	if not physBonePresets[ID] then error('error removing preset: preset "'..ID..'" does not exist') end
	physBonePresets[ID] = nil
end

-- Default presets
physBone:setPreset("physBone")
physBone:setPreset("PhysBone")
physBone:setPreset("physBoob",vec(-90,0,0),2,nil,0.5,nil,nil,200)
physBone:setPreset("PhysBoob",vec(-90,0,0),2,nil,0.5,nil,nil,200)
physBone:setPreset("physEar",vec(0,180,180),2,nil,0.5,nil,vec(0,90),120)
physBone:setPreset("PhysEar",vec(0,180,180),2,nil,0.5,nil,vec(0,90),120)

-- models API function: method by GS
local old_class_index = figuraMetatables.ModelPart.__index
local class_methods = {
	newPhysBone = function(self,physBonePreset)
		return physBone:newPhysBone(self,physBonePreset)
	end,
	getPhysBone = function(self)
		return physBone:getPhysBone(self)

	end
}

function figuraMetatables.ModelPart:__index(key)
	if class_methods[key] then
		return class_methods[key]
	else
		return old_class_index(self, key)
	end
end
--

-- Generates a physBone's debug model
local testTexture = textures:newTexture("test",1,1):setPixel(0,0,vec(1,1,1))
function physBone.addDebugParts(part,preset)
	local pivotGroup = part:newPart("PB_Debug_Pivot","Camera")
	pivotGroup:newSprite("pivot")
		:setTexture(testTexture,1,1)
		:setColor(1,0,0)
		:setRenderType("EMISSIVE_SOLID")
		:setMatrix(matrices.mat4():translate(0.5,0.5,0.5):scale(0.5,0.5,0.5):rotate(0,0,0) * 0.1)

	local directionGroup = part:newPart("PB_Debug_Direction")
	for k = 3, 6 do
		directionGroup:newSprite("line"..k)
			:setTexture(testTexture,1,1)
			:setRenderType("EMISSIVE_SOLID")
			:setMatrix(matrices.mat4():translate(0.5,0,0.5):scale(0.5,3,0.5):rotate(0,k*90,0) * 0.12)
	end
	directionGroup:setRot(-preset.rotMod)
	local springForceGroup = part:newPart("PB_Debug_SpringForce")
	for k = 3, 6 do
		springForceGroup:newSprite("line"..k)
			:setTexture(testTexture,1,1)
			:setColor(0,0,1)
			:setRenderType("EMISSIVE_SOLID")
			:setMatrix(matrices.mat4():translate(0.5,0,0.5):scale(0.25,3,0.25):rotate(0,k*90,0) * 0.11)
	end
	local pivot = springForceGroup:getPivot()
	local mat = matrices.mat4()
	mat:translate(-pivot)
		:scale(1,preset.springForce/50,1)
		:rotate(0,0,preset.equilibrium.x+90)
		:rotate(0,preset.equilibrium.y,0)
		:translate(pivot)
	springForceGroup:setMatrix(mat)

	for k,v in pairs({"PB_Debug_Pivot","PB_Debug_Direction","PB_Debug_SpringForce"}) do
		part[v]:setVisible(false)
	end
end

-- Pendulum object initialization
events.entity_init:register(function()
	local function findCustomParentTypes(path)
		for _,part in pairs(path:getChildren()) do
			local ID = part:getName()
			for presetID,preset in pairs(physBonePresets) do
				if ID:sub(0,#presetID) == presetID then
					physBone.newPhysBone(part,preset)
					part:setRot(0,90,0)
					break
				end
			end
			findCustomParentTypes(part)
		end
	end
	findCustomParentTypes(models)
end,'PHYSBONE.pendulumObjectInit')

-- Debug keybind
local debugKeybind = keybinds:newKeybind("Toggle PhysBone Debug Mode","key.keyboard.grave.accent")
function debugKeybind.press()
	debugMode = not debugMode
	for _,boneID in pairs(physBoneIndex) do
		physBone[boneID].path.PB_Debug_Pivot:setVisible(debugMode)
		physBone[boneID].path.PB_Debug_Direction:setVisible(debugMode)
		physBone[boneID].path.PB_Debug_SpringForce:setVisible(debugMode)
	end
end

-- Simple clock
local physClock = 0
events.tick:register(function()
	physClock = physClock + 1
end,'PHYSBONE.physClock')

-- Render function prep
local renderFunction = "render"
local deg = math.deg
local atan2 = math.atan2
local asin = math.asin
local invalidContexts = {
	PAPERDOLL = true,
	MINECRAFT_GUI = true,
	FIGURA_GUI = true
}
-- Render function
events[renderFunction]:register(function (delta,context)
	if(invalidContexts[context] or client:isPaused()) then
		return
	end
	-- Time calculations
	local time = (physClock + delta)
	local deltaTime = time - lastDelta


	-- If world time / render somehow runs twice, don't run
	if deltaTime == 0 then return end
	for _,curPhysBoneID in pairs(physBoneIndex) do
		curPhysBone = physBone[curPhysBoneID]
		local worldPartMat = curPhysBone.path:partToWorldMatrix()

		-- Pendulum logic
		local pendulumBase =  worldPartMat:apply()
		if pendulumBase.x ~= pendulumBase.x then return end -- avoid physics breaking if partToWorldMatrix returns NaN
		local velocity = (curPhysBone.pos - curPhysBone.lastPos) / lastestDeltaTime / ((curPhysBone.simSpeed * curPhysBone.mass)/100)

		-- Air resistance
		local airResistanceFactor = curPhysBone.airResistance
		if airResistanceFactor ~= 0 then
			local airResistance = velocity * (-airResistanceFactor)
			velocity = velocity + airResistance * lasterDeltaTime / curPhysBone.mass
		end

		-- Spring force
		if curPhysBone.springForce ~= 0 then
			local equalib = curPhysBone.equilibrium
			local relativeDirMat = curPhysBone.path:getParent():partToWorldMatrix():copy() * matrices.mat4():rotate(equalib.y,equalib.x,0)
			local reliveDir = relativeDirMat:applyDir(0,0,-1):normalized()
			local springForce = reliveDir * curPhysBone.springForce
			velocity = velocity + springForce * lasterDeltaTime / curPhysBone.mass^2
		end

		-- Custom force
		if curPhysBone.force ~= vec(0,0,0) then
			velocity = velocity + curPhysBone.force * lasterDeltaTime / curPhysBone.mass^2
		end

		-- Gravity
		velocity = velocity + vec(0, curPhysBone.gravity,0) * lasterDeltaTime / curPhysBone.mass

		-- Finalise physics
		curPhysBone.lastPos = curPhysBone.pos:copy()
		local direction = (curPhysBone.pos + velocity * lasterDeltaTime * ((curPhysBone.simSpeed * curPhysBone.mass)/100)) - pendulumBase
		curPhysBone.pos = pendulumBase + direction:normalized()

		-- Rotation calcualtion
		local relativeVec = (worldPartMat:copy()):invert():apply(pendulumBase + (curPhysBone.pos - pendulumBase)):normalize()
		relativeVec = (relativeVec * curPhysBone.vecMod):normalized()
		relativeVec = vectors.rotateAroundAxis(90,relativeVec,vec(-1,0,0))
		yaw = deg(atan2(relativeVec.x,relativeVec.z))
		pitch = deg(asin(-relativeVec.y))

		-- Transform matrix
		if curPhysBone.path:getVisible() then
			local parentPivot = curPhysBone.path:getPivot()
			for _,part in pairs(curPhysBone.path:getChildren()) do
				if part:getVisible() then
					local partID = part:getName()
					if partID ~= "PB_Debug_Pivot" and partID ~= "PB_Debug_SpringForce" then
						local pivot = part:getPivot()
						local mat = matrices.mat4()
						local rot = part:getRot()

						mat:translate(-pivot)
							:rotate(rot.x,rot.y,rot.z)
							:translate(pivot)

							:translate(-parentPivot)
							:rotate(curPhysBone.rotMod)
							:rotate(0,-90,0)
							:rotate(pitch,0,yaw)
							:translate(parentPivot)

						part:setMatrix(mat)
					end
				end
			end
		end
	end

	-- Store deltaTime values
	lastestDeltaTime,lasterDeltaTime,lastDeltaTime,lastDelta = lasterDeltaTime,lastDeltaTime,deltaTime,time
end,'PHYSBONE.'..renderFunction)

setmetatable(physBone,{__index=physBone.children,__newindex=function(this,key,value)
	rawget(this,'children')[key]= value
end})
return physBone