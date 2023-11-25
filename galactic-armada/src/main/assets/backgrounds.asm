SECTION "BackgroundsAssets", ROM0
 
titleScreenTileData: INCBIN "src/generated/backgrounds/title-screen.2bpp"
titleScreenTileDataEnd:
 
titleScreenTileMap: INCBIN "src/generated/backgrounds/title-screen.tilemap"
titleScreenTileMapEnd:
	
; ANCHOR: draw-title-screen
DrawTitleScreen::
	
	; Copy the tile data
	ld de, titleScreenTileData ; de contains the address where data will be copied from;
	ld hl, $9340 ; hl contains the address where data will be copied to;
	ld bc, titleScreenTileDataEnd - titleScreenTileData ; bc contains how many bytes we have to copy.
	call CopyDEintoMemoryAtHL;
	
	; Copy the tilemap
	ld de, titleScreenTileMap
	ld hl, $9800
	ld bc, titleScreenTileMapEnd - titleScreenTileMap
	call CopyDEintoMemoryAtHL_With52Offset

	ret
; ANCHOR_END: draw-title-screen
	
	
textFontTileData: INCBIN "src/generated/backgrounds/text-font.2bpp"
textFontTileDataEnd:

LoadTextFontIntoVRAM::
	; Copy the tile data
	ld de, textFontTileData ; de contains the address where data will be copied from;
	ld hl, $9000 ; hl contains the address where data will be copied to;
	ld bc, textFontTileDataEnd - textFontTileData ; bc contains how many bytes we have to copy.
    call CopyDEintoMemoryAtHL
	ret

	

starFieldMap: INCBIN "src/generated/backgrounds/star-field.tilemap"
starFieldMapEnd:
 
starFieldTileData: INCBIN "src/generated/backgrounds/star-field.2bpp"
starFieldTileDataEnd:


DrawStarFieldBackground::

	; Copy the tile data
	ld de, starFieldTileData ; de contains the address where data will be copied from;
	ld hl, $9340 ; hl contains the address where data will be copied to;
	ld bc, starFieldTileDataEnd - starFieldTileData ; bc contains how many bytes we have to copy.
    call CopyDEintoMemoryAtHL

	; Copy the tilemap
	ld de, starFieldMap
	ld hl, $9800
	ld bc, starFieldMapEnd - starFieldMap
    call CopyDEintoMemoryAtHL_With52Offset

	ret