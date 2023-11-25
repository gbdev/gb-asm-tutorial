
SECTION "Text", ROM0


; ANCHOR: draw-text-tiles
DrawTextInHL_AtDE::

    ; Check for the end of string character 255
    ld a, [hl]
    cp 255
    ret z

    ; Write the current character (in hl) to the address
    ; on the tilemap (in de)
    ld a, [hl]
    ld [de], a

    inc hl
    inc de

    ; move to the next character and next background tile
    jp DrawTextInHL_AtDE
; ANCHOR_END: draw-text-tiles

; ANCHOR: typewriter-effect
DrawText_WithTypewriterEffect::

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Wait a small amount of time
    ; Save our count in this variable
    ld a, 3
    ld [wVBlankCount], a

    ; Call our function that performs the code
    call WaitForVBlankFunction
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    
    ; Check for the end of string character 255
    ld a, [hl]
    cp 255
    ret z

    ; Write the current character (in hl) to the address
    ; on the tilemap (in de)
    ld a, [hl]
    ld [de], a

    ; move to the next character and next background tile
    inc hl
    inc de

    jp DrawText_WithTypewriterEffect
; ANCHOR_END: typewriter-effect
