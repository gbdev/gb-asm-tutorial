# Enemies

Enemies in SHMUPS often come in a variety of types, and travel also in a vareity of patterns. To keep things simple for this tutorial, we'll have one enemy that flys straight downward. Because of this decision, the logic for enemies is going to be similar to bullets in a way. They both travel vertically and disappear when off screeen. Some differences to point out are:

- Enemies are not spawned by the player, so we need logic that spawns them at random times and locations.
- Enemies must check for collision against the player
- We'll check for collision against bullets in the enemy update function.

Here are the RAM variables we'll use for our enemies:

- wNextEnemyXPosition - When this variable has a non-zero value, we'll spawn a new enemy at that position
- wSpawnCounter - We'll decrease this, when it reaches zero we'll spawn a new enemy (by setting 'wNextEnemyXPosition' to a non-zero value).
- wActiveEnemyCounter - This tracks how many enemies we have on screen
- wUpdateEnemiesCounter - This is used when updating enemies so we know how many we have updated.
- wUpdateEnemiesCurrentEnemyAddress - When we check for enemy v. bullet collision, we'll save the address of our current enemy here.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-start}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-start}}
```

Just like with bullets, we'll setup ROM data for our enemies tile data and metasprites.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-tile-metasprite}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-tile-metasprite}}
```

## Initializing Enemies

When initializing the enemies (at the start of gameplay), we'll copy the enemy tile data into VRAM. Also, like with bullets, we'll loop through and make sure each enemy is set to inactive.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-initialize}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-initialize}}
```

## Updating Enemies

When "UpdateEnemies" is called from gameplay, the first thing we try to do is spawn new enemies. After that, if we have no active enemies, we stop the "UpdateEnemies" function. From here, like with bullets, we'll save the address of our first enemy in hl and start looping through.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-start}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-start}}
```

When we are  looping through our enemy object pool, let's check if the current enemy is active. If it's active, we'll update it like normal. If it isn't active, the game checks if we want to spawn a new enemy. We specify we want to spawn a new enemy by setting 'wNextEnemyXPosition' to a non-zero value. If we don't want to spawn a new enemy, we'll move on to the next enemy.

If we want to spawn a new enemy, we'll set it to active. Afterwards, we'll set it's y position to zero, and it's x position to whatever was in the 'wNextEnemyXPosition' variable. After that, we'll increase our active enemy counter, and go on to update the enemy like normal.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-per-enemy}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-per-enemy}}
```

When We are done updating a single enemy, we'll jump to the "UpdateEnemies_Loop" label. Here we'll increase how many enemies we've updated, and end if we've done them all. If we still have more enemies left, we'll increase the address stored in hl by 6 and update the next enemy.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-loop}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-loop}}
```

For updating enemies, we'll first get the enemies speed. Afterwards we'll increase the enemies 16-bit y position. Once we've done that, we'll descale the y position so we can check for collisions and draw the ennemy.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-per-enemy2}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-per-enemy2}}
```

## Player Collision

One of the differences between enemies and bullets is that enemies must check for collision against the player. For this, we'll use a simple Axis-Aligned Bounding Box test. We’ve created a basic function called “CheckObjectPositionDifference”. This function will help us check for overlap on the x or y axis. Whether or not there is collision, will be stored in a variable called "wResult".

We'll use the "CheckObjectPositionDifference" function twice. Once for the x axis, and another for the y axis. If "wResult" is 0 for either, there is no  collision with the player. Otherwise, we have a collision with the player.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-check-collision}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-check-collision}}
```

If we have a collison against the player we need to damage the player, and redraw how many lives they have. In addition, it's optional, but we'll deactivate the enemy too when they collide with the player.

> **NOTE:** We pushed bc, de, and hl onto the stack before we called our "CheckObjectPositionDifference" function. To avoid any confusion with that function overriding/changing something, we'll pop them back off the stack to retain their original values.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-collision}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-collision}}
```

If there is no collision with the player, we'll draw the enemies. This is done just as we did the player and bullets, with the "DrawMetasprites" function.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-nocollision}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-nocollision}}
```

## Deactivating Enemies

Deactivating an enemy is just like with bullets. We'll set it's first byte to 0, and decrease our counter variable.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-deactivate}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-deactivate}}
```

## Spawning Enemies

Randomly, we want to spawn enemies. We'll increase a counter called "wEnemyCounter". When it reaches a preset maximum value, we'll maybe try to spawn a new enemy. We need to make sure we aren't at maximum enemy capacity, if so, we will not spawn enemy more enemies. If we can spawn a new enemy, we'll try to get a x position to spawn the enemy at. If our x position is below 24 or above 150, we'll NOT spawn a new enemy. 

> All enemies are spawned with y position of 0, so we only need to get the x position.

If we have a valid x position, we'll reset our spawn counter, and save that x position in the "wNextEnemyXPosition" variable. With this variable set, We'll later activate and update a enemy that we find in the inactive state.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-spawn}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-spawn}}
```