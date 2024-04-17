
include "src/main/utils/constants.inc"
SECTION "MetaSpriteVariables", WRAM0

wMetaspriteAddress:: dw
wMetaspriteX:: db
wMetaspriteY::db

SECTION "MetaSprites", ROM0

DrawMetasprites::


    ; get the metasprite address
    ld a, [wMetaspriteAddress+0]
    ld l, a
    ld a, [wMetaspriteAddress+1]
    ld h, a

    ; Get the y position
    ld a, [hli]
    ld b, a

    ; stop if the y position is 128 
    ld a, b
    cp 128
    ret z

    ld a, [wMetaspriteY]
    add b
    ld [wMetaspriteY], a

    ; Get the x position
    ld a, [hli]
    ld c, a

    ld a, [wMetaspriteX]
    add c
    ld [wMetaspriteX], a

    ; Get the tile position
    ld a, [hli]
    ld d, a

    ; Get the flag position
    ld a, [hli]
    ld e, a
    

    ; Get our offset address in hl
	ld a,[wLastOAMAddress+0]
    ld l, a
	ld a, HIGH(wShadowOAM)
    ld h, a

    ld a, [wMetaspriteY]
    ld [hli], a

    ld a, [wMetaspriteX]
    ld [hli], a

    ld a, d
    ld [hli], a

    ld a, e
    ld [hli], a

    call NextOAMSprite

     ; increase the wMetaspriteAddress
    ld a, [wMetaspriteAddress]
    add a, METASPRITE_BYTES_COUNT
    ld [wMetaspriteAddress], a
    ld a, [wMetaspriteAddress+1]
    adc 0
    ld [wMetaspriteAddress+1], a


    jp DrawMetasprites
