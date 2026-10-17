; ==================================================================================================
; BALLADE : longs scripts de Gulls of Life, dans leur propre section (la banque des scripts d'Ages
; est pleine). Chacun est appelé par un petit renvoi « loadscript » dans scripts/ages/ballade.s.
; ==================================================================================================

; ==================================================================================================
; INTERAC_MARINE subid $00 : la plage du réveil (chapitre 1)
;
; Link est évanoui sur le sable ; Marine arrive en volant et se pose à côté de lui, puis elle se
; glisse dans sa tunique. Le drapeau $40 de la salle retient que la scène a été vue.
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

	; La langue du jeu (gardée dans la sauvegarde) : 0 = anglais, 1 = français. Link est
	; allongé sur le sable ; Marine arrive juste après.
	showtext TX_5a17
	jumpiftextoptioneq $00, @french
	writememory wActiveLanguage, $00
	scriptjump @languageChosen
@french:
	writememory wActiveLanguage, $01
@languageChosen:
	wait 30

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
	; Tous les objets de Link's Awakening sont restés au fond de la mer
	wait 20
	showtext TX_5a15
	; Elle a froid : elle saute se mettre au chaud dans la tunique de Link, où elle passera toute
	; l'aventure (pas de mouette qui suit Link à l'écran).
	showtext TX_5a05
	wait 20
	setanimation $02
	setspeed SPEED_100
	setangle ANGLE_LEFT
	applyspeed $12
	writeobjectbyte Interaction.visible, $00
	playsound SND_PICKUP
	wait 40
	showtext TX_5a06
	orroomflag $40
	enableallobjects
	enablemenu

@alreadySeen:
	scriptend


