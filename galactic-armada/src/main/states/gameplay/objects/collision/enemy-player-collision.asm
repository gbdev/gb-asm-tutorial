; ANCHOR: enemies-start
include "src/main/utils/hardware.inc"
include "src/main/utils/constants.inc"

SECTION "EnemiesPlayerCollision", ROM0

; ANCHOR: enemies-update-check-collision
CheckEnemyPlayerCollision:

    ; Get our player's unscaled x position in d
    ld a, [wPlayerPositionX+0]
    ld d,a

    ld a, [wPlayerPositionX+1]
    ld e,a

    srl e
    rr d
    srl e
    rr d
    srl e
    rr d
    srl e
    rr d

    ; We want to use b real quick
    ; push onto the stack so we can descale the y position
    push bc
    
    ; Get our player's unscaled y position in e
    ld a, [wPlayerPositionY+0]
    ld e,a

    ld a, [wPlayerPositionY+1]
    ld b,a

    srl b
    rr e
    srl b
    rr e
    srl b
    rr e
    srl b
    rr e

    pop bc
    push bc
    push de

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Check the x distances. Jump to 'NoCollisionWithPlayer' on failure
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    ld a, b
    ld [wObject1Value], a

    ld a, d
    ld [wObject2Value], a

    ; Save if the minimum distance
    ld a, 16
    ld [wSize], a

    call CheckObjectPositionDifference

    pop de
    pop bc
    push bc
    push de

    ld a, [wResult]
    cp a, 0
    jp z, NoCollisionWithPlayer
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Check the y distances. Jump to 'NoCollisionWithPlayer' on failure
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    ld a, c
    ld [wObject1Value], a

    ld a, e
    ld [wObject2Value], a

    ; Save if the minimum distance
    ld a, 16
    ld [wSize], a

    call CheckObjectPositionDifference

    ld a, [wResult]
    cp a, 0
    jp z, NoCollisionWithPlayer
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    pop de
    pop bc

    ld a, 1
    ld [wResult], a

    ret
    
NoCollisionWithPlayer::

    pop de
    pop bc

    ld a, 0
    ld [wResult], a

    ret

; ANCHOR_END: enemies-update-check-collision