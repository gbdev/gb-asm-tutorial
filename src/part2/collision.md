# Collision

Being able to move around is great, but there's still one object we need for this game: a ball!
Just like with the paddle, the first step is to create a graphic for the ball and load it into VRAM.

Add this to the bottom of your file along with the other graphics:
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/collision/main.asm:ball-sprite}}
{{#include ../../unbricked/collision/main.asm:ball-sprite}}
```

Now copy it to VRAM in your initialization code.
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/collision/main.asm:copy-ball}}
{{#include ../../unbricked/collision/main.asm:copy-ball}}
```

In addition, we need to initialize an entry in OAM, right after where we initialize the paddle.
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/collision/main.asm:oam}}
{{#include ../../unbricked/collision/main.asm:oam}}
```

As the ball bounces around the screen its momentum will change, sending it in different directions.
Let's create two new variables to track the ball's momentum: `wBallMomentumX` and `wBallMomentumY`.
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/collision/main.asm:ram}}
{{#include ../../unbricked/collision/main.asm:ram}}
```

We'll need to initialize these, so let's so do right after we write the ball to OAM.
By setting the X momentum to 1, and the Y momentum to -1, the ball will start out by going up and to the right.
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/collision/main.asm:init}}
{{#include ../../unbricked/collision/main.asm:init}}
```

Now for the fun part!
Add a bit of code at the beginning of your main loop that adds the momentum to the OAM positions.
Notice that since this is the second OAM entry, we use `+ 4` for Y and `+ 5` for X.
This can get pretty confusing, but luckily we only have two objects to keep track of.
In the future, we'll go over a much easier way to use OAM.
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/collision/main.asm:momentum}}
{{#include ../../unbricked/collision/main.asm:momentum}}
```

You might wanna compile your game again to see what this does.
If you do, you should see the ball moving around, but it'll just go through the walls and offscreen.
We need to add collision with the walls so that the ball can bounce around.
There's some complexity to doing this, so we're going to make use of two functions.

Try not to worry too much about the details of this first one, as it uses some advanced techniques we haven't discussed yet.
The basic idea is that it converts the position of the sprite to a location on the tilemap.
This way, we can check which tile our ball is touching so that we know when to bounce!
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/collision/main.asm:get-tile}}
{{#include ../../unbricked/collision/main.asm:get-tile}}
```

The next function is called `IsWallTile`, and it's gonna contain a list of tiles which the ball can bounce off of.
This should be easier to understand!
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/collision/main.asm:is-wall-tile}}
{{#include ../../unbricked/collision/main.asm:is-wall-tile}}
```

This function might look a bit strange at first.
Instead of returning its result in a *register*, like `a`, it returns a *flag*: `z`!
If at any point a tile matches, the function has found a wall and exits with `z` set.
But if it reaches the end and `z` still isn't set, we'll know that we haven't hit a wall and don't need to bounce.

Time to use these new functions to add collision!
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/collision/main.asm:first-tile-collision}}
{{#include ../../unbricked/collision/main.asm:first-tile-collision}}
```

You'll see that when we load the sprite's positions, we subtract from them before calling `GetTileByPixel`.
You might remember from the last chapter that OAM positions are slightly offset; that is, (0, 0) in OAM is actually completely offscreen.
These `sub` instructions undo this offset.
However, there's a bit more to this: you might've noticed that we subtracted an extra pixel from the Y position.
That's because (as the label suggests), this code is checking for a tile on the top of the ball.
We actually need to check *all four* sides of the ball so we know how to change the momentum, so... let's add the rest!

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/collision/main.asm:tile-collision}}
{{#include ../../unbricked/collision/main.asm:tile-collision}}
```

That was a lot, but now the ball bounces around your screen!
There's just one last thing to do before this chapter is over, and thats ball-to-paddle collision.

Unlike with the tilemap, there's no position conversions to do here, just straight comparisons.
However, we'll need to cover a new concept: the *carry* flag.
Carry is represented by a `c`, like how zero is a `z`, but don't get it confused with the `c` register!

Just like `z`, you can use it to conditionally jump.
However, while `z` is used to check if two numbers are equal, `c` can be used to check if numbers are greater than or less than each other.
For example, `cp a, b` sets `c` if `a < b`, and does not set `c` if `a >= b`.
(If you want to check `a <= b` or `a > b`, you can use `z` and `c` in tandem with two `jp` instructions)

Armed with this knowledge, let's work through the paddle bounce code:
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/collision/main.asm:paddle-bounce}}
{{#include ../../unbricked/collision/main.asm:paddle-bounce}}
```

The Y position's check is simple, since our paddle is flat.
However, the X position has two checks which widen the area the ball can bounce on.
First we add 16 to the ball's position; if the ball is more than 16 pixels to the right of the paddle, it shouldn't bounce.
Then we undo this by subtracting 16, and while we're at it, subtract another 8 pixels; if the ball is more than 8 pixels to the left of the paddle, it shouldn't bounce.

You might be wondering why we checked 16 pixels to the right but only 8 pixels to the left.
Remember that OAM positions represent the upper-*left* corner of a sprite, so the center of our paddle is actually 4 pixels to the right of the position in OAM.
When you consider this, we're actually checking 12 pixels out on either side from the center of the paddle.
12 pixels might seem like a lot, but it gives some tolerance to the player in case their positioning is off.
If you'd prefer to make this easier or more difficult, feel free to adjust the values!
