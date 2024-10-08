-- Physbone 2.0 pre-release 2 By ChloeSpacedOut <3
-- Some funny additions made by Superpowers04 :3
local physBone = {
	-- DO NOT ENABLE THIS UNLESS YOU KNOW WHAT YOU'RE DOING, THIS APPENDS THE INDEX OF THE PHYSBONE TO IT'S NAME IF THERE'S A DUPLICATE AND CAN CAUSE ISSUES
	allowDuplicates = false,
	children = {},
	collider = {},
	index = {},
}
local physBoneIndex = physBone.index
local boneID = 0
local lastDeltaTime,lasterDeltaTime,lastestDeltaTime,lastDelta = 1,1,1,1
local physBonePresets = {}
local debugMode = false
local colliderTexture = textures:newTexture("collider",1,1)
	:setPixel(0,0,vec(0,0,0,0))


-- Physbone metatable
local physBoneBase = {
	setRotMod =
		function(self,data)
			self.rotMod = data
			if host:isHost() and self.path.PB_Debug_Direction then
				self.path.PB_Debug_Direction:setRot(-data)
			end
			return self
		end,
	getRotMod =
		function(self)
			return self.upsideDown
		end,
	setMass =
		function(self,data)
			self.mass = data
			return self
		end,
	getMass =
		function(self)
			return self.mass
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
	setSpringForce =
		function(self,data)
			self.springForce = data
			return self
		end,
	getSpringForce =
		function(self)
			return self.springForce
		end,
	setEquilibrium =
		function(self,data)
			self.equilibrium = data
			if host:isHost() and self.path.PB_Debug_SpringForce then
				local springForceGroup = self.path.PB_Debug_SpringForce
				local pivot = springForceGroup:getPivot()
				local mat = matrices.mat4()
				mat:scale(1,self.springForce/50,1)
					:translate(-pivot)
					:rotate(0,0,data.x+90)
					:rotate(0,data.y,0)
					:translate(pivot)
				springForceGroup:setMatrix(mat)
			end
			return self
		end,
	getEquilibrium =
		function(self)
			return self.equilibrium
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
	setForce =
		function(self,data)
			self.force = data
			return self
		end,
	getForce =
		function(self)
			return self.force
		end,
	setVecMod =
		function(self,data)
			self.vecMod = data
			return self
		end,
	getVecMod =
		function(self)
			return self.vecMod
		end,
	setLength =
		function(self,data)
			self.length = data
			if host:isHost() and self.path.PB_Debug_Direction then
				self.path.PB_Debug_Direction.child:setScale(1,self.length,1)
			end
			return self
		end,
	getLength =
		function(self)
			return self.length
		end,
	setNodeStart =
		function(self,data)
			self.nodeStart = data
			return self
		end,
	getNodeStart =
		function(self)
			return self.nodeStart
		end,
	setNodeEnd =
		function(self,data)
			self.nodeEnd = data
			return self
		end,
	getNodeEnd =
		function(self)
			return self.nodeEnd
		end,
	setNodeDensity =
		function(self,data)
			self.nodeDensity = data
			return self
		end,
	getNodeDensity =
		function(self)
			return self.nodeDensity
		end,
	setNodeRadius =
		function(self,data)
			self.nodeRadius = data
			return self
		end,
	getNodeRadiusy =
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
			for k,v in pairs {"rotMod","mass","gravity","airResistance","simSpeed","equilibrium","springForce","force","vecMod","length","nodeStart","nodeEnd","nodeDensity","nodeRadius","bounce"} do
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

-- Temp collider table
local colliderBase = {

}

-- Internal Function: Returns physbone metatable from set values
physBone.newPhysBoneFromValues = function(self,path,rotMod,mass,gravity,airResistance,simSpeed,equilibrium,springForce,force,vecMod,length,nodeStart,nodeEnd,nodeDensity,nodeRadius,bounce,id,name)
	if(self ~= physBone) then
		-- Literally just offsets everything so self is used as the base 
		path,rotMod,mass,gravity,airResistance,simSpeed,equilibrium,springForce,force,vecMod,length,nodeStart,nodeEnd,nodeDensity,nodeRadius,bounce,id,name = self,path,rotMod,mass,gravity,airResistance,simSpeed,equilibrium,springForce,force,vecMod,length,nodeStart,nodeEnd,nodeDensity,nodeRadius,bounce,id,name
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
		rotMod = rotMod,
		mass = mass,
		gravity = gravity,
		airResistance = airResistance,
		simSpeed = simSpeed,
		equilibrium = equilibrium,
		springForce = springForce,
		force = force,
		vecMod = vecMod,
		length = length,
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
		physBone.newPhysBoneFromValues(part,preset.rotMod,preset.mass,preset.gravity,preset.airResistance,preset.simSpeed,preset.equilibrium,preset.springForce,preset.force,preset.vecMod,preset.length,preset.nodeStart,preset.nodeEnd,preset.nodeDensity,preset.nodeRadius,preset.bounce,boneID,ID)
	)
	if host:isHost() then
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
physBone.setPreset = function(self,ID,rotMod,mass,gravity,airResistance,simSpeed,equilibrium,springForce,force,vecMod,length,nodeStart,nodeEnd,nodeDensity,nodeRadius,bounce)
	local presetCache = {}
	local references = {rotMod = rotMod, mass = mass, gravity = gravity, airResistance = airResistance, simSpeed = simSpeed, equilibrium = equilibrium, springForce = springForce, force = force, vecMod = vecMod, length = length, nodeStart = nodeStart, nodeEnd = nodeEnd, nodeDensity = nodeDensity, nodeRadius = nodeRadius, bounce = bounce}
	local fallbacks = {rotMod = vec(0,0,0), mass = 1, gravity = -9.81, airResistance = 0.1, simSpeed = 1, equilibrium = vec(0,0), springForce = 0, force = vec(0,0,0), vecMod = vec(1,1,1), length = 16, nodeStart = 0, nodeEnd = 16, nodeDensity = 1, nodeRadius = 0, bounce = 0.8}
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
physBone:setPreset("physBoob",vec(-90,0,0),2,nil,0.5,nil,nil,200)
physBone:setPreset("PhysBoob",vec(-90,0,0),2,nil,0.5,nil,nil,200)
physBone:setPreset("physEar",vec(0,180,180),2,nil,0.5,nil,vec(0,90),120)
physBone:setPreset("PhysEar",vec(0,180,180),2,nil,0.5,nil,vec(0,90),120)

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

