-- Time variables
local previousTime = client:getSystemTime() -- Milliseconds
local currentTime = client:getSystemTime() -- Milliseconds
local deltaTime = 0  -- Milliseconds
local elapsedTime = 0 -- Milliseconds


function updateTime()
	currentTime = client:getSystemTime()
	deltaTime = currentTime - previousTime
	elapsedTime = elapsedTime + deltaTime
	previousTime = currentTime
end

function find_perpendicular_direction_vector(direction,playerRot)
	-- Normalize the direction vector.
	direction = direction:normalize()

	local rotVector = vectors.angleToDir(0,playerRot-90)

	-- Calculate the cross product of the direction vector and the z-axis.
	perpendicular_direction_vector = direction:cross(vec(rotVector.x, 0, rotVector.z))

	-- If the perpendicular direction vector is the zero vector, then return the negative z-axis.
	if perpendicular_direction_vector == vec(0, 0, 0) then
		return vec(-1, 0, 0)
	else
		return perpendicular_direction_vector
	end
end

function getPos(ID)
	return physBone[ID].path:partToWorldMatrix():apply()
end

function events.entity_init()
	-- Pendulum object initialization
	physBone = {}
	function findCustomParentTypes(path)
		for k,v in pairs(path:getChildren()) do
			local name = v:getName()
			if string.find(name,'phys',0) and not (string.find(name,'PYC',0) or string.find(name,'RC',0))  then
				physBone[name] = {
					path = v,
					pos = v:partToWorldMatrix():apply(),
					lastPos = v:partToWorldMatrix():apply()
				}
				v:newPart('PYC'..name)
				v['PYC'..name]:newPart('RC'..name)
				for i,j in pairs(v:getChildren()) do
					if j:getName() ~= 'PYC'..name then
						v['PYC'..name]['RC'..name]:addChild(j)
						v:removeChild(j)
					end
				end
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
		local velocity = physBone[k].pos - physBone[k].lastPos

		-- Air Resistance
		local airResistanceFactor = 0.1 -- Adjust this value to control the strength of air resistance
		local airResistance = velocity * (-airResistanceFactor)
		velocity = velocity + airResistance

		physBone[k].lastPos = physBone[k].pos:copy()
		physBone[k].pos = physBone[k].pos + velocity + vec(0, -10* (deltaTimeInSeconds^2), 0)

		local direction = physBone[k].pos - pendulumBase
		physBone[k].pos = pendulumBase + direction:normalized()
		local playerRot = player:getRot().y -- note that a system to choose between player rot and body yaw will be needed. Maybe a custom orientation dir option too
		local rotVec = find_perpendicular_direction_vector(direction,playerRot)
		local rotVec2 = (physBone[k].path['PYC'..k]:partToWorldMatrix()):invert():apply(pendulumBase + rotVec):normalize()
		physBone[k].path['PYC'..k]['RC'..k]:setRot(0,-math.deg(math.atan(rotVec2.z,rotVec2.x)),0)
		-- Rotation Calcualtion
		local relativeVec = (physBone[k].path:partToWorldMatrix()):invert():apply(pendulumBase + (physBone[k].pos - pendulumBase)):normalize()
		
		relativeVec = vectors.rotateAroundAxis(90,relativeVec,vec(-1,0,0))
		yaw = math.deg(math.atan2(relativeVec.x,relativeVec.z))
		pitch = math.deg(math.asin(-relativeVec.y))
		physBone[k].rot = math.lerp(physBone[k].path['PYC'..k]:getRot(),vec(pitch,0,yaw),0.5)
		--- debug ----
		for i = 0, 1, 1/16 do
			local currentPos = pendulumBase + (physBone[k].pos - pendulumBase) * i
			particles['dust 1 0 0 1']:pos(currentPos):setLifetime(1):scale(1/5):spawn()
			local rotVec = physBone[k].pos + rotVec  * i/5
			particles['dust 0 0 1 1']:pos(rotVec):setLifetime(1):scale(1/5):spawn()
		end
		------------------
	end
end

function events.render(delta)
	for k,v in pairs(physBone) do
		local path = physBone[k].path['PYC'..k]
		path:setRot(math.lerp(path:getRot(),physBone[k].rot,delta))
		

	end
end