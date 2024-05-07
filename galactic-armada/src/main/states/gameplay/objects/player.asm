; ANCHOR: player-start
include "src/main/utils/hardware.inc"
include "src/main/utils/hardware.inc"
include "src/main/utils/constants.inc"

SECTION "PlayerVariables", WRAM0

; first byte is low, second is high (little endian)
wPlayerPositionX:: dw
wPlayerPositionY:: dw

mPlayerFlash: dw
; ANCHOR_END: player-start
; ANCHOR: player-data
SECTION "Player", ROM0

; ANCHOR: player-tile-data
playerShipTileData: INCBIN "src/generated/sprites/player-ship.2bpp"
playerShipTileDataEnd:
; ANCHOR_END: player-tile-data

playerTestMetaSprite::
    .metasprite1    db 0,0,0,0
    .metasprite2    db 0,8,2,0
    .metaspriteEnd  db 128
; ANCHOR_END: player-data

; ANCHOR: player-initialize
InitializePlayer::

    xor a
    ld [mPlayerFlash], a
    ld [mPlayerFlash+1], a

    ; Place in the middle of the screen
    xor a
    ld [wPlayerPositionX], a
    ld [wPlayerPositionY], a

    ld a, 5
    ld [wPlayerPositionX+1], a
    ld [wPlayerPositionY+1], a

    
CopyPlayerTileDataIntoVRAM:
    ; Copy the player's tile data into VRAM
	ld de, playerShipTileData
	ld hl, PLAYER_TILES_START
	ld bc, playerShipTileDataEnd - playerShipTileData
    call CopyDEintoMemoryAtHL

    ret
; ANCHOR_END: player-initialize

; ANCHOR: player-update-start
UpdatePlayer::

UpdatePlayer_HandleInput:

	ld a, [wCurKeys]
	and PADF_UP
	call nz, MoveUp

	ld a, [wCurKeys]
	and PADF_DOWN
	call nz, MoveDown

	ld a, [wCurKeys]
	and PADF_LEFT
	call nz, MoveLeft

	ld a, [wCurKeys]
	and PADF_RIGHT
	call nz, MoveRight

	ld a, [wCurKeys]
	and PADF_A
	call nz, TryShoot
; ANCHOR_END: player-update-start
    

; ANCHOR: player-update-flashing
    ld a, [mPlayerFlash+0]
    ld b, a

    ld a, [mPlayerFlash+1]
    ld c, a

UpdatePlayer_UpdateSprite_CheckFlashing:

    ld a, b
    or c
    jp z, UpdatePlayer_UpdateSprite

    ; decrease bc by 5
    ld a, b
    sub 5
    ld b, a
    ld a, c
    sbc 0
    ld c, a
    

UpdatePlayer_UpdateSprite_DecreaseFlashing:

    ld a, b
    ld [mPlayerFlash], a
    ld a, c
    ld [mPlayerFlash+1], a

    ; descale bc
    srl c
    rr b
    srl c
    rr b
    srl c
    rr b
    srl c
    rr b

    ld a, b
    cp 5
    jp c, UpdatePlayer_UpdateSprite_StopFlashing


    bit 0, b
    jp z, UpdatePlayer_UpdateSprite

UpdatePlayer_UpdateSprite_Flashing:

    ret
UpdatePlayer_UpdateSprite_StopFlashing:

    xor a
    ld [mPlayerFlash],a
    ld [mPlayerFlash+1],a
; ANCHOR_END: player-update-flashing

; ANCHOR: player-update-sprite
UpdatePlayer_UpdateSprite:

    ; Get the unscaled player x position in b
    ld a, [wPlayerPositionX+0]
    ld b, a
    ld a, [wPlayerPositionX+1]
    ld d, a
    
    srl d
    rr b
    srl d
    rr b
    srl d
    rr b
    srl d
    rr b

    ; Get the unscaled player y position in c
    ld a, [wPlayerPositionY+0]
    ld c, a
    ld a, [wPlayerPositionY+1]
    ld e, a

    srl e
    rr c
    srl e
    rr c
    srl e
    rr c
    srl e
    rr c
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Drawing the palyer metasprite
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    ; Save the address of the metasprite into the 'wMetaspriteAddress' variable
    ; Our DrawMetasprites functoin uses that variable
    ld a, LOW(playerTestMetaSprite)
    ld [wMetaspriteAddress+0], a
    ld a, HIGH(playerTestMetaSprite)
    ld [wMetaspriteAddress+1], a


    ; Save the x position
    ld a, b
    ld [wMetaspriteX], a

    ; Save the y position
    ld a, c
    ld [wMetaspriteY], a

    ; Actually call the 'DrawMetasprites function
    call DrawMetasprites;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ret
; ANCHOR_END: player-update-sprite

; ANCHOR: player-shoot
TryShoot:
	ld a, [wLastKeys]
	and PADF_A
    ret nz

    jp FireNextBullet
; ANCHOR_END: player-shoot

; ANCHOR: player-damage
DamagePlayer::

    

    xor a
    ld [mPlayerFlash], a
    inc a
    ld [mPlayerFlash+1], a

    ld a, [wLives]
    dec a
    ld [wLives], a

    ret
; ANCHOR_END: player-damage

; ANCHOR: player-movement
MoveUp:

    ; decrease the player's y position
    ld a, [wPlayerPositionY]
    sub PLAYER_MOVE_SPEED
    ld [wPlayerPositionY], a

    ld a, [wPlayerPositionY]
    sbc 0
    ld [wPlayerPositionY], a

    ret

MoveDown:

    ; increase the player's y position
    ld a, [wPlayerPositionY]
    add PLAYER_MOVE_SPEED
    ld [wPlayerPositionY], a

    ld a, [wPlayerPositionY+1]
    adc 0
    ld [wPlayerPositionY+1], a

    ret

MoveLeft:

    ; decrease the player's x position
    ld a, [wPlayerPositionX]
    sub PLAYER_MOVE_SPEED
    ld [wPlayerPositionX], a

    ld a, [wPlayerPositionX+1]
    sbc 0
    ld [wPlayerPositionX+1], a
    ret

MoveRight:

    ; increase the player's x position
    ld a, [wPlayerPositionX]
    add PLAYER_MOVE_SPEED
    ld [wPlayerPositionX], a

    ld a, [wPlayerPositionX+1]
    adc 0
    ld [wPlayerPositionX+1], a

    ret
; ANCHOR_END: player-movement


