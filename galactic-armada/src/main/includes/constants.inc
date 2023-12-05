include "src/main/includes/hardware.inc"

DEF MAX_ENEMY_COUNT EQU 10
DEF MAX_BULLET_COUNT EQU 5
DEF MAX_OBJECT_COUNT  EQU 16

DEF ENEMY_SPAWN_DELAY_MAX EQU 70

; from https://rgbds.gbdev.io/docs/v0.6.1/rgbasm.5#EXPRESSIONS
; The RS group of commands is a handy way of defining structure offsets:
RSRESET
DEF object_activeByte            RB   1
DEF object_yLowByte              RB   1
DEF object_yHighByte             RB   1
DEF object_xLowByte              RB   1
DEF object_xHighByte             RB   1
DEF object_metaspriteLowByte     RB   1
DEF object_metaspriteHighByte    RB   1
DEF object_healthByte            RB   1
DEF object_updateLowByte         RB   1
DEF object_updateHighByte        RB   1
DEF PER_OBJECT_BYTES_COUNT       RB   0

RSRESET
DEF PLAYER_START RB PER_OBJECT_BYTES_COUNT
DEF ENEMIES_START RB MAX_ENEMY_COUNT*PER_OBJECT_BYTES_COUNT
DEF BULLETS_START RB MAX_OBJECT_COUNT*PER_OBJECT_BYTES_COUNT

; ANCHOR: sprite-vram-constants
RSRESET
DEF spriteTilesStart            RB _VRAM
DEF PLAYER_TILES_START          RB 4*16
DEF ENEMY_TILES_START           RB 4*16
DEF BULLET_TILES_START          RB 0
; ANCHOR_END: sprite-vram-constants


DEF ENEMY_MOVE_SPEED EQU 11
DEF BULLET_MOVE_SPEED EQU 20

DEF PLAYER_MOVE_SPEED EQU 15
DEF PADDLE_Y_POSITION EQU 136
