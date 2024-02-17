
include "src/main/includes/hardware.inc"
include "src/main/includes/constants.inc"

SECTION "MetaspritesAssets", ROM0

playerTestMetaSprite::
    .metasprite1    db 0,0,0,0
    .metasprite2    db 0,8,2,0
    .metaspriteEnd  db 128

bulletMetasprite::
    .metasprite1    db 0,0,8,0
    .metaspriteEnd  db 128

enemyShipMetasprite::
    .metasprite1    db 0,0,4,0
    .metasprite2    db 0,8,6,0
    .metaspriteEnd  db 128