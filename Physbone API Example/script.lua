local physBone = require('physBoneAPI')
physBone:setPreset("physFloppy",vec(0,0,90),nil,nil,nil,nil,nil,vec(-1,0,0),50)

function events.entity_init()
  physBone.physBoneBouncy:setSpringForce(50)
  physBone.physBoneBouncy:setEquilibrium(vec(1,0,0))
  physBone.physBoneBouncy:setNodeDensity(1)
  physBone.physBoneBouncy:setNodeRadius(1)
end