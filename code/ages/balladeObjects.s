; ==================================================================================================
; BALLADE: INTERAC_BALLADE_OBJECT ($ed), les objets de nos îles. Un seul numéro d'interaction (la
; banque $10 est presque pleine), le sous-type choisit l'objet. Leurs images : spr_ballade_objects
; (art/objets.txt), image n = tuiles 4n à 4n+3 (interactionedSubidData).
;
; @subid_00{Le Bateau-Rondin, au ponton de chaque île : A -> Marine lit le vent, on choisit l'île}
; @subid_01{Invisible : Marine parle la première fois qu'on entre dans la salle (@arrivalTexts)}
; @subid_02{Invisible : les parties sauvées après le chapitre 1 de la v1.0/1.1 : Marine lit le vent}
; @subid_03{Le grelot de la grotte de la Boîte : une bombe le fait sonner, un pont apparaît}
; @subid_04{Lila (sa maison, 3:21) : elle a perdu Sire Bouchon ; quand on le lui rend, elle s'endort}
; @subid_05{Lila dans son rêve (2:21)}
; @subid_06{Le Coffre à Jouets, dans le rêve de Lila : l'entrée du donjon 2}
; @subid_07{Invisible, à l'auberge : parties de la v1.0/1.1 : l'aubergiste donne le Carnet des Rêves}
; @subid_08{Invisible, l'antichambre du donjon 2 : l'essence apparaît quand le boss est vaincu}
; @subid_09{Invisible, l'entrée d'un donjon : en arrivant par l'arche du bas, le donjon s'initialise
;           et son nom s'affiche (comme INTERAC_DUNGEON_STUFF $00, qui ne marche qu'au chargement)}
; ==================================================================================================

;;
main:
	ld e,Interaction.subid
	ld a,(de)
	rst_jumpTable
	.dw raft
	.dw arrivalTalk
	.dw windCatchUp
	.dw bell
	.dw lila
	.dw dreamLila
	.dw toyChest
	.dw carnetCatchUp
	.dw essenceSpawner
	.dw dungeonEntrance


;;
; Une boîte de collision (pour parler à l'objet avec A) : 16 pixels de haut, 40 de large (le
; Bateau-Rondin flotte à coté du ponton, on lui parle depuis les planches)
setCollisionRadii:
	ld h,d
	ld l,Interaction.collisionRadiusY
	ld (hl),$08
	inc l
	ld (hl),$14
	ret

;;
; Attendre la fin de l'arrivée dans la salle (une boîte de texte ouverte avant serait refusée)
; @param[out]	zflag	nz tant que la salle n'est pas prête
waitRoomReady:
	ld a,(wPaletteThread_mode)
	or a
	ret nz
	ld a,(wScrollMode)
	cpl
	and $01
	ret


; ==================================================================================================
; Marine parle la première fois qu'on entre (subid $01) : le texte de la salle dans @arrivalTexts,
; drapeau $40 de la salle ; elle peut aussi apprendre quelque chose (un drapeau global).
; ==================================================================================================
arrivalTalk:
	ld e,Interaction.state
	ld a,(de)
	or a
	jr nz,@waitText
	call waitRoomReady
	ret nz
	call getThisRoomFlags
	bit 6,(hl)
	jp nz,interactionDelete
	set 6,(hl)
	call interactionIncState
	ld a,$91
	ld (wDisabledObjects),a
	ld a,(wActiveGroup)
	ld b,a
	ld a,(wActiveRoom)
	ld c,a
	ld hl,@arrivalTexts
-
	ldi a,(hl)
	cp $ff
	jp z,interactionDelete
	cp b
	jr nz,+
	ld a,(hl)
	cp c
	jr nz,+
	inc hl
	ldi a,(hl)
	ld c,a
	; Ce que Marine apprend en le disant (un drapeau global, $ff = rien)
	ld a,(hl)
	cp $ff
	jr z,++
	push bc
	call setGlobalFlag
	pop bc
++
	ld b,>TX_5a00
	jp showText
+
	inc hl
	inc hl
	inc hl
	jr -

@waitText:
	ld a,(wTextIsActive)
	or a
	ret nz
	xor a
	ld (wDisabledObjects),a
	jp interactionDelete

; groupe, salle, texte (groupe $5a), drapeau global mis à 1 ($ff = aucun)
@arrivalTexts:
	.db $01, $31, <TX_5a55, $ff ; Hameau-Grelot, la jetée
	.db $01, $32, <TX_5a57, $ff ; devant la falaise de la grotte de la Boîte
	.db $05, $b0, <TX_5a56, GLOBALFLAG_BALLADE_MARINE_BOMB ; la grotte : Marine porte les bombes
	.db $04, $34, <TX_5a62, $ff ; le Coffre à Jouets : encore un grelot
	.db $04, $2b, <TX_5a63, $ff ; Pantin-Sans-Fil menace, Marine répond
	.db $ff


; ==================================================================================================
; Rattrapage (subid $02) : une partie sauvée après la fin du chapitre 1 de la v1.0/1.1 n'a pas vu
; Marine lire le vent. Si l'essence du Phare est là mais pas encore le Bateau-Rondin, et qu'aucun
; tour du village n'est en cours : Marine lit le vent (TX_5a54), le radeau est prêt.
; ==================================================================================================
windCatchUp:
	ld e,Interaction.state
	ld a,(de)
	or a
	jr nz,@waitText
	call waitRoomReady
	ret nz
	ld a,(wEssencesObtained)
	rrca
	jp nc,interactionDelete
	ld a,(wBalladeEnding)
	or a
	jp nz,interactionDelete
	ld a,GLOBALFLAG_BALLADE_RAFT
	call checkGlobalFlag
	jp nz,interactionDelete
	call interactionIncState
	ld a,$91
	ld (wDisabledObjects),a
	ld bc,TX_5a54
	jp showText

@waitText:
	ld a,(wTextIsActive)
	or a
	ret nz
	call setChapter2Flags
	xor a
	ld (wDisabledObjects),a
	jp interactionDelete

;;
; Le Bateau-Rondin est prêt et Hameau-Grelot repéré (aussi appelé par le script de fin du chapitre 1)
setChapter2Flags:
	ld a,GLOBALFLAG_BALLADE_RAFT
	call setGlobalFlag
	ld a,GLOBALFLAG_BALLADE_ISLAND2
	jp setGlobalFlag


; ==================================================================================================
; Le Bateau-Rondin (subid $00). Il n'est là qu'une fois réparé (GLOBALFLAG_BALLADE_RAFT, à la fin
; du chapitre 1). A devant lui : Marine propose les îles déjà repérées (les îles se découvrent
; dans l'ordre : GLOBALFLAG_BALLADE_ISLAND2, 3...), puis on part : fondu, et Link arrive sur le
; ponton de l'île choisie.
; ==================================================================================================
raft:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw @state0
	.dw @state1
	.dw @state2
	.dw @state3

@state0:
	ld a,GLOBALFLAG_BALLADE_RAFT
	call checkGlobalFlag
	jp z,interactionDelete
	call interactionInitGraphics
	call interactionIncState
	call setCollisionRadii
	call objectMarkSolidPosition
	ld e,Interaction.pressedAButton
	call objectAddToAButtonSensitiveObjectList
	jp objectSetVisible82

; Il attend que Link appuie sur A devant lui
@state1:
	ld e,Interaction.pressedAButton
	ld a,(de)
	or a
	ret z
	xor a
	ld (de),a
	call interactionIncState
	ld a,$91
	ld (wDisabledObjects),a
	; Le texte qui propose autant d'îles qu'on en a repéré (2 au moins : on vient d'une île)
	call countDiscoveredIslands
	sub $02
	add <TX_5a50
	ld c,a
	ld b,>TX_5a50
	jp showText

; Le choix : l'île (0 = la Brume...)
@state2:
	ld a,(wTextIsActive)
	or a
	ret nz
	call findCurrentIsland
	ld b,a
	ld a,(wSelectedTextOption)
	cp b
	jr nz,@go
	; On y est déjà
	ld e,Interaction.state
	ld a,$01
	ld (de),a
	xor a
	ld (wDisabledObjects),a
	ld bc,TX_5a53
	jp showText

@go:
	call interactionIncState
	; Destination : groupe, salle, case de la ligne (île) de @jetties
	ld hl,jetties
	ld b,a
	add a
	add b
	rst_addAToHl
	ldi a,(hl)
	or $80
	ld (wWarpDestGroup),a
	ldi a,(hl)
	ld (wWarpDestRoom),a
	ld a,(hl)
	ld (wWarpDestPos),a
	xor a
	ld (wWarpTransition),a
	ld (wDisabledObjects),a
	ld a,$03 ; fondu
	ld (wWarpTransition2),a
	ld a,SND_SPLASH
	jp playSound

@state3:
	ret


;;
; @param[out]	a	Nombre d'îles repérées (la Brume comprise)
countDiscoveredIslands:
	ld c,$01
	ld b,GLOBALFLAG_BALLADE_ISLAND2
-
	ld a,b
	push bc
	call checkGlobalFlag
	pop bc
	jr z,+
	inc c
	inc b
	ld a,b
	cp GLOBALFLAG_BALLADE_ISLAND8+1
	jr c,-
+
	ld a,c
	ret

;;
; @param[out]	a	L'île où l'on est (0 = la Brume), d'après la salle du ponton
findCurrentIsland:
	ld a,(wActiveRoom)
	ld c,a
	ld hl,jetties+1
	ld b,$00
-
	ld a,(hl)
	cp c
	jr z,+
	inc hl
	inc hl
	inc hl
	inc b
	ld a,b
	cp $08
	jr c,-
	ld b,$00
+
	ld a,b
	ret

; Le ponton de chaque île : groupe, salle (unique : sert aussi à savoir où l'on est), case d'arrivée
jetties:
	.db $01, $99, $43 ; 1. la Brume (le Ponton)
	.db $01, $31, $43 ; 2. Hameau-Grelot (la jetée)
	.db $01, $99, $52 ; 3. (pas encore construite)
	.db $01, $99, $52 ; 4.
	.db $01, $99, $52 ; 5.
	.db $01, $99, $52 ; 6.
	.db $01, $99, $52 ; 7.
	.db $01, $99, $52 ; 8.


; ==================================================================================================
; Le grelot (subid $03) : une bombe qui explose tout près le fait sonner, et un pont apparaît
; (@bridges : les cases de la salle). Le drapeau $40 de la salle s'en souvient. Au-dessus d'un
; gouffre, seule Marine peut y porter une bombe (Select en tenant la bombe).
; ==================================================================================================
bell:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw @state0
	.dw @state1
	.dw @state2

@state0:
	call interactionInitGraphics
	call interactionIncState
	call objectMarkSolidPosition
	call objectSetVisible82
	call getThisRoomFlags
	bit 6,(hl)
	ret z
	call interactionIncState
	jp @makeBridge

; Une bombe en train d'exploser, à moins de 24 pixels ?
@state1:
	ld h,FIRST_ITEM_INDEX
@nextItem:
	ld l,Item.enabled
	ld a,(hl)
	or a
	jr z,@skip
	inc l
	ld a,(hl)
	cp ITEM_BOMB
	jr nz,@skip
	ld l,Item.var2f
	bit 4,(hl)
	jr z,@skip
	ld l,Item.yh
	ld e,Interaction.yh
	ld a,(de)
	sub (hl)
	add 24
	cp 49
	jr nc,@skip
	ld l,Item.xh
	ld e,Interaction.xh
	ld a,(de)
	sub (hl)
	add 24
	cp 49
	jr c,@ring
@skip:
	inc h
	ld a,h
	cp LAST_ITEM_INDEX+1
	jr c,@nextItem
	ret

@ring:
	call interactionIncState
	call getThisRoomFlags
	set 6,(hl)
	ld a,SND_PIRATE_BELL
	call playSound
	call @makeBridge
	ld a,SND_SOLVEPUZZLE
	jp playSound

@state2:
	ret

; Les cases du pont de cette salle
@makeBridge:
	ld a,(wActiveGroup)
	ld c,a
	ld a,(wActiveRoom)
	ld b,a
	ld hl,@bridges
@nextRoom:
	ldi a,(hl)
	cp $ff
	ret z
	cp c
	jr nz,@skipRoom
	ld a,(hl)
	cp b
	jr nz,@skipRoom
	inc hl
	ldi a,(hl)
	jr @found
@skipRoom:
	inc hl
	inc hl
-
	ldi a,(hl)
	or a
	jr nz,-
	jr @nextRoom
@found:
	ld e,a
-
	ldi a,(hl)
	or a
	ret z
	ld c,a
	push hl
	push de
	ld a,e
	call setTile
	pop de
	pop hl
	jr -

; groupe, salle, brique du pont, cases (0 = fin)
@bridges:
	.db $05, $b0, $ef, $37, $47, $57, $67, $00 ; la grotte de la Boîte (5:b0)
	.db $04, $34, $a0, $56, $57, $58, $59, $00 ; le Coffre à Jouets, le grelot (4:34)
	.db $ff


; ==================================================================================================
; Les habitants en ASM (image de villageois, ils se tournent vers Link) : outils communs
; ==================================================================================================

;;
; État 0 d'un habitant : image, boîte de collision, solide, sensible au bouton A, visible
npcInit:
	call interactionInitGraphics
	call interactionIncState
	ld h,d
	ld l,Interaction.collisionRadiusY
	ld (hl),$06
	inc l
	ld (hl),$06
	call objectMarkSolidPosition
	ld e,Interaction.pressedAButton
	call objectAddToAButtonSensitiveObjectList
	jp objectSetVisiblec2

;;
; @param[out]	zflag	z si Link n'a pas appuyé sur A devant l'habitant (sinon : nz, et les
;			objets sont arrêtés pendant la conversation)
npcCheckTalk:
	ld e,Interaction.pressedAButton
	ld a,(de)
	or a
	ret z
	xor a
	ld (de),a
	ld a,$91
	ld (wDisabledObjects),a
	or a
	ret

;;
; Afficher un texte et passer à l'état a
; @param	a	État suivant
; @param	bc	Texte
npcSay:
	ld e,Interaction.state
	ld (de),a
	jp showText

;;
; Attendre la fin du texte, puis revenir à l'état 1 (les objets repartent)
npcWaitText:
	ld a,(wTextIsActive)
	or a
	ret nz
	xor a
	ld (wDisabledObjects),a
	ld e,Interaction.state
	inc a
	ld (de),a
	ret


; ==================================================================================================
; Lila (subid $04), dans sa maison (3:21). Elle a perdu Sire Bouchon (l'objet d'échange 0, dans le
; coffre de la grotte de la Boîte). Quand Link le lui rend, elle s'endort (GLOBALFLAG_BALLADE_
; LILA_ASLEEP) et Marine propose de dormir à coté d'elle (le lit de la maison, link.s) : on entre
; dans son rêve (2:21), où est le donjon 2.
; ==================================================================================================
lila:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw npcInit
	.dw @idle
	.dw npcWaitText
	.dw @gift
	.dw npcWaitText

@idle:
	call interactionAnimateAsNpc
	call npcCheckTalk
	ret z
	ld a,GLOBALFLAG_BALLADE_LILA_ASLEEP
	call checkGlobalFlag
	ld bc,TX_5a5c
	jr nz,@say
	; Sire Bouchon (objet d'échange 0) ?
	ld a,TREASURE_TRADEITEM
	call checkTreasureObtained
	jr nc,@sad
	ld a,(wTradeItem)
	or a
	jr nz,@sad
	ld a,$03
	ld bc,TX_5a5a
	jp npcSay
@sad:
	ld bc,TX_5a59
@say:
	ld a,$02
	jp npcSay

; Elle prend Sire Bouchon et s'endort ; Marine parle
@gift:
	ld a,(wTextIsActive)
	or a
	ret nz
	ld a,TREASURE_TRADEITEM
	call loseTreasure
	ld a,GLOBALFLAG_BALLADE_LILA_ASLEEP
	call setGlobalFlag
	ld a,$04
	ld bc,TX_5a5b
	jp npcSay


; ==================================================================================================
; Lila dans son rêve (subid $05, 2:21)
; ==================================================================================================
dreamLila:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw npcInit
	.dw @idle
	.dw npcWaitText

@idle:
	call interactionAnimateAsNpc
	call npcCheckTalk
	ret z
	ld a,$02
	ld bc,TX_5a5d
	jp npcSay


; ==================================================================================================
; Le Coffre à Jouets (subid $06), dans le rêve de Lila : A -> « Entrer ? » -> le donjon 2
; ==================================================================================================
toyChest:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw @init
	.dw @idle
	.dw @answer
	.dw @done

@init:
	call interactionInitGraphics
	call interactionIncState
	call setCollisionRadii
	call objectMarkSolidPosition
	ld e,Interaction.pressedAButton
	call objectAddToAButtonSensitiveObjectList
	jp objectSetVisible82

@idle:
	call npcCheckTalk
	ret z
	ld a,$02
	ld bc,TX_5a5e
	jp npcSay

@answer:
	ld a,(wTextIsActive)
	or a
	ret nz
	xor a
	ld (wDisabledObjects),a
	ld e,Interaction.state
	ld a,(wSelectedTextOption)
	or a
	ld a,$01
	jr z,+
	ld (de),a
	ret
+
	ld a,$03
	ld (de),a
	ld hl,@dungeonEntrance
	ldi a,(hl)
	or $80
	ld (wWarpDestGroup),a
	ldi a,(hl)
	ld (wWarpDestRoom),a
	ldi a,(hl)
	ld (wWarpDestPos),a
	ld a,(hl)
	ld (wWarpTransition),a
	ld a,$03 ; fondu
	ld (wWarpTransition2),a
	ld a,SND_ENTERCAVE
	jp playSound

@done:
	ret

; groupe, salle, case, transition : l'entrée du Coffre à Jouets (donjon 2), sur l'arche du bas
; (le nom du donjon : INTERAC_BALLADE_OBJECT $09)
@dungeonEntrance:
	.db $04, $39, $97, $00


; ==================================================================================================
; Le Carnet des Rêves (ITEM_12, harpFluteParent.s) : une page selon le nombre d'îles sauvées
; (les essences, à la suite) : TX_5a60 (la Brume), TX_5a61 (Hameau-Grelot)...
; ==================================================================================================
.define CARNET_PAGES 2

readCarnet:
	ld a,(wTextIsActive)
	or a
	ret nz
	ld a,(wEssencesObtained)
	ld c,$00
	ld b,$08
-
	rrca
	jr nc,+
	inc c
	dec b
	jr nz,-
+
	; Page = îles sauvées - 1 (au moins la première, au plus la dernière écrite)
	ld a,c
	or a
	jr z,+
	dec a
+
	cp CARNET_PAGES
	jr c,+
	ld a,CARNET_PAGES-1
+
	add <TX_5a60
	ld c,a
	ld b,>TX_5a60
	jp showText



; ==================================================================================================
; Rattrapage (subid $07, dans l'auberge 3:9e) : les parties sauvées après le chapitre 1 de la
; v1.0/1.1 n'ont pas eu le Carnet des Rêves (donné pendant le tour du village) : l'aubergiste le
; donne en entrant. Rien pendant le tour lui-même (wBalladeEnding).
; ==================================================================================================
carnetCatchUp:
	ld e,Interaction.state
	ld a,(de)
	or a
	jr nz,@waitText
	call waitRoomReady
	ret nz
	ld a,(wEssencesObtained)
	rrca
	jp nc,interactionDelete
	ld a,(wBalladeEnding)
	or a
	jp nz,interactionDelete
	ld a,TREASURE_12
	call checkTreasureObtained
	jp c,interactionDelete
	call interactionIncState
	ld a,$91
	ld (wDisabledObjects),a
	ld bc,TX_5a58
	jp showText

@waitText:
	ld a,(wTextIsActive)
	or a
	ret nz
	xor a
	ld (wDisabledObjects),a
	call giveCarnet
	jp interactionDelete

;;
; Le Carnet des Rêves apparaît au-dessus de la tête de Link (comme la commande « giveitem »)
giveCarnet:
	call getFreeInteractionSlot
	ret nz
	ld (hl),INTERAC_TREASURE
	inc l
	ld (hl),TREASURE_12
	inc l
	ld (hl),$00
	ld l,Interaction.yh
	ld a,(w1Link.yh)
	ld (hl),a
	ld l,Interaction.xh
	ld a,(w1Link.xh)
	ld (hl),a
	ret


; ==================================================================================================
; L'essence du Coffre à Jouets (subid $08, dans l'antichambre 4:2e) : elle apparaît (INTERAC_ESSENCE)
; quand Pantin-Sans-Fil est vaincu (drapeau $80 de sa salle, 4:2b, posé par le script de sa mort).
; ==================================================================================================
essenceSpawner:
	ld a,(wGroup4RoomFlags+$2b)
	rlca
	ret nc
	ldbc INTERAC_ESSENCE, $00
	call objectCreateInteraction
	jp interactionDelete


; ==================================================================================================
; L'entrée d'un donjon (subid $09) : quand Link arrive par l'arche du bas (y >= $80), comme
; INTERAC_DUNGEON_STUFF $00 : les blocs, cristaux et tourniquets du donjon reviennent à zéro, le
; point de retour (en cas de chute ou de mort) est l'entrée, et le nom du donjon s'affiche.
; ==================================================================================================
dungeonEntrance:
	call waitRoomReady
	ret nz
	ld a,(w1Link.yh)
	cp $80
	jp c,interactionDelete
	call initializeDungeonStuff
	call setDeathRespawnPoint
	ld a,(wDungeonIndex)
	add <TX_0200
	ld c,a
	ld b,>TX_0200
	call showText
	jp interactionDelete
