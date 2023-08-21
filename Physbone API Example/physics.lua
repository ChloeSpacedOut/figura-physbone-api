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

function getPos(ID)
    return physBone[ID].path:partToWorldMatrix():apply()
end

function find_perpendicular_direction_vector(direction)
    -- Normalize the direction vector.
    direction = direction:normalize()
  
    -- Calculate the cross product of the direction vector and the z-axis.
    perpendicular_direction_vector = direction:cross(vec(0, 0, 1))
  
    -- If the perpendicular direction vector is the zero vector, then return the negative z-axis.
    if perpendicular_direction_vector == vec(0, 0, 0) then
      return vec(0, 0, -1)
    else
        return perpendicular_direction_vector
    end
end

function events.entity_init()
    -- Pendulum object initialization
    physBone = {}
    function findCustomParentTypes(path)
        for k,v in pairs(path:getChildren()) do
            local name = v:getName()
            if string.find(name,'phys',0) and not string.find(name,'physChild',0)  then
                physBone[name] = {
                    path = v,
                    pos = v:partToWorldMatrix():apply(),
                    lastPos = v:partToWorldMatrix():apply()
                }
                v:newPart('physChild'..name)
                for i,j in pairs(v:getChildren()) do
                    if j:getName() ~= 'physChild'..name then
                        v['physChild'..name]:addChild(j)
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

        local rotVec = find_perpendicular_direction_vector(direction)

        -- Rotation Calcualtion
        local relativeVec = (physBone[k].path:partToWorldMatrix()):invert():apply(pendulumBase + (physBone[k].pos - pendulumBase)):normalize()
        for i = 0, 1, 1/16 do
            local currentPos = pendulumBase + (physBone[k].pos - pendulumBase) * i
            particles['dust 1 1 1 1']:pos(currentPos):setLifetime(1):scale(1/5):spawn()
            local rotVec = physBone[k].pos + rotVec  * i/10
            particles['dust 1 1 1 1']:pos(rotVec):setLifetime(1):scale(1/5):spawn()
        end
    end
end