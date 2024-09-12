local physBone = require('physBoneAPI')

function events.entity_init()
  physBone.physBoneBouncy:setRotMod(vec(-90,0,0))
  physBone.physBoneBouncy:setSpringForce(0)
  physBone.physBoneBouncy:setEquilibrium(vec(0,0))
end

-- temp
local test = textures:newTexture("test",1,1)
test:setPixel(0,0,vec(1,1,1))
models.model.collider:setPrimaryTexture("CUSTOM",test)