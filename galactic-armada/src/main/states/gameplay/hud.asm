INCLUDE "src/main/utils/hardware.inc"


SECTION "GameplayHUD", ROM0

; ANCHOR: hud-increase-score
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
    cp 9
    ret c

; If it HAS gone past 9
IncreaseScore_Next:

    ; Increase a counter so we can not go out of our scores bounds
    inc c
    ld a, c

    ; Check if we've gone over our scores bounds
    cp 6
    ret z

    ; Reset the current digit to zero
    ; Then go to the previous byte (visually: to the left)
    ld a, 0
    ld [hl], a
    ld [hld], a

    jp IncreaseScore_Loop
; ANCHOR_END: hud-increase-score

    
; ANCHOR: hud-draw-lives
DrawLives::

    ld hl, wLives
    ld de, $9C13 ; The window tilemap starts at $9C00

    ld a, [hl]
    add 10 ; our numeric tiles start at tile 10, so add 10 to each bytes value
    ld [de], a

    ret
; ANCHOR_END: hud-draw-lives

; ANCHOR: hud-draw-score
DrawScore::

    ; Our score has max 6 digits
    ; We'll start with the left-most digit (visually) which is also the first byte
    ld c, 6
    ld hl, wScore
    ld de, $9C06 ; The window tilemap starts at $9C00

DrawScore_Loop:

    ld a, [hli]
    add 10 ; our numeric tiles start at tile 10, so add to 10 to each bytes value
    ld [de], a

    ; Decrease how many numbers we have drawn
    dec c
		
    ; Stop when we've drawn all the numbers
    ret z

    ; Increase which tile we are drawing to
    inc de

    jp DrawScore_Loop
; ANCHOR_END: hud-draw-score
