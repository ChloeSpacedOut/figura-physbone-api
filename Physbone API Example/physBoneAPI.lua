-- By ChloeSpacedOut <3
physBone = {}
local physBoneIndex = {}

-- Time variables
local previousTime = client:getSystemTime() -- Milliseconds
local currentTime = client:getSystemTime() -- Milliseconds
local deltaTime = 0  -- Milliseconds
local elapsedTime = 0 -- Milliseconds


local function updateTime()
	currentTime = client:getSystemTime()
	deltaTime = currentTime - previousTime
	elapsedTime = elapsedTime + deltaTime
	previousTime = currentTime
end

local function getPos(ID)
	return physBone[ID].path:partToWorldMatrix():apply()
end

function events.entity_init()
	local boneID = 0
	-- Pendulum object initialization
	local function findCustomParentTypes(path)
		for k,v in pairs(path:getChildren()) do
			local name = v:getName()
			if string.find(name,'physBone',0) and not (string.find(name,'PYC',0) or string.find(name,'RC',0))  then
				boneID = boneID + 1
				physBoneIndex[boneID] = name
				physBone[name] = {
					ID = name,
					path = v,
					pos 	= v:partToWorldMatrix():apply(),
					lastPos = v:partToWorldMatrix():apply(),
					lastRelativeVec = vec(0,-1,0),
					gravity = -9.81,
					setGravity =	
						function(self,data)
							self.gravity = data
						end,
					getGravity =	
						function(self)
							return self.gravity						
						end,
					airResistance = 0.15,
					setAirResistance =	
						function(self,data)
							self.airResistance = data
						end,
					getAirResistance =	
						function(self)
							return self.airResistance						
						end,
					simSpeed = 1,
					setSimSpeed =	
						function(self,data)
							self.simSpeed = data
						end,
					getSimSpeed =	
						function(self)
							return self.simSpeed						
						end,
					equilibrium = vec(0,1,0),
					setEquilibrium =	
						function(self,data)
							self.equilibrium = data
						end,
					getEquilibrium =	
						function(self)
							return self.equilibrium						
						end,
					springForce = 0,
					setSpringForce =	
						function(self,data)
							self.springForce = data
						end,
					getSpringForce =	
						function(self)
							return self.springForce						
						end,
					boundaries = {min = vec(-0.5,-1,-1), max = vec(1,1,1)},
					setBoundaries =	
						function(self,min,max)
							self.boundaries.min = min
							self.boundaries.max = max
						end,
					getBoundaries =
						function (self)
							return self.boundaries.min, self.boundaries.max
						end
				}
				v:newPart('PYC'..name)
				v['PYC'..name]:newPart('RC'..name)
				for i,j in pairs(v:getChildren()) do
					if j:getName() ~= 'PYC'..name then
						v['PYC'..name]['RC'..name]:addChild(j)
						v:removeChild(j)
					end
				end
				physBone[name].path:setRot(0,90,0)
				physBone[name].path['PYC'..name]['RC'..name]:setRot(0,-90,0)
			end
			findCustomParentTypes(v)
		end
	end
	findCustomParentTypes(models)
end

local function boundaryCollisionCheck(k,lastRelativeVec,relativeVec)
	for v = 0, 10 do
		local lerpedRelativeVec  = math.lerp(lastRelativeVec,relativeVec,v/10)
		local doesCollideMin = (physBone[k].boundaries.min.x > lerpedRelativeVec.x) or (physBone[k].boundaries.min.y > lerpedRelativeVec.y) or (physBone[k].boundaries.min.z > lerpedRelativeVec.z)
		local doesCollideMax = (physBone[k].boundaries.max.x < lerpedRelativeVec.x) or (physBone[k].boundaries.max.y < lerpedRelativeVec.y) or (physBone[k].boundaries.max.z < lerpedRelativeVec.z)
		if doesCollideMin or doesCollideMax then
			return true, lerpedRelativeVec
		end
	end
	return false
end

function events.tick()
	updateTime()
	local deltaTimeInSeconds = deltaTime / 1000 -- Delta Time in seconds

	for key,v in ipairs(physBoneIndex) do
		local k = v	
		local simspeed = (deltaTimeInSeconds*1.3*physBone[k].simSpeed)^2
		-- Pendulum logic
		local pendulumBase = getPos(k)
		local velocity = (physBone[k].pos - physBone[k].lastPos)	

		-- Air Resistance
		local airResistanceFactor = physBone[k].airResistance -- Adjust this value to control the strength of air resistance
		local airResistance = velocity * (-airResistanceFactor)
		velocity = velocity + airResistance * simspeed
		
		-- Spring force
		local springForce = physBone[k].equilibrium:normalized() * (-physBone[k].springForce)
		velocity = velocity + springForce * simspeed

		-- Gravity
		velocity = velocity + vec(0,physBone[k].gravity,0) * simspeed

		-- Finalise Physics
		physBone[k].lastPos = physBone[k].pos
		physBone[k].pos = physBone[k].pos + velocity 

		local direction = physBone[k].pos - pendulumBase
		physBone[k].pos = pendulumBase + direction:normalized()

		-- Rotation Calcualtion
		local lastRelativeVec = physBone[k].lastRelativeVec:copy()
		local relativeVec = physBone[k].path:partToWorldMatrix():invert():apply(physBone[k].pos):normalize()
		
		

		-- Boundary Collisions
		local isTrue,lerpedRelativeVec = boundaryCollisionCheck(k,lastRelativeVec,relativeVec)
		if isTrue then
			physBone[k].lastPos = physBone[k].path:partToWorldMatrix():apply(lerpedRelativeVec)
			physBone[k].pos = physBone[k].path:partToWorldMatrix():apply(lastRelativeVec)
			relativeVec = lastRelativeVec
			-- issue with lastRelativeVec. Part isn't escaping when it should be. If it does, this should work. Maybe remvoe the invert matrix from lastPos
		end
		
		physBone[k].lastRelativeVec = relativeVec

		relativeVec = vectors.rotateAroundAxis(90,relativeVec,vec(-1,0,0))
		yaw = math.deg(math.atan2(relativeVec.x,relativeVec.z))
		pitch = math.deg(math.asin(-relativeVec.y))
		physBone[k].rot = vec(pitch,0,yaw)
	end
end

function events.render(delta)
	for k,v in pairs(physBone) do
		local path = physBone[k].path['PYC'..k]
		path:setRot(math.lerp(path:getRot(),physBone[k].rot,delta))
	end
end