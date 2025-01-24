-- Physbone 2.2 by ChloeSpacedOut <3
-- Some funny additions made by Superpowers04 :3
-- Thanks to auria for her help with midRender
local physBone = {
	-- DO NOT ENABLE THIS UNLESS YOU KNOW WHAT YOU'RE DOING, THIS APPENDS THE INDEX OF THE PHYSBONE TO IT'S NAME IF THERE'S A DUPLICATE AND CAN CAUSE ISSUES
	allowDuplicates = false,
	-- Diabled debug mode 
	disableDebugMode = false,
	children = {},
	collider = {},
	index = {},
}

local doDebugMode = host:isHost() and not physBone.disableDebugMode

local physBoneIndex = physBone.index
local boneID = 0
local lastDeltaTime,lasterDeltaTime,lastestDeltaTime,lastDelta = 1,1,1,1
local time,deltaTime = 0,0
local colliderGroups
local physBonePresets = {}
local debugMode = false
local whiteTexture = textures:newTexture("white",1,1)
	:setPixel(0,0,vec(1,1,1))
local colliderTexture = textures:newTexture("collider",1,1)
	:setPixel(0,0,vec(0,0,0,0))
local nodeTexture = textures:newTexture("node",1,1)
	:setPixel(0,0,vec(0,0.7,1))

physBone.getVals = function(val1,val2,val3,val4)
	local type = type(val1)
	if type == "Vector2" or type == "Vector3" then
		return val1
	elseif val3 then
		return vec(val1,val2,val3)
	else
		return vec(val2,val2)
	end
end

physBone.vecToRot = function(vec3)
	vec3 = vec3:copy():normalize()
	local pitch = math.deg(math.asin(-vec3.y))
	local yaw = math.deg(math.atan2(vec3.x,vec3.z))
	return pitch,yaw
end

physBone.vecToRotMat = function(vec3)
	local w = vec3:copy():normalize()
	local u = vec(1,0,0)
	if math.abs(u:copy():dot(w)) > 0.7 then
		u = vec(0,1,0)
	end
	local v = w:copy():cross(u)
	u = v:copy():cross(w)
	return matrices.mat4(vec(u.x,u.y,u.z,0),vec(v.x,v.y,v.z,0),vec(w.x,w.y,w.z,0),vec(0,0,0,1))
end

