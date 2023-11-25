INCLUDE "src/main/includes/hardware.inc"

; ANCHOR: gameplay-data-variables
INCLUDE "src/main/includes/hardware.inc"
INCLUDE "src/main/includes/character-mapping.inc"

SECTION "GameplayVariables", WRAM0

wScore:: ds 6
wLives:: db

SECTION "GameplayState", ROM0

wScoreText::  db "score", 255
wLivesText::  db "lives", 255
; ANCHOR_END: gameplay-data-variables

; ANCHOR: init-gameplay-state
InitGameplayState::

	call WaitForVBlankStart

	ld a, 3
	ld [wLives+0], a

	ld a, 0
	ld [wScore+0], a
	ld [wScore+1], a
	ld [wScore+2], a
	ld [wScore+3], a
	ld [wScore+4], a
	ld [wScore+5], a

	; Turn the LCD off
	ld a, 0
	ld [rLCDC], a

	call InitializeBackground
	call InitializePlayer
	call InitializeBullets
	call InitializeEnemies

	; Initiate STAT interrupts
	call InitStatInterrupts

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; Call Our function that draws text onto background/window tiles
    ld de, $9c00
    ld hl, wScoreText
    call DrawTextInHL_AtDE

	; Call Our function that draws text onto background/window tiles
    ld de, $9c0D
    ld hl, wLivesText
    call DrawTextInHL_AtDE
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	call DrawScore
	call DrawLives

	ld a, 0
	ld [rWY], a

	ld a, 7
	ld [rWX], a

	; Turn the LCD on
	ld a, LCDCF_ON  | LCDCF_BGON|LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_WINON | LCDCF_WIN9C00|LCDCF_BG9800
	ld [rLCDC], a

    ret;
; ANCHOR_END: init-gameplay-state
	
; ANCHOR: update-gameplay-state-start
UpdateGameplayState::
; ANCHOR_END: update-gameplay-state-start

; ANCHOR: update-gameplay-oam
	call ResetOAMSpriteAddress
; ANCHOR_END: update-gameplay-oam
	
; ANCHOR: update-gameplay-elements
	call UpdatePlayer
	call UpdateEnemies
	call UpdateBullets
	call UpdateBackground
; ANCHOR_END: update-gameplay-elements
	
; ANCHOR: update-gameplay-clear-sprites
	; Clear remaining sprites to avoid lingering rogue sprites
	call ClearRemainingSprites
; ANCHOR_END: update-gameplay-clear-sprites

; ANCHOR: update-gameplay-end-update
	ld a, [wLives]
	cp a, 250
	jp nc, EndGameplay

	ret

EndGameplay:
	
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

	ret
; ANCHOR_END: update-gameplay-end-update