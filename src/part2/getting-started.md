# Getting started

In this lesson, we will start a new project from scratch.
We will make a [Breakout](https://en.wikipedia.org/wiki/Breakout_%28video_game%29) / [Arkanoid](https://en.wikipedia.org/wiki/Arkanoid) clone, which we'll call "Unbricked"!
(Though you are free to give it any other name you like, as it will be *your* project)

Open a terminal and make a new directory (`mkdir unbricked`), and then enter it (`cd unbricked`), just like you did for ["Hello, world!"](../part1/hello_world.md).

Start by creating a file called `main.asm`, and include `hardware.inc` in your code.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/getting-started/main.asm:includes}}
{{#include ../../unbricked/getting-started/main.asm:includes}}
```

`hardware.inc` is a file that provides constants which allow you to interface with the rest of the Game Boy.
When you write code, your instructions are only read by the CPU.
To access other parts of the system, like the screen, buttons, or audio, you use special registers known as "I/O" registers.
These are different from the CPU registers in that they live within the address space, and are accessed through special numbers like `$FF40`.
Numbers like this are difficult to memorize, and there are a *lot* to keep track of, which is why we use `hardware.inc` to assign them more freidnly names, like `rLCDC`.

::: tip

This practice of accessing hardware through the address space is known as [Memory Mapped I/O (MMIO)](https://en.wikipedia.org/wiki/Memory-mapped_I/O)

Next, make room for the header.
[Remember from Part Ⅰ](../part1/header.md) that the header is where some information that the Game Boy relies on is stored, so you don't want to accidentally leave it out.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/getting-started/main.asm:header}}
{{#include ../../unbricked/getting-started/main.asm:header}}
```

The header jumps to `EntryPoint`, so let's write that now:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/getting-started/main.asm:entry}}
{{#include ../../unbricked/getting-started/main.asm:entry}}
```

The next few lines wait until "VBlank", which is the only time you can safely turn off the screen (doing so at the wrong time could damage a real Game Boy, so this is very crucial). We'll talk more about VBlank later.

Turning off the screen is important because loading new tiles while the screen is on is tricky—we'll touch on how to do that in Part 3.

Speaking of tiles, we're going to load some into VRAM next, using the following code:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/getting-started/main.asm:copy_tiles}}
{{#include ../../unbricked/getting-started/main.asm:copy_tiles}}
```

This loop might be [reminiscent of part Ⅰ](../part1/jumps#conditional-jumps).
It copies `Tiles` to `$9000`, which is the part of VRAM where our tiles are going to be stored.
`$9000` is the first background tile, so it's assigned an ID of 0, and every tile after it is just one ID higher.
To get the number of bytes to copy, we will do just like in Part Ⅰ: using another label at the end, called `TilesEnd`, the difference between it (= the address after the last byte of tile data) and `Tiles` (= the address of the first byte) will be exactly that length.

That said, we haven't written `Tiles` nor any of the related data yet.
We'll get to that later!

Almost done now—next, write another loop, this time for copying [the tilemap](../part1/tilemap.md).

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/getting-started/main.asm:copy_map}}
{{#include ../../unbricked/getting-started/main.asm:copy_map}}
```

Note that while this loop's body is exactly the same as `CopyTiles`'s, the 3 values loaded into `de`, `hl`, and `bc` are different.
These determine the source, destination, and size of the copy, respectively.

::: tip "[<abbr title="Don't Repeat Yourself">DRY</abbr>](https://en.wikipedia.org/wiki/Don't_Repeat_Yourself)"

If you think that this is super redundant, you are not wrong, and we will see later how to write actual, reusable *functions*.
But there is more to them than meets the eye, so we will start tackling them much later.

:::

Finally, let's turn the screen back on, and set a [background palette](../part1/palettes.md).
Rather than writing the non-descript number `%10000001` (or $81 or 129, to taste), we make use of two constants graciously provided by `hardware.inc`: `LCDCF_ON` and `LCDCF_BGON`.
When written to [`rLCDC`](https://gbdev.io/pandocs/LCDC), the former causes the PPU and screen to turn back on, and the latter enables the background to be drawn.
(There are other elements that could be drawn, but we are not enabling them yet.)
Combining these constants must be done using `|`, the *binary "or"* operator; we'll see why later.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/getting-started/main.asm:end}}
{{#include ../../unbricked/getting-started/main.asm:end}}
```

There's one last thing we need before we can build the ROM, and that's the graphics.
We will draw the following screen:

![Layout of unbricked](../assets/part2/img/tilemap.png)

In `hello-world.asm`, tile data had been written out by hand in hexadecimal; this was to let you see how the sausage is made at the lowest level, but *boy* is it impractical to write!
This time, we will employ a more friendly way, which will let us write each row of pixels more easily.
We will use `dw` instead of `db` (the difference between these two will be explained later); and for each row of pixels, instead of writing [the bitplanes](../part1/tiles.md#encoding) as raw numbers, we will use a backtick (`` ` ``) followed by 8 characters.
Each character defines a single pixel, intuitively from left to right; it must be one of 0, 1, 2, and 3, representing the corresponding color index in [the palette](../part1/palettes.md).

::: tip

0, 1, 2, and 3 aren't the only options for writing graphics.
You can use [`OPT g`](https://rgbds.gbdev.io/docs/v0.5.2/rgbasm.5/#Changing_options_while_assembling) to modify these characters to your liking.

:::

For example:

```rgbasm
	dw `01230123 ; This is equivalent to `db $55,$33`
```

We already have tiles made for this project, so you can copy [this premade file](https://github.com/ISSOtm/gb-asm-tutorial-part2/raw/main/tileset.asm), and paste it at the end of your code.

Then copy the tilemap from [this file](https://github.com/ISSOtm/gb-asm-tutorial-part2/raw/main/tilemap.asm), and paste it after the `TilesEnd` label.

You can build the ROM now, by running the following commands in your terminal:

```console
$ rgbasm -L -o main.o main.asm
$ rgblink -o unbricked.gb main.o
$ rgbfix -v -p 0xFF unbricked.gb
```

If you run this in your emulator, you should see the following:

![Screenshot of our game](../assets/part2/img/screenshot.png)

That white square seems to be missing!
You may have noticed this comment earlier, somewhere in the tile data:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/getting-started/main.asm:custom_logo}}
{{#include ../../unbricked/getting-started/main.asm:custom_logo}}
```

The logo tiles were left intentionally blank so that you can choose your own.
You can use one of the following pre-made logos, or try coming up with your own!

## RGBDS Logo

![The RGBDS Logo](https://github.com/ISSOtm/gb-asm-tutorial-part2/blob/main/rgbds.png?raw=true)

[Source](https://github.com/ISSOtm/gb-asm-tutorial-part2/raw/main/rgbds.asm)

## Duck

![A pixel-art duck](https://github.com/ISSOtm/gb-asm-tutorial-part2/blob/main/duck.png?raw=true)

[Source](https://github.com/ISSOtm/gb-asm-tutorial-part2/raw/main/duck.asm)

## Tail

![A silhouette of a tail](https://github.com/ISSOtm/gb-asm-tutorial-part2/blob/main/tail.png?raw=true)

[Source](https://github.com/ISSOtm/gb-asm-tutorial-part2/raw/main/tail.asm)

Replace the blank tiles with the new graphics, build the game again, and you should see your logo of choice in the bottom-right!
