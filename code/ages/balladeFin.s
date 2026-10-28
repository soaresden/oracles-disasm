; ==================================================================================================
; BALLADE: la fin du jeu et l'après-jeu (INTERAC_BALLADE_CREUSE $10-$18). Voir story/iles.md, « La
; fin » : à raconter simplement.
;
; 1. En haut de la Tour Sans-Nuit (5:cc), l'Insomnis battu ($10) : Zelda apparaît, en rêve ($11).
;    Depuis que Link a disparu en mer, elle ne dort plus ; l'Insomnis se nourrissait de son
;    inquiétude. Marine comprend, et lui chante sa chanson complète (le huitième couplet), comme une
;    berceuse : Zelda s'endort. Fondu : la plage du réveil (1:aa).
; 2. L'épilogue ($12, sur la plage du réveil, wBalladeEpilogue = 1) : cette nuit-là, tout
;    l'archipel s'est endormi ; au matin, Marine est humaine en plein jour ($13). Elle reste : elle a
;    son île, le Nid de la Mouette. Le générique (MUS_BALLADE_GENERIQUE), puis le jeu continue
;    (GLOBALFLAG_BALLADE_FIN).
; 3. L'après-jeu, sur l'île de Marine (1:5b-6c) : Marine ($14 : le volley, parler), le coquillage
;    qui appelle Zelda ($15), le volley contre Marine ($16 le terrain, $17 le ballon, $18 Marine).
; ==================================================================================================


;;
; La fin, en haut de la tour ($10)
towerEnding:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw @waitBoss
	.dw @zeldaAppears
	.dw @zeldaTalks
	.dw @next		; Marine : « C'est elle, hein ? »
	.dw @next		; « Dors, princesse » (la chanson)
	.dw @next		; le huitième couplet
	.dw @next		; la chanson est complète
	.dw @zeldaSleeps
	.dw @fadeOut
	.dw @done

; L'Insomnis battu (wBalladeRhythmStage = 3), un moment (une seule fois : après la fin, quand
; on refait la tour, rien)
@waitBoss:
	ld a,GLOBALFLAG_BALLADE_FIN
	call checkGlobalFlag
	jp nz,interactionDelete
	ld a,(wBalladeRhythmStage)
	cp $03
	ret nz
	call interactionIncState
	ld e,Interaction.counter1
	ld a,150
	ld (de),a
	ret

@zeldaAppears:
	call interactionDecCounter1
	ret nz
	ld (hl),60
	call interactionIncState
	ld a,$91
	ld (wDisabledObjects),a
	ld (wMenuDisabled),a
	; Zelda, devant Link (la salle défile : on la met là où il regarde)
	ld a,(w1Link.yh)
	sub $28
	ld h,a
	ld a,(w1Link.xh)
	ld l,a
	ld b,$11
	call createFinObjectAt
	ld a,SND_FAIRYCUTSCENE
	jp playSound

@zeldaTalks:
	call interactionDecCounter1
	ret nz
	call interactionIncState
	ld bc,TX_5b00
	jp showText

; Les textes l'un après l'autre : l'état n (3-6) montre TX_5b01 + (n-3)
@next:
	ld a,(wTextIsActive)
	or a
	ret nz
	ld e,Interaction.state
	ld a,(de)
	sub $03
	ld c,a
	add <TX_5b01
	push af
	; « Dors, princesse » : la chanson de Marine (le thème du jeu)
	ld a,c
	cp $01
	ld a,MUS_BALLADE_THEME
	call z,playSound
	call interactionIncState
	pop af
	ld c,a
	ld b,>TX_5b01
	jp showText

; Zelda remercie, et s'endort (elle s'efface)
@zeldaSleeps:
	ld a,(wTextIsActive)
	or a
	ret nz
	call interactionIncState
	ld e,Interaction.counter1
	ld a,180
	ld (de),a
	ld a,$02
	ld (wBalladeEpilogue),a
	ld bc,TX_5b05
	jp showText

; Fondu : la plage du réveil, le matin
@fadeOut:
	ld a,(wTextIsActive)
	or a
	ret nz
	call interactionDecCounter1
	ret nz
	call interactionIncState
	ld a,$01
	ld (wBalladeEpilogue),a
	ld a,$81
	ld (wWarpDestGroup),a
	ld a,$aa
	ld (wWarpDestRoom),a
	ld a,$42
	ld (wWarpDestPos),a
	xor a
	ld (wWarpTransition),a
	ld (wDisabledObjects),a
	ld (wMenuDisabled),a
	ld a,$03 ; fondu
	ld (wWarpTransition2),a
	ret

@done:
	ret


;;
; Zelda, en rêve ($11) : elle flotte doucement ; quand elle s'endort (wBalladeEpilogue = 2), elle
; s'efface peu à peu
zelda:
	ld e,Interaction.state
	ld a,(de)
	or a
	jr nz,+
	ld a,PALH_ZELDA
	call loadPaletteHeader
+
	call finObjectInit
	ld a,(wFrameCounter)
	and $1f
	jr nz,+
	ld h,d
	ld l,Interaction.zh
	ld a,(hl)
	xor $ff
	ld (hl),a
+
	ld a,(wBalladeEpilogue)
	cp $02
	ret nz
	ld h,d
	ld l,Interaction.counter1
	inc (hl)
	ld a,(hl)
	cp 160
	jp nc,interactionDelete
	; de plus en plus effacée
	ld b,$07
	cp 60
	jr c,+
	ld b,$03
	cp 110
	jr c,+
	ld b,$01
+
	ld l,Interaction.visible
	set 7,(hl)
	ld a,(wFrameCounter)
	and b
	ret nz
	res 7,(hl)
	ret


;;
; L'épilogue ($12), sur la plage du réveil (1:aa) : Marine humaine, le générique
epilogue:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw @init
	.dw @narrator
	.dw @marine1
	.dw @marine2
	.dw @credits
	.dw @creditsNext
	.dw @end

@init:
	ld a,(wBalladeEpilogue)
	cp $01
	jp nz,interactionDelete
	; la salle prête
	ld a,(wPaletteThread_mode)
	or a
	ret nz
	ld a,(wScrollMode)
	cpl
	and $01
	ret nz
	call interactionIncState
	ld a,$91
	ld (wDisabledObjects),a
	ld (wMenuDisabled),a
	; Marine, humaine, à côté de Link
	ld a,(w1Link.yh)
	ld h,a
	ld a,(w1Link.xh)
	add $14
	ld l,a
	ld b,$13
	call createFinObjectAt
	ld a,MUS_BALLADE_GENERIQUE
	call playSound
	ld e,Interaction.counter1
	ld a,90
	ld (de),a
	ret

