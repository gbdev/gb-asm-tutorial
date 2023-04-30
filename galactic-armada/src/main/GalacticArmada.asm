; ANCHOR: entry-point
INCLUDE "src/main/utils/hardware.inc"

SECTION "GameVariables", WRAM0

wLastKeys:: db
wCurKeys:: db
wGameState::db

SECTION "Header", ROM0[$100]

	jp EntryPoint

	ds $150 - @, 0 ; Make room for the header

EntryPoint:

; ANCHOR_END: entry-point
	
; ANCHOR: entry-point-end
	ld a, 0
	ld [wGameState], a

	; Wait for the vertical blank phase before initiating the library
    call WaitForOneVBlank

	; from: https://github.com/eievui5/gb-sprobj-lib
	; The library is relatively simple to get set up. First, put the following in your initialization code:
	; Initilize Sprite Object Library.
	call InitSprObjLibWrapperFunction

	; During the first (blank) frame, initialize display registers
	ld a, %11100100
	ld [rBGP], a
    ld a, %11100100
	ld [rOBP0], a

	; Turn the LCD off
	ld a, 0
	ld [rLCDC], a

	; Load our common text font into VRAM
	call LoadTextFontIntoVRAM

	; Turn the LCD on
	ld a, LCDCF_ON  | LCDCF_BGON|LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_WINON | LCDCF_WIN9C00
	ld [rLCDC], a

; ANCHOR_END: entry-point-end
; ANCHOR: next-game-state

NextGameState::

	; Do not turn the LCD off outside of VBlank
    call WaitForOneVBlank

	; Turn the LCD off
	ld a, 0
	ld [rLCDC], a

	ld a, 0
	ld [rSCX],a
	ld [rSCY],a
	ld [rWX],a
	ld [rWY],a

	call ClearBackground;

	; disable interrupts
	call DisableInterrupts
	
	; Clear all sprites
	call ClearAllSprites

	; Initiate the next state
	ld a, [wGameState]
	cp a, 2 ; 2 = Gameplay
	call z, InitGameplayState
	ld a, [wGameState]
	cp a, 1 ; 1 = Story
	call z, InitStoryState
	ld a, [wGameState]
	cp a, 0 ; 0 = Menu
	call z, InitTitleScreenState

	; Update the next state
	ld a, [wGameState]
	cp a, 2 ; 2 = Gameplay
	jp z, UpdateGameplayState
	cp a, 1 ; 1 = Story
	jp z, UpdateStoryState
	jp UpdateTitleScreenState

; ANCHOR_END: next-game-state