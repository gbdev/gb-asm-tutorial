; ANCHOR: player-start
include "src/main/includes/hardware.inc"
include "src/main/includes/constants.inc"

SECTION "Player", ROM0

; ANCHOR_END: player-start
; ANCHOR: player-initialize
InitializePlayer::

    ld hl, wObjects

    ; Set the active byte
    ld a,1
    ld [hli], a

    ; Set the y position  
    ld a,0
    ld [hli], a
    ld a, 5
    ld [hli], a

    ; Set the x position
    ld a, 0
    ld [hli], a
    ld a, 5
    ld [hli], a

    ; Set the metasprite
    ld a, LOW(playerTestMetaSprite)
    ld [hli], a
    ld a, HIGH(playerTestMetaSprite)
    ld [hli], a

    ; Set the health
    ld a, 3
    ld [hli], a

    ; Set the update
    ld a, LOW(UpdatePlayer)
    ld [hli], a
    ld a, HIGH(UpdatePlayer)
    ld [hli], a
    ret
    
; ANCHOR_END: player-initialize

; ANCHOR: player-update-start
UpdatePlayer::

	ld a, [wCurKeys]
	and a, PADF_UP
	call nz, MoveUp

	ld a, [wCurKeys]
	and a, PADF_DOWN
	call nz, MoveDown

	ld a, [wCurKeys]
	and a, PADF_LEFT
	call nz, MoveLeft

	ld a, [wCurKeys]
	and a, PADF_RIGHT
	call nz, MoveRight

	ld a, [wNewKeys]
	and a, PADF_A
	call nz, FireNextBullet

    ret
; ANCHOR_END: player-update-start
    
; ANCHOR: player-damage
DamagePlayer::

    ld a, [wObjects+object_healthByte]
    dec a
    ld [wObjects+object_healthByte], a

    ld a, 128
    ld [wObjects+object_damageByte], a

    ret
; ANCHOR_END: player-damage

; ANCHOR: player-movement
MoveUp:

    ld hl, wObjects+object_yLowByte
    ld a, [hl]
    sub a, PLAYER_MOVE_SPEED
    ld [hli], a
    ld a, [hl]
    sbc a, 0
    ld [hl], a

    ret

MoveDown:

    ld hl, wObjects+object_yLowByte
    ld a, [hl]
    add a, PLAYER_MOVE_SPEED
    ld [hli], a
    ld a, [hl]
    adc a, 0
    ld [hl], a

    ret

MoveLeft:

    ld hl, wObjects+object_xLowByte
    ld a, [hl]
    sub a, PLAYER_MOVE_SPEED
    ld [hli], a
    ld a, [hl]
    sbc a, 0
    ld [hl], a

    ret

MoveRight:

    ld hl, wObjects+object_xLowByte
    ld a, [hl]
    add a, PLAYER_MOVE_SPEED
    ld [hli], a
    ld a, [hl]
    adc a, 0
    ld [hl], a

    ret
; ANCHOR_END: player-movement


