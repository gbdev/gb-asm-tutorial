# Collision

Being able to move around is great, but there's still one object we need for this game: a ball!
Just like with the paddle, the first step is to create a tile for the ball and load it into VRAM.

## Graphics

Add this to the bottom of your file along with the other graphics:
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/collision/main.asm:ball-sprite}}
{{#include ../../unbricked/collision/main.asm:ball-sprite}}
```

Now copy it to VRAM somewhere in your initialization code, e.g. after copying the paddle's tile.
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/collision/main.asm:ball-copy}}
{{#include ../../unbricked/collision/main.asm:ball-copy}}
```

In addition, we need to initialize an entry in OAM, following the code that initializes the paddle.
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/collision/main.asm:oam}}
{{#include ../../unbricked/collision/main.asm:oam}}
```

As the ball bounces around the screen its momentum will change, sending it in different directions.
Let's create two new variables to track the ball's momentum in each axis: `wBallMomentumX` and `wBallMomentumY`.
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/collision/main.asm:ram}}
{{#include ../../unbricked/collision/main.asm:ram}}
```

We will need to initialize these before entering the game loop, so let's do so right after we write the ball to OAM.
By setting the X momentum to 1, and the Y momentum to -1, the ball will start out by going up and to the right.
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/collision/main.asm:init}}
{{#include ../../unbricked/collision/main.asm:init}}
```

## Prep work

Now for the fun part!
Add a bit of code at the beginning of your main loop that adds the momentum to the OAM positions.
Notice that since this is the second OAM entry, we use `+ 4` for Y and `+ 5` for X.
This can get pretty confusing, but luckily we only have two objects to keep track of.
In the future, we'll go over a much easier way to use OAM.
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/collision/main.asm:momentum}}
{{#include ../../unbricked/collision/main.asm:momentum}}
```

You might want to compile your game again to see what this does.
If you do, you should see the ball moving around, but it will just go through the walls and then fly offscreen.

To fix this, we need to add collision detection so that the ball can bounce around.
We'll need to repeat the collision check a few times, so we're going to make use of two functions to do this.

::: tip

Please do not get stuck on the details of this next function, as it uses some techniques and instructions we haven't discussed yet.
The basic idea is that it converts the position of the sprite to a location on the tilemap.
This way, we can check which tile our ball is touching so that we know when to bounce!

:::

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/collision/main.asm:get-tile}}
{{#include ../../unbricked/collision/main.asm:get-tile}}
```

The next function is called `IsWallTile`, and it's going to contain a list of tiles which the ball can bounce off of.
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/collision/main.asm:is-wall-tile}}
{{#include ../../unbricked/collision/main.asm:is-wall-tile}}
```

This function might look a bit strange at first.
Instead of returning its result in a *register*, like `a`, it returns it in [a *flag*](../part1/operations.md#flags): `Z`!
If at any point a tile matches, the function has found a wall and exits with `Z` set.
If the target tile ID (in `a`) matches one of the wall tile IDs, the corresponding `cp` will leave `Z` set; if so, we return immediately (via `ret z`), with `Z` set.
But if we reach the last comparison and it still doesn't set `Z`, then we will know that we haven't hit a wall and don't need to bounce.

## Putting it together

Time to use these new functions to add collision detection!
Add the following after the code that updates the ball's position:
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/collision/main.asm:first-tile-collision}}
{{#include ../../unbricked/collision/main.asm:first-tile-collision}}
```

You'll see that when we load the sprite's positions, we subtract from them before calling `GetTileByPixel`.
You might remember from the last chapter that OAM positions are slightly offset; that is, (0, 0) in OAM is actually completely offscreen.
These `sub` instructions undo this offset.

However, there's a bit more to this: you might have noticed that we subtracted an extra pixel from the Y position.
That's because (as the label suggests), this code is checking for a tile above the ball.
We actually need to check *all four* sides of the ball so we know how to change the momentum according to which side collided, so... let's add the rest!

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/collision/main.asm:tile-collision}}
{{#include ../../unbricked/collision/main.asm:tile-collision}}
```

That was a lot, but now the ball bounces around your screen!
There's just one last thing to do before this chapter is over, and thats ball-to-paddle collision.

## Paddle bounce

Unlike with the tilemap, there's no position conversions to do here, just straight comparisons.
However, for these, we will need [the *carry* flag](../part1/operations.md#flags).
The carry flag is notated as `C`, like how the zero flag is notated as `Z`, but don't confuse it with the `c` register!

::: tip A refresher on comparisons

Just like `Z`, you can use the carry flag to jump conditionally.
However, while `Z` is used to check if two numbers are equal, `C` can be used to check if a number is greater than or smaller than another one.
For example, `cp a, b` sets `C` if `a < b`, and clears it if `a >= b`.
(If you want to check `a <= b` or `a > b`, you can use `Z` and `C` in tandem with two `jp` instructions.)

:::

Armed with this knowledge, let's work through the paddle bounce code:
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/collision/main.asm:paddle-bounce}}
{{#include ../../unbricked/collision/main.asm:paddle-bounce}}
```

The Y position's check is simple, since our paddle is flat.
However, the X position has two checks which widen the area the ball can bounce on.
First we add 16 to the ball's position; if the ball is more than 16 pixels to the right of the paddle, it shouldn't bounce.
Then we undo this by subtracting 16, and while we're at it, subtract another 8 pixels; if the ball is more than 8 pixels to the left of the paddle, it shouldn't bounce.

<svg viewBox="-10 -10 860 520">
	<style>
		text { text-anchor: middle; fill: var(--fg); font-size: 20px; }
		.left { text-anchor: start; }
		.right { text-anchor: end; }
		.grid { stroke: var(--fg); opacity: 0.7; }
		.ball { stroke: teal; }
		.paddle { stroke: orange; }
		.excl { stroke: red; } text.excl { stroke: initial; fill: red; font-family: "Source Code Pro", Consolas, "Ubuntu Mono", Menlo, "DejaVu Sans Mono", monospace, monospace !important; }
		/* Overlays */
		rect, polyline { opacity: 0.5; stroke-width: 3; }
		/* Arrow */
		polygon { stroke: inherit; fill: var(--bg); }
		use + line { stroke-dasharray: 0 32 999; stroke-width: 2; }
	</style>
	<defs>
		<polygon id="arrow-head" points="0,0 -40,-16 -32,0 -40,16" stroke="context-stroke"/>
		<pattern id="ball-hatched" viewBox="0 0 4 4" width="8" height="8" patternUnits="userSpaceOnUse">
			<line x1="5" y1="-1" x2="-1" y2="5" class="ball"/>
			<line x1="5" y1="3" x2="3" y2="5" class="ball"/>
			<line x1="1" y1="-1" x2="-1" y2="1" class="ball"/>
		</pattern>
		<pattern id="paddle-hatched" viewBox="0 0 4 4" width="8" height="8" patternUnits="userSpaceOnUse">
			<line x1="5" y1="-1" x2="-1" y2="5" class="paddle"/>
			<line x1="5" y1="3" x2="3" y2="5" class="paddle"/>
			<line x1="1" y1="-1" x2="-1" y2="1" class="paddle"/>
		</pattern>
		<pattern id="excl-hatched" viewBox="0 0 4 4" width="8" height="8" patternUnits="userSpaceOnUse">
			<line x1="5" y1="-1" x2="-1" y2="5" class="excl"/>
			<line x1="5" y1="3" x2="3" y2="5" class="excl"/>
			<line x1="1" y1="-1" x2="-1" y2="1" class="excl"/>
		</pattern>
	</defs>
	<image x="128" y="0" width="256" height="256" href="../assets/part2/img/ball.png"/>
	<rect x="128" y="0" width="32" height="32" fill="url(#ball-hatched)"/>
	<image x="288" y="256" width="256" height="256" href="../assets/part2/img/paddle.png"/>
	<rect x="288" y="256" width="32" height="32" fill="url(#paddle-hatched)"/>
	<line class="grid" x1="-10" y1="0" x2="850" y2="0"/>
	<line class="grid" x1="-10" y1="32" x2="850" y2="32"/>
	<line class="grid" x1="-10" y1="64" x2="850" y2="64"/>
	<line class="grid" x1="-10" y1="96" x2="850" y2="96"/>
	<line class="grid" x1="-10" y1="128" x2="850" y2="128"/>
	<line class="grid" x1="-10" y1="160" x2="850" y2="160"/>
	<line class="grid" x1="-10" y1="192" x2="850" y2="192"/>
	<line class="grid" x1="-10" y1="224" x2="850" y2="224"/>
	<line class="grid" x1="-10" y1="256" x2="850" y2="256"/>
	<line class="grid" x1="-10" y1="288" x2="850" y2="288"/>
	<line class="grid" x1="-10" y1="320" x2="850" y2="320"/>
	<line class="grid" x1="-10" y1="352" x2="850" y2="352"/>
	<line class="grid" x1="0" y1="-20" x2="0" y2="351"/>
	<line class="grid" x1="32" y1="-20" x2="32" y2="351"/>
	<line class="grid" x1="64" y1="-20" x2="64" y2="351"/>
	<line class="grid" x1="96" y1="-20" x2="96" y2="351"/>
	<line class="grid" x1="128" y1="-20" x2="128" y2="351"/>
	<line class="grid" x1="160" y1="-20" x2="160" y2="351"/>
	<line class="grid" x1="192" y1="-20" x2="192" y2="351"/>
	<line class="grid" x1="224" y1="-20" x2="224" y2="351"/>
	<line class="grid" x1="256" y1="-20" x2="256" y2="351"/>
	<line class="grid" x1="288" y1="-20" x2="288" y2="351"/>
	<line class="grid" x1="320" y1="-20" x2="320" y2="351"/>
	<line class="grid" x1="352" y1="-20" x2="352" y2="351"/>
	<line class="grid" x1="384" y1="-20" x2="384" y2="351"/>
	<line class="grid" x1="416" y1="-20" x2="416" y2="351"/>
	<line class="grid" x1="448" y1="-20" x2="448" y2="351"/>
	<line class="grid" x1="480" y1="-20" x2="480" y2="351"/>
	<line class="grid" x1="512" y1="-20" x2="512" y2="351"/>
	<line class="grid" x1="544" y1="-20" x2="544" y2="351"/>
	<line class="grid" x1="576" y1="-20" x2="576" y2="351"/>
	<line class="grid" x1="608" y1="-20" x2="608" y2="351"/>
	<line class="grid" x1="640" y1="-20" x2="640" y2="351"/>
	<line class="grid" x1="672" y1="-20" x2="672" y2="351"/>
	<line class="grid" x1="704" y1="-20" x2="704" y2="351"/>
	<line class="grid" x1="736" y1="-20" x2="736" y2="351"/>
	<line class="grid" x1="768" y1="-20" x2="768" y2="351"/>
	<line class="grid" x1="800" y1="-20" x2="800" y2="351"/>
	<line class="grid" x1="832" y1="-20" x2="832" y2="351"/>
	<rect x="128" y="0" width="256" height="256" class="ball" style="fill: none;"/>
	<polyline points="288,352 288,256 544,256 544,352" class="paddle" style="fill: none;"/>
	<rect x="-15" y="-15" width="47" height="440" class="excl" fill="url(#excl-hatched)"/>
	<text x="40" y="430" class="excl left">jp c, DoNotBounce</text>
	<rect x="800" y="-15" width="52" height="510" class="excl" fill="url(#excl-hatched)"/>
	<text x="790" y="500" class="excl right">jp nc, DoNotBounce</text>
	<use href="#arrow-head" x="48" y="380" transform="rotate(-180,48,380)" class="paddle"/><line x1="48" y1="380" x2="304" y2="380" class="paddle"/>
	<text x="176" y="400">- 8</text>
	<use href="#arrow-head" x="304" y="450" class="paddle"/><line x1="304" y1="450" x2="48" y2="450" class="paddle"/>
	<use href="#arrow-head" x="816" y="450" class="paddle"/><line x1="816" y1="450" x2="304" y2="450" class="paddle"/>
	<text x="432" y="470">+ 8 + 16</text>
</svg>

::: tip Paddle width

You might be wondering why we checked 16 pixels to the right but only 8 pixels to the left.
Remember that OAM positions represent the upper-*left* corner of a sprite, so the center of our paddle is actually 4 pixels to the right of the position in OAM.
When you consider this, we're actually checking 12 pixels out on either side from the center of the paddle.

12 pixels might seem like a lot, but it gives some tolerance to the player in case their positioning is off.
If you'd prefer to make this easier or more difficult, feel free to adjust the values!

:::

## BONUS: tweaking the bounce height

You might notice that the ball seems to "sink" into the paddle a bit before bouncing. This is because the ball bounces when its top row of pixels aligns with the paddle's top row (see the image above). If you want, try to adjust this so that the ball bounces when its bottom row of pixels touches the paddle's top.

Hint: you can do this with just a single instruction!

<details><summary>Answer:</summary>

```diff linenos,start={{#line_no_of "" ../../unbricked/collision/main.asm:paddle-bounce}}
	ld a, [_OAMRAM]
	ld b, a
	ld a, [_OAMRAM + 4]
+	add a, 6
	cp a, b
```

Alternatively, you can add `sub a, 6` just after `ld a, [_OAMRAM]`.

In both cases, try playing with that `6` value; see what feels right!

</details>
