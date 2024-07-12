# Figura PhysBone API
A cheap, easy to use, and highly customisable physics system.
## Basic Installation 
To install the physBone API, simply add `physBoneAPI.lua` into your script. Obviously if you use autoScripts in avatar.json, add it there. Require is not needed for doing just the basics.
## Basic PhysBones
Adding basic physics is simple. Simply rename the blockbench group you want to be a physBone to include the one of the prefixes listed bellow, and it should work in-game right away! Make sure your group's pivot matches where you want your physBone to swing from! 

It's also reccomended you add a second group inside your physBone and put all your model parts in there. If you're working with meshes, this will be required or they will break (Figura bug). You will be unable to edit the pos / rot / scale of any immediate children of the physBone with scripting, but subsequest children will be fine.

Presets are listed bellow:
### Swing Physics (physBone)
The swing physics preset uses the `physBone` prefix. This will make your physBone swing like a pendulum. This is the default preset.
### Breast / Boob Physics (physBoob)
The breat physics preset uses the `physBoob` prefix. This will make your physBone springy, tweaked to move like breasts. 
### Ear Physics (physEar)
The ear physics preset uses the `physEar` prefix. This will make your physBone springy, tweaked to move like cat, wolf, fox, etc ears.
## Script Setup
To fully customise your physBones, you will need to correctly set up your own script. First you will need to require the physBone API. Doing so should look like this:
```lua
physBone = require('physBoneAPI')
```
If physBoneAPI is in a folder, make sure to specify that.

Next you will need to make an `entity_init()` function to run physBoneAPI functions you want to run at the start of your script. With this done, your script should look like this:
```lua
physBone = require('physBoneAPI')
-- pre-init functions here
function events.entity_init()
    -- init functions here
end
```
## Debug Mode
By pressing the `~` key, you will toggle debug mode. This will display your physBones for you only. Your physBone pivots are indicated by red squares, your bones are indicated with white lines, and spring force indicated by blue lines that change in length depending on the strength of the force. This mode can be used to easily debug mis-aligned physBones, and help with setting the equilibrium. More will be added to the debug mode in the future.
# PhysBone Docs
## ModelPart
### newPhysBone()
`<modelPart>:newPhysBone(String physBonePreset) → Returns PhysBone`

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
`<physBoneAPI>:setPreset(String ID, Number gravity, Number airResistance, Number simSpeed, Vector2 equilibrium, Number springForce, Vector3 rotMod) → Returns nil`

Sets the default values of a preset. Can also create a new preset by entering a unique ID. By running this function pre-init, physBone can check for prefixes in your blockbench model and generate physBones using this preset. Your ID is used at a prefix. If a a preset value as `nil`, it will use the default `physBone` value.
```lua
physBone:setPreset("physZeroGrav",0,0)
```
### removePreset()
`<physBoneAPI>:removePreset(String ID) → Returns nil`

Removes a preset. By running this function pre-init, you can prevent physBone from checking for this preset.
```lua
physBone:removePreset("physZeroGrav")
```
## PhysBone
**IMPORTANT: These functions cannot be run before `entity_init`** Make sure you put them in your `entity_init` function or a function which runs after the player entity has loaded.

**IMPORTANT: You must access the physBone to use this api**. To do this, there are 2 methods. First you can use the `getPhysBone()` function from the ModelPart API. This will return your physbone, which can be used by this API. Alternatively, you can use the `physBone` table, which contains all your physBones. By endering the ID of your physBone (the blockbench part name), you can access your physBone. Both methods will be provided in the examples for each function.
### setGravity()
`<PhysBone>:setGravity(Number gravity) → Returns PhysBone`

Sets the strength of gravity for this physBone. For normal physBones, default is `-9.81`.
```lua
local myPhysBone = models.model.myPhysBone:getPhysBone()
myPhysBone:setGravity(-1.62)
```
```lua
physBone.myPhysBone:setGravity(-1.62)
```
### getGravity()
`<PhysBone>:getGravity() → Returns Number`

Returns the strength of gravity for this physBone.
```lua
local myPhysBone = models.model.myPhysBone:getPhysBone()
local gravity = myPhysBone:getGravity()
```
```lua
local gravity = physBone.myPhysBone:getGravity()
```
### setAirResistance()
`<PhysBone>:setAirResistance(Number airResistance) → Returns PhysBone`