-- Generates a physBone's debug model
local debugTexture = textures:newTexture("test",1,1):setPixel(0,0,vec(1,1,1))
function physBone.addDebugParts(part,preset)
	local pivotGroup = part:newPart("PB_Debug_Pivot","Camera")
	pivotGroup:newSprite("pivot")
		:setTexture(debugTexture,1,1)
		:setColor(1,0,0)
		:setRenderType("EMISSIVE_SOLID")
		:setMatrix(matrices.mat4():translate(0.5,0.5,0.5):scale(0.5,0.5,0.5):rotate(0,0,0) * 0.1)

	local directionGroup = part:newPart("PB_Debug_Direction"):newPart("child")
	for k = 0, 3 do
		directionGroup:newSprite("line"..k)
			:setTexture(debugTexture,1,1)
			:setRenderType("EMISSIVE_SOLID")
			:setMatrix(matrices.mat4():translate(0.5,0,0.5):scale(0.5,math.worldScale,0.5):rotate(0,k*90,0) * 0.12)
	end
	directionGroup:setScale(1,preset.length,1)
	directionGroup:setRot(-preset.rotMod)
	local springForceGroup = part:newPart("PB_Debug_SpringForce")
	for k = 0, 3 do
		springForceGroup:newSprite("line"..k)
			:setTexture(debugTexture,1,1)
			:setColor(0,0,1)
			:setRenderType("EMISSIVE_SOLID")
			:setMatrix(matrices.mat4():translate(0.5,0,0.5):scale(0.25,3,0.25):rotate(0,k*90,0) * 0.11)
	end
	local pivot = springForceGroup:getPivot()
	local mat = matrices.mat4()
	mat:translate(-pivot)
		:scale(1,preset.springForce/50,1)
		:rotate(0,0,preset.equilibrium.x+90)
		:rotate(0,preset.equilibrium.y,0)
		:translate(pivot)
	springForceGroup:setMatrix(mat)

	for k,v in pairs({"PB_Debug_Pivot","PB_Debug_Direction","PB_Debug_SpringForce"}) do
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
function debugKeybind.press()
	debugMode = not debugMode
	for _,boneID in pairs(physBoneIndex) do
		physBone[boneID].path.PB_Debug_Pivot:setVisible(debugMode)
		physBone[boneID].path.PB_Debug_Direction:setVisible(debugMode)
		physBone[boneID].path.PB_Debug_SpringForce:setVisible(debugMode)
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
local renderFunction = "render"
local deg = math.deg
local atan2 = math.atan2
local asin = math.asin
local zeroVec = vec(0,0,0)
local invalidContexts = {
	PAPERDOLL = true,
	MINECRAFT_GUI = true,
	FIGURA_GUI = true
}

