
include "src/main/includes/constants.inc"
SECTION "MetaSpriteVariables", WRAM0

wMetaspriteAddress:: dw
wMetaspriteX:: db
wMetaspriteY::db

SECTION "MetaSprites", ROM0






; ANCHOR: reset-oam-sprite-address
ResetOAMSpriteAddress::
    
    ld a, 0
    ld [wSpritesUsed], a

	ld a, LOW(wShadowOAM)
	ld [wLastOAMAddress+0], a
	ld a, HIGH(wShadowOAM)
	ld [wLastOAMAddress+1], a

    ret
; ANCHOR_END: reset-oam-sprite-address

; ANCHOR: next-oam-sprite
NextOAMSprite::

    ld a, [wSpritesUsed]
    inc a
    ld [wSpritesUsed], a

	ld a,[wLastOAMAddress+0]
    add a, sizeof_OAM_ATTRS
	ld [wLastOAMAddress+0], a
	ld a, HIGH(wShadowOAM)
	ld [wLastOAMAddress+1], a


    ret
; ANCHOR_END: next-oam-sprite
