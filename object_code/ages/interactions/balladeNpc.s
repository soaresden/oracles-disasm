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
	; L'aubergiste ($00) n'est pas là pendant la scène de l'auberge (après le chapitre 5, le quiz
	; pas encore réussi) : Marine veut être seule avec Link (balladeObjects.inviteDream)
	ld e,Interaction.subid
	ld a,(de)
	or a
	jr nz,+
	ld a,(wEssencesObtained)
	and $10
	jr z,+
	ld a,(wBalladeEnding)
	or a
	jr nz,+
	ld a,GLOBALFLAG_BALLADE_QUIZ
	call checkGlobalFlag
	jp z,interactionDelete
+
	ld e,Interaction.state
	ld a,$01
	ld (de),a
	call interactionInitGraphics
	call objectSetVisiblec2

	ld e,Interaction.subid
	ld a,(de)
	ld hl,@scripts
	; Après l'essence du Phare, certains habitants ont changé (le tour du village)
	ld b,a
	ld a,(wEssencesObtained)
	rrca
	ld a,b
	jr nc,+
	ld hl,@scriptsSaved
+
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
	.dw mainScripts.balladeNpc08Script

@scriptsSaved:
	.dw mainScripts.balladeNpc00SavedScript
	.dw mainScripts.balladeNpc01Script
	.dw mainScripts.balladeKidsSavedScript
	.dw mainScripts.balladeKidsSavedScript
	.dw mainScripts.balladeNpc04SavedScript
	.dw mainScripts.balladeNpc05SavedScript
	.dw mainScripts.balladeNpc06Script
	.dw mainScripts.balladeNpc07Script
	.dw mainScripts.balladeNpc08Script
