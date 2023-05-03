; ANCHOR: enemies-start
include "src/main/utils/hardware.inc"
include "src/main/utils/constants.inc"

SECTION "EnemyVariables", WRAM0

wSpawnCounter: db  
wNextEnemyXPosition: db
wActiveEnemyCounter::db
wUpdateEnemiesCounter:db
wUpdateEnemiesCurrentEnemyAddress::dw

; Bytes: active, x , y (low), y (high), speed, health
wEnemies:: ds MAX_ENEMY_COUNT*PER_ENEMY_BYTES_COUNT

; ANCHOR_END: enemies-start
; ANCHOR: enemies-tile-metasprite
SECTION "Enemies", ROM0

enemyShipTileData:: INCBIN "src/generated/sprites/enemy-ship.2bpp"
enemyShipTileDataEnd::

enemyShipMetasprite::
    .metasprite1    db 0,0,4,0
    .metasprite2    db 0,8,6,0
    .metaspriteEnd  db 128
; ANCHOR_END: enemies-tile-metasprite

; ANCHOR: enemies-initialize
InitializeEnemies::

	ld de, enemyShipTileData
	ld hl, ENEMY_TILES_START
	ld bc, enemyShipTileDataEnd - enemyShipTileData
    call CopyDEintoMemoryAtHL

    ld a, 0
    ld [wSpawnCounter], a

    ld a,0
    ld [wActiveEnemyCounter], a

    ld b, 0

    ld hl, wEnemies

InitializeEnemies_Loop:

    ; Set as inactive
    ld a, 0
    ld [hl], a
    
    ; Increase the address
    ld a, l
    add a, PER_ENEMY_BYTES_COUNT
    ld l, a
    ld a, h
    adc a, 0
    ld h, a

    ld a, b
    inc a
    ld b ,a

    cp a, MAX_ENEMY_COUNT
    ret z

    jp InitializeEnemies_Loop
; ANCHOR_END: enemies-initialize

; ANCHOR: enemies-update-start
UpdateEnemies::

	call TryToSpawnEnemies

    ; Make sure we don't have the max amount of enmies
    ld a, [wActiveEnemyCounter]
    cp a, 0
    ret z
    
    ld a, 0
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
    ld a, [wUpdateEnemiesCounter]
    cp a, MAX_ENEMY_COUNT
    ret nc

    ; Increase the enemy data our address is pointingtwo
    ld a, l
    add a, PER_ENEMY_BYTES_COUNT
    ld  l, a
    ld a, h
    adc a, 0
    ld  h, a
; ANCHOR_END: enemies-update-loop


; ANCHOR: enemies-update-per-enemy
UpdateEnemies_PerEnemy:

    ; The first byte is if the current object is active
    ; If it's not zero, it's active, go to the normal update section
    ld a, [hl]
    cp 0
    jp nz, UpdateEnemies_PerEnemy_Update

UpdateEnemies_SpawnNewEnemy:

    ; If this enemy is NOT active
    ; Check If we want to spawn a new enemy
    ld a, [wNextEnemyXPosition]
    cp 0

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
    ld a, 0
    ld [hli], a
    ld [hld], a

    pop hl

    
    ; Increase counter
    ld a,[wActiveEnemyCounter]
    inc a
    ld [wActiveEnemyCounter], a

; ANCHOR_END: enemies-update-per-enemy

; ANCHOR: enemies-update-per-enemy2
UpdateEnemies_PerEnemy_Update:

    ; Save our first bytye
    push hl

    ; Get our move speed in e
    ld bc, 4
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
    
    ; get our 16-bit y position
    ; increase it (by e), but also save it 
    ld a, [hl]
    add a, e
    ld [hli], a
    ld c, a
    ld a, [hl]
    adc a, 0
    ld [hl], a
    ld d, a

    pop hl
    push hl

    ; Descale the y psoition
    srl d
    rr c
    srl d
    rr c
    srl d
    rr c
    srl d
    rr c
; ANCHOR_END: enemies-update-per-enemy2
    

; ANCHOR: enemies-update-collision
UpdateEnemies_PerEnemy_PlayerCollision:


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
    jp z, UpdateEnemies_NoCollisionWithPlayer
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
    jp z, UpdateEnemies_NoCollisionWithPlayer
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    call DamagePlayer
    call DrawLives

    pop de
    pop bc
    pop hl
    
    jp UpdateEnemies_DeActivateEnemy
; ANCHOR_END: enemies-update-collision


; ANCHOR: enemies-update-deactivate
UpdateEnemies_DeActivateEnemy:

    ; Set as inactive
    ld a, 0
    ld [hl], a

    ; Decrease counter
    ld a,[wActiveEnemyCounter]
    dec a
    ld [wActiveEnemyCounter], a

    jp UpdateEnemies_Loop

; ANCHOR_END: enemies-update-deactivate

; ANCHOR: enemies-update-nocollision
UpdateEnemies_NoCollisionWithPlayer::

    pop de
    pop bc
    pop hl

    ; See if our non scaled low byte is above 160
    ld a, c
    cp a, 160
    jp nc, UpdateEnemies_DeActivateEnemy

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
    ld a, b
    ld [wMetaspriteX],a

    ; Save the y position
    ld a, c
    ld [wMetaspriteY],a

    ; Actually call the 'DrawMetasprites function
    call DrawMetasprites;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ; check for collisions against bullets
    ld a, LOW(wEnemies)
    ld [wUpdateEnemiesCurrentEnemyAddress+0], a
    ld a, HIGH(wEnemies)
    ld [wUpdateEnemiesCurrentEnemyAddress+1], a
    
    ; If it above 160, update the next enemy
    ; If it below 160, continue on  to deactivate
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
    cp a, ENEMY_SPAWN_DELAY_MAX
    ret c

    ; Check our next enemy x position variable
    ; Stop if it's non zero
    ld a, [wNextEnemyXPosition]
    cp a, 0
    ret nz

    ; Make sure we don't have the max amount of enmies
    ld a, [wActiveEnemyCounter]
    cp a, MAX_ENEMY_COUNT
    ret nc

GetSpawnPosition:

    ; Generate a semi random value
    call rand
    
    ; make sure it's not above 150
    ld a,b
    cp a, 150
    ret nc

    ; make sure it's not below 24
    ld a, b
    cp a, 24
    ret c

    ; reset our spawn counter
    ld a, 0
    ld [wSpawnCounter], a
    
    ld a, b
    ld [wNextEnemyXPosition], a


    ret
; ANCHOR_END: enemies-spawn