# Figura PhysBone API
An easy to use, and highly customisable physics system.
## Basic Installation 
To install the physBone API, simply add `physBoneAPI.lua` into your script. Obviously if you use autoScripts in avatar.json, add it there. Require is not needed for doing just the basics.
## Basic PhysBones
Adding basic physics is simple. Simply rename the blockbench group you want to be a physBone to include the one of the prefixes listed bellow, and it should work in-game right away! Make sure your group's pivot matches where you want your physBone to swing from! 

It's also reccomended you add a second group inside your physBone and put all your model parts in there. If you're working with meshes, this will be required or they will break (Figura bug). You will be unable to edit the pos / rot / scale of any immediate children of the physBone with scripting, but subsequest children will be fine. Obviously you can't change the rot of the physBone itself.

Presets are listed bellow:
### Swing Physics (physBone / PhysBone)
The swing physics preset uses the `physBone` prefix. This will make your physBone swing like a pendulum. This is the default preset.
### Breast / Boob Physics (physBoob / PhysBoob)
The breat physics preset uses the `physBoob` prefix. This will make your physBone springy, tweaked to move like breasts. 
### Ear Physics (physEar / PhysEar)
The ear physics preset uses the `physEar` prefix. This will make your physBone springy, tweaked to move like cat, wolf, fox, etc ears.
## Advanced Physbones
### Script Setup
To fully customise your physBones, you will need to correctly set up your own script. First you will need to require the physBone API. Doing so should look like this:
```lua
physBone = require('physBoneAPI')
```
If physBoneAPI is in a folder, make sure to specify that.

Next you will need to make an `entity_init()` function. PhysBone functions can't run before entity init, so it'll be required to run them at the start of your script. With this done, your script should look like this:
```lua
physBone = require('physBoneAPI')
-- pre-init functions here
function events.entity_init()
    -- init functions here
end
```
### Accessing your PhysBones
To use the PhysBone functions, you must first access your physbone. The basic method is just `physBone.yourPhysBoneName:yourFunction()`. For example:
```lua
physBone.myPhysBone:setGravity(-4)
```
### Creating PhysBones with Scripting
You can easily create a physBone with the `newPhysBone()` function from the ModelPart API. Include your chosen preset as the first parameter. This function will return your physBone, which can be used as an altrnate method of accessing your physBone. For example:
```lua
local myBone = models.model.Head.physHair:newPhysBone("physBone")
myBone:setRotMod(vec(-90,0,0))
    :setSpringForce(70)
    :setEquilibrium(vec(0,30))
```

### Debug Mode
By pressing the `~` key, you will toggle debug mode. This will display your physBones for you only. Your physBone pivots are indicated by red squares, your bones are indicated with white lines, and spring force indicated by blue lines that change in length depending on the strength of the force. This mode can be used to easily debug mis-aligned physBones, and help with setting the equilibrium.

### Aligning your PhysBones
Unless your physBone is pointing directly down in blockbech, you will need to manually align your physBones. To do this, first enable debug mode. This will make it clearer which direction your physBone is actually facing. Then, with the `setRotMod()` function, you can rotate your model part until it alligns with the bone.

### Setting up Springs
Before setting up a spring, ensure your physBone is aligned. Next, you'll want to set your spring force using the `setSpringForce()` function. With this done, enable debug mode. You should see a blue line on your physBone. This is the equilibrium point, where the spring will pull you. Finally, you can adjust this point with `setEquilibrium()`, rotating it in degrees. An example of this might look like:
```lua
physBone.myPhysBone:setRotMod(vec(-90,0,0))
physBone.myPhysBone:setSpringForce(70)
physBone.myPhysBone:setEquilibrium(vec(0,30))
```

### Custom Presets
You can create or edit custom presets using the `setPreset()` function in the PhysBoneAPI. If you run these before entity_init, physBone will use your custom presets during automatic physBone generation. You can also update an existing physBone with the `updateWithPreset()` function in PhysBone.

# PhysBone Docs
## ModelPart
### newPhysBone()
`<modelPart>:newPhysBone(String presetID) → Returns PhysBone`

Creates a new physBone using the entered preset.
```lua
myPhysBone = models.model.group:newPhysBone("physBone")
```
### getPhysBone
`<modelPart>:getPhysBone() → Returns PhysBone`

Returns your physBone from your model part.
```lua
myPhysBone = models.model.group:getPhysBone()
```
## PhysBoneAPI
### setPreset()
`<physBoneAPI>:setPreset(String ID, Vector3 rotMod, Number mass, Number gravity, Number airResistance, Number simSpeed, Vector2 equilibrium, Number springForce, Vector3 force, Vector3 vecMod) → Returns nil`

Sets the default values of a preset. Can also create a new preset by entering a unique ID. By running this function pre-init, physBone can check for prefixes in your blockbench model and generate physBones using this preset. Your ID is used at a prefix. If a a preset value as `nil`, it will use the default `physBone` value.
```lua
physBone:setPreset("physZeroGrav",nil,nil,0)
```
### removePreset()
`<physBoneAPI>:removePreset(String ID) → Returns nil`

Removes a preset. By running this function pre-init, you can prevent physBone from checking for this preset.
```lua
physBone:removePreset("physZeroGrav")
```
### getPhysBone()
`<physBoneAPI>:getPhysBone(ModelPart) → Returns PhysBone`