-- Render function
events[renderFunction]:register(function (delta,context)
	if(invalidContexts[context] or client:isPaused()) then
		return
	end

	-- Time calculations
	local time = (physClock + delta)
	local deltaTime = time - lastDelta

	-- If world time / render somehow runs twice, don't run
	if deltaTime == 0 then return end

	-- Collider setup
	local colliderGroups = {}
	for colID,collider in pairs(physBone.collider) do
		colliderGroups[colID] = {}
		local colGroup = colliderGroups[colID]
		local colMatrix = collider.part:partToWorldMatrix()
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

	for _,curPhysBoneID in pairs(physBoneIndex) do
		local curPhysBone = physBone[curPhysBoneID]
		local worldPartMat = curPhysBone.path:partToWorldMatrix()
		local parentWorldPartMat = curPhysBone.path:getParent():partToWorldMatrix()

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
			local equalib = curPhysBone.equilibrium
			local relativeDirMat = parentWorldPartMat:copy() * matrices.mat4():rotate(equalib.y,equalib.x,0)
			local reliveDir = relativeDirMat:applyDir(0,0,-1):normalized()
			local springForce = reliveDir * curPhysBone.springForce
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
		for node = 1, curPhysBone.nodeDensity do
			local nodeLength = curPhysBone.nodeEnd * ((curPhysBone.nodeEnd - curPhysBone.nodeStart) / curPhysBone.nodeEnd) * (node  / curPhysBone.nodeDensity) + curPhysBone.nodeStart
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
					local radius = curPhysBone.nodeRadius / 16 / math.worldScale
					local isXCollided = (distanceZ - radius) <= 0 and -size.z <= distanceZ
					local isYCollided = distanceY <= penetration * size.y and (penetration * -size.y) - size.y <= distanceY and penetration >= -0.5
					local isZCollided = distanceX <= penetration * size.x and (penetration * -size.x) - size.x <= distanceX and penetration >= -0.5
					if isXCollided and isYCollided and isZCollided then
						planeNormal = normalZ
						distance = distanceZ - radius
						hasCollided = true
						nodeDir = (nodePos - pendulumBase):normalized()
					end
				end
			end
		end

		-- Finalise physics
		local nextPos = pendulumBase + direction * (curPhysBone.length / 16)
		if not hasCollided then
			curPhysBone.velocity = nextPos - curPhysBone.pos
			curPhysBone.pos = nextPos
		else
			local bounce = (curPhysBone.bounce * 2.61)
			curPhysBone.velocity = (velocity - bounce * velocity:dot(planeNormal) * planeNormal) * lasterDeltaTime * ((curPhysBone.simSpeed * curPhysBone.mass)/100)
			curPhysBone.pos = nextPos - distance * planeNormal
		end

		-- Rotation calcualtion
		local relativeVec = (worldPartMat:copy()):invert():apply(pendulumBase + (curPhysBone.pos - pendulumBase)):normalize()
		relativeVec = (relativeVec * curPhysBone.vecMod):normalized()
		relativeVec = vectors.rotateAroundAxis(90,relativeVec,vec(-1,0,0))
		local yaw = deg(atan2(relativeVec.x,relativeVec.z))
		local pitch = deg(asin(-relativeVec.y))

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
							:rotate(curPhysBone.rotMod)
							:rotate(0,-90,0)
							:rotate(pitch,0,yaw)
							:translate(parentPivot)

						part:setMatrix(mat)
					end
				end
			end
		end
	end

	-- Store deltaTime values
	lastestDeltaTime,lasterDeltaTime,lastDeltaTime,lastDelta = lasterDeltaTime,lastDeltaTime,deltaTime,time
end,'PHYSBONE.'..renderFunction)

setmetatable(physBone,{__index=physBone.children,__newindex=function(this,key,value)
	rawget(this,'children')[key]= value
end})
return physBone