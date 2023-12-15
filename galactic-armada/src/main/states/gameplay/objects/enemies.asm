; ANCHOR: enemies-start
include "src/main/includes/hardware.inc"
include "src/main/includes/constants.inc"

SECTION "Enemies", ROM0
; ANCHOR_END: enemies-start

; ANCHOR: enemies-update
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

    ; restore our original hl 
    pop hl
    
    cp a, 10
    jp nc, DeactivateEnemy

    push hl

    ; Check for collision for current enemy
    ; if a=1, we deactivate
    ; if a=2, we have shot the enemy
    ; otherwise, do nothing
    call CheckCollisionForCurrentEnemy
    
    pop hl

    cp a, ENEMY_COLLISION_END
    jp z, DeactivateEnemy
    cp a, ENEMY_COLLISION_DAMAGED
    jp z, DamageEnemy
    ret
; ANCHOR_END: enemies-update

; ANCHOR: enemies-damage
DamageEnemy:

    push hl
    ; Decrease the enemies health byte
    push de
    ld de, object_healthByte
    add hl, de
    ld a, [hl]
    dec a
    ld [hl], a

    pop de
    pop hl

    ; if the health byte is zero, kill the enemy
    and a  
    jp z, KillEnemy


    ; Move to the damage byte
    push de
    ld de, object_healthByte
    add hl, de
    pop de

    ; Set as damaged for 128 frames
    ld a, 128
    ld [hl], a

    ; Move to the next
    ret
; ANCHOR_END: enemies-damage

; ANCHOR: enemies-kill
KillEnemy::

    push hl
    push bc
    
    call IncreaseScore;

    ld hl, wScore
    ld de, $9C06 ; The window tilemap starts at $9C00
	ld b, 6
	call DrawBDigitsHL_OnDE

    pop bc
    pop hl

    ld a,0
    ld [hl], a

    ret
; ANCHOR_END: enemies-kill
    
; ANCHOR: enemies-deactivate
DeactivateEnemy::

    ld a,0
    ld [hl], a

    ret

; ANCHOR_END: enemies-deactivate