-- Physbone metatable
local physBoneBase = {
	setMass =
		function(self,data)
			self.mass = data
			return self
		end,
	getMass =
		function(self)
			return self.mass
		end,
	setLength =
		function(self,data)
			self.length = data
			if doDebugMode and self.path.PB_Debug_Direction then
				self.path.PB_Debug_Direction.child:setScale(1,data,1)
			end
			return self
		end,
	getLength =
		function(self)
			return self.length
		end,
	setGravity =
		function(self,data)
			self.gravity = data
			return self
		end,
	getGravity =
		function(self)
			return self.gravity
		end,
	setAirResistance =
		function(self,data)
			self.airResistance = data
			return self
		end,
	getAirResistance =
		function(self)
			return self.airResistance
		end,
	setSimSpeed =
		function(self,data)
			self.simSpeed = data
			return self
		end,
	getSimSpeed =
		function(self)
			return self.simSpeed
		end,
	setSpringForce =
		function(self,data)
			self.springForce = data
			if doDebugMode and self.path.PB_Debug_SpringForce then
				local springForceGroup = self.path.PB_Debug_SpringForce
				springForceGroup:setScale(1,self.springForce/50,1)
			end
			return self
		end,
	getSpringForce =
		function(self)
			return self.springForce
		end,
	setEquilibrium =
		function(self,val1,val2,val3)
			local data = physBone.getVals(val1,val2,val3)
			self.equilibrium = data
			if doDebugMode and self.path.PB_Debug_SpringForce then
				local springForceGroup = self.path.PB_Debug_SpringForce
				local equilib = vectors.rotateAroundAxis(90,data,vec(0,-1,0))
				equilib = vectors.rotateAroundAxis(90,equilib,vec(-1,0,0))
				local pitch,yaw = physBone.vecToRot(equilib)
				springForceGroup:setRot(pitch,0,yaw)
			end
			return self
		end,
	getEquilibrium =
		function(self)
			return self.equilibrium
		end,
	setForce =
		function(self,val1,val2,val3)
			local data = physBone.getVals(val1,val2,val3)
			self.force = data
			return self
		end,
	getForce =
		function(self)
			return self.force
		end,
	setRotMod =
		function(self,val1,val2,val3)
			local data = physBone.getVals(val1,val2,val3)
			self.rotMod = data
			return self
		end,
	getRotMod =
		function(self)
			return self.upsideDown
		end,
	setVecMod =
		function(self,val1,val2,val3)
			local data = physBone.getVals(val1,val2,val3)
			self.vecMod = data
			return self
		end,
	getVecMod =
		function(self)
			return self.vecMod
		end,
	setRollMod =
		function(self,data)
			self.rollMod = data
			return self
		end,
	getRollMod =
		function(self)
			return self.rollMod
		end,
	setNodeStart =
		function(self,data)
			self.nodeStart = data
			if doDebugMode and self.path.PB_Debug_NodeRadius then
				self.path.PB_Debug_NodeRadius:remove()
				physBone.addDebugNodes(self.path,data,self.nodeEnd,self.nodeRadius,self.nodeDensity)
				self.path.PB_Debug_NodeRadius:setVisible(debugMode)
			end
			return self
		end,
	getNodeStart =
		function(self)
			return self.nodeStart
		end,
	setNodeEnd =
		function(self,data)
			self.nodeEnd = data
			if doDebugMode and self.path.PB_Debug_NodeRadius then
				self.path.PB_Debug_NodeRadius:remove()
				physBone.addDebugNodes(self.path,self.nodeStart,data,self.nodeRadius,self.nodeDensity)
				self.path.PB_Debug_NodeRadius:setVisible(debugMode)
			end
			return self
		end,
	getNodeEnd =
		function(self)
			return self.nodeEnd
		end,
	setNodeDensity =
		function(self,data)
			self.nodeDensity = data
			if doDebugMode and self.path.PB_Debug_NodeRadius then
				self.path.PB_Debug_NodeRadius:remove()
				physBone.addDebugNodes(self.path,self.nodeStart,self.nodeEnd,self.nodeRadius,data)
				self.path.PB_Debug_NodeRadius:setVisible(debugMode)
			end
			return self
		end,
	getNodeDensity =
		function(self)
			return self.nodeDensity
		end,
	setNodeRadius =
		function(self,data)
			self.nodeRadius = data
			if doDebugMode and self.path.PB_Debug_NodeRadius then
				self.path.PB_Debug_NodeRadius:remove()
				physBone.addDebugNodes(self.path,self.nodeStart,self.nodeEnd,data,self.nodeDensity)
				self.path.PB_Debug_NodeRadius:setVisible(debugMode)
			end
			return self
		end,
	getNodeRadius =
		function(self)
			return self.nodeRadius
		end,
	setBounce =
		function(self,data)
			self.bounce = data
			return self
		end,
	getBounce =
		function(self)
			return self.bounce
		end,
	updateWithPreset = 
		function(self,presetID)
			assert(presetID,'error making physBone: your preset can not be nil')
			local preset = type(presetID) == "table" and presetID or physBonePresets[presetID]
			assert(preset,'error making physBone: preset "'..tostring(presetID)..'" does not exist')
			for k,v in pairs {"mass","length","gravity","airResistance","simSpeed","equilibrium","springForce","force","rotMod","vecMod","rollMod","nodeStart","nodeEnd","nodeDensity","nodeRadius","bounce"} do
				if preset[v] then
					local funct = "set"..string.upper(string.sub(v,0,1))..string.sub(v,2,-1)
					self[funct](self,preset[v])
				end
			end
			return self
		end,
	remove =
		function(self)
			local path = self.path
			local ID = self.ID
			boneID = 0
			local newIndex = {}
			for k,v in pairs(physBoneIndex) do
				if v ~= ID then
					boneID = boneID + 1
					newIndex[boneID] = v
				end
			end
			physBoneIndex = newIndex
			physBone[ID] = nil
			for k,v in pairs(path:getChildren()) do
				v:setRot(v:getRot())
			end
			path:setRot(0,0,0)
		end
}
local physBoneMT = {__index=physBoneBase}

