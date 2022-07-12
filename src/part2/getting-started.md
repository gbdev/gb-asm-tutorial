# Getting started

In this lesson, we will start a new project from scratch.
We will make a [Breakout](https://en.wikipedia.org/wiki/Breakout_%28video_game%29) / [Arkanoid](https://en.wikipedia.org/wiki/Arkanoid) clone, which we'll "Unbricked"!
(Though you are free to give it any other name you like, as it will be *your* project)

Open a terminal and make a new directory (`mkdir unbricked`), and then enter it (`cd unbricked`), just like you did for ["Hello, world!"](../part1/hello-world).

Start by creating a file called `main.asm`, and include `hardware.inc` in your code.

```
line 1
```

Then, make room for the header.
[Remember from Part Ⅰ](../part1/header) that the header is where some information that the Game Boy relies on is stored, so you don't want to accidentally leave it out.

```
lines 3-7
```

The header jumps to `EntryPoint`, so let's write that now:

```
lines 9-18
```

The next few lines wait until "VBlank".
VBlank basically means that the Game Boy's PPU has gone to sleep for a short time, during which we can do things like turning off the screen. 

Turning off the screen is important because the PPU may wake back up at while we're still working.
By turning the screen off completely, we ensure that our code won't be interrupted.
You can only load new graphics while the PPU is sleeping, so this gives us as much time as we need to load our tiles.

Speaking of tiles, we're going to load some into VRAM next, using the following code:

```
lines 20-31
```

This loop might be [reminiscent of part Ⅰ](../part1/jumps#conditional-jumps).
It copies `Tiles` to `$9000`, which is the part of VRAM where tiles are stored.
To get how many bytes to copy, we will do just like in Part Ⅰ: using another label at the end, called `TilesEnd`, the difference between it (= the address after the last byte of tile data) and `Tiles` (= the address of the first byte) will be exactly that length.

That said, we haven't written `Tiles` nor any of the related data yet.
We'll get to that later!

Almost done now—next, write another loop, this time for copying [the tilemap](../part1/tilemap).

```
lines 33-44
```

Note that while this loop's body is exactly the same as `CopyTiles`'s, the 3 values loaded into `de`, `hl`, and `bc` are different.
These determine the source, destination, and size of the copy, respectively.

::: tip DRY

If you think that this is super redundant, you are not wrong, and we will see later how to write actual, reusable *functions*.
But there is more to them than meets the eye, so we will start tackling them much later.

:::

Finally, let's turn the screen back on, and set a [background palette](../part1/palettes).
Rather than writing the non-descript number `%10000001` (or $81 or 129, to taste), we make use of two constants graciously provided by `hardware.inc`: `LCDCF_ON` and `LCDCF_BGON`.
When written to [`rLCDC`](https://gbdev.io/pandocs/LCDC), the former causes the PPU and screen to turn back on, and the latter enables the background to be drawn.
(There are other elements that could be drawn, but we are not enabling them yet.)
Combining these constants must be done using `|`, the *binary "or"* operator; we'll see why later.

```
lines 46-55
```

There's one last thing we need before we can build the ROM, and that's the graphics.
We will draw the following screen:

![Layout of unbricked](https://github.com/ISSOtm/gb-asm-tutorial-part2/blob/main/tilemap.png?raw=true)

In `hello-world.asm`, tile data had been written out by hand in hexadecimal; this was to let you see how the sausage is made at the lowest level, but *boy* is it impractical to write!
This time, we will employ a more friendly way, which will let us write each row of pixels more easily.
We will use `dw` instead of `db` (the difference between these two will be explained later); and for each row of pixels, instead of writing [the bitplanes](../part1/tiles#encoding) as raw numbers, we will use a backtick (\`) followed by 8 characters.
Each character defines a single pixel, intuitively from left to right; it must be one of 0, 1, 2, and 3, representing the corresponding color index in [the palette](../part1/palettes).

For example:

```rgbasm
	dw `01230123 ; This is equivalent to `db $55,$33`
```

(A note about OPT g could be added here?)

We already have tiles made for this project, so you can copy [this premade file](https://github.com/ISSOtm/gb-asm-tutorial-part2/raw/main/tileset.asm), and paste it at the end of your code.

Then copy the tilemap from [this file](https://github.com/ISSOtm/gb-asm-tutorial-part2/raw/main/tilemap.asm), and paste it after the `TilesEnd` label.

You can build the ROM now, by running the following commands in your terminal:

```console
$ rgbasm -L -o main.o main.asm
$ rgblink -o unbricked.gb main.o
$ rgbfix -v -p 0xFF unbricked.gb
```

If you run this in your emulator, you should see the following:

(Screenshot pending :P)

That white square seems to be missing!
You may have noticed this comment earlier, somewhere in the tile data:

```
lines 135-140
```

The logo tiles were left intentionally blank so that you can choose your own.
You can use one of the following pre-made logos, or try coming up with your own!

## RGBDS Logo
[Source](https://github.com/ISSOtm/gb-asm-tutorial-part2/raw/main/rgbds.asm)
![The RGBDS Logo](https://github.com/ISSOtm/gb-asm-tutorial-part2/blob/main/rgbds.png?raw=true)

## Duck
[Source](https://github.com/ISSOtm/gb-asm-tutorial-part2/raw/main/duck.asm)
![A pixel-art duck](https://github.com/ISSOtm/gb-asm-tutorial-part2/blob/main/duck.png?raw=true)

## Tail
[Source](https://github.com/ISSOtm/gb-asm-tutorial-part2/raw/main/tail.asm)
![A silhouette of a tail](https://github.com/ISSOtm/gb-asm-tutorial-part2/blob/main/tail.png?raw=true)

Replace the blank tiles with the new graphics, build the game again, and you should see your logo of choice in the bottom-right!
