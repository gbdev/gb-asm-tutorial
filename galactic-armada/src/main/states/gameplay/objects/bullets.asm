
; ANCHOR: bullets-top
include "src/main/utils/hardware.inc"
include "src/main/utils/constants.inc"

SECTION "BulletVariables", WRAM0

wSpawnBullet:db

; how many bullets are currently active
wActiveBulletCounter:: db

; how many bullet's we've updated
wUpdateBulletsCounter:db 

; Bytes: active, x , y (low), y (high)
wBullets:: ds MAX_BULLET_COUNT*PER_BULLET_BYTES_COUNT

SECTION "Bullets", ROM0

bulletMetasprite::
    .metasprite1    db 0,0,8,0
    .metaspriteEnd  db 128

bulletTileData:: INCBIN "src/generated/sprites/bullet.2bpp"
bulletTileDataEnd::


; ANCHOR_END: bullets-top

; ANCHOR: bullets-initialize
InitializeBullets::

    ld a, 0
    ld [wSpawnBullet], a

    ; Copy the bullet tile data intto vram
	ld de, bulletTileData
	ld hl, BULLET_TILES_START
	ld bc, bulletTileDataEnd - bulletTileData
    call CopyDEintoMemoryAtHL

    ; Reset how many bullets are active to 0
    ld a,0
    ld [wActiveBulletCounter],a

    ld b, 0
    ld hl, wBullets

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
; ANCHOR_END: bullets-initialize

; ANCHOR: bullets-update-start
UpdateBullets::

    ; Make sure we have SOME active enemies
    ld a, [wSpawnBullet]
    ld b, a
    ld a, [wActiveBulletCounter]
    or a,b
    cp a, 0
    ret z
    
    ; Reset our counter for how many bullets we have checked
    ld a, 0
    ld [wUpdateBulletsCounter], a

    ; Get the address of the first bullet in hl
    ld a, LOW(wBullets)
    ld l,  a
    ld a, HIGH(wBullets)
    ld h, a

    jp UpdateBullets_PerBullet
; ANCHOR_END: bullets-update-start

; ANCHOR: bullets-update-loop
UpdateBullets_Loop:

    ; Check our counter, if it's zero
    ; Stop the function
    ld a, [wUpdateBulletsCounter]
    inc a
    ld [wUpdateBulletsCounter], a

    ; Check if we've already
    ld a, [wUpdateBulletsCounter]
    cp a, MAX_BULLET_COUNT
    ret nc

    ; Increase the bullet data our address is pointingtwo
    ld a, l
    add a, PER_BULLET_BYTES_COUNT
    ld l, a
    ld a, h
    adc a, 0
    ld h, a
; ANCHOR_END: bullets-update-loop

; ANCHOR: bullets-update-per
UpdateBullets_PerBullet:

    ; The first byte is if the bullet is active
    ; If it's NOT  zero, it's active, go to the normal update section
    ld a, [hl]
    cp a, 0
    jp nz, UpdateBullets_PerBullet_Normal

    ; Do we need to spawn a bullet?
    ; If we dont, loop to the next enemy
    ld a, [wSpawnBullet]
    cp a, 0
    jp z, UpdateBullets_Loop
    
UpdateBullets_PerBullet_SpawnDeactivatedBullet:

    ; reset this variable so we don't spawn anymore
    ld a, 0
    ld [wSpawnBullet], a
    
    ; Increase how many bullets are active
    ld a,[wActiveBulletCounter]
    inc a
    ld [wActiveBulletCounter], a

    push hl

    ; Set the current bullet as  active
    ld a, 1
    ld [hli], a

    ; Get the unscaled player x position in b
    ld a, [wPlayerPositionX+0]
    ld b, a
    ld a, [wPlayerPositionX+1]
    ld d, a
    
    ; Descale the player's x position
    ; the result will only be in the low byt
    srl d
    rr b
    srl d
    rr b
    srl d
    rr b
    srl d
    rr b
    
    ; Set the x position to equal the player's x position
    ld a, b
    ld [hli], a

    ; Set the y position (low)
    ld a, [wPlayerPositionY+0]
    ld [hli], a

    ;Set the y position (high)
    ld a, [wPlayerPositionY+1]
    ld [hli], a

    pop hl

UpdateBullets_PerBullet_Normal:

    ; Save our active byte
    push hl

    inc hl

    ; Get our x position
    ld a, [hli]
    ld b, a

    ; get our 16-bit y position
    ld a, [hl]
    sub a, BULLET_MOVE_SPEED
    ld [hli], a
    ld c, a
    ld a, [hl] 
    sbc a, 0
    ld [hl], a
    ld d, a

    pop hl; go to the active byte

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
    
; ANCHOR_END: bullets-update-per
; ANCHOR: draw-bullets

    push hl

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
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    

    pop hl
    
    jp UpdateBullets_Loop
; ANCHOR_END: draw-bullets

; ANCHOR: deactivate-bullets
UpdateBullets_DeActivateIfOutOfBounds:

    ; if it's y value is grater than 160
    ; Set as inactive
    ld a, 0
    ld [hl], a

    ; Decrease counter
    ld a,[wActiveBulletCounter]
    dec a
    ld [wActiveBulletCounter], a

    jp UpdateBullets_Loop
; ANCHOR_END: deactivate-bullets
    
; ANCHOR: fire-bullets
FireNextBullet::

    ; Make sure we don't have the max amount of enmies
    ld a, [wActiveBulletCounter]
    cp a, MAX_BULLET_COUNT
    ret nc

    ; Set our spawn bullet variable to true
    ld a, 1
    ld [wSpawnBullet], a

    ret
; ANCHOR_END: fire-bullets