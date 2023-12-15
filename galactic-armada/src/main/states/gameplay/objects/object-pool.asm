; ANCHOR: objects-pool-top
include "src/main/includes/hardware.inc"
include "src/main/includes/constants.inc"

SECTION "ObjectVariables", WRAM0

wObjects:: ds MAX_OBJECT_COUNT*PER_OBJECT_BYTES_COUNT
wObjectsEnd:: db
wObjectsFlash:: db

SECTION "Objects", ROM0

; ANCHOR_END: objects-pool-top

; ANCHOR: initialize-objects
InitializeObjectPool::

    ; The active byte will awlays be 0 or 1
    ; When looping through the wObjects, if we read 255 we've reached wObjectsEnd
    ld a, 255
    ld [wObjectsEnd], a

    ld hl, wObjects
    ld b, MAX_OBJECT_COUNT

InitializeObjectPool_Loop:

    ld a, 0

    ; Default each byte as 0
    ; Using REPT incase the object size changes
    REPT PER_OBJECT_BYTES_COUNT
    ld [hli], a
    ENDR

    ; Decrease how many we have to initialize
    ; Stop this loop when b reaches zero
    ld a, b
    dec a
    and a
    ret z

    ld b, a
    jp InitializeObjectPool_Loop
; ANCHOR_END: initialize-objects

; ANCHOR: update-objects-1
UpdateObjectPool::

    ; Increase our flash
    ld a, [wObjectsFlash]
    add a,25
    ld [wObjectsFlash], a
; ANCHOR_END: update-objects-1

; ANCHOR: update-objects-2

    ld hl, wObjects

UpdateObjectPool_Loop:

    ; The active byte should be 0 or 1
    ; When we reach a 255, we've reached the wObjectsEnd
    ld a, [hl]
    cp a, 255
    ret z

    ; Check if the object is active
    and a
    jp z, UpdateObjectPool_GoToNextObject

; ANCHOR_END: update-objects-2

; ANCHOR: update-objects-3
.UpdateObject
        
    push hl

    ld b, h
    ld c, l

    ; Move to the update
    ld de, object_updateLowByte
    add hl, de

    ; hl points to the low byte for the address of the update function
    ; copy that address INTO hl
    ld a, [hli]
    ld h, [hl]
    ld l, a

    call callHL

    pop hl

    ; Check if we're inactive after updating
    ld a, [hl]
    and a
    jp z , UpdateObjectPool_GoToNextObject
; ANCHOR_END: update-objects-3

; ANCHOR: update-objects-4
.CheckIsDamaged

    push hl

    ; Move to the y low byte
    ld de, object_damageByte
    add hl, de

    ; Check this object is damaged
    ld a, [hl]
    and a
    jp z, NotDamaged
    jp Damaged

Damaged:

    ; decrease our damage byte
    dec a
    ld [hl], a

    pop hl

    ; if our objects timer is greater than 0 we'll not draw
    ld a, [wObjectsFlash]
    cp a, 128

    jp c, UpdateObjectPool_GoToNextObject

    push hl


NotDamaged:

    pop hl
    jp z, GetXAndY
; ANCHOR_END: update-objects-4

; ANCHOR: update-objects-5
GetXAndY:

    push hl

    ; Move to the y low byte
    ld de, object_yLowByte
    add hl, de

    ; Copy our y position to bc
    ld a, [hli]
    ld c, a
    ld a, [hli]
    ld b, a

    ; Copy our x position to de
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a

.RenderObjectMetasprite
    ld a, [hli]
    ld h, [hl]
    ld l, a

    call RenderMetasprite

    pop hl

    jp UpdateObjectPool_GoToNextObject
; ANCHOR_END: update-objects-5
; ANCHOR: update-objects-6
UpdateObjectPool_GoToNextObject:

    ld de, PER_OBJECT_BYTES_COUNT
    add hl, de

    jp UpdateObjectPool_Loop
; ANCHOR_END: update-objects-6

; ANCHOR: get-next-available-object
; parameters
; hl = start of array bytes
; b = number of objects to check
; example:
; ld hl, wObjects+BULLETS_START
; ld b, MAX_BULLET_COUNT
GetNextAvailableObject_InHL::

GetNextAvailableObject_Loop:

    ld a, [hl]
    and a
    jp nz, GetNextAvailableObject_Next


    ld a, 1
    and a
    ret

GetNextAvailableObject_Next:

    ld a, b
    dec a
    ld b, a

    jp z, GetNextAvailableObject_End

    ; move to the next object
    ld de, PER_OBJECT_BYTES_COUNT
    add hl, de

    jp GetNextAvailableObject_Loop
GetNextAvailableObject_End:

    ld a, 0
    and a
    ret;
; ANCHOR_END: get-next-available-object