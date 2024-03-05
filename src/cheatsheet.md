# RGBDS Cheatsheet

The purpose of this page is to provide concise explanations and code snippets for common tasks.
For extra depth, clarity, and understanding, it's recommended you read through the [Hello World](part1/setup.md), [Part II - Our first game](part2/getting-started.md), and [Part III - Our second game](part3/getting-started.md) tutorials.

Assembly syntax & CPU Instructions will not be explained, for more information see the [RGBDS Language Reference](https://rgbds.gbdev.io/docs/rgbasm.5)

Is there something common you think is missing? Check the [github repository](https://github.com/gbdev/gb-asm-tutorial) to open an Issue or contribute to this page. Alternatively, you can reach out on one of the @gbdev [community channels](https://gbdev.io/chat.html).

## Table of Contents

- [RGBDS Cheatsheet](#rgbds-cheatsheet)
  - [Table of Contents](#table-of-contents)
  - [Display](#display)
    - [Wait for the vertical blank phase](#wait-for-the-vertical-blank-phase)
    - [Turn on/off the LCD](#turn-onoff-the-lcd)
    - [Turn on/off the background](#turn-onoff-the-background)
    - [Turn on/off the window](#turn-onoff-the-window)
    - [Switch which tilemaps are used by the window and/or background](#switch-which-tilemaps-are-used-by-the-window-andor-background)
    - [Turn on/off sprites](#turn-onoff-sprites)
    - [Turn on/off tall (8x16) sprites](#turn-onoff-tall-8x16-sprites)
  - [Backgrounds](#backgrounds)
    - [Put background/window tile data into VRAM](#put-backgroundwindow-tile-data-into-vram)
    - [Draw on the Background/Window](#draw-on-the-backgroundwindow)
    - [Move the background](#move-the-background)
    - [Move the window](#move-the-window)
  - [Joypad Input](#joypad-input)
    - [Check if a button is down](#check-if-a-button-is-down)
    - [Check if a button was JUST pressed](#check-if-a-button-was-just-pressed)
    - [Wait for a button press](#wait-for-a-button-press)
  - [HUD](#hud)
    - [Draw text](#draw-text)
    - [Draw a bottom HUD](#draw-a-bottom-hud)
  - [Sprites](#sprites)
    - [Put sprite tile data in VRAM](#put-sprite-tile-data-in-vram)
    - [Manipulate hardware OAM sprites](#manipulate-hardware-oam-sprites)
    - [Implement a Shadow OAM using @eievui5's Sprite Object Library](#implement-a-shadow-oam-using-eievui5s-sprite-object-library)
    - [Manipulate Shadow OAM OAM sprites](#manipulate-shadow-oam-oam-sprites)
  - [Micelaneous](#micelaneous)
    - [Save Data](#save-data)
    - [Generate random numbers](#generate-random-numbers)

## Display

The `rLCDC` register controls all of the following:

-   The screen
-   The background
-   The window
-   Sprite objects

For more information on LCD control, refer to the [Pan Docs](https://gbdev.io/pandocs/LCDC.html)

### Wait for the vertical blank phase

To check for the vertical blank phase, use the `rLY` register. Compare that register's value against the height of the Game Boy screen in pixels: 144.

```rgbasm,linenos
WaitUntilVerticalBlankStart:
    ldh a, [rLY]
    cp 144
    jp c, WaitUntilVerticalBlankStart
```

### Turn on/off the LCD

You can turn the LCD on and off by altering the most significant bit of the `rLCDC` register. hardware.inc a constant for this: `LCDCF_ON` .

**To turn the LCD on:**

```rgbasm,linenos
ld a, LCDCF_ON
ldh [rLCDC], a
```

**To turn the LCD off:**

::: warning

Do not turn the LCD off outside of the Vertical Blank Phase. See "[How to wait for vertical blank phase](#how-to-wait-for-the-vertical-blank-phase)".

:::

```rgbasm,linenos
; Turn the LCD off
ld a, LCDCF_OFF
ldh [rLCDC], a
```

### Turn on/off the background

To turn the background layer on and off, alter the least significant bit of the `rLCDC` register. You can use the `LCDCF_BGON` constant for this.

**To turn the background on:**

```rgbasm,linenos
; Turn the background on
ldh a, [rLCDC]
or a, LCDCF_BGON
ldh [rLCDC], a
```

**To turn the background off:**

```rgbasm,linenos
; Turn the background off
ldh a, [rLCDC]
and a, ~LCDCF_BGON
ldh [rLCDC], a
```

### Turn on/off the window

To turn the window layer on and off, alter the least significant bit of the `rLCDC` register. You can use the `LCDCF_WINON` and `LCDCF_WINOFF` constants for this.

**To turn the window on:**

```rgbasm,linenos
; Turn the window on
ldh a, [rLCDC]
or a, LCDCF_WINON
ldh [rLCDC], a
```

**To turn the window off:**

```rgbasm,linenos
; Turn the window off
ldh a, [rLCDC]
and a, LCDCF_WINOFF
ldh [rLCDC], a
```

### Switch which tilemaps are used by the window and/or background

By default, the window and background layer will use the same tilemap.

For the window and background, there are 2 memory regions they can use: `$9800` and `$9C00`. For more information, refer to the [Pan Docs](https://gbdev.io/pandocs/Tile_Maps.html)

Which region the background uses is controlled by the 4th bit of the `rLCDC` register. Which region the window uses is controlled by the 7th bit.

You can use one of the 4 constants to specify which layer uses which region:

-   LCDCF_WIN9800
-   LCDCF_WIN9C00
-   LCDCF_BG9800
-   LCDCF_BG9C00

::: tip Note

You still need to make sure the window and background are turned on when using these constants.

:::

### Turn on/off sprites

Sprites (or objects) can be toggled on and off using the 2nd bit of the `rLCDC` register. You can use the `LCDCF_OBJON` and `LCDCF_OBJOFF` constants for this.

**To turn sprite objects on:**

```rgbasm,linenos
; Turn the sprites on
ldh a, [rLCDC]
or a, LCDCF_OBJON
ldh [rLCDC], a
```

**To turn sprite objects off:**

```rgbasm,linenos
; Turn the sprites off
ldh a, [rLCDC]
and a, LCDCF_OBJOFF
ldh [rLCDC], a
```

::: tip

Sprites are in 8x8 mode by default.

:::

### Turn on/off tall (8x16) sprites

Once sprites are enabled, you can enable tall sprites using the 3rd bit of the `rLCDC` register: `LCDCF_OBJ16`

::: tip

You can not have some 8x8 sprites and some 8x16 sprites. All sprites must be of the same size.

:::

```rgbasm,linenos
; Turn tall sprites on
ldh a, [rLCDC]
or a, LCDCF_OBJ16
ldh [rLCDC], a
```

## Backgrounds

### Put background/window tile data into VRAM

The region in VRAM dedicated for the background/window tilemaps is from $9000 to $97FF. hardware.inc defines a `_VRAM9000` constant you can use for that.

MyBackground:
    INCBIN "src/path/to/my-background.2bpp"
.end

CopyBackgroundWindowTileDataIntoVram:
    ; Copy the tile data
    ld de, myBackground
    ld hl, \_VRAM
    ld bc, MyBackground.end - MyBackground
.loop:
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or a, c
    jr nz, .Loop

### Draw on the Background/Window

The Game Boy has 2 32x32 tilemaps, one at `$9800` and another at `$9C00`. Either can be used for the background or window. By default, they both use the tilemap at `$9800`.

Drawing on the background or window is as simple as copying bytes starting at one of those addresses:

```rgbasm, lineno
CopyTilemapTo
   ; Copy the tilemap
    ld de, Tilemap
    ld hl, $9800
    ld bc, TilemapEnd - Tilemap
CopyTilemap:
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or a, c
    jp nz, CopyTilemap
```

::: tip

Make sure the layer you're targetting has been turned on. See ["Turn on/off the window"](#turn-onoff-the-window) and ["Turn on/off the background"](#turn-onoff-the-background)

:::

::: tip

In terms of tiles, The background/window tilemaps are 32x32. The Game Boy's screen is 20x18. When copying tiles, understand that RGBDS or the Game Boy won't automatically jump to the next visible row after you've reached the 20th column.

:::

### Move the background

You can move the background horizontally & vertically using the `$FF43` and `$FF42` registers, respectively. Hardware.inc defines two constants for that: `rSCX` and `rSCY`.

**How to change the background's X Position:**

```rgbasm,linenos
ld a,64
ld [rSCX], a
```

**How to change the background's Y Position:**

```rgbasm,linenos
ld a,64
ld [rSCY], a
```

Check out the Pan Docs for more info on the [Background viewport Y position, X position](https://gbdev.io/pandocs/Scrolling.html#ff42ff43--scy-scx-background-viewport-y-position-x-position)

### Move the window

Moving the window is the same as moving the background, except using the `$FF4B` and `$FF4A` registers. Hardware.inc defines two constants for that: `rWX` and `rWY`.

::: tip

The window layer has a -7 pixel horizontal offset. This means setting `rWX` to 7 places the window at the left side of the screen, and setting `rWX` to 87 places the window with its left side halfway across the screen.

:::

**How to change the window's X Position:**

```rgbasm,linenos
ld a,64
ld [rWX], a
```

**How to change the window's Y Position:**

```rgbasm,linenos
ld a,64
ld [rWY], a
```

Check out the Pan Docs for more info on the [WY, WX: Window Y position, X position plus 7](https://gbdev.io/pandocs/Scrolling.html#ff4aff4b--wy-wx-window-y-position-x-position-plus-7)

## Joypad Input

Reading joypad input is not a trivial task. For more info see [Tutorial #2](https://gbdev.io/gb-asm-tutorial/part2/input.html), or the [Joypad Input Page](https://gbdev.io/pandocs/Joypad_Input.html) in the Pan Docs. Paste this code somewhere in your project:

```rgbasm,linenos,start={{#line_no_of "" ../unbricked/input/main.asm:input-routine}}
{{#include ../unbricked/input/main.asm:input-routine}}
```

Next setup 2 variables in working ram:

```rgbasm,linenos,start={{#line_no_of "" ../unbricked/input/main.asm:vars}}
{{#include ../unbricked/input/main.asm:vars}}
```

Finally, during your game loop, be sure to call the `UpdateKeys` function during the Vertical Blank phase.

```rgbasm,linenos
; Check the current keys every frame and move left or right.
call UpdateKeys
```

### Check if a button is down

You can check if a button is down using any of the following constants from hardware.inc:

-   PADF_DOWN
-   PADF_UP
-   PADF_LEFT
-   PADF_RIGHT
-   PADF_START
-   PADF_SELECT
-   PADF_B
-   PADF_A

You can check if the associataed button is down using the `wCurKeys` variable:

```rgbasm,linenos
ld a, [wCurKeys]
and a, PADF_LEFT
jp nz, LeftIsPressedDown
```

### Check if a button was JUST pressed

You can tell if a button was JUST pressed using the `wNewKeys` variable

```rgbasm,linenos
ld a, [wNewKeys]
and a, PADF_A
jp nz, AWasJustPressed
```

### Wait for a button press

To wait **indefinitely** for a button press, create a loop where you:

-   check if the button has JUST been pressed
-   If not:
    -   Wait until the next vertical blank phase completes
    -   call the `UpdateKeys` function again
    -   Loop background to the beginning

::: tip

This will halt all other logic (outside of interrupts), be careful if you need any logic running simultaneously.

:::

```rgbasm, linenos
WaitForAButtonToBePressed:
    ld a, [wNewKeys]
    and a, PADF_A
    ret nz
WaitUntilVerticalBlankStart:
    ld a, [rLY]
    cp 144
    jp nc, WaitUntilVerticalBlankStart
WaitUntilVerticalBlankEnd:
    ld a, [rLY]
    cp 144
    jp c, WaitUntilVerticalBlankEnd
    call UpdateKeys
    jp WaitForAButtonToBePressed
```

## HUD

Heads Up Displays, or HUDs; are commonly used to prevent extra information to the player. Good examples are: Score, Health, and the current level. The window layer is drawn on top of the background, and cannot move like the background. For this reason, commonly the window layer is used for HUDs. See ["How to Draw on the Background/Window"](#how-to-draw-on-the-backgroundwindow).

### Draw text

Drawing text on the window is essentially drawing tiles (with letters/numbers/punctuation on them) on the window and/or background layer.

To simplify the process you can define constant strings.

::: tip

These constants end with a literal 255, which our code will read as the end of the string.

:::

```rgbasm, lineno

SECTION "Text ASM", ROM0

wScoreText::  db "score", 255

```

RGBDS has a character map functionality. You can read more in the [RGBDS Assembly Syntax Documentation](https://rgbds.gbdev.io/docs/rgbasm.5#DEFINING_DATA). This functionality, tells the compiler how to map each letter:

::: tip

You need to have your text font tiles in VRAM at the locations specified in the map. See [How to put background/window tile data in VRAM](#how-to-put-backgroundwindow-tile-data-into-vram)

:::

```rgbasm, lineno

CHARMAP " ", 0
CHARMAP ".", 24
CHARMAP "-", 25
CHARMAP "a", 26
CHARMAP "b", 27
CHARMAP "c", 28
CHARMAP "d", 29
CHARMAP "e", 30
CHARMAP "f", 31
CHARMAP "g", 32
CHARMAP "h", 33
CHARMAP "i", 34
CHARMAP "j", 35
CHARMAP "k", 36
CHARMAP "l", 37
CHARMAP "m", 38
CHARMAP "n", 39
CHARMAP "o", 40
CHARMAP "p", 41
CHARMAP "q", 42
CHARMAP "r", 43
CHARMAP "s", 44
CHARMAP "t", 45
CHARMAP "u", 46
CHARMAP "v", 47
CHARMAP "w", 48
CHARMAP "x", 49
CHARMAP "y", 50
CHARMAP "z", 51

```

The above character mapping would convert (by the compiler) our `wScoreText` text to:

-   s => 44
-   c => 28
-   o => 40
-   r => 43
-   e => 30
-   255

With that setup, we would loop though the bytes of `wScoreText` and copy each byte to the background/window layer. After we copy each byte, we'll increment where we will copy to, and which byte in `wScoreText` we are reading. When we read 255, our code will end.

::: tip

This example implies that your font tiles are located in VRAM at the locations specified in the character mapping.

:::

** Drawing 'score' on the window **

```rgbasm, lineno

DrawTextTiles::

    ld hl, wScoreText
    ld de, $9C00 ; The window tilemap starts at $9C00

DrawTextTilesLoop::

    ; Check for the end of string character 255
    ld a, [hl]
    cp 255
    ret z

    ; Write the current character (in hl) to the address
    ; on the tilemap (in de)
    ld a, [hl]
    ld [de], a

    inc hl
    inc de

    ; move to the next character and next background tile
    jp DrawTextTilesLoop
```

### Draw a bottom HUD

-   Enable the window (with a different tilemap than the background)
-   Move the window downwards, so only 1 or 2 rows show at the bottom of the screen
-   Draw your text, score, and icons on the top of the window layer.

::: tip

Sprites will still show over the window. To fully prevent that, you can use STAT interrupts to hide sprites where the bottom HUD will be shown.

:::

## Sprites

### Put sprite tile data in VRAM

The region in VRAM dedicated for sprites is from `$8000` to `$87F0`. Hardware.inc defines a `_VRAM` constant you can use for that. To copy sprite tile data into VRAM, you can use a loop to copy the bytes.

```rgbasm,linenos
mySprite: INCBIN "src/path/to/my/sprite.2bpp"
mySpriteEnd:

CopySpriteTileDataIntoVram:
    ; Copy the tile data
    ld de, Paddle
    ld hl, _VRAM
    ld bc, mySpriteEnd - mySprite
CopySpriteTileDataIntoVram_Loop:
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or a, c
    jp nz, CopySpriteTileDataIntoVram_Loop
```

### Manipulate hardware OAM sprites

Each hardware sprite has 4 bytes: (in this order)

-   Y position
-   X Position
-   Tile ID
-   Flags/Props (priority, y flip, x flip, palette 0 [DMG], palette 1 [DMG], bank 0 [GBC], bank 1 [GBC])

Check out the Pan Docs page on [Object Attribute Memory (OAM)](https://gbdev.io/pandocs/OAM.html) for more info.

The bytes controlling hardware OAM sprites start at `$FE00`, for which hardware.inc has defined a constant as `_OAMRAM`.

**Moving (the first) OAM sprite, one pixel downwards:**

```rgbasm, linenos
ld a, [_OAMRAM]
inc a
ld [_OAMRAM], a
```

**Moving (the first) OAM sprite, one pixel to the right:**

```rgbasm, linenos
ld a, [_OAMRAM + 1]
inc a
ld [_OAMRAM + 1], a
```

**Setting the tile for the first OAM sprite:**

```rgbasm, linenos
ld a, 3
ld [_OAMRAM+2], a
```

**Moving (the fifth) OAM sprite, one pixel downwards:**

```rgbasm, linenos
ld a, [_OAMRAM + 20]
inc a
ld [_OAMRAM + 20], a
```

TODO - Explanation on limitations of direct OAM manipulation.

::: tip

It's recommended that developers implement a shadow OAM, like @eievui5's [Sprite Object Library](https://github.com/eievui5/gb-sprobj-lib)

:::

### Implement a Shadow OAM using @eievui5's Sprite Object Library

GitHub URL: [https://github.com/eievui5/gb-sprobj-lib](https://github.com/eievui5/gb-sprobj-lib)

> This is a small, lightweight library meant to facilitate the rendering of sprite objects, including Shadow OAM and OAM DMA, single-entry "simple" sprite objects, and Q12.4 fixed-point position metasprite rendering.

**Usage**

The library is relatively simple to get set up. First, put the following in your initialization code:

```rgbasm, linenos
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

Then put a call to `ResetShadowOAM` at the beginning of your main loop.

Finally, run the following code during VBlank:

```rgbasm, linenos
ld a, HIGH(wShadowOAM)
call hOAMDMA
```

### Manipulate Shadow OAM OAM sprites

Once you've set up @eievui5's Sprite Object Library, you can manipulate shadow OAM sprites the exact same way you would manipulate normal hardware OAM sprites. Except, this time you would use the library's `wShadowOAM` constant instead of the `_OAMRAM` register.

**Moving (the first) OAM sprite, one pixel downwards:**

```rgbasm, linenos
ld a,LOW(wShadowOAM)
ld l, a
ld a, HIGH(wShadowOAM)
ld h, a

ld a, [hl]
inc a
ld [wShadowOAM], a
```

## Micelaneous

### Save Data

If you want to save data in your game, your game's header needs to specify the correct MBC/cartridge type, and it needs to have a non-zero SRAM size. This should be done in your makefile by passing special parameters to [rgbfix](https://rgbds.gbdev.io/docs/rgbfix.1).

-   Use the `-m` or `--mbc-type` parameters to set the mbc/cartidge type, 0x147, to a given value from 0 to 0xFF. [More Info](https://gbdev.io/pandocs/The_Cartridge_Header.html#0147--cartridge-type)
-   Use the `-r` or `--ram-size` parameters to set the RAM size, 0x149, to a given value from 0 to 0xFF. [More Info](https://gbdev.io/pandocs/The_Cartridge_Header.html#0149--ram-size).

To save data you need to store variables in Static RAM. This is done by creating a new SRAM "SECTION". [More Info](https://rgbds.gbdev.io/docs/rgbasm.5#SECTIONS)

```rgbasm, linenos
SECTION "SaveVariables", SRAM

wCurrentLevel:: db

```

To access SRAM, you need to write `CART_SRAM_ENABLE` to the `rRAMG` register. When done, you can disable SRAM using the `CART_SRAM_DISABLE` constant.

**To enable read/write access to SRAM:**

```rgbasm, linenos

ld a, CART_SRAM_ENABLE
ld [rRAMG], a

```

**To disable read/write access to SRAM:**

```rgbasm, linenos

ld a, CART_SRAM_DISABLE
ld [rRAMG], a

```

**Initiating Save Data**

By default, save data for your game may or may not exist. When the save data does not exist, the value of the bytes dedicated for saving will be random.

You can dedicate a couple bytes towards creating a pseudo-checksum. When these bytes have a **very specific** value, you can be somewhat sure the save data has been initialized.

```rgbasm, linenos
SECTION "SaveVariables", SRAM

wCurrentLevel:: db
wCheckSum1:: db
wCheckSum2:: db
wCheckSum3:: db
```

When initializing your save data, you'll need to

-   enable SRAM access
-   set your checksum bytes
-   give your other variables default values
-   disable SRAM access

```rgbasm, linenos

;; Setup our save data
InitSaveData::

    ld a, CART_SRAM_ENABLE
    ld [rRAMG], a

    ld a, 123
    ld [wCheckSum1], a

    ld a, 111
    ld [wCheckSum2], a

    ld a, 222
    ld [wCheckSum3], a

    ld a, 0
    ld [wCurrentLevel], a

    ld a, CART_SRAM_DISABLE
    ld [rRAMG], a

    ret
```

Once your save file has been initialized, you can access any variable normally once SRAM is enabled.

```rgbasm, linenos

;; Setup our save data
StartNextLevel::

    ld a, CART_SRAM_ENABLE
    ld [rRAMG], a

    ld a, [wCurrentLevel]
    cp a, 3
    call z, StartLevel3

    ld a, CART_SRAM_DISABLE
    ld [rRAMG], a

    ret
```

### Generate random numbers

Random number generation is a [complex task in software](https://en.wikipedia.org/wiki/Random_number_generation). What you can implement is a "pseudorandom" generator, giving you a very unpredictable sequence of values. Here's a `rand` function (from [Damian Yerrick](https://github.com/pinobatch)) you can use.

```rgbasm, lineno

SECTION "MathVariables", WRAM0
randstate:: ds 4

SECTION "Math", ROM0

;; From: https://github.com/pinobatch/libbet/blob/master/src/rand.z80#L34-L54
; Generates a pseudorandom 16-bit integer in BC
; using the LCG formula from cc65 rand():
; x[i + 1] = x[i] * 0x01010101 + 0xB3B3B3B3
; @return A=B=state bits 31-24 (which have the best entropy),
; C=state bits 23-16, HL trashed
rand::
  ; Add 0xB3 then multiply by 0x01010101
  ld hl, randstate+0
  ld a, [hl]
  add a, $B3
  ld [hl+], a
  adc a, [hl]
  ld [hl+], a
  adc a, [hl]
  ld [hl+], a
  ld c, a
  adc a, [hl]
  ld [hl], a
  ld b, a
  ret
```
