-- Physbone 2.0 pre-release 1 By ChloeSpacedOut <3
local physBone = {}
local physBoneIndex = {}
local boneID = 0
local lastDeltaTime,lasterDeltaTime,lastestDeltaTime,lastDelta = 1,1,1,1
local physBonePresets = {}
local debugMode = false

-- preset physBone functions
physBone.setPreset = function(self,ID,gravity,airResistance,simSpeed,equilibrium,springForce,rotMod)
	local presetCache = {}
	local references = {gravity = gravity, airResistance = airResistance, simSpeed = simSpeed, equilibrium = equilibrium, springForce = springForce, rotMod = rotMod}
	local fallbacks = {gravity = -9.81, airResistance = 0.1, simSpeed = 1, equilibrium = vec(0,0), springForce = 0, rotMod = vec(0,0,0)}
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

physBone.removePreset = function(self,ID)
	if not physBonePresets[ID] then error('error removing preset: preset "'..ID..'" does not exist') end
	physBonePresets[ID] = nil
end

physBone:setPreset("physBone")
physBone:setPreset("physBoob",nil,0.2,2,nil,70,vec(-90,0,0))
physBone:setPreset("physEar",nil,0.3,2,vec(90,0),30,vec(0,180,180))

-- models API function: method by GS
local old_class_index = figuraMetatables.ModelPart.__index
local class_methods = {
  newPhysBone = function(self,physBonePreset)
		local ID = self:getName()
		if physBone[ID] then error('error making physBone: this physBone "'..ID..'" already exists') end
		if not physBonePreset then error('error making physBone: your preset can not be nil') end
		if not physBonePresets[physBonePreset] then error('error making physBone: preset "'..physBonePreset..'" does not exist') end
		local preset = physBonePresets[physBonePreset]
		part = self

		boneID = boneID + 1
		physBoneIndex[boneID] = ID
		physBone[ID] = newPhysBone(part,preset.gravity,preset.airResistance,preset.simSpeed,preset.equilibrium,preset.springForce,preset.rotMod)
		part:setRot(0,90,0)
		return physBone[ID]
  end,
	getPhysBone = function(self)
		local ID = self:getName()
		if not physBone[ID] then error('cannot get physBone: this part does not have a physBone') end
		return physBone[ID]
	end
}

function figuraMetatables.ModelPart:__index(key)
  if class_methods[key] then
    return class_methods[key]
  else
    return old_class_index(self, key)
  end
end

