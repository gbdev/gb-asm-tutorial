; ANCHOR: hud-start
INCLUDE "src/main/includes/hardware.inc"
SECTION "GameplayHUD", ROM0
; ANCHOR_END: hud-start

; ANCHOR: hud-increase-score
IncreaseScore::

    ; We have 6 digits, start with the right-most digit (the last byte)
    ld c, 0
    ld hl, wScore+5

IncreaseScore_Loop:

    ; Increase the digit 
    ld a, [hl]
    inc a
    ld [hl], a

    ; Stop if it hasn't gone past 0
    cp a, 9
    ret c

; If it HAS gone past 9
IncreaseScore_Next:

    ; Increase a counter so we can not go out of our scores bounds
    ld a, c
    inc a 
    ld c, a

    ; Check if we've gone our o our scores bounds
    cp a, 6
    ret z

    ; Reset the current digit to zero
    ; Then go to the previous byte (visually: to the left)
    ld a, 0
    ld [hl], a
    ld [hld], a

    jp IncreaseScore_Loop
; ANCHOR_END: hud-increase-score


; ANCHOR: interrupts-start

SECTION "Interrupts", ROM0

 DisableInterrupts::
	ld a, 0
	ldh [rSTAT], a
	di
	ret

InitStatInterrupts::

    ld a, IEF_STAT
	ldh [rIE], a
	xor a, a ; This is equivalent to `ld a, 0`!
	ldh [rIF], a
	ei

	; This makes our stat interrupts occur when the current scanline is equal to the rLYC register
	ld a, STATF_LYC
	ldh [rSTAT], a

	; We'll start with the first scanline
	; The first stat interrupt will call the next time rLY = 0
	ld a, 0
	ldh [rLYC], a

    ret
; ANCHOR_END: interrupts-start

; ANCHOR: interrupts-section
; Define a new section and hard-code it to be at $0048.
SECTION "Stat Interrupt", ROM0[$0048]
StatInterrupt:

	push af

	; Check if we are on the first scanline
	ldh a, [rLYC]
	cp 0
	jp z, LYCEqualsZero

LYCEquals8:

	; Don't call the next stat interrupt until scanline 8
	ld a, 0
	ldh [rLYC], a

	; Turn the LCD on including sprites. But no window
	ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_WINOFF | LCDCF_WIN9C00
	ldh [rLCDC], a

	jp EndStatInterrupts

LYCEqualsZero:

	; Don't call the next stat interrupt until scanline 8
	ld a, 8
	ldh [rLYC], a

	; Turn the LCD on including the window. But no sprites
	ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJOFF | LCDCF_OBJ16| LCDCF_WINON | LCDCF_WIN9C00
	ldh [rLCDC], a


EndStatInterrupts:

	pop af

	reti;
; ANCHOR_END: interrupts-section