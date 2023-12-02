
; ANCHOR: bullets-top
include "src/main/includes/hardware.inc"
include "src/main/includes/constants.inc"

SECTION "ObjectVariables", WRAM0

wObjects:: ds MAX_OBJECT_COUNT*PER_OBJECT_BYTES_COUNT
wObjectsEnd:: db

SECTION "Objects", ROM0

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
    ld a, b
    dec a
    ld b, a
    ret z

    jp InitializeObjectPool_Loop

UpdateObjectPool::

    ld hl, wObjects

UpdateObjectPool_Loop:

    ; The active byte should be 0 or 1
    ; When we reach a 255, we've reached the wObjectsEnd
    ld a, [hl]
    cp a, 255
    ret z

    ; Check if the object is active
    cp a
    jp z, UpdateObjectPool_InActiveObject
    
    push hl

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
    cp a
    jp z , UpdateObjectPool_InActiveObject

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

    pop hl
    
    ; check if we are out of bounds
    ; we'll deactivate the object if our y high byte is larger than 10
    ld a, b
    cp a, 10
    jp c, UpdateObjectPool_DeactivateObject

    ; keep track of our hl before we render
    push hl

    ; Move to the metasprite low byte
    ld de, object_metaspriteLowByte
    add hl, de
    ld a, [hli]
    ld h, [hl]
    ld l, a

    call RenderMetasprite

    pop hl

    jp UpdateObjectPool_Loop

UpdateObjectPool_DeactivateObject:



UpdateObjectPool_InActiveObject:

    ld de, PER_OBJECT_BYTES_COUNT
    add hl, de

    jp UpdateObjectPool_Loop