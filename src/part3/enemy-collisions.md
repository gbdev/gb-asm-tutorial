# Enemy Collision

In the previous page, we used a function called `CheckCollisionForCurrentEnemy`. We'll explain and define that function on this page.

There are two parts to enemy collision detection:
- Collision Detection against the player
- Collision Detection against bullets

**Create a file called `enemies-collision.asm`, and define the `CheckCollisionForCurrentEnemy` function in it:**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies-collision.asm:enemies-collision-start}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies-collision.asm:enemies-collision-start}}
```
## Collision Detection Against the Player

Firstly, enemies will check for collision against the player. To do this, we'll use the `CheckCollisionWithObjectsInHL_andDE` function previously created. Our player and enemies are both 16x16. The minimum allowed distances on both axes is 16.

> **Note:** The player will always be the first object in `wObjects`, so we can use it for `de`.

**Add to the `CheckCollisionForCurrentEnemy` function, the following logic:**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies-collision.asm:enemies-collision-player}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies-collision.asm:enemies-collision-player}}
```

If no collision occurs (the zero flag is set), we'll check against each bullet. If a collision has occured, we'll destroy the enemy and damage the player:

**Add the following below the `CheckCollisionForCurrentEnemy` function:**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies-collision.asm:enemies-collision-player2}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies-collision.asm:enemies-collision-player2}}
```
## Collision Detection Against bullets

Checking for collisions against bullets is essentially the same thing. The major difference is that we have multiple enemies, and thus must loop & check each.

The starter has a constant in `constants.inc` called `BULLETS_START`. We'll use this with the `wObjects` array to specify the first possible enemy bullet.

**Immediately below the `EnemyPlayerCollision` logic, Start the `UpdateEnemy_CheckAllBulletCollision` logic with the following code:**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies-collision.asm:enemies-collision-bullets1}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies-collision.asm:enemies-collision-bullets1}}
```

During each iteration of this loop, we'll have a pointer to the current enemy in `hl`. In addition, we'll have a pointer to the bullet in `de`. With that setup, we can call `CheckCollisionWithObjectsInHL_andDE` without much effort.

Our bullets are 8x16 and our enemies are 16x16. The minimum allowed distance on the x-axis is 12, and the minimum allowed distance on the y-axis is 16.

**Add the `UpdateEnemy_CheckBulletCollision` logic below, to the `UpdateEnemy_CheckAllBulletCollision` function:** 

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies-collision.asm:enemies-collision-bullets2}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies-collision.asm:enemies-collision-bullets2}}
```

If there's no collision we'll jump to the `MoveToNextBullet` label. Here, we'll decrease our counter (in `b`). When it reaches 0, we've checked all bullets. If we've checked all bullets, we'll return. Otherwise, we'll increase our `de` pointer and loop back around.

**Below the `UpdateEnemy_CheckBulletCollision` code, add the `MoveToNextBullet` logic below:**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies-collision.asm:enemies-collision-bullets3}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies-collision.asm:enemies-collision-bullets3}}
```

In the case of a enemy-bullet collision, we'll deactivate the bullet. Before returning, we'll set our `a` register to `ENEMY_COLLISION_DAMAGED`.

**Finish the `enemies-collision.asm` file with the `EnemyBulletCollision` logic below:**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies-collision.asm:enemies-collision-bullet4}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies-collision.asm:enemies-collision-bullet4}}
```