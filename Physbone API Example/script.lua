function events.entity_init()
  physBone = require('physBoneAPI')
  physBone.physBoneBouncy:setSpringForce(50)
  physBone.physBoneBouncy:setEquilibrium(vec(0,0))
end