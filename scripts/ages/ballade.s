; ==================================================================================================
; BALLADE : scripts de Gulls of Life dans la banque des scripts d'Ages (mainScripts).
; Les longs scripts sont dans scripts/ages/balladeLong.s (section Ballade_Scripts) : ici, seulement
; un renvoi vers eux.
; ==================================================================================================

; INTERAC_MARINE subid $00 : la plage du réveil
marineBeachScript:
	loadscript balladeScripts.marineBeachScript

; INTERAC_MARINE subid $01 : dans le Songe, Select -> « Tu veux te réveiller ? »
; (le code de l'interaction fait le réveil quand var37 passe à 1)
marineWakeScript:
	setdisabledobjectsto91
	showtext TX_5a14
	enableallobjects
	jumpiftextoptioneq $00, @wake
	scriptend
@wake:
	writeobjectbyte Interaction.var37, $01
	wait 60
	scriptend


; ==================================================================================================
; INTERAC_BALLADE_NPC : les habitants (texte dans story/textes.yaml, groupe $5a, à partir de $20)
; ==================================================================================================
balladeNpc00Script: ; l'aubergiste
	rungenericnpc TX_5a20
balladeNpc01Script: ; le vieux pêcheur
	rungenericnpc TX_5a21
balladeNpc02Script: ; un garçon
	rungenericnpc TX_5a22
balladeNpc03Script: ; un autre enfant
	rungenericnpc TX_5a23
balladeNpc04Script: ; la dame insomniaque
	rungenericnpc TX_5a24
balladeNpc05Script: ; le vieux qui compte les moutons
	rungenericnpc TX_5a25
balladeNpc06Script: ; l'ado
	rungenericnpc TX_5a26
balladeNpc07Script: ; Marine humaine (dans le Songe)
	scriptjump marineHumanScript


; ==================================================================================================
; INTERAC_BALLADE_NPC subid $07 : Marine humaine, dans l'auberge du Songe (2:9e)
;
; La première fois : elle découvre ses mains, et elle parle de Cocolint. Ensuite, elle explique le
; Songe et le réveil. Le drapeau $40 de la salle retient que la scène a été vue.
; (Pas de « loadscript » dans le Songe : ces scripts s'exécutent depuis wBigBuffer, que
; l'ondulation de l'écran réécrit à chaque image.)
; ==================================================================================================
marineHumanScript:
	initcollisions
	jumpifroomflagset $40, @talk

	setdisabledobjectsto91
	wait 40
	showtext TX_5a27
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

