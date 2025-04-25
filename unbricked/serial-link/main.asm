INCLUDE "hardware.inc"

; BG Tile IDs
RSSET 16
DEF BG_SOLID_0  RB 1
DEF BG_SOLID_1  RB 1
DEF BG_SOLID_2  RB 1
DEF BG_SOLID_3  RB 1
DEF BG_EMPTY    RB 1
DEF BG_TICK     RB 1
DEF BG_CROSS    RB 1
DEF BG_INTERNAL RB 1
DEF BG_EXTERNAL RB 1
DEF BG_INBOX    RB 1
DEF BG_OUTBOX   RB 1

; BG map positions (addresses) of various info
DEF DISPLAY_LINK      EQU $9800
DEF DISPLAY_LOCAL     EQU DISPLAY_LINK
DEF DISPLAY_REMOTE    EQU DISPLAY_LOCAL + 32
DEF DISPLAY_CLOCK_SRC EQU DISPLAY_LINK + 18
DEF DISPLAY_TX        EQU DISPLAY_LINK + 32 * 2
DEF DISPLAY_TX_STATE  EQU DISPLAY_TX + 1
DEF DISPLAY_TX_ERRORS EQU DISPLAY_TX + 18
DEF DISPLAY_TX_BUFFER EQU DISPLAY_TX + 32
DEF DISPLAY_RX        EQU DISPLAY_LINK + 32 * 6
DEF DISPLAY_RX_STATE  EQU DISPLAY_RX + 1
DEF DISPLAY_RX_ERRORS EQU DISPLAY_RX + 18
DEF DISPLAY_RX_BUFFER EQU DISPLAY_RX + 32

; ANCHOR: serial-demo-defs
; Link finite state machine modes
DEF LINKST_MODE         EQU $03 ; Mask mode bits
DEF LINKST_MODE_DOWN    EQU $00 ; Inactive / disconnected
DEF LINKST_MODE_CONNECT EQU $01 ; Establishing link (handshake)
DEF LINKST_MODE_UP      EQU $02 ; Connected
DEF LINKST_MODE_ERROR   EQU $03 ; Fatal error occurred.
; Indicates current msg type (SYNC / DATA). If set, the next message sent will be SYNC.
DEF LINKST_STEP_SYNC    EQU $08
; Set when transmitting a DATA packet. Cleared when remote sends acknowledgement via SYNC.
DEF LINKST_TX_ACT       EQU $10
; Flag set when a MSG_DATA packet is received. Automatically cleared next LinkUpdate.
DEF LINKST_RX_DATA      EQU $20
; Default/initial Link state
DEF LINKST_DEFAULT EQU LINKST_MODE_CONNECT

; Maximum number of times to attempt TxData packet transmission.
DEF LINK_ALLOW_TX_ATTEMPTS EQU 4
; Rx fault error threshold
DEF LINK_ALLOW_RX_FAULTS EQU 4

DEF MSG_SYNC EQU $A0
DEF MSG_SHAKE EQU $B0
DEF MSG_DATA EQU $C0
; ANCHOR_END: serial-demo-defs

; ANCHOR: handshake-codes
; Handshake code sent by internally clocked device (clock provider)
DEF SHAKE_A EQU $88
; Handshake code sent by externally clocked device
DEF SHAKE_B EQU $77
DEF HANDSHAKE_COUNT EQU 5
DEF HANDSHAKE_FAILED EQU $F0
; ANCHOR_END: handshake-codes


; ANCHOR: serial-interrupt-vector
SECTION "Serial Interrupt", ROM0[$58]
SerialInterrupt:
	push af
	push hl
	call SioPortEnd
	pop hl
	pop af
	reti
; ANCHOR_END: serial-interrupt-vector


SECTION "Header", ROM0[$100]

	jp EntryPoint

	ds $150 - @, 0 ; Make room for the header

EntryPoint:
	; Do not turn the LCD off outside of VBlank
WaitVBlank:
	ld a, [rLY]
	cp 144
	jp c, WaitVBlank

	; Turn the LCD off
	ld a, 0
	ld [rLCDC], a

	; Copy the tile data
	ld de, Tiles
	ld hl, $9000
	ld bc, TilesEnd - Tiles
	call Memcopy

	; clear BG tilemap
	ld hl, $9800
	ld b, 32
	xor a, a
	ld a, BG_SOLID_0
