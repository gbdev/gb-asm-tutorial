# Project Structure

To get started download the zip file for this tutorial. You can find it on Github [here](#). This file contains everything you need to get started. 
- Dependent Libraries are included
- Graphics assets are present and organized
- The makefile is set to compile all changes
- A basic entry point & Game Loop has been setup for you.

This page is going to explain how the Galactic Armada project is structured. This includes the folders, resources, tools, entry point, and compilation process.

> **Note:** All of this has been done and is a part of the template you can find here. These explanations are for understanding purposes, you don't need to do anything yet.
## Dependent Libraries

This project uses 2 additional libraries.
- [Eievui's Sprite Object Library](https://github.com/eievui5/gb-sprobj-lib)
- The joypad input handler from [the previous tutorial](https://gbdev.io/gb-asm-tutorial/part2/input.html)

### Eievui's sprite object library

For Eievui's sprite object library, we have already initialized it at the start of the game:

*Inside the 'EntryPoint' function in "GalacticArmada.asm"*
```rgbasm, linenos
; from: https://github.com/eievui5/gb-sprobj-lib
; The library is relatively simple to get set up. First, put the following in your initialization code:
; Initilize Sprite Object Library.
call InitSprObjLibWrapper
```

Once Initialized, we must reset it at the start of your game loop. This is done using the `ResetShadowOAM` function. Later, we must call it's `hOAMDMA` function at the end of the game loop (during the vertical blank phase).

*Inside the 'GalacticArmadaGameLoop' function in "GalacticArmada.asm"*

```rgbasm, linenos
; then put a call to ResetShadowOAM at the beginning of your main loop.
call ResetShadowOAM

; Our core game loop will go here

call WaitForVBlankStart

; from: https://github.com/eievui5/gb-sprobj-lib
; Finally, run the following code during VBlank:
ld a, HIGH(wShadowOAM)
call hOAMDMA
```

### Joypad Input

For joypad input, we've already setup 2 variables in working ram: `wCurKeys` and `wNewKeys`.

*At the top of our "GalacticArmada.asm" file*

```rgbasm,linenos
SECTION "GameVariables", WRAM0

{{#include ../../galactic-armada/src/main/GalacticArmada.asm:joypad-input-variables}}
```

Besides that, the final touch is calling the `Input` function at the start of the game loop:
```rgbasm, linenos
GalacticArmadaGameLoop:

	; This is in input.asm
	; It's straight from: https://gbdev.io/gb-asm-tutorial/part2/input.html
	; In their words (paraphrased): reading player input for gameboy is NOT a trivial task
	; So it's best to use some tested code
	call Input

  ; ... the rest of the game loop

```
That covers everything about our library implementations. Next we'll explain the folder structure, graphical assets, and compilation process.
## Folder Layout

For organizational purposes, many parts of the logic are separated into reusable functions. This is to reduce duplicate code, and make logic more clear.

Here’s a basic look at how the project is structured:

::: tip

Generated files should never be included in VCS repositories. It unneccessarily bloats the repo. The folders below marked with \* contains assets generated from running the Makefile and are not included in the repository.

:::

- `libs` - Two assembly files for input and sprites are located here.
- `src`
  - `generated` - the results of RGBGFX are stored here. \*
  - `resources` - Here exist some PNGs and Aseprite files for usage with RGBGFX
  - `main` - All assembly files are located here, or in subfolders
    - `states`
      - `gameplay` - for gameplay related files
        - `objects` - for gameplay objects like the player, bullets, and enemies
          - collision - for collision among objects
      - `story` - for our story state's related files
      - `title-screen` - for our title screen's related files
    - `utils` - Extra functions includes to assist with development
      - `macros`
- `dist` - The final ROM file will be created here. \*
- `obj` - Intermediate files from the compile process. \*
- `Makefile` - used to create the final ROM file and intermediate files

At the root of the project's [github repository](https://github.com/gbdev/gb-asm-tutorial/tree/master/galactic-armada), you'll notice only 2 folders (`src`, and `lib`) and 1 file (the [makefile](https://github.com/gbdev/gb-asm-tutorial/blob/master/galactic-armada/Makefile)). Locally, if you run the makefile, you'll see the `dist` and `obj` folders will be generated.

## Background & Sprite Resources

The following backgrounds and sprites are used in Galactic Armada:

- Backgrounds - [Github Link](https://github.com/gbdev/gb-asm-tutorial/tree/master/galactic-armada/src/resources/backgrounds)
  - Star Field
  - Title Screen
  - Text Font (Tiles only)
- Sprites - [Github Link](https://github.com/gbdev/gb-asm-tutorial/tree/master/galactic-armada/src/resources/sprites)
  - Enemy Ship
  - Player Ship
  - Bullet

<img class="pixelated" src="../assets/part3/img/star-field.png">

<img class="pixelated" src="../assets/part3/img/title-screen.png">

<br>

<img class="pixelated" src="../assets/part3/img/text-font.png" height="48px">

<br>

<img class="pixelated sprites" src="../assets/part3/img/player-ship.png" height="48px">

<img class="pixelated sprites" src="../assets/part3/img/enemy-ship.png" height="48px">

<img class="pixelated sprites" src="../assets/part3/img/bullet.png" height="48x">


These images were originally created in Aseprite. The original templates are also included in the repository. They were exported as a PNG **with a specific color palette**. Ater being exported as a PNG, when you run `make`, they are converted into `.2bpp` and `.tilemap` files via the RGBDS tool: RGBGFX.

> The **`rgbgfx`** program converts PNG images into data suitable for display on the Game Boy and Game Boy Color, or vice-versa.
>
> The main function of **`rgbgfx`** is to divide the input PNG into 8×8 pixel *[squares](https://rgbds.gbdev.io/docs/v0.6.1/rgbgfx.1#squares)*, convert each of those squares into 1bpp or 2bpp tile data, and save all of the tile data in a file. It also has options to generate a tile map, attribute map, and/or palette set as well; more on that and how the conversion process can be tweaked below.

RGBGFX can be found here: [https://rgbds.gbdev.io/docs/v0.6.1/rgbgfx.1](https://rgbds.gbdev.io/docs/v0.6.1/rgbgfx.1)

We'll use it to convert all of our graphics to .2bpp, and .tilemap formats (binary files)

```bash,linenos,start={{#line_no_of "" ../../galactic-armada/Makefile:generate-graphics}}
{{#include ../../galactic-armada/Makefile:generate-graphics}}
```
> **Note:** You can see the full makefile [here](https://github.com/gbdev/gb-asm-tutorial/blob/master/galactic-armada/Makefile)

From there, INCBIN commands are used to store reference the binary tile data.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/main.asm:sprite-tile-data}}
{{#include ../../galactic-armada/main.asm:sprite-tile-data}}
```

::: tip Including binary files

You probably have some graphics, level data, etc. you'd like to include. Use **`INCBIN`** to include a raw binary file as it is. If the file isn't found in the current directory, the include-path list passed to [rgbasm(1)](https://rgbds.gbdev.io/docs/v0.6.1/rgbasm.1) (see the **`-i`** option) on the command line will be searched.

```
INCBIN "titlepic.bin"
INCBIN "sprites/hero.bin"
```

You can also include only part of a file with **`INCBIN`**. The example below includes 256 bytes from data.bin, starting from byte 78.

```
INCBIN "data.bin",78,256
```

The length argument is optional. If only the start position is specified, the bytes from the start position until the end of the file will be included.

See also: [Including binary files - RGBASM documentation](https://rgbds.gbdev.io/docs/v0.6.1/rgbasm.5#Including_binary_files)

:::
## Compilation

Compilation is done via a Makefile. This Makefile can be run using the `make` command. Make should be preinstalled on Linux and Mac systems. For Windows users, check out [cygwin](https://www.cygwin.com/).

Without going over everything in detail, here’s what the Makefile does:

- Clean generated folders
- Recreate generated folders
- Convert PNGs in src/resources to `.2bpp`, and `.tilemap` formats
- Convert `.asm` files to `.o`
- Use the `.o` files to build the ROM file
- Apply the RGBDS “fix” utility.

> **Note:** The base template already does all of this. Additionally, it will automatically pick up any new .asm files you create.