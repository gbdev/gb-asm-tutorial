# Compilation

Compilation is done via a Makefile. This Makefile can be run using the `make` command. Make should be preinstalled on Linux and Mac systems. For Windows users, check out [cygwin](https://www.cygwin.com/).

Without going over everything in detail, here’s what the Makefile does:

- Clean generated folders
- Recreate generated folders
- Convert PNGs in src/resources to `.2bpp`, and `.tilemap` formats
- Convert `.asm` files to `.o`
- Use the `.o` files to build the ROM file
- Apply the RGBDS “fix” utility.

> **Note:** The base template already does all of this. Additionally, it will automatically pick up any new .asm files you create.

## Converting our graphics to binary files
As previosly explained, all of our graphics were originally created in Aseprite. They were exported as a PNG **with a specific color palette**. 

Ater being exported as a PNG, when you run `make`, they are converted into `.2bpp` and `.tilemap` files via the RGBDS tool: RGBGFX.

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

```rgbasm,linenos
playerShipTileData: INCBIN "src/generated/sprites/player-ship.2bpp"
playerShipTileDataEnd:

enemyShipTileData:: INCBIN "src/generated/sprites/enemy-ship.2bpp"
enemyShipTileDataEnd::

bulletTileData:: INCBIN "src/generated/sprites/bullet.2bpp"
bulletTileDataEnd::
```