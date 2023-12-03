; ANCHOR: enemies-start
include "src/main/includes/hardware.inc"
include "src/main/includes/constants.inc"

SECTION "EnemyVariables", WRAM0

wCurrentEnemyX:: db  
wCurrentEnemyY:: db  

wSpawnCounter: db  
wNextEnemyXPosition: db
wActiveEnemyCounter::db
wUpdateEnemiesCounter:db
wUpdateEnemiesCurrentEnemyAddress::dw

; ANCHOR_END: enemies-start
SECTION "Enemies", ROM0

; ANCHOR: enemies-update-per-enemy2
UpdateEnemy::

    ; get the start of our object back in hl
    ld h,b
    ld l, c

    ; Save our first bytye
    push hl

    ; Get our y position
    ld bc, object_yLowByte
    add hl, bc

    ; add 10 to our y position
    ld a, [hl]
    add a, 10
    ld [hli], a
    ld a, [hl]
    adc a, 0
    ld [hl], a

    
    ; If our high byte is below 10, we're not offscreen
    ld a, [hl]
    pop hl

    cp a, 10
    jp nc, DeactivateEnemy

    ret


.UpdateEnemy_CheckPlayerCollision

    push hl


    ld a, 16
    ld [wSizeX], a
    ld [wSizeY], a
    ld de, wObjects
    call CheckCollisionWithObjectsInHL_andDE

    pop hl
    jp nz, DeactivateEnemy

.UpdateEnemy_CheckAllBulletCollision

    ld b,MAX_BULLET_COUNT
    ld de, wObjects+MAX_ENEMY_COUNT+1

UpdateEnemy_CheckBulletCollision:

    ; Save the start of our enemy's bytes
    ; Save the current bullet counter
    ; Save which bullet we are looking at
    push hl
    push bc
    push de

    ld a, 16
    ld [wSizeX], a
    ld [wSizeY], a
    call CheckCollisionWithObjectsInHL_andDE
    call nz, DeactivateEnemy

    ; Retrieve the curernt bullet counter
    ; Return hl to the start of our enemies bytes
    ; Retrieve which object we were looking at
    pop de
    pop bc
    pop hl

    ; If `CheckCollisionWithObjectsInHL_andDE` returned non zero, deactivate this enemy
    jp nz, DeactivateEnemy

    ; Decrease b
    ; return if it reaches zero
    ld a, b
    dec a
    ld b, a
    and a
    ret z

    ; Move to the next object
    ld a, e
    add a, PER_OBJECT_BYTES_COUNT
    ld e, a

    jp UpdateEnemy_CheckBulletCollision

KillEnemy::

    
    call IncreaseScore;
    call DrawScore
    
DeactivateEnemy::

    ld a,0
    ld [hl], a

ret