# Sprites

For sprites, the following library is used:  https://github.com/eievui5/gb-sprobj-lib

> This is a small, lightweight library meant to facilitate the rendering of sprite objects, including Shadow OAM and OAM DMA, single-entry "simple" sprite objects, and Q12.4 fixed-point position metasprite rendering.
> 

**Directly from the “gb-sprobj-lib” github:**

The library is relatively simple to get set up. First, put the following in your initialization code:

```nasm
; Initilize Sprite Object Library.
	call InitSprObjLib

	; Reset hardware OAM
	xor a, a
	ld b, 160
	ld hl, _OAMRAM
.resetOAM
	ld [hli], a
	dec b
	jr nz, .resetOAM
```

Then put a call to `ResetShadowOAM` at the beginning of your main loop.

Finally, run the following code during VBlank:

```nasm
ld a, HIGH(wShadowOAM)
call hOAMDMA
```

## Metasprites

A custom “metasprite” implementation is used in addition. Metasprite definitions should a multiple of 4 plus one additional byte for the end.

- Relative Y offset ( relative to the previous sprite, or the actual metasprite’s draw position)
- Relative X offset ( relative to the previous sprite, or the actual metasprite’s draw position)
- Tile to draw
- Tile Props (not used in this project)

The logic stops drawing when it reads 128. 

An example of metasprite is the enemy ship:


```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/galactic-armada/main.asm:enemy-metasprites}}
{{#include ../../unbricked/galactic-armada/main.asm:enemy-metasprites}}
```

![MetaspriteDIagram.png](../assets/img/MetaspriteDIagram.png)

The Previous snippet draws two sprites. One that the object’s actual position, which uses tile 4 and 5. The second sprite is 8 pixels to the right, and uses tile 6 and 7

<aside>
⚠️ **NOTE**: Sprites are in 8x16 mode for this project.

</aside>

I can later draw such metasprite using the following custom macro

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/galactic-armada/main.asm:draw-enemy-metasprites}}
{{#include ../../unbricked/galactic-armada/main.asm:draw-enemy-metasprites}}
```
