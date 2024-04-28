

; ANCHOR: game-entry-point

SECTION "Header", ROM0[$100]

	jp EntryPoint

	ds $150 - @, 0 ; Make room for the header

EntryPoint:

; ANCHOR_END: game-entry-point


; ANCHOR: game-states-switch

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

; ANCHOR_END: game-states-switch





; ANCHOR: wait-for-key

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Wait for A
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Save the passed value into the variable: mWaitKey
; The WaitForKeyFunction always checks against this vriable
ld a,PADF_A
ld [mWaitKey], a

call WaitForKeyFunction

; ANCHOR_END: wait-for-key



; ANCHOR: draw-text-tiles


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


; ANCHOR_END: draw-text-tiles

; ANCHOR: draw-text

    ; Call Our function that draws text onto background/window tiles
    ld de, $9c00
    ld hl, wScoreText
    call DrawTextTilesLoop


; ANCHOR_END: draw-text

; ANCHOR: draw-press-play


wPressPlayText::  db "press a to play", 255

InitTitleScreenState::

	...
	
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Draw the press play text
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	  ; Call Our function that draws text onto background/window tiles
    ld de, $99C3
    ld hl, wPressPlayText
    call DrawTextTilesLoop

	...

    ret;



; ANCHOR_END: draw-press-play


; ANCHOR: charmap

CHARMAP " ", 0
CHARMAP ".", 24
CHARMAP "-", 25
CHARMAP "a", 26
CHARMAP "b", 27
CHARMAP "c", 28
.... d - w omitted to keeep the snippet short
CHARMAP "x", 49
CHARMAP "y", 50
CHARMAP "z", 51



; ANCHOR_END: charmap


; ANCHOR: draw-text-typewriter

DrawText_WithTypewriterEffect::

    ; Wait a small amount of time
    ... wait for 3 vblank phases

    ; Check for the end of string character 255
    ld a, [hl]
    cp 255
    ret z

    ; Write the current character (in hl) to the address
    ; on the tilemap (in de)
    ld a, [hl]
    ld [de], a

    ; move to the next character and next background tile
    inc hl
    inc de

    jp DrawText_WithTypewriterEffect


; ANCHOR_END: draw-text-typewriter

; ANCHOR: story-state
Story: 
    .Line1 db "the galatic feder-", 255
    .Line2 db "ation rules the g-", 255
    .Line3 db "alaxy with an iron", 255
    .Line4 db "fist.", 255
    .Line5 db "the rebel force r-", 255
    .Line6 db "emain hopeful of", 255
    .Line7 db "freedoms dying li-", 255
    .Line8 db "ght.", 255
	
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

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Wait for A
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Save the passed value into the variable: mWaitKey
    ; The WaitForKeyFunction always checks against this vriable
    ld a,PADF_A
    ld [mWaitKey], a

    call WaitForKeyFunction

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    call ClearBackground


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


    ; Save the passed value into the variable: mWaitKey
    ; The WaitForKeyFunction always checks against this vriable
    ld a,PADF_A
    ld [mWaitKey], a

    call WaitForKeyFunction


; ANCHOR_END: story-state



; ANCHOR: scrolling-background

; This is called during gameplay state on every frame
ScrollBackground::

	; Increase our scaled integer for the background by 5
	ld a , [mBackgroundScroll+0]
	add a , 5
	ld [mBackgroundScroll+0], a
	ld a , [mBackgroundScroll+1]
	adc a , 0
	ld [mBackgroundScroll+1], a

	; we want to Get our true (non-scaled) value, and save it for later usage
 	ld a, [mBackgroundScroll+0]
  ld b,a

  ld a, [mBackgroundScroll+1]
  ld c,a

  ; Descale our 16 bit integer
  srl c
  rr b
  srl c
  rr b
  srl c
  rr b
  srl c
  rr b

  ; Save our descaled value in a RAM variable
  ld a,b
	ld [mBackgroundScrollReal], a

	ret

