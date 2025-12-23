; ANCHOR: background-utils
include "src/main/utils/hardware.inc"

SECTION "Background", ROM0

ClearBackground::

	; Turn the LCD off
	xor a
	ld [rLCDC], a

	ld bc, 1024
	ld hl, $9800

ClearBackgroundLoop:

	xor a
	ld [hli], a

	
	dec bc
	ld a, b
	or c

	jp nz, ClearBackgroundLoop


	; Turn the LCD on
	ld a, LCDCF_ON  | LCDCF_BGON|LCDCF_OBJON | LCDCF_OBJ16
	ld [rLCDC], a


	ret
; ANCHOR_END: background-utils
