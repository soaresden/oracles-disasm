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
	wait 40
	showtext TX_5a27

	; Les retrouvailles : face à face, elle se blottit contre Link (lui est en $18/$78 et la
	; regarde, elle part de $28/$68, passe juste sous lui et monte se serrer contre lui, de dos)
	; Elle fonce comme avec des bottes de Pégase et se jette dans ses bras (les deux sprites se
	; mêlent)
	writememory w1Link.direction, DIR_DOWN
	; (les déplacements comptent des images : à SPEED_200, 2 pixels par image)
	playsound SND_SLASH
	setspeed SPEED_200
	moveright $08
	moveup $06
	playsound SND_STRIKE
	wait 20
	playsound SND_GAINHEART
	spawninteraction INTERAC_KISS_HEART, $00, $0a, $70
	wait 30
	spawninteraction INTERAC_KISS_HEART, $01, $08, $80
	wait 60
	showtext TX_5a2c
	setspeed SPEED_100
	movedown $0c
	moveleft $10
	wait 20

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
; INTERAC_MARINE subid $02 : (voir plus bas)
marineToBeContinuedScript:
	disableinput
	writememory wTextboxFlags, TEXTBOXFLAG_ALTPALETTE1
	wait 40
	writememory wDontUpdateStatusBar, $77
	asm15 hideStatusBar
	asm15 scriptHelp.remoteMakuCutscene_fadeoutToBlackWithDelay, $02
	checkpalettefadedone
	; Link aussi disparaît dans le noir
	writememory w1Link.visible, $00
	wait 30
	showtext TX_5a30
	wait 30
	; (le jeu remet ce réglage à zéro après chaque texte : sans lui, noir sur noir)
	writememory wTextboxFlags, TEXTBOXFLAG_ALTPALETTE1
	showtext TX_5a31
	wait 60
	writememory w1Link.visible, $c2
	asm15 showStatusBar
	asm15 clearFadingPalettes
	asm15 fadeinFromWhiteWithDelay, $02
	checkpalettefadedone
	resetmusic
	enablemenu
	writememory wDisabledObjects, $00
	enableinput
	scriptend
