
include "src/main/utils/hardware.inc"

SECTION "SpriteVariables", WRAM0

wLastOAMAddress:: dw
wSpritesUsed:: db
wHelperValue::db

SECTION "Sprites", ROM0

ClearAllSprites::
	 
	; Start clearing oam
	xor a
    ld b, OAM_COUNT*sizeof_OAM_ATTRS ; 40 sprites times 4 bytes per sprite
    ld hl, wShadowOAM ; The start of our oam sprites in RAM

ClearOamLoop::
    ld [hli], a
    dec b
    jp nz, ClearOamLoop
    xor a
    ld [wSpritesUsed], a
    
    
	; from: https://github.com/eievui5/gb-sprobj-lib
	; Finally, run the following code during VBlank:
	ld a, HIGH(wShadowOAM)
	jp hOAMDMA

ClearRemainingSprites::

ClearRemainingSprites_Loop::

    ;Get our offset address in hl
	ld a,[wLastOAMAddress]
    ld l, a
	ld a, HIGH(wShadowOAM)
    ld h, a

    ld a, l
    cp 160
    ret nc

    ; Set the y and x to be 0
    xor a
    ld [hli], a
    ld [hld], a

    ; Move up 4 bytes
    ld a, l
    add 4
    ld l, a

    call NextOAMSprite


    jp ClearRemainingSprites_Loop

; ANCHOR: reset-oam-sprite-address
ResetOAMSpriteAddress::
    
    xor a
    ld [wSpritesUsed], a

	ld a, LOW(wShadowOAM)
	ld [wLastOAMAddress], a
	ld a, HIGH(wShadowOAM)
	ld [wLastOAMAddress+1], a

    ret
; ANCHOR_END: reset-oam-sprite-address

; ANCHOR: next-oam-sprite
NextOAMSprite::

    ld a, [wSpritesUsed]
    inc a
    ld [wSpritesUsed], a

	ld a,[wLastOAMAddress]
    add sizeof_OAM_ATTRS
	ld [wLastOAMAddress], a
	ld a, HIGH(wShadowOAM)
	ld [wLastOAMAddress+1], a


    ret
; ANCHOR_END: next-oam-sprite

    
