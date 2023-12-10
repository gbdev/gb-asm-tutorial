include "src/main/includes/hardware.inc"
include "src/main/includes/constants.inc"

SECTION "SpritesAssets", ROM0

playerShipTileData: INCBIN "src/generated/sprites/player-ship.2bpp"
playerShipTileDataEnd:
    
CopyPlayerTileDataIntoVRAM::

    ; Copy the player's tile data into VRAM
	ld de, playerShipTileData
	ld hl, PLAYER_TILES_START
	ld bc, playerShipTileDataEnd - playerShipTileData
    call CopyDEintoMemoryAtHL

    ret;


bulletTileData:: INCBIN "src/generated/sprites/bullet.2bpp"
bulletTileDataEnd::


CopyBulletTileDataIntoVRAM::
    

    ; Copy the bullet tile data intto vram
	ld de, bulletTileData
	ld hl, BULLET_TILES_START
	ld bc, bulletTileDataEnd - bulletTileData
    call CopyDEintoMemoryAtHL
    ret

enemyShipTileData:: INCBIN "src/generated/sprites/enemy-ship.2bpp"
enemyShipTileDataEnd::


CopyEnemyTileDataIntoVRAM::


	ld de, enemyShipTileData
	ld hl, ENEMY_TILES_START
	ld bc, enemyShipTileDataEnd - enemyShipTileData
    call CopyDEintoMemoryAtHL

    ret