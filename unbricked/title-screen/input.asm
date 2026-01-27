; This is a simplified version of pads.z80 by PinoBatch for use in gb-asm-tutorial
; All labels are intentionally not exported to avoid confusing the reader with unfamiliar syntax.
; Once linking is introduced in part 3, a new, exported version of this file will be provided.

INCLUDE "hardware.inc"

SECTION "Input Variables", WRAM0
wCurKeys:: db
wNewKeys:: db

SECTION "UpdateKeys", ROM0

UpdateKeys::
    ; Poll half the controller
    ld a, JOYP_GET_BUTTONS
    call .onenibble
    ld b, a ; B7-4 = 1; B3-0 = unpressed buttons

    ; Poll the other half
    ld a, JOYP_GET_CTRL_PAD
    call .onenibble
    swap a ; A3-0 = unpressed directions; A7-4 = 1
    xor a, b ; A = pressed buttons + directions
    ld b, a ; B = pressed buttons + directions

    ; And release the controller
    ld a, JOYP_GET_NONE
    ldh [rJOYP], a

    ; Combine with previous wCurKeys to make wNewKeys
    ld a, [wCurKeys]
    xor a, b ; A = keys that changed state
    and a, b ; A = keys that changed to pressed
    ld [wNewKeys], a
    ld a, b
    ld [wCurKeys], a
    ret

.onenibble
    ldh [rJOYP], a ; switch the key matrix
    call .knownret ; burn 10 cycles calling a known ret
    ldh a, [rJOYP] ; ignore value while waiting for the key matrix to settle
    ldh a, [rJOYP]
    ldh a, [rJOYP] ; this read counts
    or a, $F0 ; A7-4 = 1; A3-0 = unpressed keys
.knownret
    ret
