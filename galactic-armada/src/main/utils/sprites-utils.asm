
include "src/main/includes/hardware.inc"

SECTION "SpriteVariables", WRAM0

wLastOAMAddress:: dw
wSpritesUsed:: db
wHelperValue::db

SECTION "Sprites", ROM0

ClearAllSprites::
	 
	; Start clearing oam
	ld a, 0
    ld b, OAM_COUNT*sizeof_OAM_ATTRS ; 40 sprites times 4 bytes per sprite
    ld hl, wShadowOAM ; The start of our oam sprites in RAM

ClearOamLoop::
    ld [hli], a
    dec b
    jp nz, ClearOamLoop
    ld a,0
    ld [wSpritesUsed],a
    
    
	; from: https://github.com/eievui5/gb-sprobj-lib
	; Finally, run the following code during VBlank:
	ld a, HIGH(wShadowOAM)
	call hOAMDMA

    ret

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

    