; This is called during vblanks
UpdateBackgroundPosition::

	; Tell our background to use our previously saved true value
	ld a, [mBackgroundScrollReal]
	ld [rSCY], a

	ret
  
  
; ANCHOR_END: scrolling-background


; ANCHOR: turn-on-lcd

; Turn the LCD on
	ld a, LCDCF_ON  | LCDCF_BGON|LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_WINON | LCDCF_WIN9C00|LCDCF_BG9800
	ld [rLCDC], a
  
  
; ANCHOR_END: turn-on-lcd

; ANCHOR: stat-interrupt

; Define a new section and hard-code it to be at $0048.
SECTION "Stat Interrupt", ROM0[$0048]
StatInterrupt:

	push af

	; Check if we are on the first scanline
	ldh a, [rLYC]
	cp 0
	jp z, LYCEqualsZero

LYCEquals8:

	; Don't call the next stat interrupt until scanline 8
	ld a, 0
	ldh [rLYC], a

	; Turn the LCD on including sprites. But no window
	ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_WINOFF | LCDCF_WIN9C00|LCDCF_BG9800
	ldh [rLCDC], a

	jp EndStatInterrupts

LYCEqualsZero:

	; Don't call the next stat interrupt until scanline 8
	ld a, 8
	ldh [rLYC], a

	; Turn the LCD on including the window. But no sprites
	ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJOFF | LCDCF_OBJ16| LCDCF_WINON | LCDCF_WIN9C00|LCDCF_BG9800
	ldh [rLCDC], a

EndStatInterrupts:

	pop af

	reti;
  
; ANCHOR_END: stat-interrupt


; ANCHOR: init-stat-interrupt

InitStatInterrupts::

    ld a, IEF_STAT
	ldh [rIE], a
	xor a, a ; This is equivalent to `ld a, 0`!
	ldh [rIF], a
	ei

	; This makes our stat interrupts occur when the current scanline is equal to the rLYC register
	ld a, STATF_LYC
	ldh [rSTAT], a

	; We'll start with the first scanline
	; The first stat interrupt will call the next time rLY = 0
	ld a, 0
	ldh [rLYC], a

    ret
    
    
; ANCHOR_END: init-stat-interrupt

; ANCHOR: draw-score-text

wScoreText::  db "score", 255

InitGameplayState::

			...

      ; Call Our function that draws text onto background/window tiles
      ld de, $9c00
      ld hl, wScoreText
      call DrawTextTilesLoop

			...
      
      
; ANCHOR_END: draw-score-text

; ANCHOR: score-variables

SECTION "GameplayVariables", WRAM0

wScore:: ds 6

; ANCHOR_END: score-variables

; ANCHOR: increase-score

IncreaseScore::

    ; We have 6 digits, start with the right-most digit (the last byte)
    ld c, 0
    ld hl, wScore+5

IncreaseScore_Loop:

    ; Increase the digit 
    ld a, [hl]
    inc a
    ld [hl], a

    ; Stop if it hasn't gone past 0
    cp a, 9
    ret c

; If it HAS gone past 9
IncreaseScore_Next:

    ; Increase a counter so we can not go out of our scores bounds
    ld a, c
    inc a 
    ld c, a

    ; Check if we've gone our o our scores bounds
    cp a, 6
    ret z

    ; Reset the current digit to zero
    ; Then go to the previous byte (visually: to the left)
    ld a, 0
    ld [hl], a
    ld [hld], a

    jp IncreaseScore_Loop
; ANCHOR_END: increase-score

; ANCHOR: draw-score

DrawScore::

		; Our score has max 6 digits
		; We'll start with the left-most digit (visually) which is also the first byte
    ld c, 6
    ld hl, wScore
    ld de, $9C06 ; The window tilemap starts at $9C00

DrawScore_Loop:

    ld a, [hli]
    add a, 10 ; our numeric tiles start at tile 10, so add to 10 to each bytes value
    ld [de], a

		; Decrease how many numbers we have drawn
    ld a, c
    dec a
    ld c, a
		
		; Stop when we've drawn all the numbers
    ret z

		; Increase which tile we are drawing to
    inc de

    jp DrawScore_Loop
    
    

