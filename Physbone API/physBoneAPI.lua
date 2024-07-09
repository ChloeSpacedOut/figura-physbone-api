-- By ChloeSpacedOut <3
physBone = {}
local physBoneIndex = {}
local boneID = 0
local lastDelta = 0
local lastDeltaTime,lasterDeltaTime,lastestDeltaTime = 0,0,0

--- method by GS
local old_class_index = figuraMetatables.ModelPart.__index
local class_methods = {
  newPhysbone = function(self,physBonePreset)
		local ID = self:getName()
		if physBone[ID] then error('The physBone "'..ID..'" already exists, and cannot be created') end
		boneID = boneID + 1
		physBoneIndex[boneID] = ID
		if physBonePreset == "physBone" then
			physBone[ID] = newPhysBone(self,-9.81,0.1,1,vec(0,0),0,vec(0,0,0))
		elseif physBonePreset == "physBoob" then
			physBone[ID] = newPhysBone(self,-9.81,0.2,2,vec(0,0),70,vec(-90,0,0))
		elseif physBonePreset == "physEar" then
			physBone[ID] = newPhysBone(self,-9.81,0.3,2,vec(90,0),30,vec(0,180,180))
		end
		self:setRot(0,90,0)
		return self
  end,
	removePhysBone = function(self)
		local ID = self:getName()
		if not physBone[ID] then error('The physBone "'..ID..'" could not be found') end
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
		self:setRot(0,0,0)
		for k,v in pairs(self:getChildren()) do
			v:setRot(v:getRot())
		end
		return self
  end
}

function figuraMetatables.ModelPart:__index(key)
  if class_methods[key] then
    return class_methods[key]
  else
    return old_class_index(self, key)
  end
end
---

function newPhysBone(v,gravity,airResistance,simSpeed,equilibrium,springForce,rotMod)
	local ID = v:getName()
	return {
		ID = ID,
		path = v,
		pos = v:partToWorldMatrix():apply(),
		lastPos = v:partToWorldMatrix():apply(),
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
				return self
			end,
		getRotMod =	
			function(self)
				return self.upsideDown						
			end
	}
end

function events.entity_init()
	-- Pendulum object initialization
	local function findCustomParentTypes(path)
		for k,v in pairs(path:getChildren()) do
			local ID = v:getName()
			local isBone = string.find(ID,'physBone',0)
			local isBoob = string.find(ID,'physBoob',0)
			local isEar = string.find(ID,'physEar',0)
			if isBone or isBoob or isEar then
				boneID = boneID + 1
				physBoneIndex[boneID] = ID
				if isBone then
					physBone[ID] = newPhysBone(v,-9.81,0.1,1,vec(0,0),0,vec(0,0,0))
				elseif isBoob then
					physBone[ID] = newPhysBone(v,-9.81,0.2,2,vec(0,0),70,vec(-90,0,0))
				elseif isEar then
					physBone[ID] = newPhysBone(v,-9.81,0.3,2,vec(90,0),30,vec(0,180,180))
				end
				physBone[ID].path:setRot(0,90,0)
			end
			findCustomParentTypes(v)
		end
	end
	findCustomParentTypes(models)
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

events[renderFunction] = function (delta)
	-- Time Calculations
	deltaTime = (physClock + delta) - lastDelta
  lastDelta = (physClock + delta)
	for _,ID in ipairs(physBoneIndex) do
		
		-- Pendulum logic
		local pendulumBase = physBone[ID].path:partToWorldMatrix():apply()
		local velocity
    if lastestDeltaTime == 0 then
        velocity = 0
    else
        velocity = (physBone[ID].pos - physBone[ID].lastPos) / lastestDeltaTime / (physBone[ID].simSpeed/100)
    end

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
	lastestDeltaTime,lasterDeltaTime,lastDeltaTime = lasterDeltaTime,lastDeltaTime,deltaTime
end