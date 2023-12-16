# Object Collision Detection

For collision detection between objects in our object pool, we'll setup a universal function. This function, called `CheckCollisionWithObjectsInHL_andDE`, will have 4 requirements:
- A pointer to Object A in `hl`
- A pointer to Object B in `de`
- The minimum allowed distance on the x axis in `wSizeX`
- The minimum allowed distance on the y-axis in `wSizeY`

**Create a file called `object-collision.asm` and add the following code:**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/object-collision.asm:object-collision-start}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/object-collision.asm:object-collision-start}}
```

The logic for checking the distance on the x & y axes is identical. For that reason, we've isolated it into a function called `CheckObjectBytesOfObjects_InDE_AndHL`. 

All of our object's data share the same order and structure. For collision detection, we want to check the same bytes (the 2 x bytes , or the 2 y bytes) for 2 different objects. For this, we've created the function called `CheckObjectBytesOfObjects_InDE_AndHL`. This function has 3 requirements:

- A pointer to Object A in `hl`
- A pointer to Object B in `de`
- Which byte to check in `wCheckByte`

This function uses the `CheckObjectPositionDifference` function that comes with the starter. Our x & y bytes are Q12.4 fixed point integers. Before we can use them, we need to descale them. After descaling them, we'll call the `CheckObjectPositionDifference` function and use it's result as our own.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/object-collision.asm:object-collision-check-bytes}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/object-collision.asm:object-collision-check-bytes}}
```


The x-axis is up first. In a nutshell, we simply pass which byte we and distance we want to check to the `CheckObjectBytesOfObjects_InDE_AndHL` function. If it returns a value of zero, there is no overlap on that axis. Otherwise, we'll proceed on to check the y-axis


```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/object-collision.asm:object-collision-x}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/object-collision.asm:object-collision-x}}
```

After checking the x-axis, we'll do the same thing for the y-axis. After the `CheckObjectBytesOfObjects_InDE_AndHL` function is called, we'll return from the `CheckCollisionWithObjectsInHL_andDE` function. The result flags of the previous function call will be used.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/object-collision.asm:object-collision-y}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/object-collision.asm:object-collision-y}}
```