.clear_row
	ld c, 32
.clear_tile
	ld [hl+], a
	dec c
	jr nz, .clear_tile
	xor a, 1
	dec b
	jr nz, .clear_row

	; display static elements
	ld a, BG_OUTBOX
	ld [DISPLAY_TX], a
	ld a, BG_INBOX
	ld [DISPLAY_RX], a
	ld a, BG_CROSS
	ld [DISPLAY_RX_ERRORS - 1], a

	xor a, a
	ld b, 160
	ld hl, _OAMRAM
.clear_oam
	ld [hli], a
	dec b
	jp nz, .clear_oam

	; Turn the LCD on
	ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
	ld [rLCDC], a

	; During the first (blank) frame, initialize display registers
	ld a, %11100100
	ld [rBGP], a
	ld a, %11100100
	ld [rOBP0], a

	; Initialize global variables
	ld a, 0
	ld [wFrameCounter], a
	ld [wCurKeys], a
	ld [wNewKeys], a

; ANCHOR: serial-demo-init-callsite
	call LinkInit

Main:
; ANCHOR_END: serial-demo-init-callsite
	ld a, [rLY]
	cp 144
	jp nc, Main

; ANCHOR: serial-demo-update-callsite
	call Input
	call MainUpdate
; ANCHOR_END: serial-demo-update-callsite
WaitVBlank2:
	ld a, [rLY]
	cp 144
	jp c, WaitVBlank2

	call LinkDisplay
	ld a, [wFrameCounter]
	inc a
	ld [wFrameCounter], a
	jp Main


; ANCHOR: serial-demo-update
MainUpdate:
	; if B is pressed, reset Link
	ld a, [wNewKeys]
	and a, PADF_B
	jp nz, LinkReset

	call LinkUpdate
	; If Link in error state, do nothing
	ld a, [wLocal.state]
	and a, LINKST_MODE
	cp a, LINKST_MODE_ERROR
	ret z
	; send the next data packet if Link is ready
	ld a, [wLocal.state]
	and a, LINKST_TX_ACT
	ret nz
	; Write next message to TxData
	ld hl, wTxData
	ld a, [wCurKeys]
	and a, PADF_RIGHT | PADF_LEFT | PADF_UP | PADF_DOWN
	ld [hl+], a
	ld a, [hl]
	rlca
	inc a
	ld [hl+], a
	jp LinkTxStart
; ANCHOR_END: serial-demo-update


; ANCHOR: link-init
LinkInit:
	call SioInit

	; enable the serial interrupt
	ldh a, [rIE]
	or a, IEF_SERIAL
	ldh [rIE], a
	; enable interrupt processing globally
	ei

LinkReset:
	call SioReset
	; reset peers
	ld a, LINKST_DEFAULT
	ld [wLocal.state], a
	ld [wRemote.state], a
	ld a, $FF
	ld [wLocal.tx_id], a
	ld [wLocal.rx_id], a
	ld [wRemote.tx_id], a
	ld [wRemote.rx_id], a
	; clear faults and retry counter
	ld a, 0
	ld [wAllowTxAttempts], a
	ld a, LINK_ALLOW_RX_FAULTS
	ld [wAllowRxFaults], a
	; clear message buffers
	ld a, 0
	ld hl, wTxData
	ld c, wTxData.end - wTxData
	call Memfill
	ld hl, wRxData
	ld c, wRxData.end - wRxData
	call Memfill
	; go straight to handshake
	jp HandshakeDefault
; ANCHOR_END: link-init


; ANCHOR: link-error-stop
; Stop Link because of an unrecoverable error.
; @mut: AF
LinkErrorStop:
	ld a, [wLocal.state]
	and a, $FF ^ LINKST_MODE
	or a, LINKST_MODE_ERROR
	ld [wLocal.state], a
	jp SioAbort
; ANCHOR_END: link-error-stop


