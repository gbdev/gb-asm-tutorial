; ANCHOR: enemies-start
include "src/main/utils/hardware.inc"
include "src/main/utils/constants.inc"

SECTION "EnemiesPlayerCollision", ROM0

; ANCHOR: get-player-x
CheckEnemyPlayerCollision::

    ; Get our player's unscaled x position in d
    ld a, [wPlayerPositionX]
    ld d, a

    ld a, [wPlayerPositionX+1]
    ld e, a

    srl e
    rr d
    srl e
    rr d
    srl e
    rr d
    srl e
    rr d
    
; ANCHOR_END: get-player-x

; ANCHOR: check-x-overlap

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Check the x distances. Jump to 'NoCollisionWithPlayer' on failure
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ld a, [wCurrentEnemyX]
    ld [wObject1Value], a

    ld a, d
    ld [wObject2Value], a

    ; Save if the minimum distance
    ld a, 16
    ld [wSize], a

    call CheckObjectPositionDifference

    ld a, [wResult]
    and a
    jp z, NoCollisionWithPlayer
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    
; ANCHOR_END: check-x-overlap

; ANCHOR: get-y
    ; Get our player's unscaled y position in d
    ld a, [wPlayerPositionY+0]
    ld d, a

    ld a, [wPlayerPositionY+1]
    ld e, a

    srl e
    rr d
    srl e
    rr d
    srl e
    rr d
    srl e
    rr d

; ANCHOR_END: get-y


; ANCHOR: check-y-overlap

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Check the y distances. Jump to 'NoCollisionWithPlayer' on failure
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    ld a, [wCurrentEnemyY]
    ld [wObject1Value], a

    ld a, d
    ld [wObject2Value], a

    ; Save if the minimum distance
    ld a, 16
    ld [wSize], a

    call CheckObjectPositionDifference

    ld a, [wResult]
    and a
    jp z, NoCollisionWithPlayer
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; ANCHOR_END: check-y-overlap

; ANCHOR: result

    ld a, 1
    ld [wResult], a

    ret
    
NoCollisionWithPlayer::

    xor a
    ld [wResult], a

    ret

; ANCHOR_END: result
