local physBone = require('physBoneAPI')
--physBone:setPreset("physFloppy",vec(0,0,90),nil,nil,nil,nil,nil,vec(-1,0,0),50)

function events.entity_init()
  --physBone.physBoneBouncy:setSpringForce(500)
  --physBone.physBoneBouncy:setEquilibrium(vec(0.5,1,-1))
  --physBone.physBoneBouncy:setNodeDensity(1)
  physBone.physBoneWoa:setNodeRadius(1)
  physBone.physBoneWoa:setNodeDensity(4)
  physBone.physBoneWoa:setNodeStart(2)
end