
include "src/main/includes/hardware.inc"

SECTION "SpriteVariables", WRAM0

wLastOAMAddress:: dw
wSpritesUsed:: db
wHelperValue::db

SECTION "Sprites", ROM0

ClearRemainingSprites::

ClearRemainingSprites_Loop::

    ;Get our offset address in hl
	ld a,[wLastOAMAddress+0]
    ld l, a
	ld a, HIGH(wShadowOAM)
    ld h, a

    ld a, l
    cp a, 160
    ret nc
    ret nc

    ; Set the y and x to be 0
    ld a, 0
    ld [hli], a
    ld [hld], a

    ; Move up 4 bytes
    ld a, l
    add a, 4
    ld l, a

    call NextOAMSprite


    jp ClearRemainingSprites_Loop
    