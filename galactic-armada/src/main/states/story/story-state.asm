; ANCHOR: init-story-state
INCLUDE "src/main/includes/hardware.inc"
INCLUDE "src/main/includes/character-mapping.inc"

SECTION "StoryStateASM", ROM0

InitStoryState::

    call WaitForVBlankStart
    
	; Turn the LCD off
	ld a, 0
	ld [rLCDC], a

	call ClearBackground
	call ResetShadowOAM

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
    .Line4 db "fist.", 255
    .Line5 db "the rebel force", 255
    .Line6 db "remain hopeful of", 255
    .Line7 db "freedoms light", 255
	
; ANCHOR_END: story-screen-data
; ANCHOR: story-screen-page1
UpdateStoryState::

    ; Call Our function that typewrites text onto background/window tiles
    ld de, $9821
    ld hl, Story.Line1
    call DrawText_WithTypewriterEffect


    ; Call Our function that typewrites text onto background/window tiles
    ld de, $9861
    ld hl, Story.Line2
    call DrawText_WithTypewriterEffect


    ; Call Our function that typewrites text onto background/window tiles
    ld de, $98A1
    ld hl, Story.Line3
    call DrawText_WithTypewriterEffect


    ; Call Our function that typewrites text onto background/window tiles
    ld de, $98E1
    ld hl, Story.Line4
    call DrawText_WithTypewriterEffect

    call WaitForAToBePressed

; ANCHOR_END: story-screen-page1


    call WaitForVBlankStart

	; Turn the LCD off
	ld a, 0
	ld [rLCDC], a

    call ClearBackground

	; Turn the LCD on
	ld a, LCDCF_ON  | LCDCF_BGON
	ld [rLCDC], a



; ANCHOR: story-screen-page2
    ; Call Our function that typewrites text onto background/window tiles
    ld de, $9821
    ld hl, Story.Line5
    call DrawText_WithTypewriterEffect


    ; Call Our function that typewrites text onto background/window tiles
    ld de, $9861
    ld hl, Story.Line6
    call DrawText_WithTypewriterEffect


    ; Call Our function that typewrites text onto background/window tiles
    ld de, $98A1
    ld hl, Story.Line7
    call DrawText_WithTypewriterEffect

    call WaitForAToBePressed
    
; ANCHOR_END: story-screen-page2

; ANCHOR: story-screen-end

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