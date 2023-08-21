; Sprite Objects Library - by Eievui
;
; This is a small, lightweight library meant to facilitate the rendering of
; sprite objects, including Shadow OAM and OAM DMA, single-entry "simple" sprite
; objects, and Q12.4 fixed-point position metasprite rendering.
;
; The library is only 127 bytes of ROM0, 160 bytes of WRAM0 for Shadow OAM, and a
; single HRAM byte for tracking the current position in OAM.
;
; The library is relatively simple to use, with 4 steps to rendering:
; 1. Call InitSprObjLib during initilizations - This copies the OAMDMA function to
;    HRAM.
; 2. Call ResetShadowOAM at the beginning of each frame - This hides all sprites
;    and resets hOAMIndex, allowing you to render a new frame of sprites.
; 3. Call rendering functions - Push simple sprites or metasprites to Shadow OAM.
; 4. Wait for VBlank and call hOAMDMA - Copies wShadowOAM to the Game Boy's OAM in
;    just 160 M-cycles. Make sure to pass HIGH(wShadowOAM) in the a register.
;
; Copyright 2021, Eievui
;
; This software is provided 'as-is', without any express or implied
; warranty.  In no event will the authors be held liable for any damages
; arising from the use of this software.
; 
; Permission is granted to anyone to use this software for any purpose,
; including commercial applications, and to alter it and redistribute it
; freely, subject to the following restrictions:
; 
; 1. The origin of this software must not be misrepresented; you must not
;    claim that you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation would be
;    appreciated but is not required.
; 2. Altered source versions must be plainly marked as such, and must not be
;    misrepresented as being the original software.
; 3. This notice may not be removed or altered from any source distribution.
;

INCLUDE "src/main/utils/hardware.inc"

SECTION "OAM DMA Code", ROM0
OAMDMACode::
LOAD "OAM DMA", HRAM
; Begin an OAM DMA, waiting 160 cycles for the DMA to finish.
; This quickly copies Shadow OAM to the Game Boy's OAM, allowing the PPU to draw
; the objects. hOAMDMA should be called once per frame near the end of your
; VBlank interrupt. While an OAM DMA is running no sprites objects can be drawn
; by the PPU, which makes it preferrable to run within the VBlank interrupt, but
; it can be run at any point if more than 40 sprite objects are needed.
; @param a: High byte of active Shadow OAM. Shadow OAM must be aligned to start
;           at the beginning of a page (low byte == $00).
hOAMDMA::
  ldh [rDMA], a
  ld a, 40
.wait
  dec a
  jr nz, .wait
  ret
ENDL
OAMDMACodeEnd::

SECTION "Initialize Sprite Object Library", ROM0

; A wrapper or the InitSprObjLib code
; from: https://github.com/eievui5/gb-sprobj-lib
; The library is relatively simple to get set up. First, put the following in your initialization code:
; Initilize Sprite Object Library.
InitSprObjLibWrapper::

  call InitSprObjLib
	; Reset hardware OAM
	xor a, a
	ld b, 160
	ld hl, _OAMRAM
	
.resetOAM
	ld [hli], a
	dec b
	jr nz, .resetOAM
  
  ret

; Initializes the sprite object library, copying things such as the hOAMDMA
; function and reseting hOAMIndex
; @clobbers: a, bc, hl
InitSprObjLib::
  ; Copy OAM DMA.
  ld b, OAMDMACodeEnd - OAMDMACode
  ld c, LOW(hOAMDMA)
  ld hl, OAMDMACode
.memcpy
  ld a, [hli]
  ldh [c], a
  inc c
  dec b
  jr nz, .memcpy
  xor a, a
  ldh [hOAMIndex], a ; hOAMIndex must be reset before running ResetShadowOAM.
  ret

SECTION "Reset Shadow OAM", ROM0
; Reset the Y positions of every sprite object that was used in the last frame, 
; effectily hiding them, and reset hOAMIndex. Run this function each frame
; before rendering sprite objects.
; @clobbers: a, c, hl
ResetShadowOAM::
  xor a, a ; clear carry
  ldh a, [hOAMIndex]
  rra
  rra ; a / 4
  and a, a
  jr z, .skip
  ld c, a 
  ld hl, wShadowOAM
  xor a, a
.clearOAM
  ld [hli], a 
  inc l 
  inc l
  inc l 
  dec c
  jr nz, .clearOAM
  ldh [hOAMIndex], a
.skip
  ret

SECTION "Render Simple Sprite", ROM0
; Render a single object, or sprite, to OAM.
; @param b: Y position
; @param c: X position
; @param d: Tile ID
; @param e: Tile Attribute
; @clobbers: hl
RenderSimpleSprite::
  ld h, HIGH(wShadowOAM)
  ldh a, [hOAMIndex]
  ld l, a
  ld a, b
  add a, 16
  ld [hli], a
  ld a, c
  add a, 8
  ld [hli], a
  ld a, d
  ld [hli], a
  ld a, e
  ld [hli], a
  ld a, l
  ldh [hOAMIndex], a
  ret

SECTION "Render Metasprite", ROM0
; Render a metasprite to OAM.
; @param bc: Q12.4 fixed-point Y position.
; @param de: Q12.4 fixed-point X position.
; @param hl: Pointer to current metasprite.
RenderMetasprite::
  ; Adjust Y and store in b.
  ld a, c
  rrc b
  rra
  rrc b
  rra
  rrc b
  rra
  rrc b
  rra
  ld b, a
  ; Adjust X and store in c.
  ld a, e
  rrc d
  rra
  rrc d
  rra
  rrc d
  rra
  rrc d
  rra
  ld c, a
  ; Load Shadow OAM pointer.
  ld d, HIGH(wShadowOAM)
  ldh a, [hOAMIndex]
  ld e, a
  ; Now:
  ; bc - Y, X
  ; de - Shadow OAM
  ; hl - Metasprite
  ; Time to render!
.loop
  ; Load Y.
  ld a, [hli]
  add a, b
  ld [de], a
  inc e
  ; Load X.
  ld a, [hli]
  add a, c
  ld [de], a
  inc e
  ; Load Tile.
  ld a, [hli]
  ld [de], a
  inc e
  ; Load Attribute.
  ld a, [hli]
  ld [de], a
  inc e
  ; Check for null end byte.
  ld a, [hl]
  cp a, 128
  jr nz, .loop
  ld a, e
  ldh [hOAMIndex], a
  ret

SECTION "Shadow OAM", WRAM0, ALIGN[8]
wShadowOAM::
  ds 160

SECTION "Shadow OAM Index", HRAM
; The current low byte of shadow OAM.
hOAMIndex::
  db