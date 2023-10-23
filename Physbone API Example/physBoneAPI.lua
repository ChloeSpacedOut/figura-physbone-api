-- By ChloeSpacedOut <3
physBone = {}

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
	-- Pendulum object initialization
	local function findCustomParentTypes(path)
		for k,v in pairs(path:getChildren()) do
			local name = v:getName()
			if string.find(name,'physBone',0) and not (string.find(name,'PYC',0) or string.find(name,'RC',0))  then
				physBone[name] = {
					ID = name,
					path = v,
					pos 	= v:partToWorldMatrix():apply(),
					lastPos = v:partToWorldMatrix():apply(),
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

function events.tick()
	updateTime()
	local deltaTimeInSeconds = deltaTime / 1000 -- Delta Time in seconds

	for k,v in pairs(physBone) do
		-- Pendulum logic
		local pendulumBase = getPos(k)
		local velocity = (physBone[k].pos - physBone[k].lastPos)

		-- Air Resistance
		local airResistanceFactor = physBone[k].airResistance -- Adjust this value to control the strength of air resistance
		local airResistance = velocity * (-airResistanceFactor)
		velocity = velocity + airResistance
		
		-- Spring force
		local springForce = physBone[k].equilibrium:normalized() * (-physBone[k].springForce)
		velocity = velocity + springForce

		-- Finalise Physics
		physBone[k].lastPos = physBone[k].pos:copy()
		physBone[k].pos = physBone[k].pos + velocity + vec(0, physBone[k].gravity * ((deltaTimeInSeconds*1.3*physBone[k].simSpeed)^2), 0)
		-- NOTE!!! air resistance & spring force aren't effected by sim speed. Fix this!

		local direction = physBone[k].pos - pendulumBase
		physBone[k].pos = pendulumBase + direction:normalized()

		-- Rotation Calcualtion
		local relativeVec = (physBone[k].path:partToWorldMatrix()):invert():apply(pendulumBase + (physBone[k].pos - pendulumBase)):normalize()
		
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