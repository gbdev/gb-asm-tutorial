# Bricks

Up until this point our ball hasn't done anything but bounce around, but now we're going to make it destroy the bricks.

Before we start, let's go over a new concept: constants.
We've already used some constants, like `rLCDC` from `hardware.inc`, but we can also create our own for anything we want.
Let's make three constants at the top of our file, representing the tile IDs of left bricks, right bricks, and blank tiles.
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/bricks/main.asm:constants}}
{{#include ../../unbricked/bricks/main.asm:constants}}
```

Constants are a kind of *symbol* (which is to say, "a thing with a name").
Writing a constant's name in an expression is equivalent to writing the number the constant is equal to, so `ld a, BRICK_LEFT` is the same as `ld a, $05`.
But I think we can all agree that the former is much clearer, right?

## Destroying bricks

Now we'll write a function that checks for and destroys bricks.
Our bricks are two tiles wide, so when we hit one we'll have to remove the adjacent tile as well.
If we hit the left side of a brick (represented by `BRICK_LEFT`), we need to remove it and the tile to its right (which should be the right side).
If we instead hit the right side, we need to remove the left!

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/bricks/main.asm:check-for-brick}}
{{#include ../../unbricked/bricks/main.asm:check-for-brick}}
```

Just insert this function into each of your bounce checks now.
Make sure you don't miss any!
It should go right **before** the momentum is modified.

```diff,linenos,start={{#line_no_of "" ../../unbricked/bricks/main.asm:updated-bounce}}
BounceOnTop:
	; Remember to offset the OAM position!
	; (8, 16) in OAM coordinates is (0, 0) on the screen.
	ld a, [_OAMRAM + 4]
	sub a, 16 + 1
	ld c, a
	ld a, [_OAMRAM + 5]
	sub a, 8
	ld b, a
	call GetTileByPixel ; Returns tile address in hl
	ld a, [hl]
	call IsWallTile
	jp nz, BounceOnRight
+	call CheckAndHandleBrick
	ld a, 1
	ld [wBallMomentumY], a

BounceOnRight:
	ld a, [_OAMRAM + 4]
	sub a, 16
	ld c, a
	ld a, [_OAMRAM + 5]
	sub a, 8 - 1
	ld b, a
	call GetTileByPixel
	ld a, [hl]
	call IsWallTile
	jp nz, BounceOnLeft
+	call CheckAndHandleBrick
	ld a, -1
	ld [wBallMomentumX], a

BounceOnLeft:
	ld a, [_OAMRAM + 4]
	sub a, 16
	ld c, a
	ld a, [_OAMRAM + 5]
	sub a, 8 + 1
	ld b, a
	call GetTileByPixel
	ld a, [hl]
	call IsWallTile
	jp nz, BounceOnBottom
+	call CheckAndHandleBrick
	ld a, 1
	ld [wBallMomentumX], a

BounceOnBottom:
	ld a, [_OAMRAM + 4]
	sub a, 16 - 1
	ld c, a
	ld a, [_OAMRAM + 5]
	sub a, 8
	ld b, a
	call GetTileByPixel
	ld a, [hl]
	call IsWallTile
	jp nz, BounceDone
+	call CheckAndHandleBrick
	ld a, -1
	ld [wBallMomentumY], a
BounceDone:
```

That's it!
Pretty simple, right?
