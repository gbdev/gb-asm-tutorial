
; ANCHOR: sprite-tile-data

playerShipTileData: INCBIN "src/generated/sprites/player-ship.2bpp"
playerShipTileDataEnd:

enemyShipTileData:: INCBIN "src/generated/sprites/enemy-ship.2bpp"
enemyShipTileDataEnd::

bulletTileData:: INCBIN "src/generated/sprites/bullet.2bpp"
bulletTileDataEnd::

; ANCHOR_END: sprite-tile-data

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


; ANCHOR: load-text-font

LoadTextFontIntoVRAM::
	; Copy the tile data
	ld de, textFontTileData ; de contains the address where data will be copied from;
	ld hl, $9000 ; hl contains the address where data will be copied to;
	ld bc, textFontTileDataEnd - textFontTileData ; bc contains how many bytes we have to copy.
	
LoadTextFontIntoVRAM_Loop: 
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, LoadTextFontIntoVRAM_Loop ; Jump to COpyTiles, if the z flag is not set. (the last operation had a non zero result)
	ret


; ANCHOR_END: load-text-font

; ANCHOR: draw-title-screen

DrawTitleScreen::

	; Copy the tile data
	ld de, titleScreenTileData ; de contains the address where data will be copied from;
	ld hl, $9340 ; hl contains the address where data will be copied to;
	ld bc, titleScreenTileDataEnd - titleScreenTileData ; bc contains how many bytes we have to copy.
	
DrawTitleScreen_Loop: 
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, DrawTitleScreen_Loop ; Jump to COpyTiles, if the z flag is not set. (the last operation had a non zero result)

	; Copy the tilemap
	ld de, titleScreenTileMap
	ld hl, $9800
	ld bc, titleScreenTileMapEnd - titleScreenTileMap

DrawTitleScreen_Tilemap:
	ld a, [de]
	add a, 52 ; add 52 to skip the text-font tiles
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, DrawTitleScreen_Tilemap

	ret

; ANCHOR_END: draw-title-screen


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


; Example call: DrawText wPressPlayText, $99C3
; Draw the 'press a to play' text at $99C3
MACRO DrawText

		; Save our original de and hl values
    push de
    push hl

		; The first parameter will be a pointer to the text
		; The second parameter will be what tile to draw at
    ld de, \2
    ld hl, \1
    call DrawTextTilesLoop

		; Recover our original values
    pop hl
    pop de

    ENDM


; ANCHOR_END: draw-text

; ANCHOR: draw-press-play


wPressPlayText::  db "press a to play", 255

InitTitleScreenState::

	...

    DrawText wPressPlayText, $99C3

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
    WaitForVBlankNTimes 3

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

    TypewriteText Story.Line1, $9821
    TypewriteText Story.Line2, $9861
    TypewriteText Story.Line3, $98A1
    TypewriteText Story.Line4, $98E1

    WaitForKey PADF_A

    call ClearBackground

    TypewriteText Story.Line5, $9821
    TypewriteText Story.Line6, $9861
    TypewriteText Story.Line7, $98A1

    WaitForKey PADF_A


; ANCHOR_END: story-state

; ANCHOR: wait-for-key

; example: WaitForKey PADF_A
; waits until A is pressed
MACRO WaitForKey

    ; Save the passed value into the variable: mWaitKey
    ; The WaitForKeyFunction always checks against this vriable
    ld a, \1
    ld [mWaitKey], a

    call WaitForKeyFunction

    ENDM

; ANCHOR_END: wait-for-key

; ANCHOR: scrolling-background

; This is called during gameplay state on every frame
ScrollBackground::

	; Increase our scaled integer by 5
	Increase16BitInteger [mBackgroundScroll+0], [mBackgroundScroll+1], 5

	; Get our true (non-scaled) value, and save it for later usage
  Get16BitIntegerNonScaledValue mBackgroundScroll, b
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

			DrawText wScoreText,$9c00

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

; ANCHOR: enemy-metasprites