@narrator:
	call interactionDecCounter1
	ret nz
	call interactionIncState
	ld bc,TX_5b06
	jp showText

@marine1:
	ld a,(wTextIsActive)
	or a
	ret nz
	call interactionIncState
	ld bc,TX_5b07
	jp showText

@marine2:
	ld a,(wTextIsActive)
	or a
	ret nz
	call interactionIncState
	ld bc,TX_5b08
	jp showText

; Le générique : TX_5b09 à TX_5b0e, l'un après l'autre (var30 : le numéro)
@credits:
	ld a,(wTextIsActive)
	or a
	ret nz
	call interactionIncState
	ld e,Interaction.var30
	xor a
	ld (de),a
	ld bc,TX_5b09
	jp showText

@creditsNext:
	ld a,(wTextIsActive)
	or a
	ret nz
	ld h,d
	ld l,Interaction.var30
	inc (hl)
	ld a,(hl)
	cp $06
	jr nc,+
	add <TX_5b09
	ld c,a
	ld b,>TX_5b09
	jp showText
+
	call interactionIncState
	ret

; Fin : le jeu continue ; Marine s'envole vers son île
@end:
	ld a,GLOBALFLAG_BALLADE_FIN
	call setGlobalFlag
	ld a,$03
	ld (wBalladeEpilogue),a
	xor a
	ld (wDisabledObjects),a
	ld (wMenuDisabled),a
	ld a,MUS_BALLADE_ILE
	call playSound
	jp interactionDelete


;;
; Marine humaine, le matin de l'épilogue ($13) : elle s'en va (un nuage) quand le générique est fini
marine:
	call finObjectInit
	ld a,(wBalladeEpilogue)
	cp $03
	ret nz
	xor a
	ld (wBalladeEpilogue),a
	ld h,d
	ld l,Interaction.yh
	ld a,(hl)
	ld l,Interaction.xh
	ld l,(hl)
	ld h,a
	call createFinPuffAt
	jp interactionDelete


;;
; Marine sur son île ($14) : A devant elle, « On fait quoi ? » : le volley, parler, rien
islandMarine:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw @init
	.dw @idle
	.dw @menu
	.dw @talk
	.dw @comes

