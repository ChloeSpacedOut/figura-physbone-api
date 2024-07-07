# Figura PhysBone API
A cheap, easy to use, and highly customisable physics system.
## Installation 
To install the physBone API, simply add `physBoneAPI.lua` into your script. Obviously if you use autoScripts in avatar.json, add it there. Require is not needed!
## Basic Swing Physics
Adding basics physics is simple. Just add the `physBone` prefix to the name of the group containing your model part/s. For example, a group part named `swingingLamp` could be renamed to `physBoneSwingingLamp` or `physBone_swingLamp`. Make sure the pivot point of this group is where you want the object to swing from. It's reccomended you put the pivot at the top of your parts, though if you need it to be at the bottom, you will need to use the physBone API to set the part as upside down. It's also reccomended you only have 1 folder / model inside your physBone for best performance. Once you've set the keyword, it should have physics in game!
### Breast / Boob Physics
There is an easy preset for breast physics. Just use the `physBoob` prefix instead of `physBone`. This is still a physBone, but will automatically be configued for breast physics.
### Ear Physics
Just like the breast physics preset, there's also the `physEar` preset for easy ear physics.
## PhysBone API
You can run many functions to customise how the physics behave, all of which will be described here.

**These functions can't be executed before the player entity has loaded!!**
The physBone API requires some entity information when scanning and generating its indexes and functions from your Blockbench file. Because of this, it only generates this in `entity_init()`. If you try and run these functions before the player entity is loaded, these indexes and functions simply won't exist, and it'll error. This just means you'll have to run these functions in `entity_init()` if you want to run at the beginning of your script. The tick, render, etc functions will all work just fine since they run after `entity_init()`.

When accessing a function with the physBone API, you'll need to enter your `partName`. This is not the path to your model part like it work in Figura's model part API. It is simply the name of your part. E.g. if your model part was `models.model.Head.physBoneHair`, you would just put `physBoneHair`. 

The functions in the physBone API are the following:
### setUpsideDown()
Sets this physBone to be upsidedown, meaning the pivot is at the bottom of the model instead of the top. For normal physBones, default is `false`, and the value is a boolean.
```lua
physBone.partName:setUpsideDown(value)
```
### getUpsideDown()
Returns if this physBone has been set to upsidedown as a boolean.
```lua
physBone.partName:getUpsideDown()
```
### setGravity()
Sets the strength of gravity for this physBone. For normal physBones, default is `-9.81`, and the value is an integer.
```lua
physBone.partName:setGravity(value)
```
### getGravity()
Returns the strength of gravity for this physBone as an integer.
```lua
physBone.partName:getGravity()
```
### setAirResistance()
Sets the strength of air resistance for this physBone. For normal physBones, default is `0.1`, and the value is an integer.
```lua
physBone.partName:setAirResistance(value)
```
### getAirResistance()
Returns the strength of air resistance for this physBone as an integer.
```lua
physBone.partName:getAirResistance()
```
### setSimSpeed()
Sets the simulation speed for this physBone. For normal physBones, default is `1`, and the value is an integer.
```lua
physBone.partName:setSimSpeed(value)
```
### getSimSpeed()
Returns the simulation speed for this physBone as an integer.
```lua
physBone.partName:getSimSpeed()
```
### setEquilibrium()
Sets the equilibrium state of the spring force for this physBone. For normal physBones, default is `vec(0,0)`, and the value is a vector 2. The 2 values in the vector are rotations in degrees. The equilibrium is the state at which the spring force will always try and pull the pendulum towards.
```lua
physBone.partName:setEquilibrium(value)
```
### getEquilibrium()
Returns the equilibrium state for this physBone as a vector 2.
```lua
physBone.partName:getEquilibrium()
```
### setSpringForce()
Sets the strength of the spring force for this physBone. For normal physBones, default is `0`, and the value is an integer.
```lua
physBone.partName:setSpringForce(value)
```
### getSpringForce()
Returns the strength of the spring force for this physBone as an integer.
```lua
physBone.partName:getSpringForce()
```

## Additional Notes
If you find any issues I missed or have any features you think would be useful, please let me know and I'll see what I can do! You're also more than welcome to contribute to the project yourself if you'd like <33
