; ANCHOR: enemies-start
include "src/main/utils/hardware.inc"
include "src/main/utils/constants.inc"

SECTION "EnemyVariables", WRAM0

wCurrentEnemyX:: db  
wCurrentEnemyY:: db  

wSpawnCounter: db  
wNextEnemyXPosition: db
wActiveEnemyCounter::db
wUpdateEnemiesCounter:db
wUpdateEnemiesCurrentEnemyAddress::dw

; ANCHOR: w-enemies
; Bytes: active, x , y (low), y (high), speed, health
wEnemies:: ds MAX_ENEMY_COUNT*PER_ENEMY_BYTES_COUNT

; ANCHOR_END: w-enemies

; ANCHOR_END: enemies-start
; ANCHOR: enemies-section-header
SECTION "Enemies", ROM0
; ANCHOR_END: enemies-section-header

; ANCHOR: enemies-tile-data
enemyShipTileData:: INCBIN "src/generated/sprites/enemy-ship.2bpp"
enemyShipTileDataEnd::
; ANCHOR_END: enemies-tile-data

; ANCHOR: enemy-metasprites
enemyShipMetasprite::
    .metasprite1    db 0,0,4,0
    .metasprite2    db 0,8,6,0
    .metaspriteEnd  db 128
; ANCHOR_END: enemy-metasprites

; ANCHOR: enemies-initialize
InitializeEnemies::

	ld de, enemyShipTileData
	ld hl, ENEMY_TILES_START
	ld bc, enemyShipTileDataEnd - enemyShipTileData
    call CopyDEintoMemoryAtHL

    xor a
    ld [wSpawnCounter], a
    ld [wActiveEnemyCounter], a
    ld [wNextEnemyXPosition], a

    ld b, a

    ld hl, wEnemies

InitializeEnemies_Loop:

    ; Set as inactive
    ld [hl], 0
    
    ; Increase the address
    ld a, l
    add PER_ENEMY_BYTES_COUNT
    ld l, a
    ld a, h
    adc 0
    ld h, a

    inc b
    ld a, b

    cp MAX_ENEMY_COUNT
    ret z

    jp InitializeEnemies_Loop
; ANCHOR_END: enemies-initialize

; ANCHOR: enemies-update-start
UpdateEnemies::

	call TryToSpawnEnemies

    ; Make sure we have active enemies
    ; or we want to spawn a new enemy
    ld a, [wNextEnemyXPosition]
    ld b, a
    ld a, [wActiveEnemyCounter]
    or b
    and a
    ret z
    
    xor a
    ld [wUpdateEnemiesCounter], a

    ld a, LOW(wEnemies)
    ld l, a
    ld a, HIGH(wEnemies)
    ld h, a

    jp UpdateEnemies_PerEnemy
; ANCHOR_END: enemies-update-start
; ANCHOR: enemies-update-loop
UpdateEnemies_Loop:

    ; Check our coutner, if it's zero
    ; Stop the function
    ld a, [wUpdateEnemiesCounter]
    inc a
    ld [wUpdateEnemiesCounter], a

    ; Compare against the active count
    cp MAX_ENEMY_COUNT
    ret nc

    ; Increase the enemy data our address is pointingtwo
    ld a, l
    add PER_ENEMY_BYTES_COUNT
    ld l, a
    ld a, h
    adc 0
    ld h, a
; ANCHOR_END: enemies-update-loop


; ANCHOR: enemies-update-per-enemy
UpdateEnemies_PerEnemy:

    ; The first byte is if the current object is active
    ; If it's not zero, it's active, go to the normal update section
    ld a, [hl]
    and a
    jp nz, UpdateEnemies_PerEnemy_Update

UpdateEnemies_SpawnNewEnemy:

    ; If this enemy is NOT active
    ; Check If we want to spawn a new enemy
    ld a, [wNextEnemyXPosition]
    and a

    ; If we don't want to spawn a new enemy, we'll skip this (deactivated) enemy
    jp z, UpdateEnemies_Loop

    push hl

    ; If they are deactivated, and we want to spawn an enemy
    ; activate the enemy
    ld a, 1
    ld [hli], a

    ; Put the value for our enemies x position
    ld a, [wNextEnemyXPosition]
    ld [hli], a

    ; Put the value for our enemies y position to equal 0
    xor a
    ld [hli], a
    ld [hld], a
    ld [wNextEnemyXPosition], a

    pop hl
    
    ; Increase counter
    ld a, [wActiveEnemyCounter]
    inc a
    ld [wActiveEnemyCounter], a

