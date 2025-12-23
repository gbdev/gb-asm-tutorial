
SECTION "MathVariables", WRAM0
randstate:: ds 4

SECTION "Math", ROM0


;; From: https://github.com/pinobatch/libbet/blob/master/src/rand.z80#L34-L54
; Generates a pseudorandom 16-bit integer in BC
; using the LCG formula from cc65 rand():
; x[i + 1] = x[i] * 0x01010101 + 0xB3B3B3B3
; @return A=B=state bits 31-24 (which have the best entropy),
; C=state bits 23-16, HL trashed
rand::
  ; Add 0xB3 then multiply by 0x01010101
  ld hl, randstate
  ld a, [hl]
  add $B3
  ld [hl+], a
  adc [hl]
  ld [hl+], a
  adc [hl]
  ld [hl+], a
  ld c, a
  adc [hl]
  ld [hl], a
  ld b, a
  ret
