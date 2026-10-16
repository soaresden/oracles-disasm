; ==================================================================================================
; INTERAC_BALLADE_NPC (BALLADE)
;
; Habitants de nos îles. Le sous-type choisit l'apparence (interactione8SubidData) et le script
; (ci-dessous, scripts dans scripts/ages/ballade.s). Ils se tournent vers Link quand il approche.
; ==================================================================================================
interactionCodee8:
	ld e,Interaction.state
	ld a,(de)
	or a
	jr nz,@state1

@state0:
	inc a
	ld (de),a
	call interactionInitGraphics
	call objectSetVisiblec2

	ld e,Interaction.subid
	ld a,(de)
	ld hl,@scripts
	rst_addDoubleIndex
	ldi a,(hl)
	ld h,(hl)
	ld l,a
	call interactionSetScript
	call objectMarkSolidPosition

@state1:
	call interactionRunScript
	jp interactionAnimateAsNpc

@scripts:
	.dw mainScripts.balladeNpc00Script
	.dw mainScripts.balladeNpc01Script
	.dw mainScripts.balladeNpc02Script
	.dw mainScripts.balladeNpc03Script
	.dw mainScripts.balladeNpc04Script
	.dw mainScripts.balladeNpc05Script
	.dw mainScripts.balladeNpc06Script
	.dw mainScripts.balladeNpc07Script
