
; ANCHOR: object-collision-start
include "src/main/includes/hardware.inc"
include "src/main/includes/constants.inc"
include "src/main/includes/hardware.inc"


SECTION "ObjectObjectCollisionVariables", WRAM0
wSizeY:: db
wSizeX:: db
wCheckByte: db

SECTION "ObjectObjectCollision", ROM0

; ANCHOR_END: object-collision-start
; ANCHOR: object-collision-function
CheckCollisionWithObjectsInHL_andDE::
; ANCHOR_END: object-collision-function
; ANCHOR: object-collision-x
XAxis:

    ; Save which byte we are checking
    ld a, object_xLowByte
    ld [wCheckByte], a

    ; Save if the minimum distance
    ld a, [wSizeX]
    ld [wSize], a

    ; SAve original values for y axis
    push de
    push hl

    call CheckObjectBytesOfObjects_InDE_AndHL

    ; Restore original vaues just in case
    pop hl
    pop de

    jp nz, YAxis

    ld a,0
    and a
    ret
; ANCHOR_END: object-collision-x
; ANCHOR: object-collision-y
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
; ANCHOR_END: object-collision-y

; ANCHOR: object-collision-check-bytes
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


CheckObjectPositionDifference::

    ; at this point in time; e = enemy.y, b =bullet.y

    ld a, [wObject1Value]
    ld e, a
    ld a, [wObject2Value]
    ld b, a

    ld a, [wSize]
    ld d, a

    ; subtract  bullet.y, (aka b) - (enemy.y+8, aka e)
    ; carry means e<b, means enemy.bottom is visually above bullet.y (no collision)

    ld a, e
    add a, d
    cp a, b

    ;  carry means  no collision
    jp c, CheckObjectPositionDifference_Failure

    ; subtract  enemy.y-8 (aka e) - bullet.y (aka b)
    ; no carry means e>b, means enemy.top is visually below bullet.y (no collision)
    ld a, e
    sub a, d
    cp a, b

    ; no carry means no collision
    jp nc, CheckObjectPositionDifference_Failure

    
CheckObjectPositionDifference_Intersection:

    ld a,1
    and a
    ret;
    
CheckObjectPositionDifference_Failure:

    ld a,0
    and a
    ret;
; ANCHOR_END: object-collision-check-bytes