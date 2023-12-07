# Metasprites

We'll use the metasprite implementation that comes with Eievui's Sprite Object Library. For this we've pre-defined metasprites that we'll use for the bullets, enemies, and player. A single metasprite instructs how/where to draw multiple OAM sprites. 

A single OAM sprite has 4 bytes:
- Y Position (relative to previous metasprite)
- X Position (relative to previous metasprite)
- Which tile in VRAM it will use
- Any additional OAM attributes (priority, flipping, palette, etc..)

After the final OAM sprite, the sprite object library will know it's done when it reads a 128 byte.

![MetaspriteDIagram.png](../assets/part3/img/MetaspriteDIagram.png)

*Inside of "src/main/assets/metasprites.asm"

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/assets/metasprites.asm}}
{{#include ../../galactic-armada/src/main/assets/metasprites.asm}}
```

## Drawing Metasprites

Eievui's Sprite Object Library defines a "RenderMetasprite" function we'll use later. This function takes 3 parameters:
- A pointer to the metasprite data, in HL
- The metasprite's y position, in BC
- The metasprite's x position, in DE

*Inside of "libs/sporbs_lib.asm"

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/libs/sporbs_lib.asm:render-metasprites}}
{{#include ../../galactic-armada/libs/sporbs_lib.asm:render-metasprites}}
```