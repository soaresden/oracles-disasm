; ==================================================================================================
; INTERAC_BALLADE_DREAM_FX (BALLADE)
;
; Placée dans chaque salle du Songe : l'écran ondule doucement, comme sous l'eau. Même procédé que
; INTERAC_SCREEN_DISTORTION, en beaucoup plus doux et sans fin. L'affichage redevient normal au
; chargement d'une salle (fondu) : en sortant du Songe, il n'y a rien à défaire.
;
; Le mode « vague » de l'interruption d'affichage remplace celui qui affiche les boîtes de texte :
; l'ondulation se met donc en pause tant qu'un texte est à l'écran.
;
; Variables :
;   var30: valeur normale de wGfxRegs2.LYC (rendue pendant les textes)
; ==================================================================================================
interactionCodee9:
	call checkInteractionState
	jr nz,@state1

@state0:
	call interactionSetAlwaysUpdateBit
	call interactionIncState
	ld a,(wGfxRegs2.LYC)
	ld e,Interaction.var30
	ld (de),a
	ld a,BALLADE_DREAM_WAVE
	jp initWaveScrollValues

@state1:
	ld a,(wTextIsActive)
	or a
	jr z,@wave

	; Un texte est affiché : affichage normal
	ld e,Interaction.var30
	ld a,(de)
	ld (wGfxRegs2.LYC),a
	ld a,$03
	ldh (<hNextLcdInterruptBehaviour),a
	ret

@wave:
	ld a,$10
	ld (wGfxRegs2.LYC),a
	ld a,$02
	ldh (<hNextLcdInterruptBehaviour),a
	ld a,$01
	jp loadBigBufferScrollValues
