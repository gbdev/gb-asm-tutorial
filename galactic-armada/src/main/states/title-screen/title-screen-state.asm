; ANCHOR: title-screen-start
INCLUDE "src/main/includes/hardware.inc"
INCLUDE "src/main/includes/character-mapping.inc"

SECTION "TitleScreenState", ROM0

; ANCHOR_END: title-screen-start

wPressPlayText::  db "press a to play", 255

; ANCHOR: title-screen-init
InitTitleScreenState::

    call WaitForVBlankStart
    
	; Turn the LCD off
	ld a, 0
	ldh [rLCDC], a

    ; reset the position of the background
	ld a, 0
    ld [rSCX], a
    ld [rSCY], a

    ; Clear the background and all sprites
	call ClearBackground
	call ResetShadowOAM
    call hOAMDMA
    call DisableInterrupts

    call LoadTextFontIntoVRAM
	call DrawTitleScreen

	; Call Our function that draws text onto background/window tiles
    ld de, $99C3
    ld hl, wPressPlayText
    call DrawTextInHL_AtDE
    
	; Turn the LCD on
	ld a, LCDCF_ON  | LCDCF_BGON| LCDCF_WIN9C00|LCDCF_BG9800
	ldh [rLCDC], a

    ret;
; ANCHOR_END: title-screen-init
; ANCHOR: update-title-screen
UpdateTitleScreenState::


    call WaitForAToBePressed

    ld hl, InitStoryState
    ld a, l
    ld [wNextGameState_Initiate+0], a
    ld a, h
    ld [wNextGameState_Initiate+1], a

    ld hl, UpdateStoryState
    ld a, l
    ld [wNextGameState_Update+0], a
    ld a, h
    ld [wNextGameState_Update+1], a

    ret
; ANCHOR_END: update-title-screen
