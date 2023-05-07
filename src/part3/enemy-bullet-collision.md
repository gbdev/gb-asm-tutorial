# Enemy-Bullet Collision

When we are udating enemies, we'll call a function called "CheckCurrentEnemyAgainstBullets". This will check the current enemy against all active bullets.

This fuction needs to loop through the bullet object pool, and check if our current enemy overlaps any bullet on both the x and y axis. If so, we'll deactivate the enemy and bullet.

Our "CheckCurrentEnemyAgainstBullets" function starts off in a manner similar to how we updated enemies & bullets.

> This function expects "hl" points to the curent enemy. We'll save that in a variable for later usage.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-bullet-collision.asm:enemy-bullet-collision-start}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-bullet-collision.asm:enemy-bullet-collision-start}}
```

As we loop through the bullets, we need to make sure we only check active bullets. Inactive bullets will be skipped.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-bullet-collision.asm:enemy-bullet-collision-per-bullet-start}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-bullet-collision.asm:enemy-bullet-collision-per-bullet-start}}
```
First, we need to check if the current enemy and current bullet are overlapping on the x axis. We'll get the enemy's x position in e, and the bullet's x position in b. From there, we'll again call our "CheckObjectPositionDifference" function. If it returns a failure (wResult=0), we'll start with the next bullet.

> We add an offset to the x coordinates so they measure from their centers. That offset is half it's respective object's width.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-bullet-collision.asm:enemy-bullet-collision-per-bullet-x-overlap}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-bullet-collision.asm:enemy-bullet-collision-per-bullet-x-overlap}}
```

Next we restore our hl variable so we can get the y position of our current bullet. Once we have that y position, we'll get the current enemy's y position and check for an overlap on the y axis. If no overlap is found, we'll loop to the next bullet. Otherwise, we have a collision.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-bullet-collision.asm:enemy-bullet-collision-per-bullet-y-overlap}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-bullet-collision.asm:enemy-bullet-collision-per-bullet-y-overlap}}
```

If a collision was detected (overlap on x and y axis), we'll set the current active byte for that bullet to 0. Also , we'll set the active byte for the current enemy to zero. Before we end the function, we'll increase and redraw the score, and decrease how many bullets & enemies we have by one.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-bullet-collision.asm:enemy-bullet-collision-per-bullet-collision}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-bullet-collision.asm:enemy-bullet-collision-per-bullet-collision}}
```

If no collision happened, we'll continue our loop through the enemy bullets. When we've checked all the bullets, we'll end the function.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-bullet-collision.asm:enemy-bullet-collision-loop}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-bullet-collision.asm:enemy-bullet-collision-loop}}
```