Sets the strength of air resistance for this physBone. For normal physBones, default is `0.1`.
```lua
local myPhysBone = models.model.myPhysBone:getPhysBone()
myPhysBone:setAirResistance(0.5)
```
```lua
physBone.myPhysBone:setAirResistance(0.5)
```
### getAirResistance()
`<PhysBone>:getAirResistance() → Returns Number`

Returns the strength of air resistance for this physBone.
```lua
local myPhysBone = models.model.myPhysBone:getPhysBone()
local airResistance = myPhysBone:getAirResistance()
```
```lua
local airResistance = physBone.myPhysBone:getAirResistance()
```
### setSimSpeed()
`<PhysBone>:setSimSpeed(Number simSpreed) → Returns PhysBone`

Sets the simulation speed for this physBone. For normal physBones, default is `1`.
```lua
local myPhysBone = models.model.myPhysBone:getPhysBone()
myPhysBone:setSimSpeed(2)
```
```lua
physBone.myPhysBone:setSimSpeed(2)
```
### getSimSpeed()
`<PhysBone>:getSimSpeed() → Returns Number`

Returns the simulation speed for this physBone.
```lua
local myPhysBone = models.model.myPhysBone:getPhysBone()
local simSpeed = myPhysBone:getSimSpeed()
```
```lua
local simSpeed = physBone.myPhysBone:getSimSpeed()
```
### setEquilibrium()
`<PhysBone>:setEquilibrium(Vector 2 equilibrium) → Returns PhysBone`

Sets the equilibrium state of the spring force for this physBone. For normal physBones, default is `vec(-90,0)`. The 2 values in the vector are rotations in degrees. The equilibrium is the state at which the spring force will always try and pull the pendulum towards.
```lua
local myPhysBone = models.model.myPhysBone:getPhysBone()
myPhysBone:setEquilibrium(vec(45,0))
```
```lua
physBone.myPhysBone:setEquilibrium(vec(45,0))
```
### getEquilibrium()
`<PhysBone>:getEquilibrium() → Returns Vector 2`

Returns the equilibrium state for this physBone.
```lua
local myPhysBone = models.model.myPhysBone:getPhysBone()
local equilibrium = myPhysBone:getEquilibrium()
```
```lua
local equilibrium = physBone.myPhysBone:getEquilibrium()
```
### setSpringForce()
`<PhysBone>:setSpringForce(Number springForce) → Returns PhysBone`

Sets the strength of the spring force for this physBone. For normal physBones, default is `0`.
```lua
local myPhysBone = models.model.myPhysBone:getPhysBone()
myPhysBone:setSpringForce(50)
```
```lua
physBone.myPhysBone:setSpringForce(50)
```
### getSpringForce()
`<PhysBone>:getSpringForce() → Returns Number`

Returns the strength of the spring force for this physBone.
```lua
local myPhysBone = models.model.myPhysBone:getPhysBone()
local springForce = myPhysBone:getSpringForce()
```
```lua
local springForce = physBone.myPhysBone:getSpringForce()
```
### setRotMod()
`<PhysBone>:setRotMod(Vector 3 rotMod) → Returns PhysBone`

Sets the rotation modifyer for this physBone. This is useful for if your model parts don't match the physBone direction vector. For normal physBones, default is `vec(0,0,0)`.
```lua
local myPhysBone = models.model.myPhysBone:getPhysBone()
myPhysBone:setRotMod(vec(0,0,-90))
```
```lua
physBone.myPhysBone:setRotMod(vec(0,0,-90))
```
### getRotMod()
`<PhysBone>:getRotMod() → Returns Vector 3`

Returns the strength of gravity for this physBone.
```lua
local myPhysBone = models.model.myPhysBone:getPhysBone()
local rotMod = myPhysBone:getRotMod()
```
```lua
local rotMod = physBone.myPhysBone:getRotMod()
```
### remove()
`<PhysBone>:remove() → Returns nil`

Removes this physBone and resets its rotation.
```lua
local myPhysBone = models.model.myPhysBone:getPhysBone()
myPhysBone:remove()
```
```lua
physBone.myPhysBone:remove()
```


# Additional Notes
If you find any issues I missed or have any features you think would be useful, please let me know and I'll see what I can do! You're also more than welcome to contribute to the project yourself if you'd like <33
