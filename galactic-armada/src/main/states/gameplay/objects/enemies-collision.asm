; ANCHOR: enemies-collision-start

include "src/main/includes/constants.inc"
SECTION "EnemiesCollision", ROM0

CheckCollisionForCurrentEnemy::

; ANCHOR_END: enemies-collision-start
; ANCHOR: enemies-collision-player
    push hl

    ld a, 16
    ld [wSizeX], a
    ld [wSizeY], a
    ld de, wObjects
    call CheckCollisionWithObjectsInHL_andDE

    pop hl
    
    jp nz, EnemyPlayerCollision
    jp UpdateEnemy_CheckAllBulletCollision
; ANCHOR_END: enemies-collision-player

; ANCHOR: enemies-collision-player2
EnemyPlayerCollision:

    push hl
    push bc

    call DamagePlayer
	
    ld hl, wLives
    ld de, $9C13 ; The window tilemap starts at $9C00
	ld b, 1
	call DrawBDigitsHL_OnDE

    pop bc
    pop hl

    ; Set a to be 1
    ld a, ENEMY_COLLISION_END
    ret
; ANCHOR_END: enemies-collision-player2


; ANCHOR: enemies-collision-bullets1
UpdateEnemy_CheckAllBulletCollision:

    ld b,MAX_BULLET_COUNT
    ld de, wObjects+BULLETS_START
; ANCHOR_END: enemies-collision-bullets1

; ANCHOR: enemies-collision-bullets2
UpdateEnemy_CheckBulletCollision:

    ; Save the start of our enemy's bytes
    ; Save the current bullet counter
    ; Save which bullet we are looking at
    push hl
    push bc
    push de

    ld a, 12
    ld [wSizeX], a
    ld a, 16
    ld [wSizeY], a
    call CheckCollisionWithObjectsInHL_andDE

    ; Retrieve the curernt bullet counter
    ; Return hl to the start of our enemies bytes
    ; Retrieve which object we were looking at
    pop de
    pop bc
    pop hl

    jp z, MoveToNextBullet
    jp EnemyBulletCollision
; ANCHOR_END: enemies-collision-bullets2

; ANCHOR: enemies-collision-bullets3
MoveToNextBullet:

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
; ANCHOR_END: enemies-collision-bullets3

; ANCHOR: enemies-collision-bullet4
EnemyBulletCollision:

    push hl

    ; Copy de to hl
    ld h, d
    ld l, e

    ; Set the bullet as inactive
    ld a, 0
    ld [hl], a

    ; Go back to the enemy bytes
    pop hl

    ld a, ENEMY_COLLISION_DAMAGED

    ret
; ANCHOR_END: enemies-collision-bullet4