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
	; Marine humaine ($07, l'auberge du Songe 2:9e) : une fois les retrouvailles vues (le drapeau $40
	; de la salle), elle n'est plus toujours au même endroit (Denis) : une place au hasard à chaque
	; visite (pas quand les photos l'attendent : elle fouille les poches de Link, là où il dort)
	ld e,Interaction.subid
	ld a,(de)
	cp $07
	jr nz,@placed
	call getThisRoomFlags
	and $40
	jr z,@placed
	ld a,(wEssencesObtained)
	and $10
	jr z,+
	ld a,GLOBALFLAG_BALLADE_PHOTOS
	call checkGlobalFlag
	jr z,@placed
+
	call getRandomNumber
	and $03
	add a
	ld hl,@marinePlaces
	rst_addAToHl
	ld e,Interaction.yh
	ldi a,(hl)
	ld (de),a
	ld e,Interaction.xh
	ld a,(hl)
	ld (de),a
@placed:
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

; Les places de Marine dans l'auberge du Songe (y, x) : là où on l'a trouvée la 1re fois, près du
; pot, au milieu, près de l'étagère
@marinePlaces:
	.db $28 $68, $58 $28, $48 $58, $68 $78

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
