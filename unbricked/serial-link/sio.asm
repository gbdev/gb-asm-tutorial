; ::::::::::::::::::::::::::::::::::::::
; ::                                  ::
; ::                       ______.    ::
; ::       _              |````` ||   ::
; ::     _/ \__@_         |[- - ]||   ::
; ::    /        `--<[|]= |[ m  ]||   ::
; ::    \      .______    | ```` ||   ::
; ::    /     !| `````|   | +  oo||   ::
; ::   (      ||[ ^u^]|   |  .. #||   ::
; ::    `-<[|]=|[    ]|   `______//   ::
; ::          || ```` |               ::
; ::          || +  oo|               ::
; ::          ||  .. #|               ::
; ::          !|______/               ::
; ::                                  ::
; ::                                  ::
; ::::::::::::::::::::::::::::::::::::::

; ANCHOR: sio-status-enum
INCLUDE "hardware.inc"

DEF SIO_IDLE      EQU $00
DEF SIO_DONE      EQU $01
DEF SIO_FAILED    EQU $02
DEF SIO_RESET     EQU $03
DEF SIO_ACTIVE    EQU $80
EXPORT SIO_IDLE, SIO_DONE, SIO_FAILED, SIO_ACTIVE
; ANCHOR_END: sio-status-enum

; ANCHOR: sio-port-start-defs
; ANCHOR: sio-timeout-duration
; Duration of timeout period in ticks
DEF SIO_TIMEOUT_TICKS EQU 60
; ANCHOR_END: sio-timeout-duration

; ANCHOR: sio-catchup-duration
; Catchup delay duration
DEF SIO_CATCHUP_SLEEP_DURATION EQU 200
; ANCHOR_END: sio-catchup-duration
; ANCHOR_END: sio-port-start-defs

; ANCHOR: sio-buffer-defs
; Allocated size in bytes of the Tx and Rx data buffers.
DEF SIO_BUFFER_SIZE EQU 32
; A slightly identifiable value to clear the buffers to.
DEF SIO_BUFFER_CLEAR EQU $EE
; ANCHOR_END: sio-buffer-defs

; ANCHOR: sio-packet-defs
DEF SIO_PACKET_HEAD_SIZE EQU 2
DEF SIO_PACKET_DATA_SIZE EQU SIO_BUFFER_SIZE - SIO_PACKET_HEAD_SIZE

DEF SIO_PACKET_START EQU $70
DEF SIO_PACKET_END EQU $7F
; ANCHOR_END: sio-packet-defs


; ANCHOR: sio-buffers
SECTION "SioBufferRx", WRAM0, ALIGN[8]
wSioBufferRx:: ds SIO_BUFFER_SIZE


SECTION "SioBufferTx", WRAM0, ALIGN[8]
wSioBufferTx:: ds SIO_BUFFER_SIZE
; ANCHOR_END: sio-buffers


; ANCHOR: sio-state
SECTION "SioCore State", WRAM0
; Sio state machine current state
wSioState:: db
; Number of transfers to perform (bytes to transfer)
wSioCount:: db
; Current position in the tx/rx buffers
wSioBufferOffset:: db
; Timer state (as ticks remaining, expires at zero) for timeouts.
wSioTimer:: db
; ANCHOR_END: sio-state


; ANCHOR: sio-impl-init
SECTION "SioCore Impl", ROM0
; Initialise/reset Sio to the ready to use 'IDLE' state.
; @mut: AF, C, HL
SioInit::
	call SioReset
	ld a, SIO_IDLE
	ld [wSioState], a
	ret


; Completely reset Sio. Any active transfer will be stopped.
; Sio will return to the `SIO_IDLE` state on the next call to `SioTick`.
; @mut: AF, C, HL
SioReset::
	; bring the serial port down
	ldh a, [rSC]
	res SCB_START, a
	ldh [rSC], a
	; reset Sio state variables
	ld a, SIO_RESET
	ld [wSioState], a
	ld a, 0
	ld [wSioTimer], a
	ld [wSioCount], a
	ld [wSioBufferOffset], a
; ANCHOR_END: sio-impl-init
; ANCHOR: sio-reset-buffers
	; clear the Tx buffer
	ld hl, wSioBufferTx
	ld c, SIO_BUFFER_SIZE
	ld a, SIO_BUFFER_CLEAR
:
	ld [hl+], a
	dec c
	jr nz, :-
	; clear the Rx buffer
	ld hl, wSioBufferRx
	ld c, SIO_BUFFER_SIZE
	ld a, SIO_BUFFER_CLEAR
:
	ld [hl+], a
	dec c
	jr nz, :-
	ret
; ANCHOR_END: sio-reset-buffers


; ANCHOR: sio-tick
; Per-frame update
; @mut: AF
SioTick::
	; jump to state-specific tick routine
	ld a, [wSioState]
	cp a, SIO_ACTIVE
	jr z, .active_tick
	cp a, SIO_RESET
	jr z, .reset_tick
	ret
.active_tick
	; update timeout on external clock
	ldh a, [rSC]
	and a, SCF_SOURCE
	ret nz
	ld a, [wSioTimer]
	and a, a
	ret z ; timer == 0, timeout disabled
	dec a
	ld [wSioTimer], a
	jr z, SioAbort
	ret
.reset_tick
	; delayed reset to IDLE state
	ld a, SIO_IDLE
	ld [wSioState], a
	ret
; ANCHOR_END: sio-tick


; ANCHOR: sio-abort
; Abort the ongoing transfer (if any) and enter the FAILED state.
; @mut: AF
SioAbort::
	ld a, SIO_FAILED
	ld [wSioState], a
	ldh a, [rSC]
	res SCB_START, a
	ldh [rSC], a
	ret
; ANCHOR_END: sio-abort


; ANCHOR: sio-start-transfer
; Start a whole-buffer transfer.
; @mut: AF, L
SioTransferStart::
	ld a, SIO_BUFFER_SIZE
.CustomCount::
	ld [wSioCount], a
	ld a, 0
	ld [wSioBufferOffset], a
	; send first byte
	ld a, [wSioBufferTx]
	ldh [rSB], a
	ld a, SIO_ACTIVE
	ld [wSioState], a
	jr SioPortStart
; ANCHOR_END: sio-start-transfer


; ANCHOR: sio-port-start
; Enable the serial port, starting a transfer.
; If internal clock is enabled, performs catchup delay before enabling the port.
; Resets the transfer timeout timer.
; @mut: AF, L
SioPortStart:
	; If internal clock source, do catchup delay
	ldh a, [rSC]
	and a, SCF_SOURCE
	; NOTE: preserve `A` to be used after the loop
	jr z, .start_xfer
	ld l, SIO_CATCHUP_SLEEP_DURATION
.catchup_sleep_loop:
	nop
	nop
	dec l
	jr nz, .catchup_sleep_loop
.start_xfer:
	or a, SCF_START
	ldh [rSC], a
	; reset timeout
	ld a, SIO_TIMEOUT_TICKS
	ld [wSioTimer], a
	ret
; ANCHOR_END: sio-port-start


; ANCHOR: sio-port-end
; Collects the received value and starts the next byte transfer, if there is more to do.
; Sets wSioState to SIO_DONE when the last expected byte is received.
; Must be called after each serial port transfer (ideally from the serial interrupt).
; @mut: AF, HL
SioPortEnd::
	; Check that we were expecting a transfer (to end)
	ld hl, wSioState
	ld a, [hl+]
	cp SIO_ACTIVE
	ret nz
	; Update wSioCount
	dec [hl]
	; Get buffer pointer offset (low byte)
	ld a, [wSioBufferOffset]
	ld l, a
	ld h, HIGH(wSioBufferRx)
	ldh a, [rSB]
	; NOTE: increments L only
	ld [hl+], a
	; Store updated buffer offset
	ld a, l
	ld [wSioBufferOffset], a
	; If completing the last transfer, don't start another one
	; NOTE: We are checking the zero flag as set by `dec [hl]` up above!
	jr nz, .next
	ld a, SIO_DONE
	ld [wSioState], a
	ret
.next:
	; Construct a Tx buffer pointer (keeping L from above)
	ld h, HIGH(wSioBufferTx)
	ld a, [hl]
	ldh [rSB], a
	jr SioPortStart
; ANCHOR_END: sio-port-end


SECTION "SioPacket Impl", ROM0
; ANCHOR: sio-packet-prepare
; Initialise the Tx buffer as a packet, ready for data.
; Returns a pointer to the packet data section.
; @return HL: packet data pointer
; @mut: AF, C, HL
SioPacketTxPrepare::
	ld hl, wSioBufferTx
	; packet always starts with constant ID
	ld a, SIO_PACKET_START
	ld [hl+], a
	; checksum = 0 for initial calculation
	ld a, 0
	ld [hl+], a
	; clear packet data
	ld a, SIO_PACKET_END
	ld c, SIO_PACKET_DATA_SIZE
:
	ld [hl+], a
	dec c
	jr nz, :-
	ld hl, wSioBufferTx + SIO_PACKET_HEAD_SIZE
	ret
; ANCHOR_END: sio-packet-prepare


; ANCHOR: sio-packet-finalise
; Close the packet and start the transfer.
; @mut: AF, C, HL
SioPacketTxFinalise::
	ld hl, wSioBufferTx
	call SioPacketChecksum
	ld [wSioBufferTx + 1], a
	jp SioTransferStart
; ANCHOR_END: sio-packet-finalise


; ANCHOR: sio-packet-check
; Check if a valid packet has been received by Sio.
; @return HL: packet data pointer (only valid if packet found)
; @return F.Z: if check OK
; @mut: AF, C, HL
SioPacketRxCheck::
	ld hl, wSioBufferRx
	; expect constant
	ld a, [hl]
	cp a, SIO_PACKET_START
	ret nz

	; check the sum
	call SioPacketChecksum
	and a, a
	ld hl, wSioBufferRx + SIO_PACKET_HEAD_SIZE
	ret ; F.Z already set (or not)
; ANCHOR_END: sio-packet-check


; ANCHOR: sio-checksum
; Calculate a simple 1 byte checksum of a Sio data buffer.
; sum(buffer + sum(buffer + 0)) == 0
; @param HL: &buffer
; @return A: sum
; @mut: AF, C, HL
SioPacketChecksum:
	ld c, SIO_BUFFER_SIZE
	ld a, c
:
	sub [hl]
	inc hl
	dec c
	jr nz, :-
	ret
; ANCHOR_END: sio-checksum
