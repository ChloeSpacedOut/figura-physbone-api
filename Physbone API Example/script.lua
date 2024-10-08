local physBone = require('physBoneAPI')

function events.entity_init()
  physBone.physBoneBouncy:setRotMod(vec(-90,0,0))
  physBone.physBoneBouncy:setSpringForce(0)
  physBone.physBoneBouncy:setEquilibrium(vec(0,0))
  physBone.physBoneBouncy:setLength(16)
  physBone.physBoneBouncy:setNodeDensity(1)
  physBone.physBoneBouncy:setNodeStart(0)
  physBone.physBoneBouncy:setNodeEnd(16)
  physBone.physBoneBouncy:setNodeRadius(1)
end