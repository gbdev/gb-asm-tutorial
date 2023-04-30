
include "src/main/utils/hardware.inc"
include "src/main/utils/hardware.inc"
include "src/main/utils/constants.inc"

SECTION "PlayerVariables", WRAM0

; first byte is low, second is high (little endian)
wPlayerPositionX:: dw
wPlayerPositionY:: dw

mPlayerFlash: dw

SECTION "Player", ROM0

playerShipTileData: INCBIN "src/generated/sprites/player-ship.2bpp"
playerShipTileDataEnd:

enemyShipTileData:: INCBIN "src/generated/sprites/enemy-ship.2bpp"
enemyShipTileDataEnd::

bulletTileData:: INCBIN "src/generated/sprites/bullet.2bpp"
bulletTileDataEnd::


playerTestMetaSprite::
    .metasprite1    db 0,0,0,0
    .metasprite2    db 0,8,2,0
    .metaspriteEnd  db 128

InitializePlayer::

    ld a, 0
    ld [mPlayerFlash+0],a
    ld [mPlayerFlash+1],a

    ; Place in the middle of the screen
    ld a, 0
    ld [wPlayerPositionX+0], a
    ld [wPlayerPositionY+0], a

    ld a, 5
    ld [wPlayerPositionX+1], a
    ld [wPlayerPositionY+1], a

    
CopyPlayerTileDataIntoVRAM:

	ld de, playerShipTileData
	ld hl, PLAYER_TILES_START
	ld bc, playerShipTileDataEnd - playerShipTileData

CopyPlayerTileDataIntoVRAM_Loop:

	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, CopyPlayerTileDataIntoVRAM_Loop

    ret;

UpdatePlayer::

UpdatePlayer_HandleInput:

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

	ld a, [wCurKeys]
	and a, PADF_A
	call nz, TryShoot

    ld a, [mPlayerFlash+0]
    ld b, a

    ld a, [mPlayerFlash+1]
    ld c, a
    
    

UpdatePlayer_UpdateSprite_CheckFlashing:

    ld a, b
    or a, c
    jp z, UpdatePlayer_UpdateSprite

    ; decrease bc by 5
    ld a, b
    sub a, 5
    ld b, a
    ld a, c
    sbc a, 0
    ld c, a
    

UpdatePlayer_UpdateSprite_DecreaseFlashing:

    ld a, b
    ld [mPlayerFlash+0], a
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
    cp a, 5
    jp c, UpdatePlayer_UpdateSprite_StopFlashing


    bit 0, b
    jp z, UpdatePlayer_UpdateSprite

UpdatePlayer_UpdateSprite_Flashing:

    ret;
UpdatePlayer_UpdateSprite_StopFlashing:

    ld a, 0
    ld [mPlayerFlash+0],a
    ld [mPlayerFlash+1],a

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
    ld [wMetaspriteX],a

    ; Save the y position
    ld a, c
    ld [wMetaspriteY],a

    ; Actually call the 'DrawMetasprites function
    call DrawMetasprites;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ret

TryShoot:
	ld a, [wLastKeys]
	and a, PADF_A
    ret nz

    

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

    ld a,b
    ld [wNextBullet], a

    ld a, [wPlayerPositionY+0]
    ld [wNextBullet+1], a

    ld a, [wPlayerPositionY+1]
    ld [wNextBullet+2], a

    call FireNextBullet;

    ret

DamagePlayer::

    

    ld a, 0
    ld [mPlayerFlash+0], a
    ld a, 1
    ld [mPlayerFlash+1], a

    ld a, [wLives]
    dec a
    ld [wLives], a

    ret

MoveUp:

    ; decrease the player's y position
    ld a, [wPlayerPositionY+0]
    sub a, PLAYER_MOVE_SPEED
    ld [wPlayerPositionY+0], a

    ld a, [wPlayerPositionY+1]
    sbc a, 0
    ld [wPlayerPositionY+1], a

    ret

MoveDown:

    ; increase the player's y position
    ld a, [wPlayerPositionY+0]
    add a, PLAYER_MOVE_SPEED
    ld [wPlayerPositionY+0], a

    ld a, [wPlayerPositionY+1]
    adc a, 0
    ld [wPlayerPositionY+1], a

    ret

MoveLeft:

    ; decrease the player's x position
    ld a, [wPlayerPositionX+0]
    sub a, PLAYER_MOVE_SPEED
    ld [wPlayerPositionX+0], a

    ld a, [wPlayerPositionX+1]
    sbc a, 0
    ld [wPlayerPositionX+1], a
    ret

MoveRight:

    ; increase the player's x position
    ld a, [wPlayerPositionX+0]
    add a, PLAYER_MOVE_SPEED
    ld [wPlayerPositionX+0], a

    ld a, [wPlayerPositionX+1]
    adc a, 0
    ld [wPlayerPositionX+1], a

    ret


