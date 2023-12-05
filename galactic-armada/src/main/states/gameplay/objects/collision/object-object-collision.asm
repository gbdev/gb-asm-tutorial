
; ANCHOR: enemy-bullet-collision-start
include "src/main/includes/hardware.inc"
include "src/main/includes/constants.inc"
include "src/main/includes/hardware.inc"


SECTION "ObjectObjectCollisionVariables", WRAM0
wSizeY:: db
wSizeX:: db
wCheckByte: db

SECTION "ObjectObjectCollision", ROM0

CheckCollisionWithObjectsInHL_andDE::

    ; SAve original values for y axis
    push de
    push hl

XAxis:

    ; Save which byte we are checking
    ld a, object_xLowByte
    ld [wCheckByte], a

    ; Save if the minimum distance
    ld a, [wSizeX]
    ld [wSize], a

    call CheckObjectBytesOfObjects_InDE_AndHL

    ; Restore original vaues just in case
    pop hl
    pop de

    jp nz, YAxis

    ld a,0
    and a
    ret

YAxis:

    ; Save which byte we are checking
    ld a, object_yLowByte
    ld [wCheckByte], a

    ; Save if the minimum distance
    ld a, [wSizeY]
    ld [wSize], a

    call CheckObjectBytesOfObjects_InDE_AndHL

    ; Normal return with the z/c flags as-is
    ret


CheckObjectBytesOfObjects_InDE_AndHL::

    ; put de in hl so we can get the x bytes (for the de object) in bc and descale just to c

    push hl
    
    ; Offset de by the check byte
    ld a, [wCheckByte]
    add a,e
    ld e,a

    ; copy the low byte to c
    ld a, [de]
    ld c, a

    ; move to the high byte
    inc de

    ; copy the high byte to b
    ld a, [de]
    ld b, a

    ; Descale
    REPT 4
    srl b
    rr c
    ENDR

    ld a, c
    ld [wObject1Value], a

    pop hl

    ; get the bytes (for the hl object) in bc and descale just to c
    ld a, [wCheckByte]
    add a, l
    ld l, a

    ; move to the high byte
    ld a, [hli]
    ld c, a

    ; copy the high byte to b
    ld a, [hl]
    ld b, a

    ; Descale
    REPT 4
    srl b
    rr c
    ENDR

    ld a, c
    ld [wObject2Value], a

    call CheckObjectPositionDifference

    ld a, [wResult]
    cp a, 0

    ret