; ANCHOR: link-update
LinkUpdate:
	ld a, [wLocal.state]
	and a, LINKST_MODE
	cp a, LINKST_MODE_ERROR
	ret z

	; clear data received flag
	ld a, [wLocal.state]
	and a, $FF ^ LINKST_RX_DATA
	ld [wLocal.state], a

	call SioTick
	ld a, [wLocal.state]
	and a, LINKST_MODE
	cp a, LINKST_MODE_CONNECT
	jr z, .link_connect
	cp a, LINKST_MODE_UP
	jr z, .link_up
	ret

.link_up
	; handle Sio transfer states
	ld a, [wSioState]
	cp a, SIO_DONE
	jp z, LinkRx
	cp a, SIO_FAILED
	jp z, LinkErrorStop
	cp a, SIO_IDLE
	jp z, LinkTx
	ret
.link_connect
	ld a, [wHandshakeState]
	and a, a
	jp nz, HandshakeUpdate
	; handshake complete, enter UP state
	ld a, [wLocal.state]
	and a, $FF ^ LINKST_MODE
	or a, LINKST_MODE_UP
	ld [wLocal.state], a
	ld a, 0
	ret
; ANCHOR_END: link-update


; ANCHOR: link-tx-start
; Request transmission of TxData.
; @mut: AF
LinkTxStart::
	ld a, [wLocal.state]
	or a, LINKST_TX_ACT
	ld [wLocal.state], a
	ld a, LINK_ALLOW_TX_ATTEMPTS
	ld [wAllowTxAttempts], a
	ld a, [wLocal.tx_id]
	inc a
	ld [wLocal.tx_id], a
	ret
; ANCHOR_END: link-tx-start


; ANCHOR: link-send-message
LinkTx:
	ld a, [wLocal.state]
	ld c, a
	; if STEP_SYNC flag, do sync
	and a, LINKST_STEP_SYNC
	jr nz, .sync
	; if nothing to send, do sync
	ld a, c
	and a, LINKST_TX_ACT
	jr z, .sync

	ld a, [wAllowTxAttempts]
	and a, a
	jp z, LinkErrorStop
	dec a
	ld [wAllowTxAttempts], a
	; ensure sync follows
	ld a, c
	or a, LINKST_STEP_SYNC
	ld [wLocal.state], a
.data:
	call SioPacketTxPrepare
	ld a, MSG_DATA
	ld [hl+], a
	ld a, [wLocal.tx_id]
	ld [hl+], a
	; copy from wTxData buffer
	ld de, wTxData
	ld c, wTxData.end - wTxData
:
	ld a, [de]
	inc de
	ld [hl+], a
	dec c
	jr nz, :-
	call SioPacketTxFinalise
	ret
.sync:
	ld a, c
	and a, $FF ^ LINKST_STEP_SYNC
	ld [wLocal.state], a

	call SioPacketTxPrepare
	ld a, MSG_SYNC
	ld [hl+], a
	ld a, [wLocal.state]
	ld [hl+], a
	ld a, [wLocal.tx_id]
	ld [hl+], a
	ld a, [wLocal.rx_id]
	ld [hl+], a
	call SioPacketTxFinalise
	ret
; ANCHOR_END: link-send-message


; ANCHOR: link-receive-message
; Process received packet
; @mut: AF, BC, HL
LinkRx:
	ld a, SIO_IDLE
	ld [wSioState], a

	call SioPacketRxCheck
	jr nz, .fault
.check_passed:
	ld a, [hl+]
	cp a, MSG_SYNC
	jr z, .rx_sync
	cp a, MSG_DATA
	jr z, .rx_data
	; invalid message type
.fault:
	ld a, [wAllowRxFaults]
	and a, a
	jp z, LinkErrorStop
	dec a
	ld [wAllowRxFaults], a
	ret
; handle MSG_SYNC
.rx_sync:
	; Update remote state (always to newest)
	ld a, [hl+]
	ld [wRemote.state], a
	ld a, [hl+]
	ld [wRemote.tx_id], a
	ld a, [hl+]
	ld [wRemote.rx_id], a
	ld b, a

	ld a, [wLocal.state]
	ld c, a
	and a, LINKST_TX_ACT
	ret z ; not waiting
	ld a, [wLocal.tx_id]
	cp a, b
	ret nz
	ld a, c
	and a, $FF ^ LINKST_TX_ACT
	ld [wLocal.state], a
	ret