-- Indexes a physBone
local function newPhysBone(path,gravity,airResistance,simSpeed,equilibrium,springForce,rotMod)
	local ID = path:getName()
	return {
		ID = ID,
		path = path,
		pos = path:partToWorldMatrix():apply(),
		lastPos = path:partToWorldMatrix():apply(),
		gravity = gravity,
		setGravity =	
			function(self,data)
				self.gravity = data
				return self
			end,
		getGravity =	
			function(self)
				return self.gravity						
			end,
		airResistance = airResistance,
		setAirResistance =	
			function(self,data)
				self.airResistance = data
				return self
			end,
		getAirResistance =	
			function(self)
				return self.airResistance						
			end,
		simSpeed = simSpeed,
		setSimSpeed =	
			function(self,data)
				self.simSpeed = data
				return self
			end,
		getSimSpeed =	
			function(self)
				return self.simSpeed						
			end,
		equilibrium = equilibrium,
		setEquilibrium =	
			function(self,data)
				self.equilibrium = data
				if host:isHost() then
					local springForceGroup = self.path.PB_Debug_SpringForce
					local pivot = springForceGroup:getPivot()
					local mat = matrices.mat4()
					mat:scale(1,self.springForce/50,1)
					mat:translate(-pivot)
					mat:rotate(0,0,data.x+90)
					mat:rotate(0,data.y,0)
					mat:translate(pivot)
					springForceGroup:setMatrix(mat)
				end
				return self
			end,
		getEquilibrium =	
			function(self)
				return self.equilibrium						
			end,
		springForce = springForce,
		setSpringForce =	
			function(self,data)
				self.springForce = data
				return self
			end,
		getSpringForce =	
			function(self)
				return self.springForce						
			end,
		rotMod = rotMod,
		setRotMod =	
			function(self,data)
				self.rotMod = data
				if host:isHost() then
					self.path.PB_Debug_Direction:setRot(-data)
				end
				return self
			end,
		getRotMod =	
			function(self)
				return self.upsideDown						
			end,
		remove = 
			function(self)
				local path = self.path
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
end

-- Generates a physBone's debug model
local testTexture = textures:newTexture("test",1,1):setPixel(0,0,vec(1,1,1))
function addDebugParts(part,preset)
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
	mat:scale(1,preset.springForce/50,1)
	mat:rotate(0,0,preset.equilibrium.x+90)
	mat:rotate(0,preset.equilibrium.y,0)
	mat:translate(pivot)
	springForceGroup:setMatrix(mat)
	
	for k,v in pairs({"PB_Debug_Pivot","PB_Debug_Direction","PB_Debug_SpringForce"}) do
		part[v]:setVisible(false)
	end
end

-- Pendulum object initialization
function events.entity_init()
	local function findCustomParentTypes(path)
		for _,part in pairs(path:getChildren()) do
			local ID = part:getName()
			for presetID,preset in pairs(physBonePresets) do
				if string.find(ID,presetID,0) then
					boneID = boneID + 1
					physBoneIndex[boneID] = ID
					physBone[ID] = newPhysBone(part,preset.gravity,preset.airResistance,preset.simSpeed,preset.equilibrium,preset.springForce,preset.rotMod)
					part:setRot(0,90,0)
					if host:isHost() then
						addDebugParts(part,preset)
					end
				end
			end
			findCustomParentTypes(part)
		end
	end
	findCustomParentTypes(models)
end

-- Debug Keybind
local debugKeybind = keybinds:newKeybind("Toggle PhysBone Debug Mode","key.keyboard.grave.accent")
function debugKeybind.press()
	debugMode = not debugMode
	for _,boneID in pairs(physBoneIndex) do
		for k,v in pairs({"PB_Debug_Pivot","PB_Debug_Direction","PB_Debug_SpringForce"}) do
			physBone[boneID].path[v]:setVisible(debugMode)
		end
	end
end

-- Simple Clock
local physClock = 0
function events.tick()
	physClock = physClock + 1
end

-- Render Function Chooser
local renderFunction
if host:isHost() then
	renderFunction = "world_render"
else
	renderFunction = "render"
end

-- Render Function
events[renderFunction] = function (delta)
	-- Time Calculations
	deltaTime = (physClock + delta) - lastDelta

	-- If world time / render somehow runs twice, don't run
	if deltaTime == 0 then return end
  
	for _,ID in ipairs(physBoneIndex) do
		
		-- Pendulum logic
		local pendulumBase = physBone[ID].path:partToWorldMatrix():apply()
		local velocity = (physBone[ID].pos - physBone[ID].lastPos) / lastestDeltaTime / (physBone[ID].simSpeed/100)

		-- Air Resistance
		local airResistanceFactor = physBone[ID].airResistance
		local airResistance = velocity * (-airResistanceFactor)
		velocity = velocity + airResistance * lasterDeltaTime
		
		-- Spring force
		local equalib = physBone[ID].equilibrium
		local relativeDirMat = physBone[ID].path:getParent():partToWorldMatrix():copy() * matrices.mat4():rotate(equalib.x,equalib.y)
		local reliveDir = relativeDirMat:applyDir(0,0,-1):normalized()
		local springForce = reliveDir * physBone[ID].springForce
		velocity = velocity + springForce * lasterDeltaTime

		-- Gravity
		velocity = velocity + vec(0, physBone[ID].gravity,0) * lasterDeltaTime 

		-- Finalise Physics
		physBone[ID].lastPos = physBone[ID].pos:copy()
		local direction = (physBone[ID].pos + velocity * lasterDeltaTime * (physBone[ID].simSpeed/100)) - pendulumBase
		physBone[ID].pos = pendulumBase + direction:normalized()

		-- Rotation Calcualtion
		local relativeVec = (physBone[ID].path:partToWorldMatrix()):invert():apply(pendulumBase + (physBone[ID].pos - pendulumBase)):normalize()
		relativeVec = vectors.rotateAroundAxis(90,relativeVec,vec(-1,0,0))
		yaw = math.deg(math.atan2(relativeVec.x,relativeVec.z))
		pitch = math.deg(math.asin(-relativeVec.y))

		-- Transform Matrix
		local parentPivot = physBone[ID].path:getPivot()
		for _,part in pairs(physBone[ID].path:getChildren()) do
			local partID = part:getName()
			if partID ~= "PB_Debug_Pivot" and partID ~= "PB_Debug_SpringForce" then
				local pivot = part:getPivot()
				local mat = matrices.mat4()
				local rot = part:getRot()

				mat:translate(-pivot)
				mat:rotate(rot.x,rot.y,rot.z)
				mat:translate(pivot)

				mat:translate(-parentPivot)
				mat:rotate(physBone[ID].rotMod)
				mat:rotate(0,-90,0)
				mat:rotate(vec(pitch,0,yaw))
				mat:translate(parentPivot)

				part:setMatrix(mat)
			end
		end
	end
	
	-- Store deltaTime values
	lastestDeltaTime,lasterDeltaTime,lastDeltaTime,lastDelta = lasterDeltaTime,lastDeltaTime,deltaTime,(physClock + delta)
end
return physBone