; ANCHOR_END: enemies-update-per-enemy

; ANCHOR: enemies-update-per-enemy2
UpdateEnemies_PerEnemy_Update:

    ; Save our first bytye
    push hl

    ; Get our move speed in e
    ld bc, enemy_speedByte
    add hl, bc
    ld a, [hl]
    ld e, a

    ; Go back to the first byte
    ; put the address toe the first byte back on the stack for later
    pop hl
    push hl

    inc hl

    ; Get our x position
    ld a, [hli]
    ld b, a
    ld [wCurrentEnemyX], a

    ; get our 16-bit y position
    ; increase it (by e), but also save it 
    ld a, [hl]
    add 10
    ld [hli], a
    ld c, a
    ld a, [hl]
    adc 0
    ld [hl], a
    ld d, a

    pop hl

    ; Descale the y psoition
    srl d
    rr c
    srl d
    rr c
    srl d
    rr c
    srl d
    rr c

    ld a, c
    ld [wCurrentEnemyY], a

; ANCHOR_END: enemies-update-per-enemy2
    

; ANCHOR: enemies-update-check-collision
UpdateEnemies_PerEnemy_CheckPlayerCollision:

    push hl

    call CheckCurrentEnemyAgainstBullets
    call CheckEnemyPlayerCollision

    pop hl

    ld a, [wResult]
    and a
    jp z, UpdateEnemies_NoCollisionWithPlayer 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    push hl

    call DamagePlayer
    call DrawLives

    pop hl
    
    jp UpdateEnemies_DeActivateEnemy
; ANCHOR_END: enemies-update-check-collision


; ANCHOR: enemies-update-deactivate
UpdateEnemies_DeActivateEnemy:

    ; Set as inactive
    xor a
    ld [hl], a

    ; Decrease counter
    ld a, [wActiveEnemyCounter]
    dec a
    ld [wActiveEnemyCounter], a

    jp UpdateEnemies_Loop

; ANCHOR_END: enemies-update-deactivate

; ANCHOR: enemies-update-nocollision
UpdateEnemies_NoCollisionWithPlayer::

    ; See if our non scaled low byte is above 160
    ld a, [wCurrentEnemyY]
    cp 160
    jp nc, UpdateEnemies_DeActivateEnemy

    push hl


; ANCHOR: draw-enemy-metasprites

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; call the 'DrawMetasprites function. setup variables and call
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Save the address of the metasprite into the 'wMetaspriteAddress' variable
    ; Our DrawMetasprites functoin uses that variable
    ld a, LOW(enemyShipMetasprite)
    ld [wMetaspriteAddress+0], a
    ld a, HIGH(enemyShipMetasprite)
    ld [wMetaspriteAddress+1], a

    ; Save the x position
    ld a, [wCurrentEnemyX]
    ld [wMetaspriteX], a

    ; Save the y position
    ld a, [wCurrentEnemyY]
    ld [wMetaspriteY], a

    ; Actually call the 'DrawMetasprites function
    call DrawMetasprites

; ANCHOR_END: draw-enemy-metasprites

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    pop hl
    
    jp UpdateEnemies_Loop
; ANCHOR_END: enemies-update-nocollision



; ANCHOR: enemies-spawn
TryToSpawnEnemies::

    ; Increase our spwncounter
    ld a, [wSpawnCounter]
    inc a
    ld [wSpawnCounter], a

    ; Check our spawn acounter
    ; Stop if it's below a given value
    ld a, [wSpawnCounter]
    cp ENEMY_SPAWN_DELAY_MAX
    ret c

    ; Check our next enemy x position variable
    ; Stop if it's non zero
    ld a, [wNextEnemyXPosition]
    cp 0
    ret nz

    ; Make sure we don't have the max amount of enmies
    ld a, [wActiveEnemyCounter]
    cp MAX_ENEMY_COUNT
    ret nc

GetSpawnPosition:

    ; Generate a semi random value
    call rand
    
    ; make sure it's not above 150
    ld a, b
    cp 150
    ret nc

    ; make sure it's not below 24
    ld a, b
    cp 24
    ret c

    ; reset our spawn counter
    xor a
    ld [wSpawnCounter], a
    
    ld a, b
    ld [wNextEnemyXPosition], a


    ret
; ANCHOR_END: enemies-spawn
