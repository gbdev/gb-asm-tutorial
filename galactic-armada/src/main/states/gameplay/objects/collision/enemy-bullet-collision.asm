
; ANCHOR: enemy-bullet-collision-start
include "src/main/utils/hardware.inc"
include "src/main/utils/constants.inc"
include "src/main/utils/hardware.inc"

SECTION "EnemyBulletCollisionVariables", WRAM0

wEnemyBulletCollisionCounter: db
wBulletAddresses: dw

SECTION "EnemyBulletCollision", ROM0

; called from enemies.asm
CheckCurrentEnemyAgainstBullets::


    ld a, l
    ld [wUpdateEnemiesCurrentEnemyAddress], a
    ld a, h
    ld [wUpdateEnemiesCurrentEnemyAddress+1], a

    xor a
    ld [wEnemyBulletCollisionCounter], a
    
    ; Copy our bullets address into wBulletAddress
    ld a, LOW(wBullets)
    ld l, a
    ld a, HIGH(wBullets)
    ld h, a

    jp CheckCurrentEnemyAgainstBullets_PerBullet
; ANCHOR_END: enemy-bullet-collision-start

; ANCHOR: enemy-bullet-collision-loop
CheckCurrentEnemyAgainstBullets_Loop:

    ; increase our counter
    ld a, [wEnemyBulletCollisionCounter]
    inc a
    ld [wEnemyBulletCollisionCounter], a

    ; Stop if we've checked all bullets
    cp MAX_BULLET_COUNT
    ret nc

    ; Increase the  data our address is pointing to
    ld a, l
    add PER_BULLET_BYTES_COUNT
    ld l, a
    ld a, h
    adc 0
    ld h, a
; ANCHOR_END: enemy-bullet-collision-loop


; ANCHOR: enemy-bullet-collision-per-bullet-start
CheckCurrentEnemyAgainstBullets_PerBullet:

    ld a, [hl]
    cp 1
    jp nz, CheckCurrentEnemyAgainstBullets_Loop
; ANCHOR_END: enemy-bullet-collision-per-bullet-start

; ANCHOR: enemy-bullet-collision-per-bullet-x-overlap
CheckCurrentEnemyAgainstBullets_Check_X_Overlap:

    ; Save our first byte address
    push hl

    inc hl

    ; Get our x position
    ld a, [hli]
    add 4
    ld b, a

    push hl

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Start: Checking the absolute difference
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; The first value
    ld a, b
    ld [wObject1Value], a

    ; The second value
    ld a, [wCurrentEnemyX]
    add 8
    ld [wObject2Value], a

    ; Save if the minimum distance
    ld a, 12
    ld [wSize], a

    call CheckObjectPositionDifference

    
    ld a, [wResult]
    and a
    jp z, CheckCurrentEnemyAgainstBullets_Check_X_Overlap_Fail

    
    pop hl

    jp CheckCurrentEnemyAgainstBullets_PerBullet_Y_Overlap

CheckCurrentEnemyAgainstBullets_Check_X_Overlap_Fail:

    pop hl
    pop hl

    jp CheckCurrentEnemyAgainstBullets_Loop
; ANCHOR_END: enemy-bullet-collision-per-bullet-x-overlap

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; End: Checking the absolute difference
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; ANCHOR: enemy-bullet-collision-per-bullet-y-overlap
    
CheckCurrentEnemyAgainstBullets_PerBullet_Y_Overlap:

    ; get our bullet 16-bit y position
    ld a, [hli]
    ld b, a

    ld a, [hli]
    ld c, a

    ; Descale our 16 bit y position
    srl c
    rr b
    srl c
    rr b
    srl c
    rr b
    srl c
    rr b

    ; preserve our first byte addresss
    pop hl
    push hl

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Start: Checking the absolute difference
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; The first value
    ld a, b
    ld [wObject1Value], a

    ; The second value
    ld a, [wCurrentEnemyY]
    ld [wObject2Value], a

    ; Save if the minimum distance
    ld a, 16
    ld [wSize], a

    call CheckObjectPositionDifference

    pop hl
    
    ld a, [wResult]
    and a
    jp z, CheckCurrentEnemyAgainstBullets_Loop
    jp CheckCurrentEnemyAgainstBullets_PerBullet_Collision

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; End: Checking the absolute difference
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
; ANCHOR_END: enemy-bullet-collision-per-bullet-y-overlap


; ANCHOR: enemy-bullet-collision-per-bullet-collision
CheckCurrentEnemyAgainstBullets_PerBullet_Collision:

    ; set the active byte  and x value to 0 for bullets
    xor a
    ld [hli], a
    ld [hl], a

    ld a, [wUpdateEnemiesCurrentEnemyAddress+0]
    ld l, a
    ld a, [wUpdateEnemiesCurrentEnemyAddress+1]
    ld h, a

    ; set the active byte  and x value to 0 for enemies
    xor a
    ld [hli], a
    ld [hl], a
    
    call IncreaseScore
    call DrawScore

    ; Decrease how many active enemies their are
    ld a, [wActiveEnemyCounter]
    dec a
    ld [wActiveEnemyCounter], a

    ; Decrease how many active bullets their are
    ld a, [wActiveBulletCounter]
    dec a
    ld [wActiveBulletCounter], a

    ret
; ANCHOR_END: enemy-bullet-collision-per-bullet-collision
