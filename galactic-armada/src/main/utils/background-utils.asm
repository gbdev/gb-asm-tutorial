; ANCHOR: background-utils
include "src/main/includes/hardware.inc"

SECTION "Background", ROM0

ClearBackground::

	ld bc,1024
	ld hl, $9800

ClearBackgroundLoop:

	ld a,0
	ld [hli], a

	
	dec bc
	ld a, b
	or a, c

	jp nz, ClearBackgroundLoop


	ret
; ANCHOR_END: background-utils