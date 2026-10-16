; ==================================================================================================
; INTERAC_MARINE (BALLADE)
;
; Marine, changée en mouette. Tout son comportement est dans son script (scripts/ages/ballade.s) ;
; ce code se contente de l'afficher et de l'animer.
; ==================================================================================================
interactionCodee7:
	call checkInteractionState
	jr nz,@state1

@state0:
	ld a,$01
	ld (de),a
	call interactionInitGraphics
	call interactionSetAlwaysUpdateBit

	ld e,Interaction.subid
	ld a,(de)
	ld hl,@scripts
	rst_addDoubleIndex
	ldi a,(hl)
	ld h,(hl)
	ld l,a
	; Invisible au départ : c'est son script qui la fait apparaître
	jp interactionSetScript

@scripts:
	.dw mainScripts.marineBeachScript
	.dw mainScripts.marineWakeScript
	.dw mainScripts.marineToBeContinuedScript
	.dw mainScripts.marineBedScript
	.dw mainScripts.marineJackScript

@state1:
	call interactionRunScript
	jp c,interactionDelete
	; Le script a répondu « oui » : sous-type 1, se réveiller ; sous-type 3, s'endormir
	ld e,Interaction.var37
	ld a,(de)
	or a
	jp z,interactionAnimate
	ld e,Interaction.subid
	ld a,(de)
	cp $03
	jr z,@sleep
	callab balladeMarine.switchDream
	jp interactionDelete
@sleep:
	; Link se met contre l'oreiller (là où il pousse le lit), d'où qu'il ait parlé au lit
	ld hl,w1Link.yh
	ld (hl),$18
	ld l,<w1Link.xh
	ld (hl),$78
	ld l,<w1Link.direction
	ld (hl),DIR_RIGHT
	ld a,LINK_STATE_SLEEPING
	ld (wLinkForceState),a
	jp interactionDelete
