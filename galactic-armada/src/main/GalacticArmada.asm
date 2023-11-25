; ANCHOR: entry-point
INCLUDE "src/main/includes/hardware.inc"


SECTION "GameVariables", WRAM0

; ANCHOR: joypad-input-variables
wCurKeys:: db
wNewKeys:: db
wLastKeys:: db
; ANCHOR_END: joypad-input-variables

; ANCHOR: game-state-variables
wCurrentGameState_Update:: dw
wNextGameState_Initiate:: dw
wNextGameState_Update:: dw
; ANCHOR_END: game-state-variables


SECTION "Header", ROM0[$100]

	jp EntryPoint

	ds $150 - @, 0 ; Make room for the header

EntryPoint:
; ANCHOR_END: entry-point
	
; ANCHOR: initialize-game-state-variables
	; Default our game state variables
	ld a, 0
	ld [wCurrentGameState_Update+0], a
	ld [wCurrentGameState_Update+1], a
	ld [wNextGameState_Initiate+0], a
	ld [wNextGameState_Initiate+1], a
	ld [wNextGameState_Update+0], a
	ld [wNextGameState_Update+1], a
; ANCHOR_END: initialize-game-state-variables

	; Wait for the vertical blank phase before initiating the library
    call WaitForVBlankStart

	; Turn the LCD off
	ld a, 0
	ld [rLCDC], a

	; from: https://github.com/eievui5/gb-sprobj-lib
	; The library is relatively simple to get set up. First, put the following in your initialization code:
	; Initilize Sprite Object Library.
	call InitSprObjLibWrapper

	; Turn the LCD on
	ld a, LCDCF_ON  | LCDCF_BGON|LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_WINON | LCDCF_WIN9C00
	ld [rLCDC], a

	; During the first (blank) frame, initialize display registers
	ld a, %11100100
	ld [rBGP], a
    ld a, %11100100
	ld [rOBP0], a

	ld hl, InitTitleScreenState
    ld a, l
    ld [wNextGameState_Initiate+0], a
    ld a, h
    ld [wNextGameState_Initiate+1], a

	ld hl, UpdateTitleScreenState
    ld a, l
    ld [wNextGameState_Update+0], a
    ld a, h
    ld [wNextGameState_Update+1], a

	call InitiateNewCurrentGameState

; ANCHOR_END: entry-point-end

; ANCHOR: update-galactic-armada
GalacticArmadaGameLoop:

	; This is in input.asm
	; It's straight from: https://gbdev.io/gb-asm-tutorial/part2/input.html
	; In their words (paraphrased): reading player input for gameboy is NOT a trivial task
	; So it's best to use some tested code
	call Input

	; from: https://github.com/eievui5/gb-sprobj-lib
	; hen put a call to ResetShadowOAM at the beginning of your main loop.
	call ResetShadowOAM

; ANCHOR: update-game-state-management
	call InitiateNewCurrentGameState
	call UpdateCurrentGameState
; ANCHOR_END: update-game-state-management

	call WaitForVBlankStart

	; from: https://github.com/eievui5/gb-sprobj-lib
	; Finally, run the following code during VBlank:
	ld a, HIGH(wShadowOAM)
	call hOAMDMA

	jp GalacticArmadaGameLoop
; ANCHOR_END: update-galactic-armada

; ANCHOR: update-current-game-state-function
UpdateCurrentGameState:

	; Get the address of the current game state
	ld a, [wCurrentGameState_Update+0]
	ld l, a
	ld a, [wCurrentGameState_Update+1]
	or a, l

	; Stop if we have a 0 value
	ret z

	; call the function in HL
	ld a, [wCurrentGameState_Update+1]
	ld h, a
	call callHL

	ret
; ANCHOR_END: update-current-game-state-function

; ANCHOR: initiate-new-game-state-function
InitiateNewCurrentGameState:

	; If this is 0, we are not changing game states
	ld a, [wNextGameState_Initiate+0]
	ld l, a
	ld a, [wNextGameState_Initiate+1]
	or a, l
	ret z

	ld a, [wNextGameState_Initiate+1]
	ld h, a	
	call callHL

	ld a, [wNextGameState_Update+0]
	ld [wCurrentGameState_Update+0], a
	ld a, [wNextGameState_Update+1]
	ld [wCurrentGameState_Update+1], a

	; Reset these to zero
	ld a, 0
	ld [wNextGameState_Initiate+0],a
	ld [wNextGameState_Initiate+1], a
	ld [wNextGameState_Update+0], a
	ld [wNextGameState_Update+1], a


	ret

; ANCHOR_END: initiate-new-game-state-function