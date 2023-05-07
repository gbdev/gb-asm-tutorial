
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
    ld [wUpdateEnemiesCurrentEnemyAddress+0], a
    ld a, h
    ld [wUpdateEnemiesCurrentEnemyAddress+1], a

    ld a, 0
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
    cp a, MAX_BULLET_COUNT
    ret nc

    ; Increase the  data our address is pointing to
    ld a, l
    add a, PER_BULLET_BYTES_COUNT
    ld  l, a
    ld a, h
    adc a, 0
    ld  h, a
; ANCHOR_END: enemy-bullet-collision-loop


; ANCHOR: enemy-bullet-collision-per-bullet-start
CheckCurrentEnemyAgainstBullets_PerBullet:

    ld a, [hli]
    cp a, 1
    jp nz, CheckCurrentEnemyAgainstBullets_Loop
; ANCHOR_END: enemy-bullet-collision-per-bullet-start

; ANCHOR: enemy-bullet-collision-per-bullet-x-overlap
CheckCurrentEnemyAgainstBullets_Check_X_Overlap:

    ; Get our x position
    ; b = bullet
    ; c = enemy address
    ld a, [hli]
    ld b, a

    ;preserve hl for bullets
    ; while we get our enemies 
    push hl
    
    ld a, [wUpdateEnemiesCurrentEnemyAddress+0]
    ld l, a
    ld a, [wUpdateEnemiesCurrentEnemyAddress+1]
    ld h, a

    ; Move to the x value
    inc hl

    ld a, [hl]
    ld e, a

    ; restore our hl for bullets
    pop hl

    ; Add a 4 pixel offset to the bullet posiition
    ld a, b
    add a, 4
    ld b ,a

    ; Add 8 pixel offset to the enemy position
    ld a, e
    add a, 8
    ld e ,a

    push hl

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Start: Checking the absolute difference
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; The first value
    ld a, b
    ld [wObject1Value], a

    ; The second value
    ld a, e
    ld [wObject2Value], a

    ; Save if the minimum distance
    ld a, 12
    ld [wSize], a

    call CheckObjectPositionDifference
    
    ld a, [wResult]
    cp a, 0
    jp z, CheckCurrentEnemyAgainstBullets_JumpToNextLoop

    
; ANCHOR_END: enemy-bullet-collision-per-bullet-x-overlap

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; End: Checking the absolute difference
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; ANCHOR: enemy-bullet-collision-per-bullet-y-overlap
    pop hl
    
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

    push hl

    ld a, [wUpdateEnemiesCurrentEnemyAddress+0]
    ld l, a
    ld a, [wUpdateEnemiesCurrentEnemyAddress+1]
    ld h, a

    inc hl
    inc hl

    ; get our enemy 16-bit y position
    ld a, [hli]
    ld e, a

    ld a, [hl]
    ld d, a

    pop hl

    ; Descale our enemy 16 bit y position
    srl d
    rr e
    srl d
    rr e
    srl d
    rr e
    srl d
    rr e

    ; preserve our bullet pointer
    push hl

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Start: Checking the absolute difference
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; The first value
    ld a, b
    ld [wObject1Value], a

    ; The second value
    ld a, e
    ld [wObject2Value], a

    ; Save if the minimum distance
    ld a, 16
    ld [wSize], a

    call CheckObjectPositionDifference

    pop hl
    
    ld a, [wResult]
    cp a, 0
    jp z, CheckCurrentEnemyAgainstBullets_Loop
    jp CheckCurrentEnemyAgainstBullets_PerBullet_Collision

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; End: Checking the absolute difference
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
; ANCHOR_END: enemy-bullet-collision-per-bullet-y-overlap


; ANCHOR: enemy-bullet-collision-per-bullet-collision
CheckCurrentEnemyAgainstBullets_PerBullet_Collision:

    
    ld a, [wBulletAddresses+0]
    ld l, a
    ld a, [wBulletAddresses+1]
    ld h, a

    ; set the active byte  and x value to 0 for bullets
    ld a, 0
    ld [hli], a
    ld [hl], a

    ld a, [wUpdateEnemiesCurrentEnemyAddress+0]
    ld l, a
    ld a, [wUpdateEnemiesCurrentEnemyAddress+1]
    ld h, a

    ; set the active byte  and x value to 0 for enemies
    ld a, 0
    ld [hli], a
    ld [hl], a
    
    call IncreaseScore;
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