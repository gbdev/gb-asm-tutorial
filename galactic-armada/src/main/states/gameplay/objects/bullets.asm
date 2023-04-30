include "src/main/utils/hardware.inc"
include "src/main/utils/constants.inc"

SECTION "BulletVariables", WRAM0

wNextBullet::
    .x db
    .y dw

wActiveBulletCounter:: db

wUpdateBulletsCounter:db
wUpdateBulletsCurrentBulletAddress:dw


; Bytes: active, x , y (low), y (high)
wBullets:: ds MAX_BULLET_COUNT*PER_BULLET_BYTES_COUNT

SECTION "Bullets", ROM0

bulletMetasprite::
    .metasprite1    db 0,0,8,0
    .metaspriteEnd  db 128

InitializeBullets::

    
CopyHappyFace:

	ld de, bulletTileData
	ld hl, BULLET_TILES_START
	ld bc, bulletTileDataEnd - bulletTileData

CopyHappyFace_Loop:

	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, CopyHappyFace_Loop

    ld b, 0

    ld hl, wBullets

    ld a,0
    ld [wActiveBulletCounter],a

InitializeBullets_Loop:

    ld a, 0
    ld [hl], a

    ; Increase the address
    ld a, l
    add a, PER_BULLET_BYTES_COUNT
    ld l, a
    ld a, h
    adc a, 0
    ld h, a

    ; Increase how many bullets we have initailized
    ld a, b
    inc a
    ld b ,a

    cp a, MAX_BULLET_COUNT
    ret z

    jp InitializeBullets_Loop

UpdateBullets::

    ; Make sure we have SOME active enemies
    ld a, [wActiveBulletCounter]
    cp a, 0
    ret z

    ld a, 0
    ld [wUpdateBulletsCounter], a

    ; copy wBullets,  into wUpdateBulletsCurrentBulletAddress    
    ld a, LOW(wBullets)
    ld [wUpdateBulletsCurrentBulletAddress+0], a
    ld a, HIGH(wBullets)
    ld [wUpdateBulletsCurrentBulletAddress+1], a


    jp UpdateBullets_PerBullet

UpdateBullets_Loop:

    ; Check our coutner, if it's zero
    ; Stop the function
    ld a, [wUpdateBulletsCounter]
    inc a
    ld [wUpdateBulletsCounter], a

    ; Check if we've already
    ld a, [wUpdateBulletsCounter]
    cp a, MAX_BULLET_COUNT
    ret nc

    ; Increase the bullet data our address is pointingtwo
    ld a, [wUpdateBulletsCurrentBulletAddress+0]
    add a, PER_BULLET_BYTES_COUNT
    ld [wUpdateBulletsCurrentBulletAddress+0], a
    ld a, [wUpdateBulletsCurrentBulletAddress+1]
    adc a, 0
    ld [wUpdateBulletsCurrentBulletAddress+1], a


UpdateBullets_PerBullet:


    ; The first byte is if the bullet is active
    ; If it's zero, it's inactive, go to the loop section
    ld a, [wUpdateBulletsCurrentBulletAddress+0]
    ld l, a
    ld a, [wUpdateBulletsCurrentBulletAddress+1]
    ld h, a
    ld a, [hli]
    cp a, 0
    jp z, UpdateBullets_Loop

    ; Get our x position
    ld a, [hli]
    ld b, a

    ; get our 16-bit y position
    ld a, [hli]
    ld c, a
    ld a, [hld] ; 'hld' instead of 'hli' because we're going to re-set the y position afterwards
    ld d, a

    ; Decrease our y position by BULLET_MOVE_SPEED
    ld a, c
    sub a, BULLET_MOVE_SPEED
    ld c, a
    ld a, d
    sbc a, 0
    ld d, a

    ; set our new low and high bytes
    ld a, c
    ld [hli], a
    ld a, d
    ld [hli], a

    ; Descale our y position
    srl d
    rr c
    srl d
    rr c
    srl d
    rr c
    srl d
    rr c

    ; See if our non scaled low byte is above 160
    ld a, c
    cp a, 178
    ; If it below 160, continue on  to deactivate
    jp nc, UpdateBullets_DeActivateIfOutOfBounds
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Drawing a metasprite
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

     ; Save the address of the metasprite into the 'wMetaspriteAddress' variable
    ; Our DrawMetasprites functoin uses that variable
    ld a, LOW(bulletMetasprite)
    ld [wMetaspriteAddress+0], a
    ld a, HIGH(bulletMetasprite)
    ld [wMetaspriteAddress+1], a

    ; Save the x position
    ld a, b
    ld [wMetaspriteX],a

    ; Save the y position
    ld a, c
    ld [wMetaspriteY],a

    ; Actually call the 'DrawMetasprites function
    call DrawMetasprites;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Drawing a metasprite
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    

    
    jp UpdateBullets_Loop

UpdateBullets_DeActivateIfOutOfBounds:

 ; The first byte is if the bullet is active
    ; If it's zero, it's inactive, go to the loop section
    ld a, [wUpdateBulletsCurrentBulletAddress+0]
    ld l, a
    ld a, [wUpdateBulletsCurrentBulletAddress+1]
    ld h, a

    ; if it's y value is grater than 160
    ; Set as inactive
    ld a, 0
    ld [hl], a

    ; Decrease counter
    ld a,[wActiveBulletCounter]
    dec a
    ld [wActiveBulletCounter], a

    jp UpdateBullets_Loop
    
FireNextBullet::

    ; Make sure we don't have the max amount of enmies
    ld a, [wActiveBulletCounter]
    cp a, MAX_BULLET_COUNT
    ret nc

    push bc
    push de
    push hl

    ld a, 0
    ld [wUpdateBulletsCounter], a

    ld hl, wBullets

FireNextBullet_Loop:

    ld a, [hl]
    cp a, 0
    jp nz, FireNextBullet_NextBullet

    ; Set as  active
    ld a, 1
    ld [hli], a

    ; Set the x position
    ld a, [wNextBullet.x]
    ld [hli], a

    ; Set the y position (low)
    ld a, [wNextBullet.y+0]
    ld [hli], a

    ;Set the y position (high)
    ld a, [wNextBullet.y+1]
    ld [hli], a

    
    ; Increase counter
    ld a,[wActiveBulletCounter]
    inc a
    ld [wActiveBulletCounter], a


    jp FireNextBullet_End


FireNextBullet_NextBullet:

    ; Increase the address
    ld a, l
    add a, PER_BULLET_BYTES_COUNT
    ld l, a
    ld a, h
    adc a, 0
    ld h, a

    ld a,[wUpdateBulletsCounter]
    inc a
    ld [wUpdateBulletsCounter], a

    ld a,[wUpdateBulletsCounter]
    cp a, MAX_BULLET_COUNT
    jp nc,FireNextBullet_End

    jp FireNextBullet_Loop

FireNextBullet_End:


    pop hl
    pop de
    pop bc

    ret