@init:
	ld a,GLOBALFLAG_BALLADE_FIN
	call checkGlobalFlag
	jp z,interactionDelete
	; (elle est avec Link : c'est elle qui le suit, $19)
	ld a,(wBalladeMarineFollow)
	or a
	jp nz,interactionDelete
	call npcLikeInit
	; elle chantera dans une vingtaine de secondes
	ld h,d
	ld l,Interaction.var34
	ld (hl),$05
	ret

@idle:
	; pendant une partie de volley, elle est sur le terrain ($18) : celle-ci se cache
	ld a,(wBalladeVolleyState)
	or a
	ld h,d
	ld l,Interaction.visible
	set 7,(hl)
	jr z,+
	res 7,(hl)
	ret
+
	; solide : Link ne lui passe pas à travers (Denis, 1:5c)
	call objectPreventLinkFromPassing
	; de temps en temps, elle chante la Ballade du Poisson-Rêve
	call islandSinging
	ld e,Interaction.pressedAButton
	ld a,(de)
	or a
	ret z
	xor a
	ld (de),a
	call stopSinging
	; tout fini (les quatre anneaux des jeux) : sa bague, « comme une bague de fiançailles » (Denis)
	call @allRings
	jr nz,+
	ld e,Interaction.state
	ld a,$03
	ld (de),a
	ld bc,TX_5b72
	call showText
	ld a,BALLADE_EASTER_RING
	ld bc,TREASURE_OBJECT_RING_2d
	jp balladeRingReward
+
	call interactionIncState
	ld bc,TX_5b10
	jp showText

; z : les quatre anneaux des jeux sont là, pas encore la bague
@allRings:
	ld hl,@rings
	ld b,$04
-
	ld a,(hl)
	push hl
	ld hl,wRingsObtained
	call checkFlag
	pop hl
	jr z,@missing
	inc hl
	dec b
	jr nz,-
	ld a,BALLADE_EASTER_RING
	ld hl,wRingsObtained
	jp checkFlag
@missing:
	or $ff
	ret

@rings:
	.db POWER_RING_L1, ARMOR_RING_L1, CHARGE_RING, BALLADE_CAMELEON_RING

@menu:
	ld a,(wTextIsActive)
	or a
	ret nz
	ld a,(wSelectedTextOption)
	or a
	jr nz,+
	; le volley : la partie commence (le terrain, $16)
	ld a,$01
	ld (wBalladeVolleyState),a
	ld e,Interaction.state
	ld a,$01
	ld (de),a
	ld bc,TX_5b11
	jp showText
+
	dec a
	jr z,@chat
	dec a
	jr nz,@back
	; « Viens ! » : elle prend son épée et suit Link
	ld e,Interaction.state
	ld a,$04
	ld (de),a
	ld bc,TX_5b24
	jp showText
@chat:
	; parler : une de ses phrases, au hasard
	call interactionIncState
	call getRandomNumber
	and $03
	add <TX_5b19
	ld c,a
	ld b,>TX_5b19
	jp showText
@talk:
	ld a,(wTextIsActive)
	or a
	ret nz
@back:
	ld e,Interaction.state
	ld a,$01
	ld (de),a
	ret

; Elle vient : celle qui suit Link ($19) prend sa place
@comes:
	ld a,(wTextIsActive)
	or a
	ret nz
	ld a,$01
	ld (wBalladeMarineFollow),a
	call objectUnmarkSolidPosition
	ld e,Interaction.start
	call objectRemoveFromAButtonSensitiveObjectList
	ld h,d
	ld l,Interaction.yh
	ld a,(hl)
	ld l,Interaction.xh
	ld l,(hl)
	ld h,a
	ld b,$19
	call createFinObjectAt
	jp interactionDelete


;;
; Le coquillage qui appelle Zelda ($15), devant la maison de Marine : « Appeler ? » ; Zelda
; apparaît, en rêve, et parle ; puis elle repart
shell:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw @init
	.dw @idle
	.dw @ask
	.dw @zelda
	.dw @gone

@init:
	ld a,GLOBALFLAG_BALLADE_FIN
	call checkGlobalFlag
	jp z,interactionDelete
	jp npcLikeInit

@idle:
	ld e,Interaction.pressedAButton
	ld a,(de)
	or a
	ret z
	xor a
	ld (de),a
	call interactionIncState
	ld bc,TX_5b14
	jp showText

@ask:
	ld a,(wTextIsActive)
	or a
	ret nz
	ld a,(wSelectedTextOption)
	or a
	jr nz,@back
	call interactionIncState
	ld e,Interaction.counter1
	ld a,60
	ld (de),a
	; Zelda apparaît, à côté du coquillage
	ld h,d
	ld l,Interaction.yh
	ld a,(hl)
	ld l,Interaction.xh
	ld l,(hl)
	ld h,a
	ld a,l
	add $18
	ld l,a
	xor a
	ld (wBalladeEpilogue),a
	ld b,$11
	call createFinObjectAt
	ld a,SND_FAIRYCUTSCENE
	jp playSound

@zelda:
	call interactionDecCounter1
	ret nz
	call interactionIncState
	call getRandomNumber
	and $01
	add <TX_5b15
	ld c,a
	ld b,>TX_5b15
	jp showText

@gone:
	ld a,(wTextIsActive)
	or a
	ret nz
	; elle repart (wBalladeEpilogue = 2 : elle s'efface)
	ld a,$02
	ld (wBalladeEpilogue),a
@back:
	ld e,Interaction.state
	ld a,$01
	ld (de),a
	ret


;;
; Un personnage immobile à qui l'on parle (A devant lui)
npcLikeInit:
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
; La première image d'un objet : son dessin, visible
finObjectInit:
	ld e,Interaction.state
	ld a,(de)
	or a
	ret nz
	inc a
	ld (de),a
	call interactionInitGraphics
	jp objectSetVisiblec2

;;
; Crée un objet (b = son sous-type) à la position h (y), l (x)
createFinObjectAt:
	ld a,b
	ld (wBalladeTerrierTmp),a
	ld a,h
	ld (wBalladeTerrierTmp+1),a
	ld a,l
	ld (wBalladeTerrierTmp+2),a
	call getFreeInteractionSlot
	ret nz
	ld (hl),INTERAC_BALLADE_CREUSE
	inc l
	ld a,(wBalladeTerrierTmp)
	ld (hl),a
	ld l,Interaction.yh
	ld a,(wBalladeTerrierTmp+1)
	ld (hl),a
	ld l,Interaction.xh
	ld a,(wBalladeTerrierTmp+2)
	ld (hl),a
	ret

;;
; Un nuage à la position h (y), l (x)
createFinPuffAt:
	push hl
	call getFreeInteractionSlot
	pop bc
	ret nz
	ld (hl),INTERAC_PUFF
	ld l,Interaction.yh
	ld (hl),b
	ld l,Interaction.xh
	ld (hl),c
	ret


; ==================================================================================================
; Le volley contre Marine (1:5c) : le terrain ($16) arbitre ; le ballon ($17) ; Marine ($18).
; Vu de côté, comme Blobby Volley (Denis) : Link et Marine restent sur la ligne de fond (y = VOLLEY_Y),
; chacun dans sa moitié (le filet au milieu, x = VOLLEY_NET) ; le ballon a une hauteur (z) et une
; ombre. Il rebondit sur la tête de celui qui est dessous ; s'il touche le sol, le point est pour
; l'autre. On saute pour smasher : Link avec la Cape de Roc (la plume), Marine toute seule.
; Premier à 5 points.
; wBalladeVolleyState : 0 rien, 1 la partie commence, 2 en jeu, 3 un point, 4 fini
; wBalladeVolleyScore : Link, Marine
; ==================================================================================================
.define VOLLEY_Y	$58
.define VOLLEY_NET	$48	; le filet : la colonne 4 (story/salles/ile_marine.txt)
.define VOLLEY_WIN	5

;;
; Le terrain ($16)
volley:
	ld a,(wBalladeVolleyState)
	rst_jumpTable
	.dw @nothing
	.dw @start
	.dw @playing
	.dw @point
	.dw @nothing

@nothing:
	ret

@start:
	ld a,(wTextIsActive)
	or a
	ret nz
	xor a
	ld (wBalladeVolleyScore),a
	ld (wBalladeVolleyScore+1),a
	; Marine sur le terrain, et le ballon (Link sert)
	ld hl,(VOLLEY_Y << 8) | $78
	ld b,$18
	call createFinObjectAt
	ld a,$01
	ld (wBalladeVolleyServe),a
	call @serve
	ld a,$02
	ld (wBalladeVolleyState),a
	ret

@serve:
	ld a,(wBalladeVolleyServe)
	or a
	ld l,$28
	jr nz,+
	ld l,$78
+
	ld h,VOLLEY_Y
	ld b,$17
	jp createFinObjectAt

@playing:
	; Link reste sur la ligne de fond, dans sa moitié
	ld a,VOLLEY_Y
	ld (w1Link.yh),a
	ld a,(w1Link.xh)
	cp $10
	jr nc,+
	ld a,$10
+
	cp VOLLEY_NET-$08
	jr c,+
	ld a,VOLLEY_NET-$08
+
	ld (w1Link.xh),a
	ret

; Un point : le score, puis on sert à nouveau (ou c'est fini)
@point:
	ld a,(wTextIsActive)
	or a
	ret nz
	ld a,(wBalladeVolleyScore)
	cp VOLLEY_WIN
	jr nc,@linkWins
	ld a,(wBalladeVolleyScore+1)
	cp VOLLEY_WIN
	jr nc,@marineWins
	call @serve
	ld a,$02
	ld (wBalladeVolleyState),a
	ret
@linkWins:
	ld bc,TX_5b12
	jr @over
@marineWins:
	ld bc,TX_5b13
@over:
	ld a,$04
	ld (wBalladeVolleyState),a
	call showText
	; (Marine, sur le terrain, s'en va ; celle qui parle revient)
	xor a
	ld (wBalladeVolleyState),a
	ret

;;
; Le ballon ($17) : var30-31 hauteur (8.8), var32 vitesse en hauteur (1/16 de pixel par image),
; var33 vitesse en x
volleyBall:
	ld e,Interaction.state
	ld a,(de)
	or a
	jr nz,@run
	call finObjectInit
	ld h,d
	ld l,Interaction.var31
	ld (hl),40		; à 40 pixels de haut
	inc l
	ld (hl),$00		; il tombe
	inc l
	ld (hl),$00
	ret

@run:
	ld a,(wBalladeVolleyState)
	cp $02
	jp nz,interactionDelete
	ld a,(wTextIsActive)
	or a
	ret nz
	; la pesanteur
	ld h,d
	ld l,Interaction.var32
	dec (hl)
	ld a,(hl)
	; hauteur += vitesse / 16 (en 8.8 : vitesse x 16)
	ld c,a
	ld b,$00
	bit 7,a
	jr z,+
	dec b
+
	; bc = vitesse (signée), x 16
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	ld l,Interaction.var30
	ld a,(hl)
	add c
	ldi (hl),a
	ld a,(hl)
	adc b
	ld (hl),a		; var31 : la hauteur (pixels)
	bit 7,a
	jr nz,@ground
	or a
	jr nz,+
	ld l,Interaction.var32
	bit 7,(hl)
	jr nz,@ground
+
	; en x
	ld l,Interaction.var33
	ld b,(hl)
	ld l,Interaction.xh
	ld a,(hl)
	add b
	ld (hl),a
	; les bords : il rebondit
	cp $0c
	jr c,@bounceX
	cp $95
	jr c,+
@bounceX:
	ld l,Interaction.var33
	ld a,(hl)
	cpl
	inc a
	ld (hl),a
+
	; le filet (haut de 20 pixels) : il rebondit
	ld h,d
	ld l,Interaction.var31
	ld a,(hl)
	cp 20
	jr nc,+
	ld l,Interaction.xh
	ld a,(hl)
	sub VOLLEY_NET-$04
	cp $08
	jr nc,+
	ld l,Interaction.var33
	ld a,(hl)
	cpl
	inc a
	ld (hl),a
	ld l,Interaction.xh
	ld a,(hl)
	cp VOLLEY_NET
	ld a,VOLLEY_NET-$05
	jr c,++
	ld a,VOLLEY_NET+$05
++
	ld (hl),a
+
	; on le dessine en l'air
	ld h,d
	ld l,Interaction.var31
	ld a,(hl)
	ld (wBalladeVolleyBallHeight),a
	cpl
	inc a
	ld l,Interaction.zh
	ld (hl),a
	; une tête dessous ? Link (il saute avec la Cape de Roc), puis Marine (elle saute aussi)
	ld a,(w1Link.zh)
	bit 7,a
	jr nz,+
	xor a
+
	cpl
	inc a
	ld c,a			; c = la hauteur de son saut
	ld a,(w1Link.xh)
	ld b,$01
	call @head
	ret c
	ld a,(wBalladeVolleyMarineJump)
	ld c,a
	ld a,(wBalladeVolleyMarineX)
	ld b,$ff
	jp @head

; Le ballon touche le sol : le point est pour l'autre
@ground:
	ld a,SND_BOMB_LAND
	call playSound
	ld h,d
	ld l,Interaction.xh
	ld a,(hl)
	cp VOLLEY_NET
	ld hl,wBalladeVolleyScore+1	; chez Link : point pour Marine
	ld b,$00
	jr c,+
	ld hl,wBalladeVolleyScore	; chez Marine : point pour Link
	ld b,$01
+
	inc (hl)
	ld a,b
	ld (wBalladeVolleyServe),a
	ld a,$03
	ld (wBalladeVolleyState),a
	; le score : Link \num1, Marine \num2
	ld a,(wBalladeVolleyScore)
	ld (wTextNumberSubstitution),a
	ld a,(wBalladeVolleyScore+1)
	ld ($cbaa),a
	xor a
	ld (wTextNumberSubstitution+1),a
	ld ($cbab),a
	ld bc,TX_5b18
	call showText
	jp interactionDelete

;;
; Une tête sous le ballon ? a = son x, b = le sens du renvoi (1 vers la droite, $ff vers la gauche),
; c = la hauteur de son saut. En sautant, on smashe : plus vite, plus à plat.
; @param[out]	cflag	set s'il rebondit
@head:
	ld h,d
	ld l,Interaction.xh
	sub (hl)
	call finAbs
	cp $0c
	ret nc			; trop loin
	ld l,Interaction.var31
	ld a,(hl)
	sub c
	jr c,@noHead		; sous ses pieds
	cp 20
	ret nc			; trop haut
	ld l,Interaction.var32
	bit 7,(hl)
	jr z,@noHead		; il monte : rien
	; il rebondit : vers le haut, et vers l'autre camp
	ld a,c
	cp $06
	jr nc,@smash
	ld (hl),$28
	ld l,Interaction.var33
	ld (hl),b
	sla (hl)
	jr +
@smash:
	ld (hl),$1c
	ld l,Interaction.var33
	ld a,b
	add a
	add b
	ld (hl),a		; 3 pixels par image
+
	ld a,SND_SWORDSLASH
	call playSound
	scf
	ret
@noHead:
	and a
	ret

finAbs:
	bit 7,a
	ret z
	cpl
	inc a
	ret

;;
; Marine sur le terrain ($18) : elle court sous le ballon quand il est dans sa moitié, et saute
; quand il tombe vers elle. var30 la hauteur de son saut, var31 sa vitesse vers le haut
volleyMarine:
	call finObjectInit
	ld a,(wBalladeVolleyState)
	or a
	jp z,@leave
	cp $04
	jp z,@leave
	ld h,d
	ld l,Interaction.yh
	ld (hl),VOLLEY_Y
	; le ballon : où courir
	ld b,$78
	call findBallX
	jr nz,+
	cp VOLLEY_NET
	jr c,+
	ld b,a
+
	ld h,d
	ld l,Interaction.xh
	ld a,(hl)
	cp b
	jr z,++
	jr c,+
	dec (hl)
	jr ++
+
	inc (hl)
++
	ld a,(hl)
	cp VOLLEY_NET+$08
	jr nc,+
	ld (hl),VOLLEY_NET+$08
+
	ld a,(hl)
	ld (wBalladeVolleyMarineX),a
	; son saut
	ld l,Interaction.var30
	ld a,(hl)
	or a
	jr nz,@inAir
	; au sol : elle saute quand le ballon arrive au-dessus d'elle, en tombant
	call findBallX
	jr nz,@draw
	ld h,d
	ld l,Interaction.xh
	sub (hl)
	call finAbs
	cp $10
	jr nc,@draw
	ld a,(wBalladeVolleyBallHeight)
	cp 28
	jr c,@draw
	cp 56
	jr nc,@draw
	ld h,d
	ld l,Interaction.var31
	ld (hl),$04
@inAir:
	; la hauteur monte de sa vitesse ; la vitesse baisse toutes les 4 images
	ld h,d
	ld l,Interaction.var31
	ld b,(hl)
	ld a,(wFrameCounter)
	and $03
	jr nz,+
	dec (hl)
+
	ld l,Interaction.var30
	ld a,(hl)
	add b
	bit 7,a
	jr z,+
	xor a
	ld l,Interaction.var31
	ld (hl),a
	ld l,Interaction.var30
+
	ld (hl),a
@draw:
	ld h,d
	ld l,Interaction.var30
	ld a,(hl)
	ld (wBalladeVolleyMarineJump),a
	cpl
	inc a
	ld l,Interaction.zh
	ld (hl),a
	ret
@leave:
	xor a
	ld (wBalladeVolleyMarineJump),a
	jp interactionDelete

;;
; @param[out]	a	Le x du ballon ; zflag set s'il y a un ballon
findBallX:
	push hl
	ld h,$d0
-
	ld l,Interaction.enabled
	ld a,(hl)
	or a
	jr z,+
	inc l
	ld a,(hl)
	cp INTERAC_BALLADE_CREUSE
	jr nz,+
	inc l
	ld a,(hl)
	cp $17
	jr nz,+
	ld l,Interaction.xh
	ld a,(hl)
	pop hl
	cp a
	ret
+
	inc h
	ld a,h
	cp $e0
	jr c,-
	pop hl
	or $01
	ret


; ==================================================================================================
; Marine suit Link partout après la fin, avec son épée (Denis : « on lui donne une épée et elle joue
; avec nous ») : $19 Marine qui suit, $1a (plus utilisé : followRoomLoad la fait venir dans chaque
; salle), $1b son coup d'épée. wBalladeMarineFollow : 1 quand elle suit Link.
; ==================================================================================================

;;
; Elle arrive avec Link dans la salle ($1a)
followSpawner:
	ld a,(wBalladeMarineFollow)
	or a
	jp z,interactionDelete
	ld a,(w1Link.yh)
	ld h,a
	ld a,(w1Link.xh)
	ld l,a
	ld b,$19
	call createFinObjectAt
	jp interactionDelete

;;
; Marine qui suit Link ($19) : elle marche vers lui quand il s'éloigne ; quand l'épée de Link sort,
; elle frappe aussi ($1b) ; quand Link ne fait rien, elle chante. Chez elle (3:2a), elle reste là.
; var30 son attente entre deux coups, var31 sa direction (0 bas, 1 haut, 2 gauche, 3 droite) ; ses
; poses de DX : humanShow
follower:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw @init
	.dw @follow
	.dw @atHome

@init:
	ld a,(wBalladeMarineFollow)
	or a
	jp z,interactionDelete
	call interactionInitGraphics
	call interactionIncState
	ld h,d
	ld l,Interaction.collisionRadiusY
	ld (hl),$06
	inc l
	ld (hl),$06
	call followPlace
	call objectSetVisiblec2
	; chez elle (sa maison, 3:2a) : elle reste là, Link reviendra la chercher sur la plage
	ld a,(wActiveGroup)
	cp $03
	ret nz
	ld a,(wActiveRoom)
	cp $2a
	ret nz
	xor a
	ld (wBalladeMarineFollow),a
	call interactionIncState
	; elle chantera dans quelques secondes
	ld h,d
	ld l,Interaction.var34
	ld (hl),$01
	ld bc,TX_5b25
	jp showText

@follow:
	ld a,(wBalladeMarineFollow)
	or a
	jp z,@home
	ld a,(wTextIsActive)
	or a
	ret nz
	call @bombCheck
	ret c
	call @idle
	call @walk
	jp @sword

; La bombe (Select : Marine l'emporte, INTERAC_MARINE $06) : humaine, elle ne peut pas venir de la
; tunique (Denis : « faut désincarner Marine vite fait ») : un nuage, la mouette s'envole de là où
; elle est, et la remporte ; la mouette rentrée, Marine réapparaît (un nuage) derrière Link.
; var3d : 1 pendant que la mouette vole. cflag : c tant qu'elle est cachée
@bombCheck:
	ld h,FIRST_INTERACTION_INDEX
-
	ld l,Interaction.enabled
	ld a,(hl)
	or a
	jr z,+
	inc l
	ld a,(hl)
	cp INTERAC_MARINE
	jr nz,+
	inc l
	ld a,(hl)
	cp $06
	jr z,@carrier
+
	inc h
	ld a,h
	cp LAST_INTERACTION_INDEX+1
	jr c,-
	ld e,Interaction.var3d
	ld a,(de)
	or a
	ret z
	xor a
	ld (de),a
	call followPlace
	call objectSetVisiblec2
	call @puffHere
	or a
	ret
@carrier:
	ld e,Interaction.var3d
	ld a,(de)
	or a
	jr nz,++
	inc a
	ld (de),a
	; la mouette part de Marine, pas de la tunique de Link
	ld l,Interaction.yh
	ld e,l
	ld a,(de)
	ld (hl),a
	ld l,Interaction.xh
	ld e,l
	ld a,(de)
	ld (hl),a
	call stopSinging
	call @puffHere
	call objectSetInvisible
++
	scf
	ret

@puffHere:
	ld e,Interaction.yh
	ld a,(de)
	ld h,a
	ld e,Interaction.xh
	ld a,(de)
	ld l,a
	jp createFinPuffAt

; Quand Link ne fait rien (10 secondes sans bouger ni toucher un bouton), elle chante ; dès qu'il
; bouge, elle s'arrête. var38-var39 : où était Link ; var3a-var3b : depuis combien de temps
@idle:
	call singNotes
	ld a,(wGameKeysPressed)
	or a
	jr nz,@busy
	ld h,d
	ld l,Interaction.var38
	ld a,(w1Link.yh)
	cp (hl)
	jr nz,@busy
	inc l
	ld a,(w1Link.xh)
	cp (hl)
	jr nz,@busy
	ld l,Interaction.var3a
	inc (hl)
	jr nz,+
	inc l
	inc (hl)
+
	ld l,Interaction.var3b
	ld a,(hl)
	cp >600
	ret c
	dec l
	ld a,(hl)
	cp <600
	ret c
	jp startSinging
@busy:
	ld h,d
	ld l,Interaction.var38
	ld a,(w1Link.yh)
	ldi (hl),a
	ld a,(w1Link.xh)
	ldi (hl),a
	xor a
	ldi (hl),a
	ld (hl),a
	jp stopSinging

; Chez elle : elle reste là, et chante de temps en temps
@atHome:
	ld a,(wTextIsActive)
	or a
	ret nz
	jp islandSinging

@home:
	call stopSinging
	; elle rentre chez elle (un nuage)
	ld h,d
	ld l,Interaction.yh
	ld a,(hl)
	ld l,Interaction.xh
	ld l,(hl)
	ld h,a
	call createFinPuffAt
	jp interactionDelete

; Elle marche derrière Link, comme dans DX (Denis : « elle passe sur l'eau, elle nous suit pas ») :
; elle vise la case dans le dos de Link, un pixel par image sur chaque axe, sans marcher sur l'eau,
; un trou ou un mur ; coincée loin de lui 1,5 s : un nuage, elle réapparaît derrière lui.
; var3c : depuis combien de temps elle est coincée
@walk:
	ld a,(w1Link.direction)
	and $03
	add a
	ld hl,@behind
	rst_addAToHl
	ld a,(w1Link.yh)
	add (hl)
	ld b,a
	inc hl
	ld a,(w1Link.xh)
	add (hl)
	ld c,a
	; b, c = l'écart jusqu'à sa place
	ld h,d
	ld l,Interaction.yh
	ld a,b
	sub (hl)
	ld b,a
	ld l,Interaction.xh
	ld a,c
	sub (hl)
	ld c,a
	ld a,b
	call finAbs
	ld e,a
	ld a,c
	call finAbs
	add e
	cp 4
	ret c
	push bc
	ld e,$00		; les axes où elle a pu avancer
	; en y
	ld a,b
	or a
	jr z,+
	ld b,$01
	bit 7,a
	jr z,++
	ld b,$ff
++
	ld l,Interaction.yh
	ld a,(hl)
	add b
	add $04			; (ses pieds)
	ld b,a
	ld l,Interaction.xh
	ld c,(hl)
	call @walkable
	jr c,+
	ld h,d
	ld l,Interaction.yh
	ld a,b
	sub $04
	ld (hl),a
	inc e
+
	pop bc
	push bc
	; en x
	ld a,c
	or a
	jr z,+
	ld c,$01
	bit 7,a
	jr z,++
	ld c,$ff
++
	ld h,d
	ld l,Interaction.xh
	ld a,(hl)
	add c
	ld c,a
	ld l,Interaction.yh
	ld a,(hl)
	add $04
	ld b,a
	call @walkable
	jr c,+
	ld h,d
	ld l,Interaction.xh
	ld (hl),c
	inc e
+
	pop bc
	; coincée, et loin de Link : elle le rejoint d'un coup (un nuage)
	ld h,d
	ld l,Interaction.var3c
	ld a,e
	or a
	jr z,+
	ld (hl),$00
	jr @draw
+
	push bc
	ld c,40
	push hl
	call objectCheckLinkWithinDistance
	pop hl
	pop bc
	jr c,@draw
	inc (hl)
	ld a,(hl)
	cp 90
	jr c,@draw
	ld (hl),$00
	call @puffHere
	call followPlace
	call @puffHere
	ret

; @param	bc	La position à essayer (ses pieds)
; @param[out]	cflag	c si elle ne peut pas y aller (un mur, un trou, de l'eau)
@walkable:
	push bc
	push de
	call checkTileCollisionAt_disallowHoles
	pop de
	pop bc
	ret c
	push bc
	push de
	call checkTileAtPositionIsWater
	pop de
	pop bc
	ret

@behind:
	.db $10 $00, $00 $f0, $f0 $00, $00 $10	; Link regarde en haut, à droite, en bas, à gauche

@draw:
	ld h,d
	; son dessin : face, dos, profil (le plus grand des deux écarts)
	ld a,b
	call finAbs
	ld e,a
	ld a,c
	call finAbs
	cp e
	jr nc,@sideways
	bit 7,b
	ld a,$00		; vers le bas : de face
	jr z,@setDir
	ld a,$01		; vers le haut : de dos
	jr @setDir
@sideways:
	bit 7,c
	ld a,$03		; vers la droite
	jr z,@setDir
	ld a,$02		; vers la gauche
@setDir:
	ld l,Interaction.var31
	ld (hl),a
	; un pas toutes les 8 images, comme dans DX : de face et de dos, l'image retournée ; de profil,
	; l'image du pas (vers la droite : retournée)
	ld c,a
	ld a,(wFrameCounter)
	and $08
	rrca
	rrca
	rrca
	ld b,a			; b = le pas (0 ou 1)
	ld a,c
	cp $02
	jp c,humanShow		; a = 0 de face, 1 de dos ; b : retournée au pas
	sub $02
	ld c,a			; c = 1 vers la droite
	ld a,b
	add $02
	ld b,c
	jp humanShow

; Elle frappe toute seule un ennemi tout près (Denis : « elle ne tape que quand on tape, c'est
; débile ») : elle se tourne vers lui ; et aussi quand l'épée de Link sort, devant elle
@sword:
	ld h,d
	ld l,Interaction.var30
	ld a,(hl)
	or a
	jr z,+
	dec (hl)
	ret
+
	call @nearEnemy
	jr c,+
	ld a,(w1WeaponItem.enabled)
	or a
	ret z
+
	ld h,d
	ld l,Interaction.var30
	ld (hl),30
	ld l,Interaction.var31
	ld a,(hl)
	add a
	ld hl,@swordOffsets
	rst_addAToHl
	ld b,(hl)
	inc hl
	ld c,(hl)
	ld h,d
	ld l,Interaction.yh
	ld a,(hl)
	add b
	ld b,a
	ld l,Interaction.xh
	ld a,(hl)
	add c
	ld c,a
	ld l,Interaction.var31
	ld a,(hl)
	push af
	ld h,b
	ld l,c
	ld b,$1b
	call createFinObjectAt
	pop bc			; b = sa direction
	ret nz
	ld l,Interaction.var30	; (le coup d'épée : sa direction)
	ld (hl),b
	ld a,SND_SWORDSLASH
	jp playSound

@swordOffsets:
	.db $0e $00, $f2 $00, $00 $f2, $00 $0e	; bas, haut, gauche, droite

; Un ennemi à moins de 28 pixels (sur chaque axe) : elle se tourne vers lui (var31)
; @param[out]	cflag	c s'il y en a un
@nearEnemy:
	ld h,FIRST_ENEMY_INDEX
-
	ld l,Enemy.enabled
	ld a,(hl)
	or a
	jr z,@nextEnemy
	ld l,Enemy.health
	ld a,(hl)
	or a
	jr z,@nextEnemy
	ld l,Enemy.yh
	ld b,(hl)
	ld e,Interaction.yh
	ld a,(de)
	sub b
	cpl
	inc a
	ld b,a			; b = y de l'ennemi - le sien
	ld l,Enemy.xh
	ld c,(hl)
	ld e,Interaction.xh
	ld a,(de)
	sub c
	cpl
	inc a
	ld c,a			; c = x de l'ennemi - le sien
	ld a,b
	call finAbs
	cp 28
	jr nc,@nextEnemy
	ld e,a
	ld a,c
	call finAbs
	cp 28
	jr nc,@nextEnemy
	cp e
	jr nc,@enemySide
	bit 7,b
	ld a,$00		; en bas
	jr z,@enemyDir
	inc a			; en haut
	jr @enemyDir
@enemySide:
	bit 7,c
	ld a,$03		; à droite
	jr z,@enemyDir
	dec a			; à gauche
@enemyDir:
	ld e,Interaction.var31
	ld (de),a
	scf
	ret
@nextEnemy:
	inc h
	ld a,h
	cp LAST_ENEMY_INDEX+1
	jr c,-
	or a
	ret

;;
; Le coup d'épée de Marine ($1b) : un instant ; chaque ennemi qu'il touche perd 2 points de vie (une
; fois par coup : var31-var32, un bit par emplacement) ; les gros ennemis et les boss tiennent
marineSword:
	ld e,Interaction.state
	ld a,(de)
	or a
	jr nz,@run
	inc a
	ld (de),a
	call interactionInitGraphics
	call objectSetVisible81
	; sa direction (var30) : bas, haut (l'épée verticale, retournée en bas), gauche, droite
	; (horizontale)
	ld e,Interaction.var30
	ld a,(de)
	ld b,a
	ld h,d
	ld l,Interaction.oamTileIndexBase
	cp $02
	jr c,+
	ld a,(hl)
	add $04
	ld (hl),a
+
	ld l,Interaction.oamFlags
	ld a,b
	or a
	jr nz,+
	set 6,(hl)		; vers le bas : retournée
+
	cp $02
	jr nz,+
	; vers la gauche : retournée, ses deux moitiés échangées (l'animation 5 ; le miroir seul
	; (oamFlags bit 5) retournait chaque moitié sur place : l'épée à l'envers que Denis voyait)
	ld a,$05
	call interactionSetAnimation
+
	ld h,d
	ld l,Interaction.counter1
	ld (hl),12
	ret

@run:
	; les ennemis tout près tombent
	ld h,FIRST_ENEMY_INDEX
-
	ld l,Enemy.enabled
	ld a,(hl)
	or a
	jr z,+
	ld l,Enemy.yh
	ld a,(hl)
	ld e,Interaction.yh
	ld b,a
	ld a,(de)
	sub b
	call finAbs
	cp $0e
	jr nc,+
	ld l,Enemy.xh
	ld a,(hl)
	ld e,Interaction.xh
	ld b,a
	ld a,(de)
	sub b
	call finAbs
	cp $0e
	jr nc,+
	; déjà touché par ce coup ?
	push hl
	ld a,h
	sub FIRST_ENEMY_INDEX
	ld b,a
	srl a
	srl a
	srl a
	add Interaction.var31
	ld e,a
	ld a,b
	and $07
	ld c,$01
	jr z,++
--
	sla c
	dec a
	jr nz,--
++
	ld a,(de)
	and c
	pop hl
	jr nz,+
	ld a,(de)
	or c
	ld (de),a
	ld l,Enemy.health
	ld a,(hl)
	sub $02
	jr nc,++
	xor a
++
	ld (hl),a
	ld a,SND_BOSS_DAMAGE
	call playSound
+
	inc h
	ld a,h
	cp LAST_ENEMY_INDEX+1
	jp c,-
	call interactionDecCounter1
	ret nz
	jp interactionDelete


;;
; Marine arrive avec Link dans la salle (appelé au chargement des objets de chaque salle, quand elle
; le suit : code/objectLoading.s), juste derrière lui
followRoomLoad:
	ld a,(w1Link.yh)
	ld h,a
	ld a,(w1Link.xh)
	ld l,a
	ld b,$19
	jp createFinObjectAt

;;
; Marine se place derrière Link (à sa première image dans la salle : au chargement de la salle, Link
; n'est pas encore à sa place)
followPlace:
	ld a,(w1Link.direction)
	and $03
	add a
	ld hl,@behind
	rst_addAToHl
	ld a,(w1Link.yh)
	add (hl)
	ld b,a
	inc hl
	ld a,(w1Link.xh)
	add (hl)
	ld c,a
	; derrière lui, c'est hors de l'écran (en entrant par le bord) : sur lui
	ld a,(wRoomEdgeY)
	dec a
	cp b
	jr c,+
	ld a,(wRoomEdgeX)
	dec a
	cp c
	jr nc,++
+
	ld a,(w1Link.yh)
	ld b,a
	ld a,(w1Link.xh)
	ld c,a
++
	ld h,d
	ld l,Interaction.yh
	ld (hl),b
	ld l,Interaction.xh
	ld (hl),c
	ret

@behind:
	.db $10 $00, $00 $f0, $f0 $00, $00 $10	; Link regarde en haut, à droite, en bas, à gauche

;;
; Après la fin, en revenant dans un donjon (son nom s'affiche : INTERAC_DUNGEON_STUFF $00) : il est
; comme neuf. Ses portes à clé, ses énigmes, ses boss et ses coffres reviennent (les drapeaux de
; ses salles, sauf « visitée » ; dans la salle du boss, on garde le réceptacle déjà pris), ses
; petites clés et sa clé du boss repartent à zéro. (La Fosse de Bulle, $09, n'en fait pas partie.)
resetDungeon:
	; (Denis) La boussole et la carte : d'office, dans chaque donjon (leurs coffres donnent des
	; rubis : postGameChest)
	ld a,(wDungeonIndex)
	cp $10
	jr nc,+
	push af
	ld hl,wDungeonCompasses
	call setFlag
	pop af
	ld hl,wDungeonMaps
	call setFlag
+
	ld a,GLOBALFLAG_BALLADE_FIN
	call checkGlobalFlag
	ret z
	ld a,(wDungeonIndex)
	cp $09
	ret z
	cp $0f
	ret nc
	push de
	; les petites clés, la clé du boss
	ld hl,wDungeonSmallKeys
	rst_addAToHl
	ld (hl),$00
	ld a,(wDungeonIndex)
	ld hl,wDungeonBossKeys
	call unsetFlag
	; les salles du donjon (w2DungeonLayout, banque 2 de la WRAM)
	ld c,$00
@nextRoom:
	ld a,($ff00+R_SVBK)
	push af
	ld a,:w2DungeonLayout
	ld ($ff00+R_SVBK),a
	ld b,>w2DungeonLayout
	ld a,(bc)
	ld b,a
	pop af
	ld ($ff00+R_SVBK),a
	ld a,b
	or a
	jr z,@skip
	; la salle du boss garde son réceptacle (le drapeau $20)
	push bc
	call getRoomDungeonProperties
	ld a,b
	pop bc
	and DUNGEONROOMPROPERTY_BOSS
	ld e,$10		; on garde : visitée
	jr z,+
	ld e,$30		; (la salle du boss : visitée, le réceptacle pris)
+
	ld a,(wDungeonFlagsAddressH)
	ld h,a
	ld l,b
	ld a,(hl)
	and e
	ld (hl),a
@skip:
	inc c
	jr nz,@nextRoom
	pop de
	ret

;;
; Un coffre de boussole ou de carte (on les a d'office) donne 10 rubis (Denis : moins d'argent) ; après la fin, un coffre
; qui donne un objet déjà eu (pas une clé, des rubis ni un quart de cœur) aussi
; @param	bc	Le contenu du coffre (le trésor, son sous-type) ; modifié
postGameChest:
	ld a,b
	or a
	ret z
	cp TREASURE_RUPEES
	ret z
	cp TREASURE_HEART_PIECE
	ret z
	cp TREASURE_SMALL_KEY
	ret z
	cp TREASURE_BOSS_KEY
	ret z
	; la boussole et la carte : on les a déjà (resetDungeon), toujours des rubis à la place
	cp TREASURE_COMPASS
	jr z,@rupees
	cp TREASURE_MAP
	jr z,@rupees
	push bc
	ld a,GLOBALFLAG_BALLADE_FIN
	call checkGlobalFlag
	pop bc
	ret z
	ld a,b
	push bc
	call checkTreasureObtained
	pop bc
	ret nc
@rupees:
	ld bc,TREASURE_OBJECT_RUPEES_02
	ret


;;
; Marine chante la Ballade du Poisson-Rêve (MUS_TITLESCREEN : la Ballade chantée par Marine) ; des
; notes s'envolent. var35 la musique d'avant, var36 elle chante, var37 le temps avant la note
startSinging:
	ld e,Interaction.var36
	ld a,(de)
	or a
	ret nz
	inc a
	ld (de),a
	ld a,(wActiveMusic)
	ld e,Interaction.var35
	ld (de),a
	; (la musique en cours : en changeant d'écran, le jeu remet celle de l'écran)
	ld a,MUS_TITLESCREEN
	ld (wActiveMusic),a
	jp playSound

stopSinging:
	ld e,Interaction.var36
	ld a,(de)
	or a
	ret z
	xor a
	ld (de),a
	; de nouveau de face
	ld b,a
	call humanShow
	ld e,Interaction.var35
	ld a,(de)
	ld (wActiveMusic),a
	jp playSound

; Pendant qu'elle chante : elle se balance (singPose) ; une note qui s'envole, de temps en temps
singNotes:
	ld e,Interaction.var36
	ld a,(de)
	or a
	ret z
	call singPose
	ld h,d
	ld l,Interaction.var37
	ld a,(hl)
	or a
	jr z,+
	dec (hl)
	ret
+
	ld (hl),40
	call getRandomNumber
	and $01
	ld bc,$f800
	jp objectCreateFloatingMusicNote

;;
; Pendant qu'elle chante, elle se balance comme dans DX (MarinCreditsSpriteVariants 8, 8, 8, 9, 10,
; 10, 10, 9 : penchée, droite, penchée de l'autre côté, droite ; 16 images chacune)
singPose:
	ld a,(wFrameCounter)
	swap a
	and $07
	ld hl,@sway
	rst_addAToHl
	ld a,(hl)
	ld b,$00
	cp $06
	jr c,+
	ld a,$04		; (6 : la 4 retournée)
	inc b
+
	jp humanShow

@sway:
	.db $04 $04 $04 $05 $06 $06 $06 $05

;;
; Marine humaine (spr_marine_human, tools/make_marine_dx.py : ses poses de Link's Awakening DX) :
; montre l'image a (0 de face, 1 de dos, 2-3 de profil vers la gauche, 4-5 elle chante), retournée
; si b = 1 (l'animation 5 d'INTERAC_BALLADE_CREUSE). En relatif : le jeu recale oamTileIndexBase
; selon la place des images en mémoire vidéo. var3e l'image montrée (4 x l'image), var3f retournée
humanShow:
	add a
	add a
	ld h,d
	ld l,Interaction.var3e
	ld c,(hl)
	ld (hl),a
	sub c
	ld l,Interaction.oamTileIndexBase
	add (hl)
	ld (hl),a
	ld l,Interaction.var3f
	ld a,(hl)
	cp b
	ret z
	ld (hl),b
	ld a,b
	or a
	jr z,+
	ld a,$05
+
	jp interactionSetAnimation

;;
; Marine sur son île : de temps en temps, elle chante (var33-var34 : le temps qui reste avant de
; chanter, ou de s'arrêter)
islandSinging:
	call singNotes
	ld h,d
	ld l,Interaction.var33
	ld a,(hl)
	inc l
	or (hl)
	jr nz,@wait
	; le moment de chanter, ou de s'arrêter
	ld e,Interaction.var36
	ld a,(de)
	or a
	jr nz,@stop
	call startSinging
	ld h,d
	ld l,Interaction.var33
	ld (hl),<600
	inc l
	ld (hl),>600
	ret
@stop:
	call stopSinging
	; la prochaine fois : dans 20 à 40 secondes
	call getRandomNumber
	and $07
	add $05
	ld h,d
	ld l,Interaction.var34
	ld (hl),a
	dec l
	ld (hl),$00
	ret
@wait:
	ld l,Interaction.var33
	ld a,(hl)
	sub $01
	ldi (hl),a
	ld a,(hl)
	sbc $00
	ld (hl),a
	ret
