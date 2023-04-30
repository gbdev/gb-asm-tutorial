include "src/main/utils/hardware.inc"
include "src/main/utils/constants.inc"

SECTION "EnemyVariables", WRAM0

wSpawnCounter: db
wNextEnemy:
    .x db
    .y dw
    .speed db
    .health db
wActiveEnemyCounter::db
wUpdateEnemiesCounter:db
wUpdateEnemiesCurrentEnemyAddress::dw

; Bytes: active, x , y (low), y (high), speed, health
wEnemies:: ds MAX_ENEMY_COUNT*PER_ENEMY_BYTES_COUNT

SECTION "Enemies", ROM0

enemyShipTileData:: INCBIN "src/generated/sprites/enemy-ship.2bpp"
enemyShipTileDataEnd::

enemyShipMetasprite::
    .metasprite1    db 0,0,4,0
    .metasprite2    db 0,8,6,0
    .metaspriteEnd  db 128

InitializeEnemies::


CopyHappyFace:

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

UpdateEnemies::

	call TryToSpawnEnemies

    ; Make sure we don't have the max amount of enmies
    ld a, [wActiveEnemyCounter]
    cp a, 0
    ret z
    
    ld a, 0
    ld [wUpdateEnemiesCounter], a

    ld a, LOW(wEnemies)
    ld [wUpdateEnemiesCurrentEnemyAddress+0], a
    ld a, HIGH(wEnemies)
    ld [wUpdateEnemiesCurrentEnemyAddress+1], a

    jp UpdateEnemies_Loop

UpdateEnemies_NextEnemy:

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
    ld a, [wUpdateEnemiesCurrentEnemyAddress+0]
    add a, PER_ENEMY_BYTES_COUNT
    ld  [wUpdateEnemiesCurrentEnemyAddress+0], a
    ld a, [wUpdateEnemiesCurrentEnemyAddress+1]
    adc a, 0
    ld  [wUpdateEnemiesCurrentEnemyAddress+1], a


UpdateEnemies_Loop:

    ; The first byte is if the current object is active
    ; If it's zero, it's inactive, go to the loop section
    ld a, [wUpdateEnemiesCurrentEnemyAddress+0]
    ld l, a
    ld a, [wUpdateEnemiesCurrentEnemyAddress+1]
    ld h, a
    ld a, [hli]
    cp 0
    jp z, UpdateEnemies_NextEnemy

    ; Get our x position
    ld a, [hli]
    ld b, a

    ; get our 16-bit y position
    ld a, [hli]
    ld c, a
    ld a, [hli]
    ld d, a

    ; Descale the y psoition
    srl d
    rr c
    srl d
    rr c
    srl d
    rr c
    srl d
    rr c

UpdateEnemies_Loop_PlayerCollision:


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
    push hl
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

    call DamagePlayer
    call DrawLives

    pop de
    pop bc
    pop hl
    
    jp UpdateEnemies_DeActivateEnemy

NoCollisionWithPlayer::

    pop de
    pop bc
    pop hl

    ; Get our move speed
    ld a, [hld]
    ld e, a

    dec hl
    
    ; Get/Set and increase our y low byte
    ld a, [hl]
    add a, e
    ld [hli], a
    ld c, a

    ; Get/Set our add remainder for y high byte 
    ld a, [hl]
    adc a, 0
    ld [hl], a
    ld d, a

    ; Descale our y 
    srl d
    rr c
    srl d
    rr c
    srl d
    rr c
    srl d
    rr c

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
    
    ; check for collisions against bulelts
    call CheckCurrentEnemyAgainstBullets
    
    ; If it above 160, update the next enemy
    ; If it below 160, continue on  to deactivate
    jp UpdateEnemies_NextEnemy

UpdateEnemies_DeActivateEnemy:

    ; we should be at our speed byte
    ; decrease four to get to our y low byte
    dec hl
    dec hl
    dec hl
    dec hl

    ; Set as inactive
    ld a, 0
    ld [hli], a
    ld [hli], a

    ; Decrease counter
    ld a,[wActiveEnemyCounter]
    dec a
    ld [wActiveEnemyCounter], a

    jp UpdateEnemies_NextEnemy
    
SpawnNextEnemy:

    ; Make sure we don't have the max amount of enmies
    ld a, [wActiveEnemyCounter]
    cp a, MAX_ENEMY_COUNT
    ret nc

    push bc
    push de
    push hl

    ld b, 0

    ld hl, wEnemies

    jp SpawnNextEnemy_Loop


SpawnNextEnemy_NextEnemy:

    ; Increase the address
    ld a, l
    add a, PER_ENEMY_BYTES_COUNT
    ld l, a
    ld a, h
    adc a, 0
    ld h, a

    ld a, b
    cp a, MAX_ENEMY_COUNT
    jp nc,SpawnNextEnemy_End

    inc a
    ld b ,a

SpawnNextEnemy_Loop:

    ld a, [hl]

    cp a, 0
    jp nz, SpawnNextEnemy_NextEnemy

    ; Set as  active
    ld a, 1
    ld [hli], a

    ; Set the x position
    ld a, [wNextEnemy.x]
    ld [hli], a

    ; Set the y position (low)
    ld a, [wNextEnemy.y+0]
    ld [hli], a

    ;Set the y position (high)
    ld a, [wNextEnemy.y+1]
    ld [hli], a

    ;Set the speed
    ld a, [wNextEnemy.speed]
    ld [hli], a

    ;Set the health
    ld a, [wNextEnemy.health]
    ld [hli], a

    ; Increase counter
    ld a,[wActiveEnemyCounter]
    inc a
    ld [wActiveEnemyCounter], a

    jp SpawnNextEnemy_End


SpawnNextEnemy_End:


    pop hl
    pop de
    pop bc

    ret



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
    ld [wNextEnemy.x], a
    
    ld a, 0
    ld [wNextEnemy.y+0], a
    ld [wNextEnemy.y+1], a

    ld a, ENEMY_MOVE_SPEED
    ld [wNextEnemy.speed], a

    ld a, 1
    ld [wNextEnemy.health], a

    call SpawnNextEnemy

    ret