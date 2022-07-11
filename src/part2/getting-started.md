# Getting started

In this lesson we will start a new project from scratch, an arkanoid clone called "Unbricked"! (Or any other name you like, as this is *your* project)

Open a terminal and make new directory, like you did for "Hello, world!" (`mkdir unbricked`), and then enter it (`cd unbricked`).

Start by creating a file called `main.asm`, and include hardware.inc in your code.

```
line 1
```

Then create a header. Remember from part 1 that the header includes some information the Game Boy relies on, so you don't wanna accidentally leave it out.

```
lines 3-7
```

The header jumps to `EntryPoint`, so let's write that now:

```
lines 9-18
```

The next few lines wait until "VBlank". This basically means that the Game Boy's PPU has went to sleep for a short time, during which we can do things like turning off the screen.

Turning off the screen is important because it puts the PPU to sleep until the screen is turned back on. You can only load new graphics while the PPU is sleeping, so this gives us time to load our tiles.

Speaking of tiles, we're going to load some into VRAM next, using the following code:
```
lines 20-31
```

This loop might look familiar if you've read part 1. It copies `Tiles` to `$9000`, which is a part of VRAM where tiles are stored. To get the length of `Tiles`, we use another label at the end, called `TilesEnd`, and get the difference!

Note that our code still doesn't have anything called `Tiles`. We'll get to that later!

We're almost done now. Next, write another loop, this time for copying the tilemap, which will organize our tiles on the screen.

```
lines 33-44
```

You might notice that while this code is exactly the same, the 3 values loaded into `de`, `hl`, and `bc` are different. These determine the source, destination, and size of the copy, respectively.

Finally, we are going to turn the screen back on and initialize a background palette. hardware.inc provides the constants `LCDCF_ON` and `LCDCF_BGON`, which turn on the screen and the background respectively. We can "combine" these together using `|` (the or operator).

```
lines 46-55
```

There's one last thing we need before we can build the rom, and that's our graphics. We're going to be drawing the following screen:

![Layout of unbricked](https://github.com/ISSOtm/gb-asm-tutorial-part2/blob/main/tilemap.png?raw=true)

In the "Hello, world!" lesson, you saw graphics which were wirtten out by hand in hexadecimal. This time, we're going to write our graphics in a more friendly way; by assigning a character to each shade! To do this, type `dw`, followed by a space, a backtick (\`) and a series of 8 characters; by default these are 0, 1, 2, and 3, from lightest to darkest. This defines a row of 8 pixels.

```rgbasm,linenos
; For example:
Tiles:
	dw `01230123
```

(A note about OPT g could be added here?)

We already have tiles made for this project, so you can copy [this premade file](https://github.com/ISSOtm/gb-asm-tutorial-part2/raw/main/tileset.asm), and paste it at the end of your code.

Then copy the tilemap from [this file](https://github.com/ISSOtm/gb-asm-tutorial-part2/raw/main/tilemap.asm), and paste it after the `TilesEnd` label.

You can try building the rom at this point, using the following commands in your terminal:

```console
$ rgbasm -L -o unbricked.o unbricked.asm
$ rgblink -o unbricked.gb unbricked.o
$ rgbfix -v -p 0xFF unbricked.gb
```

If you run this in your emulator, you should see the following:

(Screenshot pending :P)

That white square seems to be missing! If you paid attention to your tiles earlier, you may have noticed this comment:

```
lines 135-140
```

The logo tiles were left intentionally blank so that you could customize this project. If you feel up to it, you can try creating your own logo by hand, or you can copy one of the following logos into your code:

## RGBDS Logo
[Source](https://github.com/ISSOtm/gb-asm-tutorial-part2/raw/main/rgbds.asm)
![The RGBDS Logo](https://github.com/ISSOtm/gb-asm-tutorial-part2/blob/main/rgbds.png?raw=true)

## Duck
[Source](https://github.com/ISSOtm/gb-asm-tutorial-part2/raw/main/duck.asm)
![A pixel-art duck](https://github.com/ISSOtm/gb-asm-tutorial-part2/blob/main/duck.png?raw=true)

## Tail
[Source](https://github.com/ISSOtm/gb-asm-tutorial-part2/raw/main/tail.asm)
![A silhouette of a tail](https://github.com/ISSOtm/gb-asm-tutorial-part2/blob/main/tail.png?raw=true)

Build your game again and your logo of choice should appear in the bottom right!