-- Internal Function: Returns physbone metatable from set values
physBone.newPhysBoneFromValues = function(self,path,mass,length,gravity,airResistance,simSpeed,equilibrium,springForce,force,rotMod,vecMod,rollMod,nodeStart,nodeEnd,nodeDensity,nodeRadius,bounce,id,name)
	if(self ~= physBone) then
		-- Literally just offsets everything so self is used as the base 
		path,mass,length,gravity,airResistance,simSpeed,equilibrium,springForce,force,rotMod,vecMod,rollMod,nodeStart,nodeEnd,nodeDensity,nodeRadius,bounce,id,name = self,path,mass,length,gravity,airResistance,simSpeed,equilibrium,springForce,force,rotMod,vecMod,rollMod,nodeStart,nodeEnd,nodeDensity,nodeRadius,bounce,id,name
	end
	assert(user:isLoaded(),'error making physBone: attempt to create part before entity init')
	assert(path,'error making physBone: part is null!')
	local ID = name or path:getName()
	local pos = path:partToWorldMatrix():apply()
	local velocity = vec(0,0,0)
	return setmetatable({
		index=nil,
		ID = ID,
		path = path,
		pos = pos,
		velocity = velocity,
		mass = mass,
		length = length,
		gravity = gravity,
		airResistance = airResistance,
		simSpeed = simSpeed,
		equilibrium = equilibrium,
		springForce = springForce,
		force = force,
		rotMod = rotMod,
		vecMod = vecMod,
		rollMod = rollMod,
		nodeStart = nodeStart,
		nodeEnd = nodeEnd,
		nodeDensity = nodeDensity,
		nodeRadius = nodeRadius,
		bounce = bounce
	},physBoneMT)
end

-- Internal Function: Creates a physbone based on the provided metatable
physBone.addPhysBone = function(self,part,index)
	if self ~= physBone then
		index,part=part,index
	end
	assert(part,'error making physBone: part is null!')

	local ID = part.ID
	if(index == nil) then
		boneID = boneID + 1
		index = boneID
	end
	assert(not physBoneIndex[index],'error adding physBone: a physBone with index "'..index..'" already exists')
	physBoneIndex[index] = ID
	part.index = index
	physBone[ID] = part

	part.path.midRender = function(delta,context)
		physBone.physBoneRender(delta, context, ID)
	end

	return part
end

-- Creates a new physBone
physBone.newPhysBone = function(self,part,physBonePreset)
	if self ~= physBone then
		physBonePreset,part=part,self
	end
	assert(part,'error making physBone: part is null!')
	local ID = part:getName()

	if(physBone.allowDuplicates and physBone[ID]) then
			ID = ID..boneID+1
	end
	assert(not physBone[ID],'error making physBone: this physBone "'..ID..'" already exists')
	assert(physBonePreset,'error making physBone: your preset can not be nil')
	local preset = type(physBonePreset) == "table" and physBonePreset or physBonePresets[physBonePreset]
	assert(preset,'error making physBone: preset "'..tostring(physBonePreset)..'" does not exist')
	part:setRot(0,90,0)
	local p = physBone:addPhysBone(
		physBone.newPhysBoneFromValues(part,preset.mass,preset.length,preset.gravity,preset.airResistance,preset.simSpeed,preset.equilibrium,preset.springForce,preset.force,preset.rotMod,preset.vecMod,preset.rollMod,preset.nodeStart,preset.nodeEnd,preset.nodeDensity,preset.nodeRadius,preset.bounce,boneID,ID)
	)
	if doDebugMode then
		physBone.addDebugParts(part,preset)
	end
	return p
end

-- Returns your physBone
physBone.getPhysBone = function(self,part)
	if self ~= physBone then
		part = self
	end
	assert(part,'cannot get physBone: part is null!')
	local ID = self:getName()
	assert(physBone[ID],('cannot get physBone: this part does not have a physBone'))
	return physBone[ID]
end

