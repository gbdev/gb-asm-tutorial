INCLUDE "src/main/utils/hardware.inc"

SECTION "VBlankVariables", WRAM0

wVBlankCount:: db 


SECTION "VBlankFunctions", ROM0

WaitForOneVBlank::

    ; Wait a small amount of time
    ; Save our count in this variable
    ld a, 1
    ld [wVBlankCount], a

    push bc

    ld a, [wVBlankCount]
    ld b, a

WaitForVBlankFunction::

    push bc

    ld a, [wVBlankCount]
    ld b, a

WaitForVBlankFunction_Loop::

	ld a, [rLY] ; Copy the vertical line to a
	cp 144 ; Check if the vertical line (in a) is 0
	jp c, WaitForVBlankFunction_Loop ; A conditional jump. The condition is that 'c' is set, the last operation overflowed

    ld a, b
    sub a, 1
    ld b, a
    jp z, WaitForVBlankFunction_End

WaitForVBlankFunction_Loop2::

	ld a, [rLY] ; Copy the vertical line to a
	cp 144 ; Check if the vertical line (in a) is 0
	jp nc, WaitForVBlankFunction_Loop2 ; A conditional jump. The condition is that 'c' is set, the last operation overflowed

    jp WaitForVBlankFunction_Loop

WaitForVBlankFunction_End:

    pop bc
    ret
