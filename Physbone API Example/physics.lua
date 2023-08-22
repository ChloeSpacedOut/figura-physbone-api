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
      
    
  --[[   pendulum = {
        position = getPosition(),
        previousPosition = getPosition()
    } ]]
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

        -- Rotation Calcualtion
        local relativeVec = (physBone[k].path:partToWorldMatrix()):invert():apply(pendulumBase + (physBone[k].pos - pendulumBase)):normalize()
        
        relativeVec = vectors.rotateAroundAxis(90,relativeVec,vec(-1,0,0))
        yaw = math.deg(math.atan2(relativeVec.x,relativeVec.z))
        pitch = math.deg(math.asin(-relativeVec.y))
        physBone[k].rot = math.lerp(physBone[k].path['physChild'..k]:getRot(),vec(pitch,0,yaw),0.5)
    end
end

function events.render(delta)
    for k,v in pairs(physBone) do
        local path = physBone[k].path['physChild'..k]
        path:setRot(math.lerp(path:getRot(),physBone[k].rot,delta))
    end
end