# Dependent Libraries

This project uses 2 additional libraries.
- [Eievui's Sprite Object Library](https://github.com/eievui5/gb-sprobj-lib)
- The joypad input handler from [the previous tutorial](https://gbdev.io/gb-asm-tutorial/part2/input.html)
## Eievui's sprite object library

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
## Joypad Input

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

