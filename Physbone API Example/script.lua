local physBone = require('physBoneAPI')

function events.entity_init()
  physBone.physBoneBouncy:setSpringForce(0)
  physBone.physBoneBouncy:setEquilibrium(vec(0,0))
  physBone.physBoneBouncy:setNodeDensity(1)
  physBone.physBoneBouncy:setNodeRadius(1)
end