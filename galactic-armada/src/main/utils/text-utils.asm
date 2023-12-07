
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
TypewriteTextInHL_AtDE::

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

    jp TypewriteTextInHL_AtDE
; ANCHOR_END: typewriter-effect


; ANCHOR: multiline-typewriter-effect
MultilineTypewriteTextInHL_AtDE::

    ; Save where we are writing to, the "current line"
    push de 
    
MultilineTypewriteTextInHL_AtDE_NewLine:

    call TypewriteTextInHL_AtDE

    ; hl should point to a 255 after `TypewriteTextInHL_AtDE`
    ; move past that 255
    inc hl

    ; Restore the "current line"    
    pop de
    
    ; Check for the end of string character 255
    ; consecutive 255's mean were all done
    ld a, [hl]
    cp 255
    ret z

    ; Skip a line
    ld a, 64
    add a, e
    ld e, a

    ; Save where we are writing to, the "current line"
    push de

    ; continue until we read those consecutive 255's
    jp MultilineTypewriteTextInHL_AtDE_NewLine
; ANCHOR_END: multiline-typewriter-effect