; ANCHOR_END: draw-score







; ANCHOR: update-bullets

UpdateBullets::

    ; Make sure we have SOME active enemies
    ld a, [wActiveBulletCounter]
    cp a, 0
    ret z

		; Reset our counter for how many bullets we have tried to update
    ld a, 0
    ld [wUpdateBulletsCounter], a

    ; copy wBullets,  into wUpdateBulletsCurrentBulletAddress    
    ld a, LOW(wBullets)
    ld [wUpdateBulletsCurrentBulletAddress+0], a
    ld a, HIGH(wBullets)
    ld [wUpdateBulletsCurrentBulletAddress+1], a

		; Update the first bullet
    jp UpdateBullets_PerBullet

UpdateBullets_Loop:

    ; Check our coutner, if it's zero
    ; Stop the function
    ld a, [wUpdateBulletsCounter]
    inc a
    ld [wUpdateBulletsCounter], a

    ; Check if we've already
    ld a, [wUpdateBulletsCounter]
    cp a, MAX_BULLET_COUNT
    ret nc

UpdateBullets_PerBullet:

    ; The first byte is if the bullet is active
    ; If it's zero, it's inactive, go to the loop section
    ld a, [wUpdateBulletsCurrentBulletAddress+0]
    ld l, a
    ld a, [wUpdateBulletsCurrentBulletAddress+1]
    ld h, a
    ld a, [hli]
    cp a, 0
    jp z, UpdateBullets_Loop

		... Proceed to update the bullet pointed to by 'wUpdateBulletsCurrentBulletAddress'
    
; ANCHOR_END: update-bullets


; ANCHOR: joypad-constants

;***************************************************************************
;*
;* Keypad related
;*
;***************************************************************************

DEF PADF_DOWN   EQU $80
DEF PADF_UP     EQU $40
DEF PADF_LEFT   EQU $20
DEF PADF_RIGHT  EQU $10
DEF PADF_START  EQU $08
DEF PADF_SELECT EQU $04
DEF PADF_B      EQU $02
DEF PADF_A      EQU $01

; ANCHOR_END: joypad-constants

; ANCHOR: update-player

UpdatePlayer::

UpdatePlayer_HandleInput:

	ld a, [wCurKeys]
	and a, PADF_UP
	call nz, MoveUp

	ld a, [wCurKeys]
	and a, PADF_DOWN
	call nz, MoveDown

	ld a, [wCurKeys]
	and a, PADF_LEFT
	call nz, MoveLeft

	ld a, [wCurKeys]
	and a, PADF_RIGHT
	call nz, MoveRight

	ld a, [wCurKeys]
	and a, PADF_A
	call nz, TryShoot

UpdatePlayer_UpdateSprite:

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Drawing the player metasprite
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    ; Save the address of the metasprite into the 'wMetaspriteAddress' variable
    ; Our DrawMetasprites functoin uses that variable
    ld a, LOW(playerTestMetaSprite)
    ld [wMetaspriteAddress+0], a
    ld a, HIGH(playerTestMetaSprite)
    ld [wMetaspriteAddress+1], a


    ; Save the x position
    ld a, b
    ld [wMetaspriteX],a

    ; Save the y position
    ld a, c
    ld [wMetaspriteY],a

    ; Actually call the 'DrawMetasprites function
    call DrawMetasprites;

    ret
; ANCHOR_END: update-player






; ANCHOR: player-collision-label

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Check the absolute distances. Jump to 'NoAxisOverlap' on failure
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    ld a, b
    ld [wObject1Value], a

    ld a, d
    ld [wObject2Value], a

    ; Save if the minimum distance
    ld a, 16
    ld [wSize], a

    call CheckObjectPositionDifference

    ld a, [wResult]
    cp a, 0
    jp z, NoAxisOverlap

OverlapExists:

  ... There is an overlap

NoAxisOverlap:

  ... no overlap
    

; ANCHOR_END: player-collision-label