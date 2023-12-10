# Object Pools

Galactic Armada will use a single "object pool" for all obejcts (the player, enemies, and bullets). This pool repsents an array of objects, but is realy just a collection of bytes. Each object has the same number of bytes allocated for it. 

- Active (1 byte)
- Y Position (2 bytes)
- X Position (2 bytes)
- Metasprite address (2 bytes)
- Health (1 byte)
- Update function address (2 bytes)
- Damage Timer (1 byte)

We've pre-defined that in the starter. 

*inside of our `constants.inc` include file:*

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/includes/constants.inc:object-bytes}}
{{#include ../../galactic-armada/src/main/includes/constants.inc:object-bytes}}
```

We need to next setup and implement variables that use that structure.

**Create a file called `object-pool.asm`, add the following code to it:**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/object-pool.asm:objects-pool-top}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/object-pool.asm:objects-pool-top}}
```

We'll explain each variable soon, but notice how we allocated space in WRAM for `wObjects`. Rather than using a literal number for how many objects our game can handle, we use the constant `MAX_OBJECT_COUNT`. This constant is declared in `constants.inc`, and prevents any sort of inconsistincies if we change our minds.

## Initializing the object pool

When we initialize the object pool, we need to do 2 primary things:
- Set all bytes in the pool to 0
- Set our `wObjectsEnd` variable to 255

Our `wObjectsEnd` variable is used to simplify looping through all objects. More on that later.

**Add the following code to the bottom of your `object-pool.asm` file:**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/object-pool.asm:initialize-objects}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/object-pool.asm:initialize-objects}}
```

The above code is just going to loop through each object, and set all of it's bytes to 0.

## Updating objects in our object pool

We've created a variable called `wObjectsFlash`. This will be used as a counter. We'll increase it each frame. Because it's a a unsigned 8-bit integer, it's values will be between 0 and 255. Later, When it's value is larger than 128, any object that is damaged will not be shown. This overall creates a "blinking" damaged effect.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/object-pool.asm:update-objects-1}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/object-pool.asm:update-objects-1}}
```

We're going to loop through each object in our object pool. Our `wObjectsEnd` variable is used to simplify looping through all objects. When iterating through our `wObjects`, the first byte for an object is the active byte (aka `object_activeByte` in constants.inc). The valid values of this byte are 0 and 1. If the code reads a 255 (from `wObjectsEnd`), then we know we've reached the end of the bytes associated with our object pool.

If we haven't read 255 yet, then we need to check if the current object is active. We can use `and a` (where the value in the 'a' register comes from the previous 'ld' instruction). If the zero flag is set, then that object is inactive and we'll jump to the next object.

The Code will proceed on, if the object is active.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/object-pool.asm:update-objects-2}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/object-pool.asm:update-objects-2}}
```

The first thing we'll do for an active object is call it's update function. We'll copy the address of that function into it 'hl' and call it. Before such, we need to push hl onto the stack. When we're done calling our object's update function, we'll pop it off the stack.

> **Note:** Before we change 'hl', we'll copy it's value into 'bc'. For each object's update function, 'bc' will have the address of that object's first byte.

After updating, we want to draw the object. Before so, we need to check if the object is inactive. If so, we'll avoid drawing and jump to the next object.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/object-pool.asm:update-objects-3}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/object-pool.asm:update-objects-3}}
```

AFter updating, if our object is still active, we'll conditionally draw the object. Now we're going to put into use the previously mentioned `wObjectsFlash` variable.

Each object has a damage byte (aka `object_damageByte` in constants.inc). If this byte is non-zero, the associated object has been damaged and we want it to blink. We'll skip drawing the object if the damage byte is non-zero and the `wObjectsFlash` variable is greater than 128.


```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/object-pool.asm:update-objects-4}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/object-pool.asm:update-objects-4}}
```

For drawing our object, we'll use the `RenderMetasprite` function from Evieue's Sprite Object library. This function requires the following parameters:
- the Q12.4 Fixed-point y position in bc
- The Q12.4 fixed-point X position in de
- The Pointer to current metasprite in hl

To prepare for that function, we'll copy bytes from our object to the proper registers.

> **Note:** After copying our x position to de, our 'hl' registers are not exactly what we need for `RenderMetasprite`. At that point in time, 'hl' doesn't contain the address of our metasprite. It contains a pointer to that address.

After rendering our metasprite, we'll pop the start of our metasprite off the stack. This makes going to the next object simple. With 'hl' pointing to our object's first byte, we simply need to increment 'hl'

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/object-pool.asm:update-objects-5}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/object-pool.asm:update-objects-5}}
```

When 'hl' points to the first byte of an object ,we can easily move on to the next object. This is done by adding to it: the dynamic constant `PER_OBJECT_BYTES_COUNT` (from constants.inc). From there, we'll go back to our `UpdateObjectPool_Loop` label and repeat until we read 255.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/object-pool.asm:update-objects-6}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/object-pool.asm:update-objects-6}}
```

## Getting an inactive object

When firing bullets and/or when spawning enemies, we'll need to find an object in our pool that is inactive. For this, we'll create a function called `GetNextAvailableObject_InHL`

This function takes two parameters
- the starting byte in hl
- how many objects to check in b

When this function is done, if the zero flag is not set: an inactive object has been found. At that point in time, 'hl' will point to the first byte of that object.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/object-pool.asm:get-next-available-object}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/object-pool.asm:get-next-available-object}}
```

Later, when spawning bullets, we'll call that function like so:

*This code will be covered later*

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/bullets.asm:fire-bullets}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/bullets.asm:fire-bullets}}

    ; ... More FireNextBullet logic
```

