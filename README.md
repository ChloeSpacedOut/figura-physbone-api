# Figura PhysBone API
A cheap, easy to use, and highly customisable physics system.
## Installation 
To install the physbone API, simply add `physBoneAPI.lua` into your script. Obviously if you use autoScripts in avatar.json, add it there.
## Basic Physics
To add basic physics to a model part, simply add the `physBone` prefix to the name of your model part. For example, a model part named `swingingLamp` could be renamed to `physBoneSwingingLamp` or `physBone_swingLamp`. This works exactly the same as parent types (Blockbench keywords), so you can just treat it as the physbone parent type if you like, but it technically isn't. Once you've set the keyword, it should have physics in game!
## PhysBone API
You can run many functions to customize how the physics behave, all of which will be described here.

**These functions can't be executed before the player entity has loaded!!**
The physbone API requires some entity information when scanning and generating its indexes and functions from your Blockbench file. Because of this, it only generates this in `entity_init()`. If you try and run these functions before the player entity is loaded, these indexes and functions simply won't exist, and it'll error. This just means you'll have to run these functions in `entity_init()` if you want to run at the beginning of your script. The tick, render, etc functions will all work just fine since they run after `entity_init()`.

When accessing a function with the physbone API, you'll need to enter your `partName`. This is not the path to your model part like it work in Figura's model part API. It is simply the name of your part. E.g. if your model part was `models.model.Head.physBoneHair`, you would just put `physBoneHair`. 

Due to how this works, it edits the Blockbench file structure. Due to this, if you're using the default blockbench file path, you won't be able to access model parts inside any part you labled as a physbone. They will have been moved to a new location. This is inside the PYC group (pitch yaw correction group, located in your physbone group), and then inside that, in the RC group (rotation correction group). These names are also prefixes, and use the same name as your origional group name. For example, if your file path was origionally `models.model.Head.physBoneHair.bow`, it will now become `models.model.Head.physBoneHair.PYCHair.RCHair.bow`.

The functions are the following:
### setGravity()
Sets the strength of gravity for that physbone. Default is `-9.81`, and the value is an integer.
```lua
physBone.partName:setGravity(value)
```
### getGravity()
Returns the strength of gravity for that physbone as an integer.
```lua
physBone.partName:getGravity()
```
### setAirResistance()
Sets the strength of air resistance for that physbone. Default is `0.15`, and the value is an integer.
```lua
physBone.partName:setAirResistance(value)
```
### getAirResistance()
Returns the strength of air resistance for that physbone as an integer.
```lua
physBone.partName:getAirResistance()
```
### setSimSpeed()
Sets the simulation speed for that physbone. Default is `1`, and the value is an integer.
```lua
physBone.partName:setSimSpeed(value)
```
### getSimSpeed()
Returns the simulation speed for that physbone as an integer.
```lua
physBone.partName:getSimSpeed()
```
### setEquilibrium()
Sets the equilibrium state for the spring force for that physbone. Default is `vec(0,1,0)`, and the value is a vector 3. The equilibrium is the state at which the spring force will always try and pull the pendulum towards.
```lua
physBone.partName:setEquilibrium(value)
```
### getEquilibrium()
Returns the equilibrium state for that physbone as a vector 3. The equilibrium is the state at which the spring force will always try and pull the pendulum towards.
```lua
physBone.partName:getEquilibrium()
```
### setSpringForce()
Sets the strength of the spring force for that physbone. Default is `0`, and the value is an integer.
```lua
physBone.partName:setSpringForce(value)
```
### getSpringForce()
Returns the strength of the spring force for that physbone as an integer.
```lua
physBone.partName:getSpringForce()
```

## Additional Notes
This is an early version. There are many issues I need to fix, and features I'd like to add. Please let me know if you have found any of these issues, and any features that would be useful. You're also more than welcome to contribute to the project yourself if you'd like <33
