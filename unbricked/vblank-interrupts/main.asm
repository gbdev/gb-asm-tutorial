INCLUDE "hardware.inc"

; ANCHOR: vblank-interrupt
SECTION "VBlank Interrupt", ROM0[INT_HANDLER_VBLANK]
VBlankInterrupt:
	push af

	ld a, 1
	ld [wVBlankDone], a

	ld a, [wFrameCounter]
	inc a
	ld [wFrameCounter], a

	pop af
	reti
; ANCHOR_END: vblank-interrupt

SECTION "Header", ROM0[$100]

	jp EntryPoint

	ds $150 - @, 0 ; Make room for the header

EntryPoint:
	; Do not turn the LCD off outside of VBlank
WaitVBlank:
	ld a, [rLY]
	cp 144
	jp c, WaitVBlank

	; Turn the LCD off
	ld a, 0
	ld [rLCDC], a

; ANCHOR: copy_tiles
	; Copy the tile data
	ld de, Tiles
	ld hl, $9000
	ld bc, TilesEnd - Tiles
	call MemCopy
; ANCHOR_END: copy_tiles

; ANCHOR: copy_map
	; Copy the tilemap
	ld de, Tilemap
	ld hl, $9800
	ld bc, TilemapEnd - Tilemap
	call MemCopy
; ANCHOR_END: copy_map

; ANCHOR: copy_paddle
	; Copy the paddle tile
	ld de, Paddle
	ld hl, $8000
	ld bc, PaddleEnd - Paddle
	call MemCopy
; ANCHOR_END: copy_paddle

	xor a, a
	ld b, 160
	ld hl, STARTOF(OAM)
ClearOam:
	ld [hli], a
	dec b
	jp nz, ClearOam

	ld hl, STARTOF(OAM)
	ld a, 128 + 16
	ld [hli], a
	ld a, 16 + 8
	ld [hli], a
	ld a, 0
	ld [hli], a
	ld [hl], a

	; Turn the LCD on
	ld a, LCDC_ON | LCDC_BG_ON | LCDC_OBJ_ON
	ld [rLCDC], a

	; During the first (blank) frame, initialize display registers
	ld a, %11100100
	ld [rBGP], a
	ld a, %11100100
	ld [rOBP0], a

	; Initialize global variables
	xor a, a
	ld [wFrameCounter], a
	ld [wVBlankDone], a

; ANCHOR: enable-vblank-interrupt
	; Enable the VBlank interrupt
	ldh [rIF], a
	ld a, IE_VBLANK
	ldh [rIE], a
	ei
; ANCHOR_END: enable-vblank-interrupt

; ANCHOR: main
Main:
	call WaitForVBlank

	ld a, [wFrameCounter]
	cp a, 15 ; Every 15 frames (a quarter of a second), run the following code
	jp c, Main

	; Reset the frame counter back to 0
	xor a, a
	ld [wFrameCounter], a

	; Move the paddle one pixel to the right.
	ld a, [STARTOF(OAM) + 1]
	inc a
	ld [STARTOF(OAM) + 1], a
	jp Main
; ANCHOR_END: main

; ANCHOR: wait-for-vblank
WaitForVBlank:
	xor a, a
	ld [wVBlankDone], a
.wait
	halt
	nop
	ld a, [wVBlankDone]
	and a, a
	jp z, .wait
	ret
; ANCHOR_END: wait-for-vblank

; ANCHOR: memcpy
; Copy bytes from one area to another.
; @param de: Source
; @param hl: Destination
; @param bc: Length
MemCopy:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, MemCopy
	ret
; ANCHOR_END: memcpy

Tiles:
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33322222
	dw `33322222
	dw `33322222
	dw `33322211
	dw `33322211
	dw `33333333
	dw `33333333
	dw `33333333
	dw `22222222
	dw `22222222
	dw `22222222
	dw `11111111
	dw `11111111
	dw `33333333
	dw `33333333
	dw `33333333
	dw `22222333
	dw `22222333
	dw `22222333
	dw `11222333
	dw `11222333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33322211
	dw `33322211
	dw `33322211
	dw `33322211
	dw `33322211
	dw `33322211
	dw `33322211
	dw `33322211
	dw `22222222
	dw `20000000
	dw `20111111
	dw `20111111
	dw `20111111
	dw `20111111
	dw `22222222
	dw `33333333
	dw `22222223
	dw `00000023
	dw `11111123
	dw `11111123
	dw `11111123
	dw `11111123
	dw `22222223
	dw `33333333
	dw `11222333
	dw `11222333
	dw `11222333
	dw `11222333
	dw `11222333
	dw `11222333
	dw `11222333
	dw `11222333
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `11001100
	dw `11111111
	dw `11111111
	dw `21212121
	dw `22222222
	dw `22322232
	dw `23232323
	dw `33333333
	; My custom logo (tail)
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33302333
	dw `33333133
	dw `33300313
	dw `33300303
	dw `33013330
	dw `30333333
	dw `03333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `03333333
	dw `30333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333330
	dw `33333320
	dw `33333013
	dw `33330333
	dw `33100333
	dw `31001333
	dw `20001333
	dw `00000333
	dw `00000033
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33330333
	dw `33300333
	dw `33333333
	dw `33033333
	dw `33133333
	dw `33303333
	dw `33303333
	dw `33303333
	dw `33332333
	dw `33332333
	dw `33333330
	dw `33333300
	dw `33333300
	dw `33333100
	dw `33333000
	dw `33333000
	dw `33333100
	dw `33333300
	dw `00000001
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `10000333
	dw `00000033
	dw `00000003
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `33332333
	dw `33302333
	dw `32003333
	dw `00003333
	dw `00003333
	dw `00013333
	dw `00033333
	dw `00033333
	dw `33333300
	dw `33333310
	dw `33333330
	dw `33333332
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `30000000
	dw `33000000
	dw `33333000
	dw `33333333
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000003
	dw `00000033
	dw `00003333
	dw `02333333
	dw `33333333
	dw `00333333
	dw `03333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
TilesEnd:

Tilemap:
	db $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $02, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $05, $06, $05, $06, $05, $06, $05, $06, $05, $06, $05, $06, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $08, $05, $06, $05, $06, $05, $06, $05, $06, $05, $06, $08, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $05, $06, $05, $06, $05, $06, $05, $06, $05, $06, $05, $06, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $08, $05, $06, $05, $06, $05, $06, $05, $06, $05, $06, $08, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $05, $06, $05, $06, $05, $06, $05, $06, $05, $06, $05, $06, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $08, $05, $06, $05, $06, $05, $06, $05, $06, $05, $06, $08, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $0A, $0B, $0C, $0D, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $0E, $0F, $10, $11, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $12, $13, $14, $15, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $16, $17, $18, $19, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
TilemapEnd:

Paddle:
	dw `33333333
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
PaddleEnd:

; ANCHOR: variables
SECTION "Counter", WRAM0
wFrameCounter: db
wVBlankDone: db
; ANCHOR_END: variables

SECTION "Input Variables", WRAM0
wCurKeys: db
wNewKeys: db
