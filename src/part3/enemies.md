# Enemies

Enemies in Shoot-em-ups often come in a variety of types, and travel also in a variety of patterns. To keep things simple for this tutorial, we'll have one single enemy type. That single type of enemy will only fly straight downward. Because of this decision, the logic for enemies is going to be similar to bullets in a way. They both travel vertically and disappear when off screeen. Some differences to point out are:

- Enemies are not spawned by the player, so we need logic that spawns them at random times and locations.
- Enemies must check for collision against the player
- Enemies must check for collision against bullets

**Create a new file called `enemies.asm`:**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-start}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-start}}
```

Our enemies will be a part of the object pool we [previously](#object-pools) setup

## Updating Enemies

When updating a single enemy, we first get the pointer to our enemies object. We copy this from `bc`. With that said, we'll  increase the y bytes to move the enemy downward.

Like with [bullets](#bullets), if the y high byte is above 10, we'll consider the enemy off screen.

**Create an `UpdateEnemy` function the following code:**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update1}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update1}}
```

If the enemy is still on screen we want to check for collisions. We'll do this using a function called `CheckCollisionForCurrentEnemy`. We'll define that in the next page. This function will set a result in the `a` register. 
- `ENEMY_COLLISION_NOTHING` - No collisions have occured
- `ENEMY_COLLISION_DAMAGED` - The enemy has been damaged by a bullet
- `ENEMY_COLLISION_END` - The enemy should be deactivated

>**Note:** These constants are already defined in constants.inc

We'll finish the `UpdateEnemy` exection based on the response for the function.

**Finish the `UpdateEnemy` function, with the following code:**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update2}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update2}}
```

When the enemy has been damaged, we'll jump to their health byte and decrement it. If it becomes zero, we'll kill the enemy. If the enemy still has health remaining, we'll set it as damaged for small time.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-damage}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-damage}}
```

When an enemy is killed, we simply increase the score and deactivate it.


```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-kill}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-kill}}
```

To deactivate any object in our object pool, we simply set the first byte to 0.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-deactivate}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-deactivate}}
```