; handle MSG_DATA
.rx_data:
	; save message ID
	ld a, [hl+]
	ld [wLocal.rx_id], a

	; copy data to buffer
	ld de, wRxData
	ld c, wRxData.end - wRxData
:
	ld a, [hl+]
	ld [de], a
	inc de
	dec c
	jr nz, :-

	; set data received flag
	ld a, [wLocal.state]
	or a, LINKST_RX_DATA
	ld [wLocal.state], a
	ret
; ANCHOR_END: link-receive-message


; @param A: value
; @param C: length
; @param HL: from address
; @mut: C, HL
Memfill:
	ld [hl+], a
	dec c
	jr nz, Memfill
	ret


LinkDisplay:
	ld hl, DISPLAY_CLOCK_SRC
	call DrawClockSource
	ld a, [wFrameCounter]
	rrca
	rrca
	and 2
	add BG_SOLID_1
	ld [hl+], a

	ld hl, DISPLAY_LOCAL
	ld a, [wLocal.state]
	call DrawLinkState
	inc hl
	ld a, [wLocal.tx_id]
	ld b, a
	call PrintHex
	inc hl
	ld a, [wLocal.rx_id]
	ld b, a
	call PrintHex

	ld hl, DISPLAY_REMOTE
	ld a, [wRemote.state]
	call DrawLinkState
	inc hl
	ld a, [wRemote.tx_id]
	ld b, a
	call PrintHex
	inc hl
	ld a, [wRemote.rx_id]
	ld b, a
	call PrintHex

	ld hl, DISPLAY_TX_STATE
	ld a, [wTxData.id]
	ld b, a
	call PrintHex
	inc hl
	ld a, [wTxData.value]
	ld b, a
	call PrintHex
	ld hl, DISPLAY_TX_ERRORS
	ld a, [wAllowTxAttempts]
	ld b, a
	call PrintHex

	ld hl, DISPLAY_RX_STATE
	ld a, [wRxData.id]
	ld b, a
	call PrintHex
	inc hl
	ld a, [wRxData.value]
	ld b, a
	call PrintHex
	ld hl, DISPLAY_RX_ERRORS
	ld a, [wAllowRxFaults]
	ld b, a
	call PrintHex

	ld a, [wFrameCounter]
	and a, $01
	jp z, DrawBufferTx
	jp DrawBufferRx


; Draw Link state
; @param A: value
; @param HL: dest
; @mut: AF, B, HL
DrawLinkState:
	and a, LINKST_MODE
	cp a, LINKST_MODE_CONNECT
	jr nz, :+
	ld a, [wHandshakeState]
	and $0F
	ld [hl+], a
	ret
:
	ld b, BG_EMPTY
	cp a, LINKST_MODE_DOWN
	jr z, .end
	ld b, BG_TICK
	cp a, LINKST_MODE_UP
	jr z, .end
	ld b, BG_CROSS
	cp a, LINKST_MODE_ERROR
	jr z, .end
	ld b, a
	jp PrintHex
.end
	ld a, b
	ld [hl+], a
	ret


; @param HL: dest
; @mut AF, HL
DrawClockSource:
	ldh a, [rSC]
	and SCF_SOURCE
	ld a, BG_EXTERNAL
	jr z, :+
	ld a, BG_INTERNAL
:
	ld [hl+], a
	ret


; @mut: AF, BC, DE, HL
DrawBufferTx:
	ld de, wSioBufferTx
	ld hl, DISPLAY_TX_BUFFER
	ld c, 8
.loop_tx
	ld a, [de]
	inc de
	ld b, a
	call PrintHex
	dec c
	jr nz, .loop_tx
	ret


; @mut: AF, BC, DE, HL
DrawBufferRx:
	ld de, wSioBufferRx
	ld hl, DISPLAY_RX_BUFFER
	ld c, 8
.loop_rx
	ld a, [de]
	inc de
	ld b, a
	call PrintHex
	dec c
	jr nz, .loop_rx
	ret


