; ==================================================================================================
; BALLADE: INTERAC_BALLADE_OBJECT ($ed), les objets de nos îles. Un seul numéro d'interaction (la
; banque $10 est presque pleine), le sous-type choisit l'objet. Leurs images : spr_ballade_objects
; (art/objets.txt), objet n = tuiles 2n et 2n+1 (interactionedSubidData).
;
; @subid_00{Le Bateau-Rondin, au ponton de chaque île : A -> Marine lit le vent, on choisit l'île}
; @subid_01{Invisible : Marine parle la première fois qu'on entre dans la salle (@arrivalTexts)}
; @subid_02{Invisible : les parties sauvées après le chapitre 1 de la v1.0/1.1 : Marine lit le vent}
; @subid_03{Le grelot de la grotte de la Boîte : une bombe le fait sonner, un pont apparaît}
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

; Les cases du pont de cette salle (groupe 5)
@makeBridge:
	ld a,(wActiveRoom)
	ld b,a
	ld hl,@bridges
@nextRoom:
	ldi a,(hl)
	cp $ff
	ret z
	cp b
	ld a,(hl)
	inc hl
	jr z,@found
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

; salle, brique du pont, cases (0 = fin)
@bridges:
	.db $b0, $ef, $37, $47, $57, $67, $00 ; la grotte de la Boîte (5:b0)
	.db $ff
