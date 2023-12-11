
; ANCHOR: game-state-variables
INCLUDE "src/main/includes/hardware.inc"

SECTION "GameStateManagementVariables", WRAM0

wCurrentGameState_Update:: dw
wNextGameState_Initiate:: dw
wNextGameState_Update:: dw
; ANCHOR_END: game-state-variables

SECTION "GameStateManagement", ROM0

; ANCHOR: initialize-default-game-state-function
InitializeGameStateManagment::
	
    ; ANCHOR: initialize-game-state-variables
	; Default our game state variables
	ld a, 0
	ld [wCurrentGameState_Update+0], a
	ld [wCurrentGameState_Update+1], a
	ld [wNextGameState_Initiate+0], a
	ld [wNextGameState_Initiate+1], a
	ld [wNextGameState_Update+0], a
	ld [wNextGameState_Update+1], a
    ; ANCHOR_END: initialize-game-state-variables

	call InitTitleScreenState

	ld hl, UpdateTitleScreenState
    ld a, l
    ld [wCurrentGameState_Update+0], a
    ld a, h
    ld [wCurrentGameState_Update+1], a

    ret
; ANCHOR_END: initialize-default-game-state-function


; ANCHOR: update-current-game-state-function
UpdateCurrentGameState::

	; Get the address of the current game state
	ld a, [wCurrentGameState_Update+0]
	ld l, a
	ld a, [wCurrentGameState_Update+1]
	or a, l

	; Stop if we have a 0 value
	ret z

	; call the function in HL
	ld a, [wCurrentGameState_Update+1]
	ld h, a
	call callHL

	ret
; ANCHOR_END: update-current-game-state-function

; ANCHOR: initiate-new-game-state-function
InitiateNewCurrentGameState::

	; If this is 0, we are not changing game states
	ld a, [wNextGameState_Initiate+0]
	ld l, a
	ld a, [wNextGameState_Initiate+1]
	or a, l
	ret z

	ld a, [wNextGameState_Initiate+1]
	ld h, a	
	call callHL

	ld a, [wNextGameState_Update+0]
	ld [wCurrentGameState_Update+0], a
	ld a, [wNextGameState_Update+1]
	ld [wCurrentGameState_Update+1], a

	; Reset these to zero
	ld a, 0
	ld [wNextGameState_Initiate+0],a
	ld [wNextGameState_Initiate+1], a
	ld [wNextGameState_Update+0], a
	ld [wNextGameState_Update+1], a


	ret

; ANCHOR_END: initiate-new-game-state-function