# Object Collision Detection

Collision Detection is cruical to games. It can be a very complicated topic. In Galactic Armada, things will be kept super simple. We're going to perform a basic implementation of "Axis-Aligned Bounding Box Collision Detection":

> One of the simpler forms of collision detection is between two rectangles that are axis aligned — meaning no rotation. The algorithm works by ensuring there is no gap between any of the 4 sides of the rectangles. Any gap means a collision does not exist.[^mdn_source]

The easiest way to check for overlap, is to check the difference bewteen their centers. If the absolute value of their x & y differences (I'll refer to as "the absolute difference") are BOTH smaller than the sum of their half widths, we have a collision. This collision detection is run for bullets against enemies, and enemies against the player. Here's a visualization with bullets and enemies.

![CollisionDetectionVisualized.png](../assets/part3/img/CollisionDetectionVisualized.png)

For collision detection between objects in our object pool, we'll setup a universal function. This function, called `CheckCollisionWithObjectsInHL_andDE`, will have 4 requirements:
- A pointer to Object A in `hl`
- A pointer to Object B in `de`
- The minimum allowed distance on the x axis in `wSizeX`
- The minimum allowed distance on the y-axis in `wSizeY`

**Create a file called `object-collision.asm` and add the following code:**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/object-collision.asm:object-collision-start}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/object-collision.asm:object-collision-start}}
```

The logic for checking the distance on the x & y axes is identical. For that reason, we've isolated it into a function called `CheckObjectBytesOfObjects_InDE_AndHL`. We'll cover that function before we cove the `CheckCollisionWithObjectsInHL_andDE` function.

## Comparing the bytes on our two objects

All of our object's data share the same order and structure. For collision detection, we want to check the same bytes (the 2 x bytes , or the 2 y bytes) for 2 different objects. For this, we've created the function called `CheckObjectBytesOfObjects_InDE_AndHL`. This function has 3 requirements:

- A pointer to Object A in `hl`
- A pointer to Object B in `de`
- Which byte to check in `wCheckByte`

This function uses the `CheckObjectPositionDifference` function that comes with the starter. Our x & y bytes are Q12.4 fixed point integers. Before we can use them, we need to descale them. After descaling them, we'll call the `CheckObjectPositionDifference` function and use it's result as our own.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/object-collision.asm:object-collision-check-bytes}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/object-collision.asm:object-collision-check-bytes}}
```

## Checking for collision

Now that we've defined the `CheckObjectBytesOfObjects_InDE_AndHL` function, we can implement our main function. 

**Create the `CheckCollisionWithObjectsInHL_andDE` function in your `object-collision.asm`**

>**Note:** This function should be exported, since it is going to be callled in other files.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/object-collision.asm:object-collision-function}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/object-collision.asm:object-collision-function}}
```

The x-axis is up first. In a nutshell, we simply pass which byte we and distance we want to check to the `CheckObjectBytesOfObjects_InDE_AndHL` function. If it returns a value of zero, there is no overlap on that axis. Otherwise, we'll proceed on to check the y-axis

**Copy the following into the `CheckCollisionWithObjectsInHL_andDE` function**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/object-collision.asm:object-collision-x}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/object-collision.asm:object-collision-x}}
```

After checking the x-axis, we'll do the same thing for the y-axis. 

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/object-collision.asm:object-collision-y}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/object-collision.asm:object-collision-y}}
```

After the `CheckObjectBytesOfObjects_InDE_AndHL` function is called, we'll return from the `CheckCollisionWithObjectsInHL_andDE` function. The result flags from the last `CheckObjectBytesOfObjects_InDE_AndHL`  will be used for the whole function.


[^mdn_source]:
From [mdn web docs - 2D collision detection](https://developer.mozilla.org/en-US/docs/Games/Techniques/2D_collision_detection)