Returns your physBone from your model part.
```lua
physBone:getPhysBone(models.model.group)
```
## PhysBone
**IMPORTANT: These functions cannot be run before `entity_init`** Make sure you put them in your `entity_init` function or a function which runs after the player entity has loaded.

### setMass()
`<PhysBone>:setMass(Number mass) → Returns PhysBone`

Sets the mass (weight) for this physBone. Mass cannot be 0 or bellow. For normal physBones, default is `1`.
```lua
physBone.myPhysBone:setMass(2)
```
### getMass()
`<PhysBone>:getMass() → Returns Number`

Returns the mass (weight) for this physBone.
```lua
local mass = physBone.myPhysBone:getMass()
```
### setGravity()
`<PhysBone>:setGravity(Number gravity) → Returns PhysBone`

Sets the strength of gravity for this physBone. For normal physBones, default is `-9.81`.
```lua
physBone.myPhysBone:setGravity(-1.62)
```
### getGravity()
`<PhysBone>:getGravity() → Returns Number`

Returns the strength of gravity for this physBone.
```lua
local gravity = physBone.myPhysBone:getGravity()
```
### setAirResistance()
`<PhysBone>:setAirResistance(Number airResistance) → Returns PhysBone`

Sets the strength of air resistance for this physBone. For normal physBones, default is `0.1`.
```lua
physBone.myPhysBone:setAirResistance(0.5)
```
### getAirResistance()
`<PhysBone>:getAirResistance() → Returns Number`

Returns the strength of air resistance for this physBone.
```lua
local airResistance = physBone.myPhysBone:getAirResistance()
```
### setSimSpeed()
`<PhysBone>:setSimSpeed(Number simSpreed) → Returns PhysBone`

Sets the simulation speed for this physBone. For normal physBones, default is `1`.
```lua
physBone.myPhysBone:setSimSpeed(2)
```
### getSimSpeed()
`<PhysBone>:getSimSpeed() → Returns Number`

Returns the simulation speed for this physBone.
```lua
local simSpeed = physBone.myPhysBone:getSimSpeed()
```
### setEquilibrium()
`<PhysBone>:setEquilibrium(Vector 2 equilibrium) → Returns PhysBone`

Sets the equilibrium state of the spring force for this physBone. For normal physBones, default is `vec(-90,0)`. The 2 values in the vector are rotations in degrees. The equilibrium is the state at which the spring force will always try and pull the pendulum towards.
```lua
physBone.myPhysBone:setEquilibrium(vec(45,0))
```
### getEquilibrium()
`<PhysBone>:getEquilibrium() → Returns Vector 2`

Returns the equilibrium state for this physBone.
```lua
local equilibrium = physBone.myPhysBone:getEquilibrium()
```
### setSpringForce()
`<PhysBone>:setSpringForce(Number springForce) → Returns PhysBone`

Sets the strength of the spring force for this physBone. For normal physBones, default is `0`.
```lua
physBone.myPhysBone:setSpringForce(50)
```
### getSpringForce()
`<PhysBone>:getSpringForce() → Returns Number`

Returns the strength of the spring force for this physBone.
```lua
local springForce = physBone.myPhysBone:getSpringForce()
```
### setRotMod()
`<PhysBone>:setRotMod(Vector 3 rotMod) → Returns PhysBone`

Sets the rotation modifyer for this physBone. This is useful for if your model parts don't match the physBone direction vector. For normal physBones, default is `vec(0,0,0)`.
```lua
physBone.myPhysBone:setRotMod(vec(0,0,-90))
```
### getRotMod()
`<PhysBone>:getRotMod() → Returns Vector 3`

Returns the strength of gravity for this physBone.
```lua
local rotMod = physBone.myPhysBone:getRotMod()
```
### setForce()
`<PhysBone>:setForce(Vector 3 force) → Returns PhysBone`

Sets the custom force for this physBone. This allows for more direct control of the physBones. The force is applied constantly. For normal physBones, default is `vec(0,0,0)`.
```lua
physBone.myPhysBone:setForce(vec(45,0,45))
```
### getForce()
`<PhysBone>:getForce() → Returns Vector 3`

Returns the custom force for this physBone.
```lua
local force = physBone.myPhysBone:getForce()
```
### setVecMod()
`<PhysBone>:setVecMod(Vector 3 vecMod) → Returns PhysBone`

Sets the vector modifyer for this physBone. This allows for scaling axies of the physBone vector, allowing restricted or exaggerated motion for specified axies. For normal physBones, default is `vec(1,1,1)`.
```lua
physBone.myPhysBone:setVecMod(vec(1,1,0))
```
### getVecMod()
`<PhysBone>:getVecMod() → Returns Vector 3`

Returns the vector modifyer for this physBone.
```lua
local force = physBone.myPhysBone:getForce()
```
### updateWithPreset()
`<PhysBone>:updateWithPreset(String presetID) → Returns PhysBone`

Updates this physBone to use the specified preset. If values in the preset are nil, they will not be updated in the physBone.
```lua
physBone.myPhysBone:updateWithPreset("myCustomPreset")
```
### remove()
`<PhysBone>:remove() → Returns nil`

Removes this physBone and resets its rotation.
```lua
physBone.myPhysBone:remove()
```
# Additional Notes
If you find any issues I missed or have any features you think would be useful, please let me know and I'll see what I can do! You're also more than welcome to contribute to the project yourself if you'd like <33
