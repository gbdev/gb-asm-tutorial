; ANCHOR: header
INCLUDE "src/main/includes/hardware.inc"
INCLUDE "src/main/includes/character-mapping.inc"

SECTION "StoryStateASM", ROM0

; ANCHOR_END: header
; ANCHOR: init-story-state
InitStoryState::

    call WaitForVBlankStart
    
	; Turn the LCD off
	ld a, 0
	ld [rLCDC], a

	call ClearBackground
	call ResetShadowOAM
    call hOAMDMA

	; Turn the LCD on
	ld a, LCDCF_ON  | LCDCF_BGON
	ld [rLCDC], a

    ret;
; ANCHOR_END: init-story-state

; ANCHOR: story-screen-data
Story: 
    .Line1 db "the galatic empire", 255
    .Line2 db "rules the galaxy", 255
    .Line3 db "with an iron", 255
    .Line4 db "fist.", 255, 255
Story2: 
    .Line1 db "the rebel force", 255
    .Line2 db "remain hopeful of", 255
    .Line3 db "freedoms light", 255, 255
	
; ANCHOR_END: story-screen-data
; ANCHOR: story-screen-page1
UpdateStoryState::

    ; Call Our function that typewrites text onto background/window tiles
    ld de, $9821
    ld hl, Story.Line1
    call MultilineTypewriteTextInHL_AtDE
; ANCHOR_END: story-screen-page1
; ANCHOR: between-pages

    call WaitForAToBePressed
    call WaitForVBlankStart

	; Turn the LCD off
	ld a, 0
	ld [rLCDC], a

    call ClearBackground

	; Turn the LCD on
	ld a, LCDCF_ON  | LCDCF_BGON
	ld [rLCDC], a
; ANCHOR_END: between-pages

; ANCHOR: story-screen-page2
    ; Call Our function that typewrites text onto background/window tiles
    ld de, $9821
    ld hl, Story2.Line1
    call MultilineTypewriteTextInHL_AtDE

; ANCHOR_END: story-screen-page2


; ANCHOR: story-screen-end
    call WaitForAToBePressed

    ld hl, InitGameplayState
    ld a, l
    ld [wNextGameState_Initiate+0], a
    ld a, h
    ld [wNextGameState_Initiate+1], a

    ld hl, UpdateGameplayState
    ld a, l
    ld [wNextGameState_Update+0], a
    ld a, h
    ld [wNextGameState_Update+1], a

    ret
; ANCHOR_END: story-screen-end