enemyShipMetasprite::
    .metasprite1    db 0,0,4,0
    .metasprite2    db 0,8,6,0
    .metaspriteEnd  db 128

; ANCHOR_END: enemy-metasprites


; ANCHOR: draw-enemy-metasprites
DrawSpecificMetasprite enemyShipMetasprite, b, c
; ANCHOR_END: draw-enemy-metasprites

; ANCHOR: w-bullets

; Bytes: active, x , y (low), y (high)
wBullets:: ds MAX_BULLET_COUNT*PER_BULLET_BYTES_COUNT

; ANCHOR_END: w-bullets

; ANCHOR: bullet-offset-constants

; from https://rgbds.gbdev.io/docs/v0.6.1/rgbasm.5#EXPRESSIONS
; The RS group of commands is a handy way of defining structure offsets:
RSRESET
DEF bullet_activeByte            RB   1
DEF bullet_xByte                 RB   1
DEF bullet_yLowByte              RB   1
DEF bullet_yHighByte             RB   1
DEF PER_BULLET_BYTES_COUNT       RB   0


; ANCHOR_END: bullet-offset-constants

; ANCHOR: w-enemies

; Bytes: active, x , y (low), y (high), speed, health
wEnemies:: ds MAX_ENEMY_COUNT*PER_ENEMY_BYTES_COUNT

; ANCHOR_END: w-enemies

; ANCHOR: w-bullets

; Bytes: active, x , y (low), y (high)
wBullets:: ds MAX_BULLET_COUNT*PER_BULLET_BYTES_COUNT

; ANCHOR_END: w-bullets

; ANCHOR: update-bullets

UpdateBullets::

    ; Make sure we have SOME active enemies
    ld a, [wActiveBulletCounter]
    cp a, 0
    ret z

		; Reset our counter for how many bullets we have tried to update
    ld a, 0
    ld [wUpdateBulletsCounter], a

		; A custom macro for getting the address of the first bullet (wBullets)
		; in a dw (wUpdateBulletsCurrentBulletAddress
    CopyAddressToPointerVariable wBullets, wUpdateBulletsCurrentBulletAddress

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
    GetPointerVariableValue wUpdateBulletsCurrentBulletAddress, bullet_activeByte, b
    ld a, b
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

    Get16BitIntegerNonScaledValue wPlayerPosition.x, b
    Get16BitIntegerNonScaledValue wPlayerPosition.y, c

    DrawSpecificMetasprite playerTestMetaSprite, b, c

    ret
; ANCHOR_END: update-player

; ANCHOR: rand

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
; ANCHOR_END: rand


; ANCHOR: check-distance-and-jump
MACRO CheckDistanceAndJump

    push bc
    push de
    push hl

    ld a, \1
    ld [wObject1Value], a

    ld a, \2
    ld [wObject2Value], a

    ; Save if the minimum distance
    ld a, \3
    ld [wSize], a

    call CheckObjectPositionDifference


    pop hl
    pop de
    pop bc

    ld a, [wResult]
    cp a, 0
    jp z, \4

    ENDM
; ANCHOR_END: check-distance-and-jump

; ANCHOR: player-collision-label

    ... ; Get our enemy's x position in b, and the player's x position in d
        ; If |b-d|<=16, there is overlap on the x axis, otherwise there is no collision (and no need to check the y axis)
    ... ; Get our enemy's y position in c, and the player's x position in e
        ; If |c-e|<=16, there is collision
    
    ; Check the x distances. Jump to 'NoCollision' if their absolute difference is greater than 16
    CheckAbsoluteDifferenceAndJump b,d, 16, NoCollision

    ; Check the y distances. Jump to 'NoCollision' if their absolute difference is greater than 16
    CheckAbsoluteDifferenceAndJump c,e, 16, NoCollision

    call DamagePlayer
    call DrawLives

    pop bc
    pop de
    
    jp UpdateEnemies_DeActivateEnemy

NoCollision::

  ... Continue on normally
; ANCHOR_END: player-collision-label