; Increment the byte at [HL], if it's less than the upper bound (B).
; Input values greater than (B) will be clamped.
; @param B: upper bound (inclusive)
; @param HL: pointer to value
; @return F.Z: (result == bound)
; @return F.C: (result < bound)
u8ptr_IncrementTo:
	ld a, [hl]
	inc a
	jr z, .clampit ; catch overflow (value was 255)
	cp a, b
	jr nc, .clampit ; value >= bound
	ret c ; value < bound
.clampit
	ld [hl], b
	xor a, a ; return Z, NC
	ret


; @param B: value
; @param HL: dest
; @mut: AF, HL
PrintHex:
	ld a, b
	swap a
	and a, $0F
	ld [hl+], a
	ld a, b
	and a, $0F
	ld [hl+], a
	ret


Input:
	; Poll half the controller
	ld a, P1F_GET_BTN
	call .onenibble
	ld b, a ; B7-4 = 1; B3-0 = unpressed buttons

	; Poll the other half
	ld a, P1F_GET_DPAD
	call .onenibble
	swap a ; A3-0 = unpressed directions; A7-4 = 1
	xor a, b ; A = pressed buttons + directions
	ld b, a ; B = pressed buttons + directions

	; And release the controller
	ld a, P1F_GET_NONE
	ldh [rP1], a

	; Combine with previous wCurKeys to make wNewKeys
	ld a, [wCurKeys]
	xor a, b ; A = keys that changed state
	and a, b ; A = keys that changed to pressed
	ld [wNewKeys], a
	ld a, b
	ld [wCurKeys], a
	ret

.onenibble
	ldh [rP1], a ; switch the key matrix
	call .knownret ; burn 10 cycles calling a known ret
	ldh a, [rP1] ; ignore value while waiting for the key matrix to settle
	ldh a, [rP1]
	ldh a, [rP1] ; this read counts
	or a, $F0 ; A7-4 = 1; A3-0 = unpressed keys
.knownret
	ret

; Copy bytes from one area to another.
; @param de: Source
; @param hl: Destination
; @param bc: Length
Memcopy:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, Memcopy
	ret

Tiles:
	; Hexadecimal digits (0123456789ABCDEF)
	dw $0000, $1c1c, $2222, $2222, $2a2a, $2222, $2222, $1c1c
	dw $0000, $0c0c, $0404, $0404, $0404, $0404, $0404, $0e0e
	dw $0000, $1c1c, $2222, $0202, $0202, $1c1c, $2020, $3e3e
	dw $0000, $1c1c, $2222, $0202, $0c0c, $0202, $2222, $1c1c
	dw $0000, $2020, $2020, $2828, $2828, $3e3e, $0808, $0808
	dw $0000, $3e3e, $2020, $3e3e, $0202, $0202, $0404, $3838
	dw $0000, $0c0c, $1010, $2020, $3c3c, $2222, $2222, $1c1c
	dw $0000, $3e3e, $2222, $0202, $0202, $0404, $0808, $1010
	dw $0000, $1c1c, $2222, $2222, $1c1c, $2222, $2222, $1c1c
	dw $0000, $1c1c, $2222, $2222, $1e1e, $0202, $0202, $0202
	dw $0000, $1c1c, $2222, $2222, $4242, $7e7e, $4242, $4242
	dw $0000, $7c7c, $2222, $2222, $2424, $3a3a, $2222, $7c7c
	dw $0000, $1c1c, $2222, $4040, $4040, $4040, $4242, $3c3c
	dw $0000, $7c7c, $2222, $2222, $2222, $2222, $2222, $7c7c
	dw $0000, $7c7c, $4040, $4040, $4040, $7878, $4040, $7c7c
	dw $0000, $7c7c, $4040, $4040, $4040, $7878, $4040, $4040

	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000

	dw `11111111
	dw `11111111
	dw `11111111
	dw `11111111
	dw `11111111
	dw `11111111
	dw `11111111
	dw `11111111

	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222222

	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333

	; empty
	dw `00000000
	dw `01111110
	dw `21000210
	dw `21000210
	dw `21000210
	dw `21000210
	dw `21111110
	dw `22222200

	; tick
	dw `00000000
	dw `01111113
	dw `21000233
	dw `21000330
	dw `33003310
	dw `21333110
	dw `21131110
	dw `22222200

	; cross
	dw `03000000
	dw `03311113
	dw `21330330
	dw `21033210
	dw `21333210
	dw `33003310
	dw `21111310
	dw `22222200

	; internal
	dw `03333333
	dw `01223333
	dw `00033300
	dw `00033300
	dw `00023300
	dw `00023300
	dw `03333333
	dw `01223333

	; external
	dw `03333221
	dw `03333333
	dw `03300000
	dw `03333210
	dw `03333330
	dw `03300000
	dw `03333221
	dw `03333333

	; inbox
	dw `33330003
	dw `30000030
	dw `30030300
	dw `30033000
	dw `30033303
	dw `30000003
	dw `30000003
	dw `33333333

	; outbox
	dw `33330333
	dw `30000033
	dw `30000303
	dw `30003000
	dw `30030003
	dw `30000003
	dw `30000003
	dw `33333333
