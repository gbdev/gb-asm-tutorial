# Collision Detection


For this, we've created a basic function called "CheckObjectPositionDifference". This function will help us check for overlap on the x or y axis. When the (absolute) difference between the first two values passed is greater than the third value passed, it jump's to the label passed in the fourth parameter.

Here's an example of how to call this function:

> We have the player's x & y position in registers d & e respectively. We have the enemy's x & y position in registers b & c respectively. If there is no overlap on the x or y axis, the program jumps to the "NoCollisionWithPlayer" label.


When checking for collision, we'll use that function twice. Once for the x-axis, and again for the y-axis.

> NOTE: We don't need to test the y-axis if the x-axis fails. 

The source code for that function looks like this:

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/utils/collision-utils.asm:collision-utils}}
{{#include ../../galactic-armada/src/main/utils/collision-utils.asm:collision-utils}}
```

[^mdn_source]:
From [mdn web docs - 2D collision detection](https://developer.mozilla.org/en-US/docs/Games/Techniques/2D_collision_detection)