; ==================================================================================================
; BALLADE : scripts de Gulls of Life dans la banque des scripts d'Ages (mainScripts).
; Les longs scripts sont dans scripts/ages/balladeLong.s (section Ballade_Scripts) : ici, seulement
; un renvoi vers eux.
; ==================================================================================================

; INTERAC_MARINE subid $00 : la plage du réveil
marineBeachScript:
	loadscript balladeScripts.marineBeachScript

; INTERAC_MARINE subid $02 : après l'essence du Phare (« À suivre... »)
marineToBeContinuedScript:
	stopifroomflag40set
	jumpifc6xxset <wEssencesObtained, $01, @go
	scriptend
@go:
	orroomflag $40
	loadscript balladeScripts.marineToBeContinuedScript

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
	loadscript balladeScripts.marineHumanScript


; ==================================================================================================
; INTERAC_BALLADE_NPC subid $01 : le vieux pêcheur. La 1re fois, il rend à Link l'épée qu'il a
; repêchée après le naufrage (le jeu commence sans épée).
; (Dans la banque des scripts : « checkabutton » ne marche pas dans un script chargé par
; « loadscript ».)
; ==================================================================================================
balladeNpc01Script: ; le vieux pêcheur (il rend son épée à Link)
	initcollisions
@loop:
	checkabutton
	setdisabledobjectsto91
	jumpifitemobtained TREASURE_SWORD, @hasSword
	showtext TX_5a2b
	giveitem TREASURE_OBJECT_SWORD_00
	enableallobjects
	scriptjump @loop
@hasSword:
	showtext TX_5a21
	enableallobjects
	scriptjump @loop

