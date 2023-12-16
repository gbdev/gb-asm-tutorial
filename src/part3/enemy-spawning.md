# Spawning Enemies

Our gameplay state will try to spawn more enemies, as the game progresses. It will do this using a function called `TryToSpawnEnemies`.

**Create a file called `enemies-spawning.asm` like so:**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies-spawning.asm:enemies-start}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies-spawning.asm:enemies-start}}
```

In our above code, we declared a variable in WRAM called `wSpawnCounter`. We'll use this variable as a timer. When it reaches a maximum value, we'll spawn a new enemy.

When we want to spawn a new enemy, first we need to find an inactive object in our object's pool. We'll do that using the `GetNextAvailableObject_InHL` function again. If the zero flag is set afterwards, all our enemy objects are currently active.

**Create a function called `TryToSpawnEnemies` in your `enemies-spawning.asm` file:**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies-spawning.asm:enemies-spawn1}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies-spawning.asm:enemies-spawn1}}
```

Before spawning an enemy, we need to determine a spawn position. All enemies will spawn with a y-position of 0. We only need to calculate the x position. We'll use the `rand` function that comes with the starter. We don't want enemies to spawn on the edges of the screen. Before continuing, make sure our spawn position is at least 3 tiles from the edge of the screen.

> **Note:** We'll save the random position in the `b` register.

**Add to the `TryToSpawnEnemies` function, the logic to calculate the spawn x position:**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies-spawning.asm:enemies-spawn2}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies-spawning.asm:enemies-spawn2}}
```

When spawning an enemy, first thing we do is reset our `wSpawnCounter` variable. With that done, we'll do the following:
- Set it as active
- Reset it's y position to 0
- Set the x position (we need to scale up the previously calculated value)
- Set it's metasprite
- Set it's health
- Set it's update function
- Reset it's damage byte to 0

**Finish the `TryToSpawnEnemies` function by activating the enemy, using the code below:**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies-spawning.asm:enemies-spawn3}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies-spawning.asm:enemies-spawn3}}
```

Once all of that's done, enemies should spawon on the screen.