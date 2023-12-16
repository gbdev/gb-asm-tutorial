; ANCHOR: enemies-start
include "src/main/includes/hardware.inc"
include "src/main/includes/constants.inc"

SECTION "EnemySpawningVariables",    WRAM0

wSpawnCounter: db

SECTION "EnemySpawning", ROM0
; ANCHOR_END: enemies-start

; ANCHOR: enemies-spawn1
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


    ld hl, wObjects+ENEMIES_START
    ld b, MAX_ENEMY_COUNT

    ; Get the next available enemy, and put it's address in hl
    ; if the zero flag is set, stop early
    call GetNextAvailableObject_InHL
    ret z
; ANCHOR_END: enemies-spawn1

; ANCHOR: enemies-spawn2
.GetSpawnPosition

    push hl

    ; Generate a semi random value
    call rand

    pop hl
    
    ; make sure it's not above 136
    ld a,b
    cp a, 136
    ret nc

    ; make sure it's not below 24
    ld a, b
    cp a, 24
    ret c
; ANCHOR_END: enemies-spawn2

; ANCHOR: enemies-spawn3

.SpawnEnemy

    ; reset our spawn counter
    ld a, 0
    ld [wSpawnCounter], a
    
    ; Set as active
   ld a, 1
    ld [hli], a

    ; y position = 0
    ld a, 0
    ld [hli], a
    ld [hli], a
    
    ; x high byte  = 0
    ; b will become our x low byte (originally set from 'rand')
    ld a, 0

    REPT 4
    sla b
    rl a

    ENDR
    ; got to the high byte
    inc hl

    ; set our high byte from a
    ; go back to the low byte
    ld [hld], a

    ; set the low byte from b
    ld a, b
    ld [hli], a

    inc hl

    ; set our metasprite
    ld a, LOW(enemyShipMetasprite)
    ld [hli], a
    ld a, HIGH(enemyShipMetasprite)
    ld [hli], a

    ; set our health
    ld a, 1
    ld [hli], a

    ld a, LOW(UpdateEnemy)
    ld [hli], a
    ld a, HIGH(UpdateEnemy)
    ld [hli], a

    ; set our damage
    ld a, 0
    ld [hli], a

    ret
; ANCHOR_END: enemies-spawn3