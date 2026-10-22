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

; L'Insomnis battu (wBalladeRhythmStage = 3), un moment
@waitBoss:
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

@init:
	ld a,GLOBALFLAG_BALLADE_FIN
	call checkGlobalFlag
	jp z,interactionDelete
	call npcLikeInit
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
	ld e,Interaction.pressedAButton
	ld a,(de)
	or a
	ret z
	xor a
	ld (de),a
	call interactionIncState
	ld bc,TX_5b10
	jp showText

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
	jr nz,@back
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