TilesEnd:


SECTION "Counter", WRAM0
wFrameCounter: db

SECTION "Input Variables", WRAM0
wCurKeys: db
wNewKeys: db

; ANCHOR: serial-demo-wram
SECTION "Link", WRAM0
; Local peer state
wLocal:
	.state: db
	.tx_id: db
	.rx_id: db
; Remote peer state
wRemote:
	.state: db
	.tx_id: db
	.rx_id: db

; Buffer for outbound MSG_DATA
wTxData:
	.id: db
	.value: db
	.end:
; Buffer for inbound MSG_DATA
wRxData:
	.id: db
	.value: db
	.end:

wAllowTxAttempts: db
wAllowRxFaults: db
; ANCHOR_END: serial-demo-wram


; ANCHOR: handshake-state
SECTION "Handshake State", WRAM0
wHandshakeState:: db
; ANCHOR_END: handshake-state


; ANCHOR: handshake-begin
SECTION "Handshake Impl", ROM0
; Begin handshake as the default externally clocked device.
HandshakeDefault:
	call SioAbort
	ld a, 0
	ldh [rSC], a
	ld a, HANDSHAKE_COUNT
	ld [wHandshakeState], a
	jr HandshakeSendPacket


; Begin handshake as the clock provider / internally clocked device.
HandshakeAsClockProvider:
	call SioAbort
	ld a, SCF_SOURCE
	ldh [rSC], a
	ld a, HANDSHAKE_COUNT
	ld [wHandshakeState], a
	jr HandshakeSendPacket


HandshakeSendPacket:
	call SioPacketTxPrepare
	ld a, MSG_SHAKE
	ld [hl+], a
	ld b, SHAKE_A
	ldh a, [rSC]
	and a, SCF_SOURCE
	jr nz, :+
	ld b, SHAKE_B
:
	ld [hl], b
	jp SioPacketTxFinalise
; ANCHOR_END: handshake-begin


; ANCHOR: handshake-update
HandshakeUpdate:
	; press START: perform handshake as clock provider
	ld a, [wNewKeys]
	bit PADB_START, a
	jr nz, HandshakeAsClockProvider
	; Check if transfer has completed.
	ld a, [wSioState]
	cp a, SIO_DONE
	jr z, HandshakeMsgRx
	cp a, SIO_ACTIVE
	ret z
	; Use DIV to "randomly" try being the clock provider
	ldh a, [rDIV]
	rrca
	jr c, HandshakeAsClockProvider
	jr HandshakeDefault
; ANCHOR_END: handshake-update


; ANCHOR: handshake-xfer-complete
HandshakeMsgRx:
	; flush sio status
	ld a, SIO_IDLE
	ld [wSioState], a
	call SioPacketRxCheck
	jr nz, .failed
	ld a, [hl+]
	cp a, MSG_SHAKE
	jr nz, .failed
	ld b, SHAKE_A
	ldh a, [rSC]
	and a, SCF_SOURCE
	jr z, :+
	ld b, SHAKE_B
:
	ld a, [hl+]
	cp a, b
	jr nz, .failed
	ld a, [wHandshakeState]
	dec a
	ld [wHandshakeState], a
	jr nz, HandshakeSendPacket
	ret
.failed
	ld a, [wHandshakeState]
	or a, HANDSHAKE_FAILED
	ld [wHandshakeState], a
	ret
; ANCHOR_END: handshake-xfer-complete
