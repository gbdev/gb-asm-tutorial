; ANCHOR: gameplay-data-variables
INCLUDE "src/main/includes/hardware.inc"
INCLUDE "src/main/includes/constants.inc"
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

	ld a, 3
	ld [wLives+0], a

	ld a, 0
	ld [wScore+0], a
	ld [wScore+1], a
	ld [wScore+2], a
	ld [wScore+3], a
	ld [wScore+4], a
	ld [wScore+5], a
	
	call InitializeObjectPool
	call InitializePlayer

	call WaitForVBlankStart

	; Turn the LCD off
	ld a, 0
	ld [rLCDC], a

	call ClearBackground
	call ResetShadowOAM
	call hOAMDMA
	
    call CopyPlayerTileDataIntoVRAM
    call CopyEnemyTileDataIntoVRAM
    call CopyBulletTileDataIntoVRAM

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

; ANCHOR: draw-score
    ld hl, wScore
    ld de, $9C06 ; The window tilemap starts at $9C00
	ld b, 6
	call DrawBDigitsHL_OnDE
; ANCHOR_END: draw-score
	
    ld hl, wLives
    ld de, $9C13 ; The window tilemap starts at $9C00
	ld b, 1
	call DrawBDigitsHL_OnDE

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	ld a, 0
	ld [rWY], a

	ld a, 7
	ld [rWX], a

	; Turn the LCD on
	ld a, LCDCF_ON  | LCDCF_BGON|LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_WINON | LCDCF_WIN9C00|LCDCF_BG9800
	ld [rLCDC], a
	
    ret;
; ANCHOR_END: init-gameplay-state
	
; ANCHOR: update-gameplay-state
UpdateGameplayState::

	call TryToSpawnEnemies
	call UpdateObjectPool
	call UpdateBackground 

	ld a, [wObjects+object_healthByte]
	cp a, 250
	jp z, EndGameplay

	ret
; ANCHOR_END: update-gameplay-state

; ANCHOR: end-gameplay-state
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
; ANCHOR_END: end-gameplay-state