-- Internal function to get part parents
local function getParents(part,parentsTable)
	local parent = part:getParent()
	if not parent then return parentsTable end
	parentsTable[#parentsTable + 1] = parent
	getParents(parent,parentsTable)
	return parentsTable
end

-- Creates a new collider
physBone.newCollider = function(self,part)
	assert(part,'error making collider: part is null!')
	local ID = part:getName()
	assert(not physBone.collider[ID],'error making collider: this collider "'..ID..'" already exists')
	local parents = getParents(part,{part})
	local nbtIndex = avatar:getNBT()
	for i = #parents, 1, -1 do
		for k,v in pairs(nbtIndex) do
			if v.name == parents[i]:getName() then
				if v.chld then 
					nbtIndex = v.chld
				else
					nbtIndex = v
				end
			end
		end
	end
	assert(nbtIndex.cube_data,"error making collider '"..ID.."'. This part isn't a cube")
	if next(nbtIndex.cube_data) == nil then
		error("error making collider '"..ID.."'. This cube either has no texture applied to it in Blockbench or has all faces disabled")
	end

	part:setVisible(true)
	part:setPrimaryTexture("CUSTOM", colliderTexture)

	local t = nbtIndex.t
	local f = nbtIndex.f
	local piv = nbtIndex.piv
	local rot = nbtIndex.rot
	if not t then t = {0,0,0} end
	if not f then f = {0,0,0} end
	if not piv then piv = {0,0,0} end
	if not rot then rot = {0,0,0} end
	t = vec(t[1],t[2],t[3])
	f = vec(f[1],f[2],f[3])
	piv = vec(piv[1],piv[2],piv[3])

	local offset = t - piv
	local size = t - f

	local faces = {}
	for k,v in pairs(nbtIndex.cube_data) do
		faces[k] = true
	end
	local pivot = part:getPivot()
	part:setMatrix(matrices.mat4():translate(-pivot):rotate(part:getRot()):translate(pivot) * 0.15)
		:setLight(15)

	-- temp code for steph to replace

	physBone.collider[ID] = {
		ID = ID,
		part = part,
		offset = offset,
		size = size,
		faces = faces
	}
end

-- Creates a new or sets the value of an existing preset
physBone.setPreset = function(self,ID,mass,length,gravity,airResistance,simSpeed,equilibrium,springForce,force,rotMod,vecMod,rollMod,nodeStart,nodeEnd,nodeDensity,nodeRadius,bounce)
	local presetCache = {}
	local references = {mass = mass, length = length, gravity = gravity, airResistance = airResistance, simSpeed = simSpeed, equilibrium = equilibrium, springForce = springForce, force = force, rotMod = rotMod, vecMod = vecMod, rollMod = rollMod, nodeStart = nodeStart, nodeEnd = nodeEnd, nodeDensity = nodeDensity, nodeRadius = nodeRadius, bounce = bounce}
	local fallbacks = {mass = 1, length = 16, gravity = -9.81, airResistance = 0.1, simSpeed = 1, equilibrium = vec(0,-1,0), springForce = 0, force = vec(0,0,0), rotMod = vec(0,0,0), vecMod = vec(1,1,1), rollMod = 0, nodeStart = 0, nodeEnd = 16, nodeDensity = 1, nodeRadius = 0, bounce = 0.75}
	for valID, fallbackVal in pairs(fallbacks) do
		local presetVal = references[valID]
		if presetVal then
			presetCache[valID] = presetVal
		else
			presetCache[valID] = fallbackVal
		end
	end
	physBonePresets[ID] = presetCache
end

-- Removes an existing preset
physBone.removePreset = function(self,ID)
	if not physBonePresets[ID] then error('error removing preset: preset "'..ID..'" does not exist') end
	physBonePresets[ID] = nil
end

-- Default presets
physBone:setPreset("physBone")
physBone:setPreset("PhysBone")
physBone:setPreset("physBoob",2,nil,nil,0.5,nil,vec(0,0,-1),200,nil,vec(-90,0,0),nil,nil,nil,nil,0)
physBone:setPreset("PhysBoob",2,nil,nil,0.5,nil,vec(0,0,-1),200,nil,vec(-90,0,0),nil,nil,nil,nil,0)

-- models API function: method by GS
local old_class_index = figuraMetatables.ModelPart.__index
local class_methods = {
	newPhysBone = function(self,physBonePreset)
		return physBone:newPhysBone(self,physBonePreset)
	end,
	getPhysBone = function(self)
		return physBone:getPhysBone(self)

	end
}

function figuraMetatables.ModelPart:__index(key)
	if class_methods[key] then
		return class_methods[key]
	else
		return old_class_index(self, key)
	end
end
--

-- Generates sphere mesh
function physBone.newSphere(part,ID)
	for i = 0, 9 do
		local faces = {}
		for j = 1,5 do
			faces["face"..j] = part:newSprite(ID..i..j)
			:setTexture(nodeTexture,1,1)
			:setUVPixels(2,2)
		end
		local face1,face2,face3,face4,face5 = faces.face1,faces.face2,faces.face3,faces.face4,faces.face5

		face1:getVertices()[1]:setPos(0,8,0)
		face1:getVertices()[2]:setPos(0,8,0)
		face1:getVertices()[3]:setPos(-1.5279,6.4721,-4.7023)
		face1:getVertices()[4]:setPos(1.5279,6.4721,-4.7023)
		face1:setRot(0,i*36,0):setRenderType("EMISSIVE_SOLID")

		face2:getVertices()[1]:setPos(1.5279,6.4721,-4.7023)
		face2:getVertices()[2]:setPos(-1.5279,6.4721,-4.7023)
		face2:getVertices()[3]:setPos(-2.4721,2.4721,-7.6085)
		face2:getVertices()[4]:setPos(2.4721,2.4721,-7.6085)
		face2:setRot(0,i*36,0):setRenderType("EMISSIVE_SOLID")

		face3:getVertices()[1]:setPos(2.4721,2.4721,-7.6085)
		face3:getVertices()[2]:setPos(-2.4721,2.4721,-7.6085)
		face3:getVertices()[3]:setPos(-2.4721,-2.4721,-7.6085)
		face3:getVertices()[4]:setPos(2.4721,-2.4721,-7.6085)
		face3:setRot(0,i*36,0):setRenderType("EMISSIVE_SOLID")

		face4:getVertices()[1]:setPos(2.4721,-2.4721,-7.6085)
		face4:getVertices()[2]:setPos(-2.4721,-2.4721,-7.6085)
		face4:getVertices()[3]:setPos(-1.5279,-6.4721,-4.7023)
		face4:getVertices()[4]:setPos(1.5279,-6.4721,-4.7023)
		face4:setRot(0,i*36,0):setRenderType("EMISSIVE_SOLID")
		
		face5:getVertices()[1]:setPos(1.5279,-6.4721,-4.7023)
		face5:getVertices()[2]:setPos(-1.5279,-6.4721,-4.7023)
		face5:getVertices()[3]:setPos(0,-8,0)
		face5:getVertices()[4]:setPos(0,-8,0)
		face5:setRot(0,i*36,0):setRenderType("EMISSIVE_SOLID")
	end
end

-- Generates physbone debug nodes
function physBone.addDebugNodes(part,nodeStart,nodeEnd,nodeRadius,nodeDensity)
	local nodeRadiusGroup = part:newPart("PB_Debug_NodeRadius")
	if nodeRadius == 0 then
		for i = 1, nodeDensity do
			local nodeParent = nodeRadiusGroup:newPart("nodeParent"..i)
			local nodeLength = nodeEnd * ((nodeEnd - nodeStart) / nodeEnd) * (i  / nodeDensity) + nodeStart
			nodeParent:setPos(0,-nodeLength,0)
			local node = nodeParent:newPart("node"..i,"CAMERA")
			node:newSprite("nodeRadius")
				:setTexture(nodeTexture,1,1)
				:setRenderType("EMISSIVE_SOLID")
				:setMatrix(matrices.mat4():translate(0.5,0.5,0.5):scale(0.5,0.5,0.5):rotate(0,0,0) * 0.1)
		end
	else
		for i = 1, nodeDensity do
			local nodeParent = nodeRadiusGroup:newPart("nodeParent"..i)
			local nodeLength = nodeEnd * ((nodeEnd - nodeStart) / nodeEnd) * (i  / nodeDensity) + nodeStart
			nodeParent:setPos(0,-nodeLength,0)
			local node = nodeParent:newPart("node"..i)
			physBone.newSphere(node,"sphere"..i)
			local pivot = node:getPivot()
			node:setMatrix(matrices.mat4():translate(-pivot):scale(0.125 * nodeRadius):translate(pivot) * 0.1)
		end
	end
end

-- Generates a physBone's debug model
function physBone.addDebugParts(part,preset)
	local pivotGroup = part:newPart("PB_Debug_Pivot","Camera")
	pivotGroup:newSprite("pivot")
		:setTexture(whiteTexture,1,1)
		:setColor(1,0,0)
		:setRenderType("EMISSIVE_SOLID")
		:setMatrix(matrices.mat4():translate(0.5,0.5,0.5):scale(0.5,0.5,0.5):rotate(0,0,0) * 0.1)

	local directionGroup = part:newPart("PB_Debug_Direction"):newPart("child")
	for k = 0, 3 do
		directionGroup:newSprite("line"..k)
			:setTexture(whiteTexture,1,1)
			:setRenderType("EMISSIVE_SOLID")
			:setMatrix(matrices.mat4():translate(0.5,0,0.5):scale(0.5,1,0.5):rotate(0,k*90,0) * 0.12)
	end
	directionGroup:setScale(1,preset.length,1)
	local springForceGroup = part:newPart("PB_Debug_SpringForce")
	for k = 0, 3 do
		springForceGroup:newSprite("line"..k)
			:setTexture(whiteTexture,1,1)
			:setColor(0,0,1)
			:setRenderType("EMISSIVE_SOLID")
			:setMatrix(matrices.mat4():translate(0.5,0,0.5):scale(0.25,3,0.25):rotate(0,k*90,0) * 0.11)
	end
	local equilib = vectors.rotateAroundAxis(90,preset.equilibrium,vec(0,-1,0))
	equilib = vectors.rotateAroundAxis(90,equilib,vec(-1,0,0))
	local pitch,yaw = physBone.vecToRot(equilib)
	springForceGroup:setRot(pitch,0,yaw)
		:setScale(1,preset.springForce/50,1)

	physBone.addDebugNodes(part,preset.nodeStart,preset.nodeEnd,preset.nodeRadius,preset.nodeDensity)

	for k,v in pairs({"PB_Debug_Pivot","PB_Debug_Direction","PB_Debug_SpringForce","PB_Debug_NodeRadius"}) do
		part[v]:setVisible(false)
	end
end

-- Generate physBones and colliders from model parts
events.entity_init:register(function()
	local function findCustomParentTypes(path)
		for _,part in pairs(path:getChildren()) do
			local ID = part:getName()
			local ID_sub = ID:sub(0,8)
			if ID_sub == "collider" or ID_sub == "Collider" then
				physBone:newCollider(part)
			end
			for presetID,preset in pairs(physBonePresets) do
				if ID:sub(0,#presetID) == presetID then
					physBone.newPhysBone(part,preset)
					for _,child in pairs(part:getChildren()) do
						local ID_child = child:getName()
						local ID_child_BEsub = ID_child:sub(0,7)
						local ID_child_SFsub = ID_child:sub(0,11)
						if ID_child_BEsub == "boneEnd" or ID_child_BEsub == "BoneEnd" then
							local childPos = child:getPivot() - part:getPivot()
							local rotModVec = vectors.rotateAroundAxis(90,childPos:normalized(),vec(-1,0,0))
							local pitch,yaw = physBone.vecToRot(rotModVec)
							local length = childPos:length()
							physBone[ID]:setRotMod(vec(-pitch,0,-yaw))
							physBone[ID]:setRollMod(child:getRot().y)
							physBone[ID]:setLength(length)
							physBone[ID]:setNodeEnd(length)
						elseif ID_child_SFsub == "springForce" or ID_child_SFsub == "SpringForce" then
							local childPos = child:getPivot() - part:getPivot()
							local equalibVec = childPos:normalized()
							physBone[ID]:setEquilibrium(equalibVec)
							physBone[ID]:setSpringForce(child:getRot().y)
						end
					end
					part:setRot(0,90,0)
					break
				end
			end
			findCustomParentTypes(part)
		end
	end
	findCustomParentTypes(models)
end,'PHYSBONE.generateFromModelParts')

-- Debug keybind
local debugKeybind = keybinds:newKeybind("Toggle PhysBone Debug Mode","key.keyboard.grave.accent")
function debugKeybind.press(mod)
	if not (mod == 1) or not doDebugMode then return end
	debugMode = not debugMode
	for _,boneID in pairs(physBoneIndex) do
		physBone[boneID].path.PB_Debug_Pivot:setVisible(debugMode)
		physBone[boneID].path.PB_Debug_Direction:setVisible(debugMode)
		physBone[boneID].path.PB_Debug_SpringForce:setVisible(debugMode)
		physBone[boneID].path.PB_Debug_NodeRadius:setVisible(debugMode)
	end
	if debugMode then
		colliderTexture:setPixel(0,0,vec(1,0.5,0)):update()
	else
		colliderTexture:setPixel(0,0,vec(0,0,0,0)):update()
	end
end

-- Simple clock
local physClock = 0
events.tick:register(function()
	physClock = physClock + 1
end,'PHYSBONE.physClock')

-- Render function prep
local zeroVec = vec(0,0,0)
local invalidContexts = {
	PAPERDOLL = true,
	MINECRAFT_GUI = true,
	FIGURA_GUI = true
}

-- Global render function
events.RENDER:register(function (delta,context)

	if invalidContexts[context] or client:isPaused() then
		return
	end

	-- Time calculations
	time = (physClock + delta)
	deltaTime = time - lastDelta

	-- If world time / render somehow runs twice, don't run
	if deltaTime == 0 then return end

	-- Collider setup
	colliderGroups = {}
	for colID,collider in pairs(physBone.collider) do
		colliderGroups[colID] = {}
		local colGroup = colliderGroups[colID]
		local colMatrix = collider.part:partToWorldMatrix() * (1/0.15)
		local partPos = colMatrix:apply()
		local size = collider.size
		local colTransMat = colMatrix:copy():translate(-partPos)
		local offsetMat = matrices.mat4():translate(collider.offset)
		local colNormalX = colMatrix:applyDir(vec(1,0,0)):normalize()
		local colNormalY = colMatrix:applyDir(vec(0,1,0)):normalize()
		local colNormalZ = colMatrix:applyDir(vec(0,0,1)):normalize()
		local faces = collider.faces
		if faces.s then
			local colPos = (colTransMat * offsetMat:copy()):translate(partPos):apply()
			colGroup.s = {pos = colPos, normals = {colNormalX,colNormalY,colNormalZ}, size = vec(size.x,size.y,size.z)}
		end
		if faces.n then
			local colPos = (colTransMat * offsetMat:copy():translate(-size)):translate(partPos):apply()
			colGroup.n = {pos = colPos, normals = {-colNormalX,-colNormalY,-colNormalZ}, size = vec(size.x,size.y,size.z)}
		end
		if faces.e then
			local colPos = (colTransMat * offsetMat:copy():translate(-size * vec(0,1,0))):translate(partPos):apply()
			colGroup.e = {pos = colPos, normals = {colNormalZ,-colNormalY,colNormalX}, size = vec(size.z,size.y,size.x)}
		end
		if faces.w then
			local colPos = (colTransMat * offsetMat:copy():translate(-size * vec(1,0,1))):translate(partPos):apply()
			colGroup.w = {pos = colPos, normals = {-colNormalZ,colNormalY,-colNormalX}, size = vec(size.z,size.y,size.x)}
		end
		if faces.u then
			local colPos = (colTransMat * offsetMat:copy():translate(-size * vec(0,0,1))):translate(partPos):apply()
			colGroup.u = {pos = colPos, normals = {colNormalX,-colNormalZ,colNormalY}, size = vec(size.x,size.z,size.y)}
		end
		if faces.d then
			local colPos = (colTransMat * offsetMat:copy():translate(-size * vec(1,1,0))):translate(partPos):apply()
			colGroup.d = {pos = colPos, normals = {-colNormalX,colNormalZ,-colNormalY}, size = vec(size.x,size.z,size.y)}
		end
	end
end,'PHYSBONE.RENDER')

function physBone.physBoneRender(delta, context, curPhysBoneID)
	if client:isPaused() or (colliderGroups == nil) then
		return
	end	

	local curPhysBone = physBone[curPhysBoneID]
	local worldPartMat = curPhysBone.path:partToWorldMatrix()

	-- Pendulum logic
	local pendulumBase =  worldPartMat:apply()
	if pendulumBase.x ~= pendulumBase.x then return end -- avoid physics breaking if partToWorldMatrix returns NaN
	local velocity = curPhysBone.velocity / lastestDeltaTime / ((curPhysBone.simSpeed * curPhysBone.mass)/100)

	-- Air resistance
	local airResistanceFactor = curPhysBone.airResistance
	if airResistanceFactor ~= 0 then
		local airResistance = velocity * (-airResistanceFactor)
		velocity = velocity + airResistance * lasterDeltaTime / curPhysBone.mass
	end

	-- Spring force
	if curPhysBone.springForce ~= 0 then
		local equilib = physBone.vecToRotMat(-curPhysBone.equilibrium)
		local relativeDirMat = worldPartMat:copy() * equilib:rotate(0,-90,0)
		local relativeDir = relativeDirMat:applyDir(0,0,-1):normalized()
		local springForce = relativeDir * curPhysBone.springForce
		velocity = velocity + springForce * lasterDeltaTime / curPhysBone.mass^2
		end

	-- Custom force
	if curPhysBone.force ~= zeroVec then
		velocity = velocity + curPhysBone.force * lasterDeltaTime / curPhysBone.mass^2
	end

	-- Gravity
	velocity = velocity + vec(0, curPhysBone.gravity,0) * lasterDeltaTime / curPhysBone.mass

	-- Collisions
	local direction = ((curPhysBone.pos + velocity * lasterDeltaTime * ((curPhysBone.simSpeed * curPhysBone.mass)/100)) - pendulumBase):normalized()
	local nodeDir = direction
	local hasCollided = false
	local planeNormal
	local distance
	local colNodePos
	for node = 1, curPhysBone.nodeDensity do
		local nodeLength = (curPhysBone.nodeEnd * ((curPhysBone.nodeEnd - curPhysBone.nodeStart) / curPhysBone.nodeEnd) * (node  / curPhysBone.nodeDensity) + curPhysBone.nodeStart) / math.worldScale
		local nodePos = pendulumBase + nodeDir * (nodeLength / 16)
		for groupID,group in pairs(colliderGroups) do
			for _,face in pairs(group) do
				local normalX = face.normals[1]
				local normalY = face.normals[2]
				local normalZ = face.normals[3]
				local diff = nodePos - face.pos
				local distanceX = diff:dot(normalX) / normalX:length()
				local distanceY = diff:dot(normalY) / normalY:length()
				local distanceZ = diff:dot(normalZ) / normalZ:length()
				local worldScale = 16*math.worldScale
				local pendulumThickness = 0/worldScale
				local size = vec(face.size.x,face.size.y,face.size.z) / worldScale
				local penetration = (distanceZ + pendulumThickness) / size.z
				local radius = curPhysBone.nodeRadius / worldScale
				local isXCollided = (distanceZ - radius) <= 0 and -size.z <= distanceZ
				local isYCollided = distanceY <= penetration * size.y and (penetration * -size.y) - size.y <= distanceY and penetration >= -0.5
				local isZCollided = distanceX <= penetration * size.x and (penetration * -size.x) - size.x <= distanceX and penetration >= -0.5
				if isXCollided and isYCollided and isZCollided then
					planeNormal = normalZ
					distance = distanceZ - radius
					hasCollided = true
					nodeDir = (nodePos - pendulumBase):normalized()
					colNodePos = nodeLength
				end
			end
		end
	end

	-- Finalise physics

	if not hasCollided then
		local nextPos = pendulumBase + direction * (curPhysBone.length / 16 / math.worldScale)
		curPhysBone.velocity = nextPos - curPhysBone.pos
		curPhysBone.pos = nextPos
	else
		local bounce = curPhysBone.bounce * 2.61
		local colNextPos = direction * (colNodePos / 16 / math.worldScale) - distance * planeNormal
		local nextPos = pendulumBase + colNextPos:normalized() * (curPhysBone.length / 16 / math.worldScale)
		curPhysBone.velocity = (velocity - bounce * velocity:dot(planeNormal) * planeNormal) * lasterDeltaTime * ((curPhysBone.simSpeed * curPhysBone.mass)/100)
		curPhysBone.pos = nextPos
	end

	-- Rotation calcualtion
	local relativeVec = (worldPartMat:copy()):invert():apply(pendulumBase + (curPhysBone.pos - pendulumBase)):normalize()
	relativeVec = (relativeVec * curPhysBone.vecMod.zyx):normalized()
	relativeVec = vectors.rotateAroundAxis(90,relativeVec,vec(-1,0,0))
	local pitch,yaw = physBone.vecToRot(relativeVec)

	-- Transform matrix
	if curPhysBone.path:getVisible() then
		local parentPivot = curPhysBone.path:getPivot()
		for _,part in pairs(curPhysBone.path:getChildren()) do
			if part:getVisible() then
				local partID = part:getName()
				if partID ~= "PB_Debug_Pivot" and partID ~= "PB_Debug_SpringForce" then
					local pivot = part:getPivot()
					local mat = matrices.mat4()
					local rot = part:getRot()

					mat:translate(-pivot)
						:rotate(rot.x,rot.y,rot.z)
						:translate(pivot)

						:translate(-parentPivot)
					if partID ~= "PB_Debug_Direction" and partID ~= "PB_Debug_NodeRadius" then
						mat:rotate(vec(0,0,curPhysBone.rotMod.z))
							:rotate(vec(0,curPhysBone.rotMod.y,0))
							:rotate(vec(curPhysBone.rotMod.x,0,0))
							:rotate(vec(0,curPhysBone.rollMod,0))
					end
					mat:rotate(0,-90,0)
						:rotate(pitch,0,yaw)
						:translate(parentPivot)

					part:setMatrix(mat)
				end
			end
		end
	end
end

events.POST_RENDER:register(function(delta, context)
	if invalidContexts[context] or client:isPaused() then
		return
	end

	-- If world time / render somehow runs twice, don't run
	if deltaTime == 0 then return end
	lastestDeltaTime,lasterDeltaTime,lastDeltaTime,lastDelta = lasterDeltaTime,lastDeltaTime,deltaTime,time
end)

setmetatable(physBone,{__index = physBone.children,__newindex = function(this,key,value)
	rawget(this,'children')[key] = value
end})
return physBone