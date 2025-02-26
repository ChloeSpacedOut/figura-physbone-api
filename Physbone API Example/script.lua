local physBone = require('physBoneAPI')

function events.entity_init()
  local hair = models.model.Head.HairPhysics:newPhysBone("physBone")
  hair:setNodeRadius(0.5)
    :setNodeDensity(3)
    :setNodeEnd(12.5)
    :setVecMod(0.6,1,1)
    :setBounce(0.3)
    :setLength(20)

  physBone.physBoneLeftEar:setNodeDensity(0)
  physBone.physBoneRightEar:setNodeDensity(0)
  physBone.physBoneRope1:setNodeDensity(0)
  physBone.physBoneRope2:setNodeDensity(0)
  physBone.physBoneRope3:setNodeDensity(0)
  physBone.physBoneRope4:setNodeDensity(0)
  physBone.physBoneRope5:setNodeDensity(0)
  physBone.physBoneRope6:setNodeDensity(0)
  physBone.physBoneRope7:setNodeDensity(0)
  physBone.physBoneRope8:setNodeDensity(0)
end