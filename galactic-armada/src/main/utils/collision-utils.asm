
include "src/main/utils/hardware.inc"
include "src/main/utils/constants.inc"
include "src/main/utils/hardware.inc"

SECTION "CollisionUtilsVariables", WRAM0

wResult::db;
wSize::db;
wObject1Value:: db
wObject2Value:: db

SECTION "CollisionUtils", ROM0

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

    ld a,1
    ld [wResult], a
    ret;

    
CheckObjectPositionDifference_Failure:

    ld a,0
    ld [wResult], a
    ret;