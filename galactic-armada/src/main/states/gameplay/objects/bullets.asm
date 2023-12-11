
; ANCHOR: bullets-top
include "src/main/includes/hardware.inc"
include "src/main/includes/constants.inc"

SECTION "Bullets", ROM0


; ANCHOR_END: bullets-top

UpdateBullet::

    ; The start of our object will be in bc
    ; Copy that to hl so we can check/adjust some bytes
    ld h,b
    ld l, c

    ; Get to our y position
    ld de, object_yLowByte
    add hl, de

    ; subtract our speed from our y position
    ld a, [hl]
    sub a, BULLET_MOVE_SPEED
    ld [hli], a
    ld a, [hl] 
    sbc a, 0
    ld [hl], a

    ; If our high byte is below 10, we're not offscreen
    ld a, [hl]
    cp a, 10
    ret c

UpdateBullet_OutOfScreen:

    ; get the start of our object back in hl
    ld h,b
    ld l, c

    ; Set the first (active) byte as 0 (inactive)
    ld a, 0
    ld [hl], a

    ret
; ANCHOR_END: draw-bullets
    
; ANCHOR: fire-bullets
FireNextBullet::

    ld hl, wObjects+BULLETS_START
    ld b, MAX_BULLET_COUNT

    ; Get the next available bullet, and put it's address in hl
    ; if the zero flag is set, stop early
    call GetNextAvailableObject_InHL
    ret z
; ANCHOR_END: fire-bullets

; ANCHOR: fire-bullets2
    ld a, 1
    ld [hli], a

    ld a, [wObjects+object_yLowByte]
    ld [hli], a
    ld a, [wObjects+object_yHighByte]
    ld [hli], a
    ld a, [wObjects+object_xLowByte]
    ld [hli], a
    ld a, [wObjects+object_xHighByte]
    ld [hli], a

    ld a, LOW(bulletMetasprite)
    ld [hli], a

    ld a, HIGH(bulletMetasprite)
    ld [hli], a

    ld a, 1
    ld [hli], a

    ld a, LOW(UpdateBullet)
    ld [hli], a
    ld a, HIGH(UpdateBullet)
    ld [hli], a


    ret
; ANCHOR_END: fire-bullets2
