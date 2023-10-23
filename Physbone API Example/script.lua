require('physBoneAPI')
function events.entity_init()
  physBone.physBoneBouncy:setSpringForce(0.5)
end

function events.tick()
  physBone.physBoneBouncy:setEquilibrium(-player:getLookDir())
end
