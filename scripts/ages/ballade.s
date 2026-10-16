; ==================================================================================================
; BALLADE : scripts de La Ballade de la Mouette
; ==================================================================================================

; ==================================================================================================
; INTERAC_MARINE subid $00 : la plage du réveil (chapitre 1)
;
; Link est évanoui sur le sable ; Marine arrive en volant et se pose à côté de lui.
; Le drapeau $40 de la salle retient que la scène a été vue.
; ==================================================================================================
marineBeachScript:
	jumpifroomflagset $40, @alreadySeen

	; Link passe dans l'état de cinématique (LINK_STATE_08), qui prend ensuite l'animation
	; écrite dans wcc50 : il reste allongé tant que wDisabledObjects n'est pas nul. On ne
	; désactive que les ennemis (bit 2) : désactiver Link l'empêcherait de changer d'état.
	writememory wDisabledObjects, $04
	disablemenu
	asm15 setLinkForceStateToState08
	; (l'état n'est pris qu'à la fin du fondu d'entrée, et son 1er passage efface wcc50)
	checkmemoryeq w1Link.state, LINK_STATE_08
	wait 2
	writememory wcc50, LINK_ANIM_MODE_COLLAPSED
	wait 90

	; Elle descend du ciel en diagonale, puis plane jusqu'au sable, à droite de Link
	setanimation $02
	writeobjectbyte Interaction.visible, $80
	setspeed SPEED_100
	setangle $14
	applyspeed $60
	setangle ANGLE_LEFT
	applyspeed $14
	setanimation $00
	wait 40

	showtext TX_5a01
	wait 20

	; Link se relève (son état de cinématique se termine dès que wDisabledObjects est nul)
	enableallobjects
	wait 1
	setdisabledobjectsto91
	wait 40
	showtext TX_5a02
	jumpiftextoptioneq $00, @answeredYes
	showtext TX_5a04
	scriptjump @sceneDone
@answeredYes:
	showtext TX_5a03
@sceneDone:
	orroomflag $40
	enableallobjects
	enablemenu
	scriptjump @npc

@alreadySeen:
	setcoords $48, $40
	setanimation $00
	writeobjectbyte Interaction.visible, $80

@npc:
	setcollisionradii $08, $08
	makeabuttonsensitive
@npcLoop:
	checkabutton
	setdisabledobjectsto91
	cplinkx Interaction.direction
	setanimationfromobjectbyte Interaction.direction
	showtext TX_5a05
	enableallobjects
	scriptjump @npcLoop