; ==================================================================================================
; INTERAC_BALLADE_NPC subid $07 : Marine humaine, dans l'auberge du Songe (2:9e)
;
; La première fois : elle découvre ses mains, se jette dans les bras de Link (des cœurs
; s'envolent), puis elle parle de Cocolint. Ensuite, elle explique le
; Songe et le réveil. Le drapeau $40 de la salle retient que la scène a été vue.
; (Chargé par « loadscript » : il tourne depuis wBigBuffer ; l'auberge du Songe n'a donc pas
; d'ondulation, qui réécrit cette mémoire à chaque image.)
; ==================================================================================================
marineHumanScript:
	initcollisions
	jumpifroomflagset $40, @talk

	setdisabledobjectsto91
	; Link au pied du lit, toujours au même endroit (il sort du lit plus ou moins haut) : le câlin
	; doit superposer les deux sprites
	writememory w1Link.yh, $16
	writememory w1Link.xh, $78
	wait 40
	showtext TX_5a27

	; Elle le dit d'abord (« je peux enfin te serrer dans mes bras ! »)...
	showtext TX_5a2c
	wait 10

	; ... puis les retrouvailles. Elle fonce comme avec des bottes de Pégase, traverse Link et se
	; blottit contre lui juste au-dessus (elle finit en $0f/$78, 7 pixels plus haut) : Link, de
	; dos, la serre dans ses bras, on voit le visage de Marine par-dessus son épaule. (Le jeu
	; dessine Link devant tout objet moins de 11 pixels plus bas que lui : impossible de la mettre
	; devant lui en les superposant vraiment.)
	writememory w1Link.direction, DIR_UP
	; Sinon elle pousse Link en se jetant sur lui (PNJ solide) et ils ne se superposent pas
	writememory wLinkCanPassNpcs, $01
	; (les déplacements comptent des images : à SPEED_200, 2 pixels par image)
	playsound SND_SLASH
	setspeed SPEED_200
	moveright $08
	moveup $0b
	; puis 3 pixels de plus : son visage dépasse par-dessus l'épaule de Link
	setspeed SPEED_100
	moveup $03
	playsound SND_STRIKE
	wait 20
	playsound SND_GAINHEART
	spawninteraction INTERAC_KISS_HEART, $00, $06, $70
	wait 30
	spawninteraction INTERAC_KISS_HEART, $01, $04, $80
	wait 40
	; Dans ses bras : « je suis tellement heureuse ! »
	showtext TX_5a2f
	playsound SND_GAINHEART
	spawninteraction INTERAC_KISS_HEART, $00, $02, $78
	wait 40
	; Elle se détache et recule d'un pas, à gauche
	setspeed SPEED_100
	moveleft $14
	movedown $0f
	writememory wLinkCanPassNpcs, $00
	writememory w1Link.direction, DIR_LEFT
	wait 20

	; Elle recule d'un pas... et le taquine : « Tu rêves de moi ?! »
	showtext TX_5a32
	wait 10
	showtext TX_5a2d
	jumpiftextoptioneq $00, @sawHer
	showtext TX_5a29
	scriptjump @sceneDone
@sawHer:
	showtext TX_5a28
@sceneDone:
	orroomflag $40
	showtext TX_5a2a
	enableallobjects

@talk:
	checkabutton
	setdisabledobjectsto91
	showtext TX_5a2a
	enableallobjects
	scriptjump @talk


; ==================================================================================================
; INTERAC_MARINE subid $02 : après l'essence du Phare, sur le cap. Comme la télépathie de l'Arbre
; Bojo d'Ages : fond noir, Marine parle depuis la tunique, « À suivre... », puis on rend la main.
marineBedScript:
	setdisabledobjectsto91
	showtext TX_5a16
	enableallobjects
	jumpiftextoptioneq $00, @sleep
	scriptend
@sleep:
	; Le code de l'interaction endort Link (comme quand il pousse le lit)
	writeobjectbyte Interaction.var37, $01
	wait 60
	scriptend


; ==================================================================================================
; INTERAC_MARINE subid $02 : sur le cap, après l'essence du Phare. Le phare brille de nouveau ;
; Marine emmène Link voir les gens qu'ils ont sauvés : le tour du village (subid $05 ci-dessous).
marineToBeContinuedScript:
	disableinput
	wait 40
	showtext TX_5a30
	wait 20
	writememory wBalladeEnding, $01
	writememory wWarpDestRoom, $9b
	writememory wWarpTransition, $00
	writememory wWarpDestPos, $75
	writememory wWarpTransition2, $03 ; fondu
	writememory wWarpDestGroup, $81
	wait 240
	scriptend


; ==================================================================================================
; INTERAC_MARINE subid $05 : le tour du village à la fin du chapitre 1 (une étape par salle, selon
; wBalladeEnding) : la place (la dame insomniaque dort enfin, le vieux ne compte plus les
; moutons), la plage (les enfants jouent), l'auberge (pleine), le port (Marine, « À suivre... »).
; Sans étape en cours, rien.
marineEndingScript:
	jumpifmemoryeq wBalladeEnding, $00, @none
	disableinput
	disablemenu
	; (un texte affiché pendant l'arrivée dans la salle serait effacé aussitôt)
	wait 70
	jumptable_memoryaddress wBalladeEnding
	.dw @none
	.dw @place
	.dw @beach
	.dw @inn
	.dw @harbour
@none:
	scriptend

@place:
	showtext TX_5a3e
	wait 30
	showtext TX_5a3f
	wait 30
	writememory wBalladeEnding, $02
	writememory wWarpDestRoom, $9c
	writememory wWarpTransition, $00
	writememory wWarpDestPos, $55
	writememory wWarpTransition2, $03 ; fondu
	writememory wWarpDestGroup, $81
	wait 240
	scriptend

@beach:
	showtext TX_5a40
	wait 30
	writememory wBalladeEnding, $03
	writememory wWarpDestRoom, $9e
	writememory wWarpTransition, $00
	writememory wWarpDestPos, $46
	writememory wWarpTransition2, $03 ; fondu
	writememory wWarpDestGroup, $83
	wait 240
	scriptend

@inn:
	showtext TX_5a41
	wait 30
	writememory wBalladeEnding, $04
	writememory wWarpDestRoom, $ab
	writememory wWarpTransition, $00
	writememory wWarpDestPos, $65
	writememory wWarpTransition2, $03 ; fondu
	writememory wWarpDestGroup, $81
	wait 240
	scriptend

@harbour:
	showtext TX_5a42
	wait 40
	showtext TX_5a31
	writememory wBalladeEnding, $00
	enablemenu
	enableinput
	scriptend


; ==================================================================================================
; INTERAC_MARINE subid $04 : salle du boss du Phare. Jack menace les héros, Marine lui répond
; (une seule fois, tant que Jack n'est pas battu ; les ennemis attendent la fin)
marineJackScript:
	stopifroomflag80set
	stopifroomflag40set
	orroomflag $40
	setdisabledobjectsto91
	wait 40
	showtext TX_5a34
	wait 20
	showtext TX_5a35
	enableallobjects
	scriptend
