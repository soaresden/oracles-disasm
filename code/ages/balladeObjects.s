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
; @subid_0a{Invisible : la fin d'un chapitre (chez Lila, puis la place du Grelot ; @endings)}
; @subid_0b{Un enfant de la place du Grelot (avant / après le Coffre à Jouets)}
; @subid_0c{Un autre enfant de la place du Grelot}
; @subid_0d{Mme Bonnet, la maîtresse (l'école)}
; @subid_0e{Héloïse (la Lagune, 3:23 ; avant / après le Récif Murmurant)}
; @subid_0f{Bulle, la monitrice du club de plongée (3:24) ; après le Récif : sa planche de surf}
; @subid_10{Le facteur des bouteilles (la plage des bouteilles, 1:35)}
; @subid_11{Gaspard (3:23) : la bouteille contre les Palmes de Zora}
; @subid_12{La bouteille à la mer, sur l'îlot de la lagune (1:15, 0:15)}
; @subid_13{Invisible : les coquillages-échos du Récif Murmurant (5:39)}
; @subid_14{Brasia, la forgeronne goron (Mont-Braise, 1:2a) : le tableau contre le Bracelet de force}
; @subid_15{Pinceau, le peintre (1:19, dans le Réel)}
; @subid_16{Pinceau dans le Songe (0:19) : il peint la mer, et donne le tableau}
; @subid_17{Un musicien des Cuivres, la fanfare goron (1:2a)}
; @subid_18{Le marchand de copies (1:3a)}
; @subid_19{Bêche, le fossoyeur (l'île des Échos, 3:25) : la Pelle}
; @subid_1a{Noé, l'enfant de la place du silence (1:62)}
; @subid_1b{La grand-mère de Noé, dans le Songe (0:62) : où est la clé ; le quart de cœur}
; @subid_1c{La veuve Marée, sur son rocher (1:74)}
; @subid_1d{Le sonneur (la chapelle, 1:63)}
; @subid_1e{Invisible : la clé de la cathédrale enterrée (1:64) ; la Pelle la déterre}
; @subid_1f{Invisible : la grille de la cathédrale des Échos (1:42) ; la clé l'ouvre}
; (...)
; @subid_26{Le roi d'une nuit, endormi (l'île du Grand Sommeil, 1:d2)}
; @subid_27{Le veilleur (3:27) : le Lance-Graines}
; @subid_28{La petite sœur (3:28), la seule réveillée de sa famille}
; @subid_29{La chanteuse (3:29) : la Clochette d'Aube la réveille ; un quart de cœur}
; @subid_2a{La mère, endormie (3:28)}
; @subid_2b{Le père, endormi (3:28)}
; @subid_2c{Le roi dans le Songe (0:d2) : il dit où frapper le cristal}
; @subid_2d{Invisible : la porte gelée du Palais Givré (1:b2)}
; @subid_2e{Invisible : le cristal du Songe (0:b2) : frappé, il dégèle la porte du Réel}
; @subid_2f{Un garde endormi debout (le Palais Givré) : la Clochette d'Aube le réveille, il s'en va}
; @subid_30{Invisible : la porte de la Tour Sans-Nuit (1:c9) : Marine chante les sept couplets}
; @subid_31{Invisible : la Lune qui tombe (5:c1) : quatre torches allumées peu de temps ; l'escalier}
; @subid_32{Invisible : l'escalier d'un étage de la tour, quand l'étage est vaincu (plus d'ennemis)}
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
	.dw chapterEnding
	.dw villager
	.dw villager
	.dw villager
	.dw villager
	.dw surfInstructor
	.dw villager
	.dw gaspard
	.dw bottle
	.dw echoShells
	.dw brasia
	.dw villager
	.dw dreamPainter
	.dw villager
	.dw villager
	.dw gravedigger
	.dw villager
	.dw grandma
	.dw villager
	.dw villager
	.dw buriedKey
	.dw cathedralGate
	.dw tarkin
	.dw villager
	.dw villager
	.dw villager
	.dw villager
	.dw motherPlume
	.dw sleeper
	.dw watchman
	.dw villager
	.dw singer
	.dw sleeper
	.dw sleeper
	.dw villager
	.dw frozenGate
	.dw dreamCrystal
	.dw standingSleeper
	.dw towerDoor
	.dw moonTorches
	.dw floorStairs


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
	; Le nom du donjon s'affiche peut-être (l'entrée de la Cathédrale) : Marine parle après
	; (quelques images d'attente : le nom n'est pas encore ouvert à la première)
	ld e,Interaction.counter2
	ld a,(de)
	cp 8
	jr nc,+
	inc a
	ld (de),a
	ret
+
	ld a,(wTextIsActive)
	or a
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
	jr z,@noText
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
; Pas de texte pour cette salle : on rend la main (sinon tout reste gelé)
@noText:
	xor a
	ld (wDisabledObjects),a
	jp interactionDelete

@arrivalTexts:
	.db $01, $31, <TX_5a55, $ff ; Hameau-Grelot, la jetée
	.db $01, $32, <TX_5a57, $ff ; devant la falaise de la grotte de la Boîte
	.db $05, $b0, <TX_5a56, GLOBALFLAG_BALLADE_MARINE_BOMB ; la grotte : Marine porte les bombes
	.db $04, $34, <TX_5a62, $ff ; le Coffre à Jouets : encore un grelot
	.db $04, $2b, <TX_5a63, $ff ; Pantin-Sans-Fil menace, Marine répond
	.db $01, $24, <TX_5a70, $ff ; la Lagune des Serments, le ponton
	.db $05, $b1, <TX_5a7a, $ff ; la grotte des amoureux
	.db $01, $36, <TX_5a7b, $ff ; devant le Récif Murmurant
	.db $01, $38, <TX_5a80, $ff ; Mont-Braise, le ponton
	.db $01, $70, <TX_5a90, $ff ; l'île des Échos, le ponton
	.db $01, $64, <TX_5a91, $ff ; le cimetière de l'est : la tombe fleurie
	.db $05, $aa, <TX_5a9e, $ff ; la Cathédrale des Échos : les Veilleurs
	.db $05, $7b, <TX_5a9f, $ff ; le chœur : l'escalier vers le souvenir
	.db $01, $75, <TX_5aad, $ff ; le Nid des Vents, le courant ascendant
	.db $01, $57, <TX_5aae, $ff ; le pont de nuages : dans le Songe, rien ne tombe
	.db $04, $3c, <TX_5ab8, $ff ; la Spirale Céleste : ne pas regarder en bas
	.db $04, $54, <TX_5ab9, $ff ; l'Ombre de Marine, Marine lui répond
	.db $01, $d1, <TX_5abc, $ff ; l'île du Grand Sommeil, le ponton
	.db $01, $b2, <TX_5acd, $ff ; le Palais Givré : la porte gelée
	.db $04, $55, <TX_5ace, $ff ; le Palais Givré, l'entrée : ça glisse
	.db $04, $64, <TX_5ad1, $ff ; Givrolin menace, Marine répond
	.db $01, $d9, <TX_5ad4, $ff ; l'Œil de l'Insomnis, le ponton
	.db $05, $c0, <TX_5ad8, $ff ; la Tour Sans-Nuit, l'entrée : un battement
	.db $05, $c1, <TX_5ad9, $ff ; 1F : la lune tombe
	.db $05, $c4, <TX_5ada, $ff ; 2F : Dark Link
	.db $05, $c7, <TX_5adb, $ff ; 3F : Ganon
	.db $05, $f5, <TX_5adb, $ff ; 3F : Ganon (il pose son arène, 5:f5, à la place de 5:c7)
	.db $05, $ca, <TX_5adc, $ff ; 4F : « TU ME RECONNAIS ? »
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
; ponton de l'île choisie. Plus de 4 îles : deux pages (la Brume, Grelot, la Lagune ou « Suite »,
; puis Mont-Braise, les Échos...) : une boîte de texte n'a que deux lignes.
; ==================================================================================================
raft:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw @state0
	.dw @state1
	.dw @state2
	.dw @state3
	.dw @state4
	.dw @state5
	.dw @state6
	.dw @state7

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
	cp $05
	jr nc,@twoPages
	sub $02
	add <TX_5a50
	ld c,a
	ld b,>TX_5a50
	jp showText

@twoPages:
	; La première page : la Brume, Grelot, la Lagune, ou « Suite » (état 4)
	ld e,Interaction.state
	ld a,$04
	ld (de),a
	ld bc,TX_5aa8
	jp showText

; Le choix : l'île (0 = la Brume)
@state2:
	ld a,(wTextIsActive)
	or a
	ret nz
	ld a,(wSelectedTextOption)
	jr @chosen

; La première page : l'option 3 est « Suite »
@state4:
	ld a,(wTextIsActive)
	or a
	ret nz
	ld a,(wSelectedTextOption)
	cp $03
	jr nz,@chosen
	call countDiscoveredIslands
	cp $08
	jr nz,+
	; Huit îles : la deuxième page a aussi « Suite » (Braise, Échos, Nid, Suite), puis une troisième
	; (Sommeil, Œil)
	ld e,Interaction.state
	ld a,$06
	ld (de),a
	ld bc,TX_5aac
	jp showText
+
	ld e,Interaction.state
	ld a,$05
	ld (de),a
	call countDiscoveredIslands
	sub $05
	add <TX_5aa9
	ld c,a
	ld b,>TX_5aa9
	jp showText

; La deuxième page : Mont-Braise (3), les Échos (4)...
@state5:
	ld a,(wTextIsActive)
	or a
	ret nz
	ld a,(wSelectedTextOption)
	add $03
	jr @chosen

@state6:
	ld a,(wTextIsActive)
	or a
	ret nz
	ld a,(wSelectedTextOption)
	cp $03
	jr nz,@state5Chosen
	ld e,Interaction.state
	ld a,$07
	ld (de),a
	ld bc,TX_5ade
	jp showText
@state5Chosen:
	add $03
	jr @chosen

@state7:
	ld a,(wTextIsActive)
	or a
	ret nz
	ld a,(wSelectedTextOption)
	add $06

; @param	a	L'île choisie (0 = la Brume)
@chosen:
	push af
	call findCurrentIsland
	ld b,a
	pop af
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
	ld b,a
	ld e,Interaction.state
	ld a,$03
	ld (de),a
	ld a,b
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
	.db $01, $24, $33 ; 3. la Lagune des Serments (le ponton)
	.db $01, $38, $44 ; 4. Mont-Braise (le ponton)
	.db $01, $70, $44 ; 5. l'île des Échos (le ponton)
	.db $01, $75, $44 ; 6. le Nid des Vents (le courant ascendant)
	.db $01, $d1, $44 ; 7. l'île du Grand Sommeil (le ponton)
	.db $01, $d9, $44 ; 8. l'Œil de l'Insomnis (le ponton)


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
	; Après le Coffre à Jouets, elle est réveillée et joue
	ld a,(wEssencesObtained)
	and $02
	ld bc,TX_5a6e
	jr nz,@say
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
; (les essences, à la suite) : @pages (TX_5a60 la Brume, TX_5a61 Hameau-Grelot, TX_5a7f la
; Lagune...)
; ==================================================================================================
.define CARNET_PAGES 5

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
	ld hl,@pages
	rst_addAToHl
	ld c,(hl)
	ld b,>TX_5a60
	jp showText

; Une page par nombre d'îles sauvées (chacune reprend les précédentes)
@pages:
	.db <TX_5a60, <TX_5a61, <TX_5a7f, <TX_5aa6, <TX_5aa7



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
; L'essence (subid $08) : elle apparaît (INTERAC_ESSENCE) quand le boss est vaincu (drapeau $80 de sa
; salle) : Pantin-Sans-Fil (4:2b, l'essence dans l'antichambre 4:2e), la Murène du Silence (Octogon,
; 5:36 : dans sa salle), Copiator (Smog, 4:bf : dans sa salle).
; ==================================================================================================
essenceSpawner:
	ld a,(wDungeonIndex)
	ld b,a
	cp $07
	ld a,(wGroup4RoomFlags+$64)
	jr z,+
	ld a,b
	cp $06
	ld a,(wGroup4RoomFlags+$54)
	jr z,+
	ld a,b
	cp $05
	ld a,(wPastRoomFlags+$26)
	jr z,+
	ld a,b
	cp $04
	ld a,(wGroup4RoomFlags+$bf)
	jr z,+
	ld a,b
	cp $03
	ld a,(wGroup4RoomFlags+$2b)
	jr nz,+
	ld a,(wGroup5RoomFlags+$36)
+
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


; ==================================================================================================
; La fin d'un chapitre (subid $0a, invisible) : une suite d'ordres (@endings) qui passe d'une salle
; à l'autre ; l'étape en cours est dans wBalladeEnding (comme le tour du village du chapitre 1,
; qui prend les valeurs 1 à 4 ; ici $11...).
;   END_TEXT t      un texte (groupe $5a), on attend qu'il se ferme
;   END_WARP g r c  fondu vers une salle (on y reprend avec l'objet $0a de cette salle)
;   END_FLAG f      un drapeau global
;   END_STEP v      wBalladeEnding = v
;   END_SOUND s     un son
;   END_WAIT n      attendre n images
;   END_DONE        fin : Link reprend la main
; ==================================================================================================
.enum 0
	END_DONE	db
	END_TEXT	db
	END_WARP	db
	END_FLAG	db
	END_STEP	db
	END_SOUND	db
	END_WAIT	db
.ende

chapterEnding:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw @start
	.dw @run
	.dw @idle

@start:
	call waitRoomReady
	ret nz
	; Chaque suite : groupe, salle, wBalladeEnding attendu, masque d'essence (si l'étape attendue
	; est $00 : au réveil, après l'essence, une seule fois : drapeau $40 de la salle), ordres
	ld hl,@endings
@nextEnding:
	ldi a,(hl)
	cp $ff
	jp z,interactionDelete
	ld b,a
	ld a,(wActiveGroup)
	cp b
	jr nz,@skip3
	ld a,(wActiveRoom)
	cp (hl)
	jr nz,@skip3
	inc hl
	ld a,(wBalladeEnding)
	cp (hl)
	jr nz,@skip2
	inc hl
	or a
	jr nz,@go
	ld a,(wEssencesObtained)
	and (hl)
	jr z,@skip1
	push hl
	call getThisRoomFlags
	bit 6,(hl)
	set 6,(hl)
	pop hl
	jr nz,@skip1
@go:
	inc hl
	ldi a,(hl)
	ld h,(hl)
	ld l,a
	ld e,Interaction.var30
	ld a,l
	ld (de),a
	inc e
	ld a,h
	ld (de),a
	call interactionIncState
	ld a,$91
	ld (wDisabledObjects),a
	ret
@skip3:
	inc hl
@skip2:
	inc hl
@skip1:
	inc hl
	inc hl
	inc hl
	jr @nextEnding

@run:
	ld a,(wTextIsActive)
	or a
	ret nz
	ld e,Interaction.counter1
	ld a,(de)
	or a
	jr z,+
	dec a
	ld (de),a
	ret
+
	ld h,d
	ld l,Interaction.var30
	ldi a,(hl)
	ld h,(hl)
	ld l,a
	ldi a,(hl)
	push hl
	rst_jumpTable
	.dw @done
	.dw @text
	.dw @warp
	.dw @flag
	.dw @step
	.dw @sound
	.dw @wait

; @param	hl	La suite des ordres (sauvée dans var30/31)
@saveAndRet:
	ld e,Interaction.var30
	ld a,l
	ld (de),a
	inc e
	ld a,h
	ld (de),a
	ret

@done:
	pop hl
	xor a
	ld (wDisabledObjects),a
	jp interactionDelete

@text:
	pop hl
	ldi a,(hl)
	ld c,a
	ld b,>TX_5a00
	push bc
	call @saveAndRet
	pop bc
	jp showText

@warp:
	pop hl
	ldi a,(hl)
	or $80
	ld b,a
	ldi a,(hl)
	ld (wWarpDestRoom),a
	ldi a,(hl)
	ld (wWarpDestPos),a
	xor a
	ld (wWarpTransition),a
	ld a,$03 ; fondu
	ld (wWarpTransition2),a
	ld a,b
	ld (wWarpDestGroup),a
	ld e,Interaction.state
	ld a,$02
	ld (de),a
	ret

@flag:
	pop hl
	ldi a,(hl)
	push hl
	call setGlobalFlag
	pop hl
	jr @saveAndRet

@step:
	pop hl
	ldi a,(hl)
	ld (wBalladeEnding),a
	jr @saveAndRet

@sound:
	pop hl
	ldi a,(hl)
	push hl
	call playSound
	pop hl
	jr @saveAndRet

@wait:
	pop hl
	ldi a,(hl)
	ld e,Interaction.counter1
	ld (de),a
	jr @saveAndRet

@idle:
	ret

; groupe, salle, wBalladeEnding attendu, masque d'essence (si l'étape attendue est $00), ordres
@endings:
	.db $03, $21, $00, $02
	.dw @lilaWakes
	.db $01, $11, $11, $00
	.dw @grelotSquare
	.db $01, $35, $00, $04
	.dw @reefReturn
	.db $03, $23, $21, $00
	.dw @vowsHouse
	.db $01, $2a, $00, $08
	.dw @forgeAwake
	.db $01, $62, $00, $10
	.dw @bellsSing
	.db $01, $67, $00, $20
	.dw @windSings
	.db $01, $b1, $00, $40
	.dw @frostMelts
	.db $ff

; Chapitre 2 : Lila se réveille ; la place du Grelot ; Marine lit le vent (la Lagune des Serments)
@lilaWakes:
	.db END_WAIT, 40
	.db END_TEXT, <TX_5a64
	.db END_TEXT, <TX_5a65
	.db END_STEP, $11
	.db END_WARP, $01, $11, $46
@grelotSquare:
	.db END_WAIT, 30
	.db END_SOUND, SND_PIRATE_BELL
	.db END_TEXT, <TX_5a66
	.db END_WAIT, 40
	.db END_TEXT, <TX_5a67
	.db END_FLAG, GLOBALFLAG_BALLADE_ISLAND3
	.db END_STEP, $00
	.db END_WAIT, 30
	.db END_TEXT, <TX_5a31
	.db END_DONE

; Chapitre 3 : Link ressort du Récif Murmurant, sur la plage des bouteilles où Marine l'attendait ; chez Héloïse et Gaspard ;
; Marine lit le vent (Mont-Braise)
@reefReturn:
	.db END_WAIT, 40
	.db END_TEXT, <TX_5a7c
	.db END_STEP, $21
	.db END_WARP, $03, $23, $57
@vowsHouse:
	.db END_WAIT, 30
	.db END_TEXT, <TX_5a7d
	.db END_WAIT, 40
	.db END_TEXT, <TX_5a7e
	.db END_FLAG, GLOBALFLAG_BALLADE_ISLAND4
	.db END_STEP, $00
	.db END_WAIT, 30
	.db END_TEXT, <TX_5a31
	.db END_DONE

; Chapitre 4 : la Forge s'est réveillée ; le village goron fête ça ; Marine lit le vent (l'île des
; Échos)
@forgeAwake:
	.db END_WAIT, 40
	.db END_TEXT, <TX_5a8c
	.db END_WAIT, 30
	.db END_TEXT, <TX_5a8d
	.db END_WAIT, 40
	.db END_TEXT, <TX_5a8e
	.db END_FLAG, GLOBALFLAG_BALLADE_ISLAND5
	.db END_WAIT, 30
	.db END_TEXT, <TX_5a31
	.db END_DONE

; Chapitre 5 : sur la place du silence, les cloches chantent la chanson de Mamie Rose ; Marine lit
; le vent (le Nid des Vents)
@bellsSing:
	.db END_WAIT, 40
	.db END_SOUND, SND_TUNE_OF_ECHOES
	.db END_WAIT, 90
	.db END_TEXT, <TX_5aa4
	.db END_WAIT, 40
	.db END_TEXT, <TX_5aa5
	.db END_FLAG, GLOBALFLAG_BALLADE_ISLAND6
	.db END_WAIT, 30
	.db END_TEXT, <TX_5a31
	.db END_DONE

; Chapitre 6 : au village des plumes, le vent revient : les moulins tournent, Zéphyr saute, le Rito
; rentre chez lui ; Marine lit le vent (l'île du Grand Sommeil)
@windSings:
	.db END_WAIT, 40
	.db END_SOUND, MUS_BALLADE_TEMPETES ; le Chant des Tempêtes : les moulins repartent
	.db END_WAIT, 90
	.db END_TEXT, <TX_5aba
	.db END_WAIT, 40
	.db END_TEXT, <TX_5abb
	.db END_FLAG, GLOBALFLAG_BALLADE_ISLAND7
	.db END_WAIT, 30
	.db END_TEXT, <TX_5a31
	.db END_DONE

; Chapitre 7 : au village gelé, la neige fond, tout le monde se réveille ; Marine lit le vent (l'Œil de
; l'Insomnis : une tour noire au milieu de la mer)
@frostMelts:
	.db END_WAIT, 40
	.db END_SOUND, SND_SOLVEPUZZLE_2
	.db END_WAIT, 60
	.db END_TEXT, <TX_5ad2
	.db END_WAIT, 40
	.db END_TEXT, <TX_5ad3
	.db END_FLAG, GLOBALFLAG_BALLADE_ISLAND8
	.db END_WAIT, 30
	.db END_TEXT, <TX_5a31
	.db END_DONE


; ==================================================================================================
; Les habitants à deux répliques (subids $0b-$0d) : une avant que l'île soit sauvée, une après
; (le bit de wEssencesObtained de l'île).
; ==================================================================================================
villager:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw npcInit
	.dw @idle
	.dw npcWaitText

@idle:
	call interactionAnimateAsNpc
villagerTalk:
	call npcCheckTalk
	ret z
	; La ligne de l'habitant dans @texts
	ld e,Interaction.subid
	ld a,(de)
	ld c,a
	ld hl,villagerTexts
-
	ldi a,(hl)
	cp c
	jr z,+
	inc hl
	inc hl
	inc hl
	jr -
+
	ldi a,(hl)
	ld b,a
	ld a,(wEssencesObtained)
	and b
	ldi a,(hl)
	jr z,+
	ld a,(hl)
+
	ld c,a
	ld b,>TX_5a00
	ld a,$02
	jp npcSay

; sous-type, masque d'essence de l'île, texte avant, texte après
villagerTexts:
	.db $0b, $02, <TX_5a68, <TX_5a69 ; un enfant de la place du Grelot
	.db $0c, $02, <TX_5a6a, <TX_5a6b ; un autre enfant
	.db $0d, $02, <TX_5a6c, <TX_5a6d ; Mme Bonnet, la maîtresse
	.db $0e, $04, <TX_5a74, <TX_5a75 ; Héloïse
	.db $0f, $04, <TX_5a76, <TX_5a77 ; Bulle, la monitrice du club de plongée
	.db $10, $04, <TX_5a78, <TX_5a79 ; le facteur des bouteilles
	.db $15, $08, <TX_5a84, <TX_5a85 ; Pinceau, le peintre (dans le Réel)
	.db $17, $08, <TX_5a88, <TX_5a89 ; un musicien des Cuivres
	.db $18, $08, <TX_5a8a, <TX_5a8b ; le marchand de copies
	.db $1a, $10, <TX_5a94, <TX_5a95 ; Noé
	.db $1c, $10, <TX_5a9a, <TX_5a9b ; la veuve Marée
	.db $1d, $10, <TX_5a9c, <TX_5a9d ; le sonneur
	.db $21, $20, <TX_5aaf, <TX_5ab0 ; le Rito égaré
	.db $22, $20, <TX_5ab1, <TX_5ab2 ; Zéphyr
	.db $23, $20, <TX_5ab3, <TX_5ab3 ; Zéphyr dans le Songe
	.db $24, $20, <TX_5ab4, <TX_5ab5 ; un meunier
	.db $26, $40, <TX_5abd, <TX_5abe ; le roi d'une nuit (endormi : sleeper)
	.db $28, $40, <TX_5ac1, <TX_5ac2 ; la petite sœur
	.db $2a, $40, <TX_5ac3, <TX_5ac4 ; la mère (sleeper)
	.db $2b, $40, <TX_5ac5, <TX_5ac6 ; le père (sleeper)
	.db $2c, $40, <TX_5aca, <TX_5aca ; le roi dans le Songe


; ==================================================================================================
; Gaspard (subid $11), dans sa maison de la Lagune (3:23). Il a jeté une bouteille à la mer (l'objet
; d'échange 1, sur l'îlot de la lagune : subid $12) ; quand Link la lui rapporte, il se souvient
; d'Héloïse et donne les Palmes de Zora.
; ==================================================================================================
gaspard:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw npcInit
	.dw @idle
	.dw npcWaitText
	.dw @gift

@idle:
	call interactionAnimateAsNpc
	call npcCheckTalk
	ret z
	ld a,TREASURE_FLIPPERS
	call checkTreasureObtained
	ld bc,TX_5a73
	jr c,@say
	call hasBottle
	ld bc,TX_5a71
	jr nc,@say
	ld a,$03
	ld bc,TX_5a72
	jp npcSay
@say:
	ld a,$02
	jp npcSay

; Il reprend la bouteille, et les Palmes de Zora apparaissent au-dessus de la tête de Link
@gift:
	ld a,(wTextIsActive)
	or a
	ret nz
	ld a,TREASURE_TRADEITEM
	call loseTreasure
	ldbc TREASURE_FLIPPERS, $00
	call giveTreasureAtLink
	xor a
	ld (wDisabledObjects),a
	ld e,Interaction.state
	inc a
	ld (de),a
	ret

;;
; @param[out]	cflag	c si Link a la bouteille (l'objet d'échange 1)
hasBottle:
	ld a,TREASURE_TRADEITEM
	call checkTreasureObtained
	ret nc
	ld a,(wTradeItem)
	cp $01
	scf
	ret z
	xor a
	ret

;;
; Un trésor apparaît au-dessus de la tête de Link (comme la commande « giveitem »)
; @param	b	Le trésor (TREASURE_*)
; @param	c	Son sous-type
giveTreasureAtLink:
	call getFreeInteractionSlot
	ret nz
	ld (hl),INTERAC_TREASURE
	inc l
	ld (hl),b
	inc l
	ld (hl),c
	ld l,Interaction.yh
	ld a,(w1Link.yh)
	ld (hl),a
	ld l,Interaction.xh
	ld a,(w1Link.xh)
	ld (hl),a
	ret


; ==================================================================================================
; La bouteille à la mer (subid $12), sur l'îlot de la lagune (1:15 et 0:15). Dans le Réel, on la voit
; sans pouvoir l'atteindre (la lagune est profonde) ; dans le Songe, la mer s'écarte (0:15) : A
; devant elle -> l'objet d'échange 1. Elle n'est plus là quand Link l'a, ou a les Palmes.
; ==================================================================================================
bottle:
	ld e,Interaction.state
	ld a,(de)
	or a
	jr nz,@idle
	call hasBottle
	jp c,interactionDelete
	ld a,TREASURE_FLIPPERS
	call checkTreasureObtained
	jp c,interactionDelete
	call interactionInitGraphics
	call interactionIncState
	ld h,d
	ld l,Interaction.collisionRadiusY
	ld (hl),$06
	inc l
	ld (hl),$06
	ld e,Interaction.pressedAButton
	call objectAddToAButtonSensitiveObjectList
	jp objectSetVisible82

@idle:
	ld e,Interaction.pressedAButton
	ld a,(de)
	or a
	ret z
	ldbc TREASURE_TRADEITEM, $01
	call giveTreasureAtLink
	jp interactionDelete


; ==================================================================================================
; Les coquillages-échos (subid $13, invisible, le lobe droit du Récif Murmurant, 5:39). Le grand
; coquillage (brique $11, @master) chante trois airs (les flûtes de Ricky, Dimitri et Moosh) dans
; un ordre (@order) ; les trois petits (@shells) chantent chacun le leur quand Link les touche (A
; ou B face à eux). Dans le bon ordre : le coffre de la clé du boss apparaît (@chest). Le drapeau
; $40 de la salle s'en souvient.
;   var30 : combien de bons coquillages à la suite ; var31 : l'air que le grand chante ;
;   counter1 : attente entre deux airs
; ==================================================================================================
.define ECHO_PAUSE 80

echoShells:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw @init
	.dw @idle
	.dw @singing
	.dw @solved

@init:
	call waitRoomReady
	ret nz
	call interactionIncState
	call getThisRoomFlags
	bit 6,(hl)
	ret z
	; Déjà résolue : le coffre (ouvert ou non)
	ld e,Interaction.state
	ld a,$03
	ld (de),a
	jp @showChest

@idle:
	ld a,(wTextIsActive)
	ld b,a
	ld a,(wDisabledObjects)
	or b
	ret nz
	ld a,(wGameKeysJustPressed)
	and BTN_A|BTN_B
	ret z
	call @tileInFrontOfLink
	ld b,a
	ld a,(@master)
	cp b
	jr z,@startSong
	; Un des petits coquillages ?
	ld hl,@shells
	ld c,$00
-
	ldi a,(hl)
	cp b
	jr z,@touched
	inc c
	ld a,c
	cp $03
	jr c,-
	ret

; Le coquillage c chante ; on compare avec l'ordre du grand
@touched:
	ld a,c
	ld hl,@sounds
	rst_addAToHl
	ld a,(hl)
	push bc
	call playSound
	pop bc
	ld h,d
	ld l,Interaction.var30
	ld a,(hl)
	push hl
	ld hl,@order
	rst_addAToHl
	ld a,(hl)
	pop hl
	cp c
	jr z,+
	; Raté : on recommence (le bon premier coquillage compte quand même)
	ld (hl),$00
	ld a,(@order)
	cp c
	ret nz
	inc (hl)
	ret
+
	inc (hl)
	ld a,(hl)
	cp $03
	ret c
	; Résolue
	ld e,Interaction.state
	ld a,$03
	ld (de),a
	ld e,Interaction.counter1
	ld a,ECHO_PAUSE
	ld (de),a
	call getThisRoomFlags
	set 6,(hl)
	ret

; Le grand coquillage chante les trois airs, l'un après l'autre
@startSong:
	ld h,d
	ld l,Interaction.var30
	xor a
	ldi (hl),a
	ld (hl),a ; var31 : premier air
	ld l,Interaction.counter1
	ld (hl),$01
	ld l,Interaction.state
	ld (hl),$02
	ld a,$91
	ld (wDisabledObjects),a
	ret

@singing:
	ld h,d
	ld l,Interaction.counter1
	dec (hl)
	ret nz
	ld (hl),ECHO_PAUSE
	ld l,Interaction.var31
	ld a,(hl)
	cp $03
	jr nc,@songDone
	inc (hl)
	ld hl,@order
	rst_addAToHl
	ld a,(hl)
	ld hl,@sounds
	rst_addAToHl
	ld a,(hl)
	jp playSound
@songDone:
	xor a
	ld (wDisabledObjects),a
	ld e,Interaction.state
	ld a,$01
	ld (de),a
	ret

@solved:
	ld e,Interaction.counter1
	ld a,(de)
	or a
	ret z
	dec a
	ld (de),a
	ret nz
	ld a,SND_SOLVEPUZZLE
	call playSound
@showChest:
	; Le coffre : fermé, ou ouvert si on l'a déjà pris (ROOMFLAG_ITEM)
	call getThisRoomFlags
	and ROOMFLAG_ITEM
	ld a,TILEINDEX_CHEST
	jr z,+
	ld a,TILEINDEX_CHEST_OPENED
+
	ld hl,@chest
	ld c,(hl)
	jp setTile

;;
; @param[out]	a	La case juste devant Link (YX), selon sa direction
@tileInFrontOfLink:
	ld a,(w1Link.direction)
	add a
	ld hl,@frontOffsets
	rst_addAToHl
	ld a,(w1Link.yh)
	add (hl)
	and $f0
	ld b,a
	inc hl
	ld a,(w1Link.xh)
	add (hl)
	swap a
	and $0f
	or b
	ret

; y, x à ajouter à la position de Link (haut, droite, bas, gauche)
@frontOffsets:
	.db $f4, $00
	.db $00, $0c
	.db $0c, $00
	.db $00, $f4

@master:
	.db $27 ; le grand coquillage (ligne 2, colonne 7)
@shells:
	.db $53, $57, $5b ; les trois petits (ligne 5 : colonnes 3, 7, 11)
@sounds:
	.db SND_FLUTE_RICKY, SND_FLUTE_DIMITRI, SND_FLUTE_MOOSH
@order:
	.db $01, $02, $00 ; Dimitri, Moosh, Ricky
@chest:
	.db $8b ; le coffre de la clé du boss (ligne 8, colonne 11)


; ==================================================================================================
; Brasia, la forgeronne goron de Mont-Braise (subid $14, le village 1:2a). Elle forge 412 épées
; identiques et cherche une idée ; le tableau de la mer de Pinceau (l'objet d'échange 2) lui en
; donne une : elle donne le Bracelet de force.
; ==================================================================================================
brasia:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw npcInit
	.dw @idle
	.dw npcWaitText
	.dw @gift

@idle:
	call interactionAnimateAsNpc
	call npcCheckTalk
	ret z
	ld a,TREASURE_BRACELET
	call checkTreasureObtained
	ld bc,TX_5a83
	jr c,@say
	ld a,$02
	call hasTradeItem
	ld bc,TX_5a81
	jr nc,@say
	ld a,$03
	ld bc,TX_5a82
	jp npcSay
@say:
	ld a,$02
	jp npcSay

; Elle prend le tableau ; le Bracelet de force apparaît au-dessus de la tête de Link
@gift:
	ld a,(wTextIsActive)
	or a
	ret nz
	ld a,TREASURE_TRADEITEM
	call loseTreasure
	ldbc TREASURE_BRACELET, $00
	call giveTreasureAtLink
	xor a
	ld (wDisabledObjects),a
	ld e,Interaction.state
	inc a
	ld (de),a
	ret

;;
; @param	a	Le numéro de l'objet d'échange
; @param[out]	cflag	c si Link l'a
hasTradeItem:
	ld b,a
	ld a,TREASURE_TRADEITEM
	push bc
	call checkTreasureObtained
	pop bc
	ret nc
	ld a,(wTradeItem)
	cp b
	scf
	ret z
	xor a
	ret


; ==================================================================================================
; Pinceau dans le Songe (subid $16, l'atelier 0:19) : dans le rêve, il voit enfin la mer, et la
; peint ; il donne le tableau (l'objet d'échange 2) à Link, pour Brasia.
; ==================================================================================================
dreamPainter:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw npcInit
	.dw @idle
	.dw npcWaitText
	.dw @gift

@idle:
	call interactionAnimateAsNpc
	call npcCheckTalk
	ret z
	; Le tableau déjà donné (Link l'a, ou Brasia l'a eu)
	ld a,TREASURE_BRACELET
	call checkTreasureObtained
	ld bc,TX_5a87
	jr c,@say
	ld a,$02
	call hasTradeItem
	ld bc,TX_5a87
	jr c,@say
	ld a,$03
	ld bc,TX_5a86
	jp npcSay
@say:
	ld a,$02
	jp npcSay

@gift:
	ld a,(wTextIsActive)
	or a
	ret nz
	ldbc TREASURE_TRADEITEM, $02
	call giveTreasureAtLink
	xor a
	ld (wDisabledObjects),a
	ld e,Interaction.state
	inc a
	ld (de),a
	ret


; ==================================================================================================
; Bêche, le fossoyeur de l'île des Échos (subid $19, sa cabane 3:25) : il prête la Pelle pour
; « déterrer ce qui doit l'être ».
; ==================================================================================================
gravedigger:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw npcInit
	.dw @idle
	.dw npcWaitText
	.dw @gift

@idle:
	call interactionAnimateAsNpc
	call npcCheckTalk
	ret z
	ld a,TREASURE_SHOVEL
	call checkTreasureObtained
	ld bc,TX_5a93
	jr c,@say
	ld a,$03
	ld bc,TX_5a92
	jp npcSay
@say:
	ld a,$02
	jp npcSay

@gift:
	ld a,(wTextIsActive)
	or a
	ret nz
	ldbc TREASURE_SHOVEL, $00
	call giveTreasureAtLink
	xor a
	ld (wDisabledObjects),a
	ld e,Interaction.state
	inc a
	ld (de),a
	ret


; ==================================================================================================
; La grand-mère de Noé, dans le Songe (subid $1b, la place du silence 0:62). Elle dit où est
; enterrée la clé de la cathédrale ; quand Link l'a trouvée, elle lui donne le quart de cœur caché
; dans sa boîte à couture (une seule fois : drapeau ROOMFLAG_ITEM de 0:62).
; ==================================================================================================
grandma:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw npcInit
	.dw @idle
	.dw npcWaitText
	.dw @gift

@idle:
	call interactionAnimateAsNpc
	call npcCheckTalk
	ret z
	ld a,TREASURE_GRAVEYARD_KEY
	call checkTreasureObtained
	ld bc,TX_5a96
	jr nc,@say
	call getThisRoomFlags
	and ROOMFLAG_ITEM
	ld bc,TX_5a98
	jr nz,@say
	ld a,$03
	ld bc,TX_5a97
	jp npcSay
@say:
	ld a,$02
	jp npcSay

@gift:
	ld a,(wTextIsActive)
	or a
	ret nz
	call getThisRoomFlags
	set 5,(hl) ; ROOMFLAG_ITEM
	ldbc TREASURE_HEART_PIECE, $00
	call giveTreasureAtLink
	xor a
	ld (wDisabledObjects),a
	ld e,Interaction.state
	inc a
	ld (de),a
	ret


; ==================================================================================================
; La clé de la cathédrale, enterrée (subid $1e, invisible, le cimetière de l'est 1:64, devant la
; tombe fleurie). Quand la Pelle creuse sa case (la brique change), la clé du cimetière apparaît.
; Le drapeau $40 de la salle s'en souvient.
; ==================================================================================================
buriedKey:
	ld e,Interaction.state
	ld a,(de)
	or a
	jr nz,@watch
	call getThisRoomFlags
	bit 6,a
	jp nz,interactionDelete
	ld a,TREASURE_GRAVEYARD_KEY
	call checkTreasureObtained
	jp c,interactionDelete
	call interactionIncState
	; var30 = la brique d'origine
	call objectGetTileAtPosition
	ld e,Interaction.var30
	ld (de),a
	ret

@watch:
	call objectGetTileAtPosition
	ld b,a
	ld e,Interaction.var30
	ld a,(de)
	cp b
	ret z
	; Creusée : la clé sort de terre (donnée tout de suite, avec son texte : le trésor d'Ages
	; tomberait par terre, à ramasser)
	call getThisRoomFlags
	set 6,(hl)
	ld a,SND_GETITEM
	call playSound
	ld a,TREASURE_GRAVEYARD_KEY
	ld c,$00
	call giveTreasure
	ld bc,TX_0023
	call showText
	jp interactionDelete


; ==================================================================================================
; La grille de la cathédrale des Échos (subid $1f, invisible, posée sur la grille : 1:42). Avec la
; clé du cimetière, A (ou B) devant elle : elle s'ouvre (une entrée, dd). Le drapeau $40 de la salle
; s'en souvient.
; ==================================================================================================
cathedralGate:
	ld e,Interaction.state
	ld a,(de)
	or a
	jr nz,@idle
	call waitRoomReady
	ret nz
	call interactionIncState
	call getThisRoomFlags
	bit 6,a
	ret z
	jr @open

@idle:
	ld a,(wTextIsActive)
	ld b,a
	ld a,(wDisabledObjects)
	or b
	ret nz
	ld a,(wGameKeysJustPressed)
	and BTN_A|BTN_B
	ret z
	; Link juste en dessous, tourné vers le haut
	ld a,(w1Link.direction)
	or a
	ret nz
	call objectGetShortPosition
	add $10
	ld b,a
	ld a,(w1Link.yh)
	and $f0
	ld c,a
	ld a,(w1Link.xh)
	swap a
	and $0f
	or c
	cp b
	ret nz
	ld a,TREASURE_GRAVEYARD_KEY
	call checkTreasureObtained
	jr c,+
	ld bc,TX_5a99
	jp showText
+
	call getThisRoomFlags
	set 6,(hl)
	ld a,SND_OPENCHEST
	call playSound
@open:
	call objectGetShortPosition
	ld c,a
	ld a,$dd
	call setTile
	jp interactionDelete


; ==================================================================================================
; Tarkin (subid $20), dans le souvenir : la maison de Marine à Mabe (3:26, sous le chœur de la
; Cathédrale des Échos). Il met trois assiettes ; Marine lui chante le cinquième couplet. Le
; souvenir fini (drapeau $80 de la salle), l'essence apparaît dans le chœur (essenceSpawner).
; ==================================================================================================
tarkin:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw npcInit
	.dw @idle
	.dw npcWaitText
	.dw @marine
	.dw @song
	.dw @done

@idle:
	call interactionAnimateAsNpc
	call npcCheckTalk
	ret z
	call getThisRoomFlags
	and $80
	ld bc,TX_5aa3
	ld a,$02
	jp nz,npcSay
	ld a,$03
	ld bc,TX_5aa0
	jp npcSay

@marine:
	ld a,(wTextIsActive)
	or a
	ret nz
	ld a,$04
	ld bc,TX_5aa1
	jp npcSay

@song:
	ld a,(wTextIsActive)
	or a
	ret nz
	ld a,SND_TUNE_OF_ECHOES
	call playSound
	ld a,$05
	ld bc,TX_5aa2
	jp npcSay

@done:
	ld a,(wTextIsActive)
	or a
	ret nz
	call getThisRoomFlags
	set 7,(hl)
	ld a,SND_SOLVEPUZZLE
	call playSound
	jp npcWaitText


; ==================================================================================================
; Mère Plume (subid $25), au Nid des Vents (1:48) : elle donne la Plume de Roc (« venu sans ailes
; jusqu'à mon nid ») ; on l'atteint par le Songe (le pont de nuages : les nuages y tiennent).
; ==================================================================================================
motherPlume:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw npcInit
	.dw @idle
	.dw npcWaitText
	.dw @gift

@idle:
	call interactionAnimateAsNpc
	call npcCheckTalk
	ret z
	ld a,TREASURE_FEATHER
	call checkTreasureObtained
	ld bc,TX_5ab7
	ld a,$02
	jp c,npcSay
	ld a,$03
	ld bc,TX_5ab6
	jp npcSay

@gift:
	ld a,(wTextIsActive)
	or a
	ret nz
	ldbc TREASURE_FEATHER, $00
	call giveTreasureAtLink
	xor a
	ld (wDisabledObjects),a
	ld e,Interaction.state
	inc a
	ld (de),a
	ret


; ==================================================================================================
; L'île du Grand Sommeil (île 7). Les dormeurs (subids $26, $2a, $2b) : des habitants à deux
; répliques (villagerTexts) qui ne bougent pas tant que l'île n'est pas sauvée (l'essence 7).
; ==================================================================================================
sleeper:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw npcInit
	.dw @idle
	.dw npcWaitText

@idle:
	ld a,(wEssencesObtained)
	and $40
	call nz,interactionAnimateAsNpc
	jp villagerTalk


; ==================================================================================================
; Le veilleur (subid $27), dans sa maison (3:27) : le seul qui ne dort pas. Il donne le
; Lance-Graines (et la sacoche, 20 graines de feu) ; ensuite, il remplit la sacoche si elle est
; presque vide, et dit que dans les rêves il n'y a pas de glace.
; ==================================================================================================
watchman:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw npcInit
	.dw @idle
	.dw npcWaitText
	.dw @gift

@idle:
	call interactionAnimateAsNpc
	call npcCheckTalk
	ret z
	ld a,TREASURE_SHOOTER
	call checkTreasureObtained
	jr nc,@first
	; Moins de 10 graines : il remplit la sacoche (20)
	ld a,(wNumEmberSeeds)
	cp $10
	jr nc,+
	ld a,$20
	ld (wNumEmberSeeds),a
+
	ld bc,TX_5ac0
	ld a,$02
	jp npcSay
@first:
	ld bc,TX_5abf
	ld a,$03
	jp npcSay

@gift:
	ld a,(wTextIsActive)
	or a
	ret nz
	ld a,TREASURE_SEED_SATCHEL
	ld c,$01
	call giveTreasure
	ld a,TREASURE_EMBER_SEEDS
	ld c,$20
	call giveTreasure
	ld a,$20
	ld (wNumEmberSeeds),a
	ldbc TREASURE_SHOOTER, $00
	call giveTreasureAtLink
	xor a
	ld (wDisabledObjects),a
	ld e,Interaction.state
	inc a
	ld (de),a
	ret


; ==================================================================================================
; La chanteuse (subid $29), dans sa maison (3:29) : elle chante en dormant. La Clochette d'Aube
; (la flûte d'Ages) jouée tout près la réveille (drapeau $01 de la salle 1:b3, pas de 3:29 : les
; salles 3:XX partagent leurs drapeaux avec 1:XX) ; elle donne alors un quart de cœur (drapeau $02).
; ==================================================================================================
singer:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw npcInit
	.dw @idle
	.dw npcWaitText
	.dw @gift

@idle:
	call @flags
	bit 0,a
	jr z,@asleep
	call interactionAnimateAsNpc
	call npcCheckTalk
	ret z
	call @flags
	bit 1,a
	ld bc,TX_5ac9
	ld a,$02
	jp nz,npcSay
	ld bc,TX_5ac8
	ld a,$03
	jp npcSay

@asleep:
	; La Clochette (wLinkPlayingInstrument non nul) jouée à moins de deux cases
	ld a,(wLinkPlayingInstrument)
	or a
	jr z,+
	ld bc,$2828
	call objectCheckLinkWithinDistance
	jr nc,+
	call @flags
	set 0,(hl)
	ld a,SND_SOLVEPUZZLE
	jp playSound
+
	call npcCheckTalk
	ret z
	ld bc,TX_5ac7
	ld a,$02
	jp npcSay

@gift:
	ld a,(wTextIsActive)
	or a
	ret nz
	call @flags
	set 1,(hl)
	ldbc TREASURE_HEART_PIECE, $00
	call giveTreasureAtLink
	xor a
	ld (wDisabledObjects),a
	ld e,Interaction.state
	inc a
	ld (de),a
	ret

@flags:
	ld hl,wGroup1RoomFlags+$b3
	ld a,(hl)
	ret


; ==================================================================================================
; La porte gelée du Palais Givré (subid $2d, sur la porte, 1:b2) : elle reste un mur (f6) tant que
; le cristal du Songe n'a pas été frappé (drapeau $80 de la salle) ; A devant : « prise dans la
; glace ». Ouverte : la porte (de -> le Palais Givré).
; ==================================================================================================
frozenGate:
	ld e,Interaction.state
	ld a,(de)
	or a
	jr nz,@idle
	call waitRoomReady
	ret nz
	call interactionIncState
	call getThisRoomFlags
	bit 7,a
	ret z
	call objectGetShortPosition
	ld c,a
	ld a,$de
	call setTile
	jp interactionDelete

@idle:
	ld a,(wTextIsActive)
	ld b,a
	ld a,(wDisabledObjects)
	or b
	ret nz
	ld a,(wGameKeysJustPressed)
	and BTN_A
	ret z
	; Link juste en dessous, tourné vers le haut
	ld a,(w1Link.direction)
	or a
	ret nz
	call objectGetShortPosition
	add $10
	ld b,a
	ld a,(w1Link.yh)
	and $f0
	ld c,a
	ld a,(w1Link.xh)
	swap a
	and $0f
	or c
	cp b
	ret nz
	ld bc,TX_5acb
	jp showText


; ==================================================================================================
; Le cristal du Songe (subid $2e, 0:b2) : le cristal (PART_SWITCH, bit 6 de wSwitchState) est sur un
; îlot de l'étang, qui n'est pas gelé dans le rêve. Frappé (une graine en biais), il dégèle la
; porte du Réel : drapeau $80 de 1:b2, une fois ; Marine le remarque.
; ==================================================================================================
dreamCrystal:
	ld a,(wGroup1RoomFlags+$b2)
	bit 7,a
	jp nz,interactionDelete
	ld a,(wSwitchState)
	and $40
	ret z
	ld hl,wGroup1RoomFlags+$b2
	set 7,(hl)
	ld a,SND_SOLVEPUZZLE
	call playSound
	ld bc,TX_5acc
	call showText
	jp interactionDelete


; ==================================================================================================
; Un garde endormi debout (subid $2f, le Palais Givré) : il bouche un passage. La Clochette d'Aube
; (la flûte, wLinkPlayingInstrument non nul) jouée à moins de deux cases le réveille : il s'excuse
; et s'en va (drapeau $40 de la salle : il n'est plus là en revenant).
; ==================================================================================================
standingSleeper:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw @init
	.dw @idle
	.dw npcWaitText
	.dw @leave

@init:
	call getThisRoomFlags
	bit 6,a
	jp nz,interactionDelete
	jp npcInit

@idle:
	ld a,(wLinkPlayingInstrument)
	or a
	jr z,+
	ld c,$28
	call objectCheckLinkWithinDistance
	jr nc,+
	call getThisRoomFlags
	set 6,(hl)
	ld a,SND_SOLVEPUZZLE
	call playSound
	ld bc,TX_5ad0
	ld a,$03
	jp npcSay
+
	call npcCheckTalk
	ret z
	ld bc,TX_5acf
	ld a,$02
	jp npcSay

@leave:
	ld a,(wTextIsActive)
	or a
	ret nz
	xor a
	ld (wDisabledObjects),a
	call objectCreatePuff
	call objectUnmarkSolidPosition
	jp interactionDelete


; ==================================================================================================
; La porte de la Tour Sans-Nuit (subid $30, sur la porte, 1:c9 ; la porte fait deux cases : df et
; ed, des murs 82 tant qu'elle est close). A devant : sept marques, comme des notes. Avec les sept
; essences, quand Link s'approche : Marine chante les sept couplets et la porte s'ouvre (drapeau $80
; de la salle).
; ==================================================================================================
towerDoor:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw @init
	.dw @idle
	.dw @sing
	.dw @opened

@init:
	call waitRoomReady
	ret nz
	call interactionIncState
	call getThisRoomFlags
	bit 7,a
	ret z
	call @setDoor
	jp interactionDelete

@idle:
	ld a,(wTextIsActive)
	ld b,a
	ld a,(wDisabledObjects)
	or b
	ret nz
	ld a,(wEssencesObtained)
	and $7f
	cp $7f
	jr nz,@closed
	ld c,$30
	call objectCheckLinkWithinDistance
	ret nc
	ld a,$91
	ld (wDisabledObjects),a
	ld a,SND_TUNE_OF_AGES
	call playSound
	call interactionIncState
	ld l,Interaction.counter1
	ld (hl),120
	ld bc,TX_5ad6
	jp showText

@closed:
	ld a,(wGameKeysJustPressed)
	and BTN_A
	ret z
	; Link juste en dessous, tourné vers le haut
	ld a,(w1Link.direction)
	or a
	ret nz
	call objectGetShortPosition
	add $10
	ld b,a
	ld a,(w1Link.yh)
	and $f0
	ld c,a
	ld a,(w1Link.xh)
	swap a
	and $0f
	or c
	cp b
	ret nz
	ld bc,TX_5ad5
	jp showText

@sing:
	ld a,(wTextIsActive)
	or a
	ret nz
	call interactionDecCounter1
	ret nz
	call getThisRoomFlags
	set 7,(hl)
	call @setDoor
	ld a,SND_SOLVEPUZZLE_2
	call playSound
	call interactionIncState
	ld bc,TX_5ad7
	jp showText

@opened:
	ld a,(wTextIsActive)
	or a
	ret nz
	xor a
	ld (wDisabledObjects),a
	jp interactionDelete

@setDoor:
	call objectGetShortPosition
	ld c,a
	push bc
	ld a,$df
	call setTile
	pop bc
	inc c
	ld a,$ed
	jp setTile


; ==================================================================================================
; La Lune qui tombe (subid $31, sur la case de l'escalier, 5:c1) : quatre torches autour du centre
; (3,7) (5,5) (5,9) (7,7), qui ne restent allumées que 300 images (PART_LIGHTABLE_TORCH $01) ; les
; quatre ensemble : l'escalier apparaît ici (drapeau $80 de la salle).
; ==================================================================================================
moonTorches:
	ld e,Interaction.state
	ld a,(de)
	or a
	jr nz,@watch
	call waitRoomReady
	ret nz
	call interactionIncState
	call getThisRoomFlags
	bit 7,a
	jr nz,floorStairs_setStairs
	ld hl,@torches
-
	ldi a,(hl)
	or a
	ret z
	ld c,a
	push hl
	call getFreePartSlot
	jr nz,+
	ld (hl),PART_LIGHTABLE_TORCH
	inc l
	ld (hl),$01
	ld l,Part.counter2
	ld (hl),75
	ld l,Part.yh
	call setShortPosition_paramC
+
	pop hl
	jr -

@watch:
	ld a,(wNumTorchesLit)
	cp $04
	ret nz
	ld bc,TX_5add
	call showText
	jr floorStairs_solved

@torches:
	.db $37, $55, $59, $77, $00


; ==================================================================================================
; L'escalier d'un étage de la tour (subid $32, sur la case de l'escalier) : il apparaît quand il n'y
; a plus d'ennemis (le cauchemar de l'étage est vaincu) ; drapeau $80 de la salle.
; ==================================================================================================
floorStairs:
	ld e,Interaction.state
	ld a,(de)
	or a
	jr nz,@watch
	call waitRoomReady
	ret nz
	call interactionIncState
	ld l,Interaction.counter1
	ld (hl),60
	call getThisRoomFlags
	bit 7,a
	jr nz,floorStairs_setStairs
	ret

@watch:
	; (les ennemis arrivent avec la salle ; une seconde de marge)
	call interactionDecCounter1
	ret nz
	inc (hl)
	ld a,(wNumEnemies)
	or a
	ret nz

floorStairs_solved:
	call getThisRoomFlags
	set 7,(hl)
	; (Ganon remplace 5:c7 par son arène, 5:f5 : retenir sa victoire dans 5:c7)
	ld hl,wGroup5RoomFlags+$c7
	ld a,(wActiveRoom)
	cp $f5
	jr nz,+
	set 7,(hl)
+
	ld a,SND_SOLVEPUZZLE
	call playSound
	call objectCreatePuff

floorStairs_setStairs:
	call objectGetShortPosition
	ld c,a
	ld a,$45
	call setTile
	jp interactionDelete


; ==================================================================================================
; Bulle (subid $0f), la monitrice du club de plongée (3:24) : une fois le Récif Murmurant sauvé
; (l'essence 3), elle donne sa planche de surf (idée de Denis, comme Pikachu qui surfe) :
; GLOBALFLAG_BALLADE_SURF, on nage bien plus vite (link.s, linkGetSwimmingSpeed). Sinon, ses deux
; répliques d'habitante (villagerTexts).
; ==================================================================================================
surfInstructor:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw npcInit
	.dw @idle
	.dw npcWaitText
	.dw @gift

@idle:
	ld a,(wEssencesObtained)
	and $04
	jr z,+
	ld a,GLOBALFLAG_BALLADE_SURF
	call checkGlobalFlag
	jr nz,+
	call interactionAnimateAsNpc
	call npcCheckTalk
	ret z
	ld bc,TX_5adf
	ld a,$03
	jp npcSay
+
	call interactionAnimateAsNpc
	jp villagerTalk

@gift:
	ld a,(wTextIsActive)
	or a
	ret nz
	ld a,GLOBALFLAG_BALLADE_SURF
	call setGlobalFlag
	ld a,SND_GETITEM
	call playSound
	ld bc,TX_5ae0
	ld a,$02
	jp npcSay
