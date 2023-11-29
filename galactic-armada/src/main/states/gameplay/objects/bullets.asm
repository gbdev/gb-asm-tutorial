
; ANCHOR: bullets-top
include "src/main/includes/hardware.inc"
include "src/main/includes/constants.inc"

SECTION "BulletVariables", WRAM0

wSpawnBullet:db

; how many bullets are currently active
wActiveBulletCounter:: db

; how many bullet's we've updated
wUpdateBulletsCounter:db 

SECTION "Bullets", ROM0


; ANCHOR_END: bullets-top



UpdateBullet::

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

    ret
; ANCHOR_END: draw-bullets
    
; ANCHOR: fire-bullets
FireNextBullet::

    ; Make sure we don't have the max amount of enmies
    ld a, [wActiveBulletCounter]
    cp a, MAX_BULLET_COUNT
    ret nc

    ; Set our spawn bullet variable to true
    ld a, 1
    ld [wSpawnBullet], a

    ret
; ANCHOR_END: fire-bullets