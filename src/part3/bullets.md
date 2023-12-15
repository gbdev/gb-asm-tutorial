# Bullets

Bullets are relatively simple, logic-wise. They all travel straight-forward, and de-activate themselves when they leave the screen.

**Create a `bullets.asm` file with the following code:**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/bullets.asm:bullets-top}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/bullets.asm:bullets-top}}
```
## Updating Bullets

The first thing we need to do, get the address to the current. 

> **Note:** Recall from the ['Object Pools'](#object-pools) page, Before an object's update function is called, the address of that object is stored in bc.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/bullets.asm:bullets-update}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/bullets.asm:bullets-update}}
```

With 'hl' pointing to our bullet's first byte, we can move the bullet just like the player.

**Create the following `UpdateBullets` function in bullets.asm.**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/bullets.asm:bullets-update2}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/bullets.asm:bullets-update2}}
```

Once our bullet has been moved, we'll mark it as inactive if the high byte of the y position is larger than 10. In that scenario we are certain the bullet has traveled off screen.

**Extend the `UpdateBullets` function with the following code.**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/bullets.asm:bullets-update3}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/bullets.asm:bullets-update3}}
```

That's it for our bullet's update function
## Firing New Bullets

During the "UpdatePlayer" function [previously](#player), when the user pressed A: we called the `FireNextBullet` function. 

Now, inside of our `FireNextBullet` function, we need to make sure we have bullet's available. . If we don't, we'll end the function early.if we have an available bullet, we need it's address. To handle both of these things, we'll use the `GetNextAvailableObject_InHL` function.

**Copy the following function into `bullets.asm` below the previous code snippet.**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/bullets.asm:fire-bullets}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/bullets.asm:fire-bullets}}
```

If our `GetNextAvailableObject_InHL` didn't set the zero flag, 'hl' should point to the bullet now. From there, we'll do the nitialize it.
- activate it, by setting it's first byte to 1
- Copy the player's x and y position
- Set it's metasprite
- Set it's health
- Set it's update function

**Finish `bullets.asm` by copying the FireNextBullet function into it**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/bullets.asm:fire-bullets2}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/bullets.asm:fire-bullets2}}
```