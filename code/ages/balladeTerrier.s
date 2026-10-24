; ==================================================================================================
; BALLADE: le Terrier des Serpents (donjon facultatif, index $0b, salles 4:d0-d7 ; idée de Denis : le
; gantelet des âmes d'Onimusha, le nom en clin d'œil à Snake). Voir story/salles/terrier.txt.
;
; - Le Gantelet des âmes ($0d), sur son socle (4:d1) : A devant, Link le prend (bit 0 de
;   wBalladeSoulState). Ensuite, chaque ennemi battu laisse une âme ($0b) qui vole jusqu'à Link :
;   le gantelet l'absorbe (wBalladeSouls). Une jarre ($0e), dans le coin de l'écran, se remplit.
; - Le contrôleur de chaque salle ($0a) : les âmes des ennemis qui meurent ; les ennemis qui
;   reviennent toujours (@config) ; les portes des âmes (le volet du haut, $07) qui s'ouvrent à 4, 8
;   et 12 âmes ; dans l'arène (4:d7), à 16 âmes, le boss (Denis : « tu demandes 16 âmes et j'en fais
;   à peine 8 » : c'était 6, 12, 18 et 24). Les serpents (ENEMY_ROPE) sont gris (la palette 6) et
;   tiennent quatre coups d'épée.
; - Le boss ($0c) : une machine de guerre à deux pattes (clin d'œil à Metal Gear REX), possédée
;   par un fantôme (art/rex.txt : il marche, deux images de pattes). Chaque coup d'épée lui arrache
;   une âme ; à moitié, son blindage tombe, il va plus vite et s'efface (il clignote) ; à zéro, le
;   fantôme ($0f) s'en échappe, très vite ; trois coups, et le gantelet absorbe son âme : il devient
;   une relique, le Bracelet des Âmes (bit 1) : l'épée lance toujours un rayon, et chaque ennemi
;   touché rend un peu de vie à Link (object_code/common/itemParents/swordParent.s,
;   items/swordBeam.s). Puis Link revient à l'entrée du Terrier (Denis : pas tout le chemin à
;   l'envers).
; ==================================================================================================

.define TERRIER_BOSS_SOULS	16	; les âmes qu'il faut pour que le boss apparaisse
.define TERRIER_BOSS_HP		12
.define TERRIER_GHOST_HP	3
.define TERRIER_RESPAWN		100	; un ennemi revient toutes les 100 images (s'il en manque)
.define TERRIER_SNAKE_HP	8	; un serpent : quatre coups d'épée (l'épée L-1 enlève 2)

;;
; Le contrôleur d'une salle du Terrier (d = le contrôleur). var31 l'ennemi qui revient, var32
; combien au plus, var33 la porte des âmes (0 : pas de porte), var34-var35 les ennemis déjà
; comptés (un bit par emplacement), var36 le texte de la porte est dit, var37 le boss est là
controller:
	ld e,Interaction.state
	ld a,(de)
	or a
	jp nz,@run

	inc a
	ld (de),a
	ld a,PALH_TERRIER
	call loadPaletteHeader
	; La configuration de la salle
	ld a,(wActiveRoom)
	ld b,a
	ld hl,@config
-
	ldi a,(hl)
	cp $ff
	jr z,@configDone
	cp b
	jr z,+
	inc hl
	inc hl
	inc hl
	jr -
+
	ld e,Interaction.var31
	ldi a,(hl)
	ld (de),a
	inc e
	ldi a,(hl)
	ld (de),a
	inc e
	ld a,(hl)
	ld (de),a
@configDone:
	ld e,Interaction.counter1
	ld a,TERRIER_RESPAWN
	ld (de),a
	; La jarre des âmes, si Link a le gantelet
	ld a,(wBalladeSoulState)
	rrca
	jr nc,+
	ld b,$0e
	call createTerrierObject
+
	; L'arène, une fois le boss battu : plus d'ennemis
	ld a,(wActiveRoom)
	cp $d7
	jr nz,+
	ld a,(wBalladeSoulState)
	bit 1,a
	jr z,+
	ld e,Interaction.var31
	xor a
	ld (de),a
+
	ret

@texts:
	; (les serpents gris dès qu'ils sont là, même pendant que l'écran défile)
	call @snakes
	; Les textes en arrivant (la salle prête) : l'entrée (une fois), l'arène (une fois)
	ld a,(wPaletteThread_mode)
	or a
	ret nz
	ld a,(wScrollMode)
	cpl
	and $01
	ret nz
	ld e,Interaction.state
	ld a,$02
	ld (de),a
	ld a,(wActiveRoom)
	cp $d0
	ld b,$04
	ld hl,TX_5a18
	jr z,@onceText
	cp $d7
	ld b,$08
	ld hl,TX_5a1b
	ret nz
	ld a,(wBalladeSoulState)
	bit 1,a
	ret nz
@onceText:
	ld a,(wBalladeSoulState)
	and b
	ret nz
	ld a,(wBalladeSoulState)
	or b
	ld (wBalladeSoulState),a
	ld b,h
	ld c,l
	jp showText

@run:
	cp $01
	jr z,@texts
	ld a,(wTextIsActive)
	or a
	ret nz
	call @snakes
	call @absorb
	call @respawn
	call @gate
	ld a,(wActiveRoom)
	cp $d7
	ret nz
	jp @arena

;;
; Les serpents du Terrier : gris (la palette 6, PALH_TERRIER) et solides (TERRIER_SNAKE_HP), une
; fois qu'ils sont initialisés (Enemy.state non nul ; la palette 6 dit qu'ils sont déjà réglés)
@snakes:
	ld h,FIRST_ENEMY_INDEX
-
	ld l,Enemy.enabled
	ld a,(hl)
	or a
	jr z,+
	inc l
	ld a,(hl)
	cp ENEMY_ROPE
	jr nz,+
	ld l,Enemy.state
	ld a,(hl)
	or a
	jr z,+
	ld l,Enemy.oamFlagsBackup
	ld a,(hl)
	and $07
	cp $06
	jr z,+
	ld a,(hl)
	and $f8
	or $06
	ldi (hl),a		; oamFlagsBackup, puis oamFlags
	ld (hl),a
	ld l,Enemy.health
	ld (hl),TERRIER_SNAKE_HP
+
	inc h
	ld a,h
	cp LAST_ENEMY_INDEX+1
	jr c,-
	ret

;;
; Les âmes : chaque ennemi qui meurt laisse une âme, si Link a le gantelet. (Un ennemi battu
; disparaît aussitôt : on guette le nuage qu'il laisse, PART_ENEMY_DESTROYED, une âme par nuage.)
@absorb:
	ld a,(wBalladeSoulState)
	rrca
	ret nc
	ld b,$00		; b = l'emplacement (0-15)
@nextSlot:
	ld a,b
	add FIRST_PART_INDEX
	ld h,a
	ld l,Part.enabled
	ld a,(hl)
	or a
	jr z,@clear
	inc l
	ld a,(hl)
	cp PART_ENEMY_DESTROYED
	jr nz,@clear
	; déjà compté ?
	call @markAddress
	and (hl)
	jr nz,@next
	ld a,c
	or (hl)
	ld (hl),a
	; une âme, là où il est tombé
	ld a,b
	add FIRST_PART_INDEX
	ld h,a
	ld l,Part.yh
	ld a,(hl)
	ld l,Part.xh
	ld l,(hl)
	ld h,a
	push bc
	ld b,$0b
	call createTerrierObjectAt
	pop bc
	jr @next
@clear:
	call @markAddress
	cpl
	and (hl)
	ld (hl),a
@next:
	inc b
	ld a,b
	cp $10
	jr c,@nextSlot
	ret

;;
; @param	b	L'emplacement
; @param[out]	hl	Son octet dans var34-var35
; @param[out]	a,c	Son bit
@markAddress:
	ld a,b
	srl a
	srl a
	srl a
	add Interaction.var34
	ld l,a
	ld h,d
	ld a,b
	and $07
	ld c,$01
	jr z,++
-
	sla c
	dec a
	jr nz,-
++
	ld a,c
	ret

;;
; Les ennemis qui reviennent toujours (s'il en manque)
@respawn:
	ld e,Interaction.var31
	ld a,(de)
	or a
	ret z
	ld c,a			; c = l'ennemi
	; combien en vie ?
	ld b,$00
	ld h,FIRST_ENEMY_INDEX
-
	ld l,Enemy.enabled
	ld a,(hl)
	or a
	jr z,+
	inc l
	ld a,(hl)
	cp c
	jr nz,+
	ld l,Enemy.health
	ld a,(hl)
	or a
	jr z,+
	inc b
+
	inc h
	ld a,h
	cp LAST_ENEMY_INDEX+1
	jr c,-
	ld e,Interaction.var32
	ld a,(de)
	cp b
	ret z
	ret c
	; un de moins : il revient dans un moment
	call interactionDecCounter1
	ret nz
	ld (hl),TERRIER_RESPAWN
	; dans un coin, loin de Link
	call getRandomNumber
	and $03
	ld b,a
	ld a,(w1Link.yh)
	cp $58
	ld a,b
	jr c,+
	and $01			; Link en bas : un coin du haut
	jr ++
+
	or $02			; Link en haut : un coin du bas
++
	add a
	ld hl,@corners
	rst_addAToHl
	ldi a,(hl)
	ld b,a
	ld a,(hl)
	ld c,a
	push bc
	call getFreeEnemySlot
	pop bc
	ret nz
	ld e,Interaction.var31
	ld a,(de)
	ldi (hl),a		; l'ennemi
	ld (hl),$00		; sous-type
	ld l,Enemy.yh
	ld (hl),b
	ld l,Enemy.xh
	ld (hl),c
	; un nuage là où il apparaît
	ld h,b
	ld l,c
	ld b,$10		; (sous-type inutilisé : seulement le nuage)
	jp createTerrierPuffAt

@corners:
	.db $28 $28, $28 $c8, $88 $28, $88 $c8	; haut gauche, haut droite, bas gauche, bas droite

;;
; La porte des âmes (le volet du haut, $07) : elle s'ouvre quand le gantelet a assez d'âmes ; sinon,
; en entrant, la porte dit combien il en faut
@gate:
	ld e,Interaction.var33
	ld a,(de)
	or a
	ret z
	ld b,a
	ld a,(wRoomLayout+$07)
	cp $78
	ret nz
	ld a,(wBalladeSouls)
	cp b
	jr c,@notEnough
	ld c,$07
	ld a,$a0
	call setTile
	ld a,SND_SOLVEPUZZLE
	jp playSound
@notEnough:
	ld e,Interaction.var36
	ld a,(de)
	or a
	ret nz
	inc a
	ld (de),a
	; (combien il en manque encore, en BCD, pour \num1)
	ld a,(wBalladeSouls)
	cpl
	inc a
	add b
	call hexToDec
	ld (wTextNumberSubstitution),a
	xor a
	ld (wTextNumberSubstitution+1),a
	ld bc,TX_5a1a
	jp showText

;;
; L'arène : à 24 âmes, les ennemis s'en vont et le boss apparaît
@arena:
	ld e,Interaction.var37
	ld a,(de)
	or a
	ret nz
	ld a,(wBalladeSoulState)
	bit 1,a
	ret nz
	ld a,(wBalladeSouls)
	cp TERRIER_BOSS_SOULS
	ret c
	ld a,$01
	ld (de),a
	ld e,Interaction.var31
	xor a
	ld (de),a
	; les ennemis : en fumée
	ld h,FIRST_ENEMY_INDEX
-
	ld l,Enemy.enabled
	ld a,(hl)
	or a
	jr z,+
	push hl
	ld l,Enemy.yh
	ld a,(hl)
	ld l,Enemy.xh
	ld l,(hl)
	ld h,a
	call createTerrierPuffAt
	pop hl
	ld l,Enemy.enabled
	ld (hl),$00
+
	inc h
	ld a,h
	cp LAST_ENEMY_INDEX+1
	jr c,-
	; le boss, au milieu en haut
	ld hl,$4078
	ld b,$0c
	call createTerrierObjectAt
	ld a,SND_STRONG_POUND
	call playSound
	ld a,$20
	call setScreenShakeCounter
	ld bc,TX_5a1c
	jp showText

; salle, l'ennemi qui revient, combien au plus, la porte des âmes (0 : pas de porte)
@config:
	.db $d2, ENEMY_ROPE, 3, 4
	.db $d4, ENEMY_GHINI, 2, 8
	.db $d6, ENEMY_KEESE, 3, 12
	.db $d7, ENEMY_ROPE, 3, 0
	.db $ff


;;
; Crée un objet du Terrier à la position du contrôleur... (b = son sous-type)
createTerrierObject:
	ld hl,$0808
;;
; Crée un objet du Terrier (b = son sous-type) à la position h (y), l (x)
createTerrierObjectAt:
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
; Un nuage de fumée à la position h (y), l (x)
createTerrierPuffAt:
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


;;
; a (0-99) -> a en BCD
hexToDec:
	ld b,$00
-
	cp 10
	jr c,+
	sub 10
	inc b
	jr -
+
	ld c,a
	ld a,b
	swap a
	or c
	ret


;;
; La première image d'un objet du Terrier : son dessin, visible
terrierObjectInit:
	ld e,Interaction.state
	ld a,(de)
	or a
	ret nz
	inc a
	ld (de),a
	call interactionInitGraphics
	jp objectSetVisible82

;;
; a -> |a| (signé)
terrierAbs:
	bit 7,a
	ret z
	cpl
	inc a
	ret


;;
; Une âme ($0b) : elle vole jusqu'à Link (2 pixels par image), et le gantelet l'absorbe
soul:
	call terrierObjectInit
	ld a,(wTextIsActive)
	or a
	ret nz
	ld h,d
	ld l,Interaction.yh
	ld a,(w1Link.yh)
	call @step
	ld l,Interaction.xh
	ld a,(w1Link.xh)
	call @step
	ld l,Interaction.yh
	ld a,(w1Link.yh)
	sub (hl)
	call terrierAbs
	cp $06
	ret nc
	ld l,Interaction.xh
	ld a,(w1Link.xh)
	sub (hl)
	call terrierAbs
	cp $06
	ret nc
	ld hl,wBalladeSouls
	ld a,(hl)
	cp 99
	jr nc,+
	inc (hl)
+
	ld a,SND_GETSEED
	call playSound
	jp interactionDelete

; (hl) va vers a : deux pixels (un seul s'il est à un pixel)
@step:
	sub (hl)
	ret z
	jr c,@minus
	cp $01
	jr z,+
	inc (hl)
+
	inc (hl)
	ret
@minus:
	cp $ff
	jr z,+
	dec (hl)
+
	dec (hl)
	ret


;;
; Le Gantelet des âmes ($0d) sur son socle : A devant, Link le prend
gauntlet:
	ld e,Interaction.state
	ld a,(de)
	or a
	jr nz,@waitA
	ld a,(wBalladeSoulState)
	rrca
	jp c,interactionDelete
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
@waitA:
	ld e,Interaction.pressedAButton
	ld a,(de)
	or a
	ret z
	xor a
	ld (de),a
	ld hl,wBalladeSoulState
	set 0,(hl)
	call objectUnmarkSolidPosition
	ld e,Interaction.start
	call objectRemoveFromAButtonSensitiveObjectList
	ld a,SND_GETITEM
	call playSound
	ld b,$0e
	call createTerrierObject
	ld bc,TX_5a19
	call showText
	jp interactionDelete


;;
; La jarre des âmes ($0e) : fixe à l'écran (en haut à droite), elle se remplit ; pleine à chaque
; porte des âmes (4, 8, 12) et pour le boss (16). var30 : le dessin de la jarre vide
jar:
	ld e,Interaction.state
	ld a,(de)
	or a
	jr nz,+
	inc a
	ld (de),a
	call interactionInitGraphics
	call objectSetVisible80
	ld e,Interaction.oamTileIndexBase
	ld a,(de)
	ld e,Interaction.var30
	ld (de),a
+
	ldh a,(<hCameraY)
	add $18
	ld e,Interaction.yh
	ld (de),a
	ldh a,(<hCameraX)
	add $90
	ld e,Interaction.xh
	ld (de),a
	ld a,(wBalladeSouls)
	cp TERRIER_BOSS_SOULS
	ld b,$04
	jr nc,++
	and $03
	ld hl,@fill
	rst_addAToHl
	ld b,(hl)
++
	ld a,b
	add a
	add a
	ld b,a
	ld e,Interaction.var30
	ld a,(de)
	add b
	ld e,Interaction.oamTileIndexBase
	ld (de),a
	ret

@fill:
	.db 0, 1, 2, 3


; ==================================================================================================
; Le boss ($0c) : la machine possédée, en grand, au fond de l'arène (Denis : « regarde comment c'est
; dans Ghost Babel ») : 7 x 5 briques du décor (tools/make_rex.py) qui sortent de l'ombre quand elle
; apparaît. Elle tire des missiles et fait tomber des rochers (les projectiles, $0f). Seule une bombe
; qui explose contre elle l'arrête (Denis) : cinq secondes, ses yeux s'éteignent, des étincelles ;
; une attaque tourbillon contre elle, alors, la touche. Cinq fois, et elle explose ; le gantelet
; absorbe l'âme du fantôme : le Bracelet des Âmes ; puis Link revient à l'entrée du Terrier.
;
; var30 sa vie, var31 la rangée de briques (en apparaissant, en disparaissant), var32 le temps
; qu'elle reste arrêtée (images), var33 l'attaque suivante (0 missiles, 1 rochers), var34 le temps
; qu'elle reste blanche (touchée), counter1 le temps avant l'attaque suivante
; ==================================================================================================

.define REX_HP		5
.define REX_STUN	300	; (cinq secondes)
.define REX_BRICK	$c0	; ses briques ($c0-$e2, tools/make_rex.py), 7 par rangée
.define REX_POS		$14	; la brique en haut à gauche (ligne 1, colonne 4)
.define REX_BOTTOM	$60	; (en pixels : le bas, la gauche, la droite de la machine)
.define REX_LEFT	$40
.define REX_RIGHT	$b0

rex:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw @init
	.dw @rise
	.dw @fight
	.dw @explode
	.dw @vanish
	.dw @relic

@init:
	call interactionIncState
	call interactionInitGraphics	; (les images des projectiles : spr_ballade_rex)
	ld h,d
	ld l,Interaction.var30
	ld (hl),REX_HP
	ld l,Interaction.counter1
	ld (hl),90
	ld a,PALH_REX
	call loadPaletteHeader
	; Link pas dans la machine
	ld a,(w1Link.yh)
	cp REX_BOTTOM+$10
	jr nc,+
	ld a,$88
	ld (w1Link.yh),a
+
	ld a,MUS_MINIBOSS
	jp playSound

; Elle sort de l'ombre : une rangée de briques toutes les 8 images, de bas en haut
@rise:
	ld a,(wFrameCounter)
	and $07
	ret nz
	ld h,d
	ld l,Interaction.var31
	ld a,(hl)
	cp $05
	jp nc,interactionIncState
	inc (hl)
	ld b,a
	ld a,$04
	sub b
	ld e,$01
	call @drawRow
	ld a,SND_STRONG_POUND
	call playSound
	ld a,$08
	jp setScreenShakeCounter

;;
; Une rangée de briques : la machine (e = 1) ou le sol (e = 0)
; @param	a	La rangée (0-4)
@drawRow:
	ld c,a
	swap a
	add REX_POS
	ld b,a			; b = la position de la première brique
	ld a,c
	add a
	add a
	add a
	sub c
	add REX_BRICK
	ld c,a			; c = sa brique
	ld a,$07
--
	push af
	push bc
	push de
	ld a,e
	or a
	ld a,c
	jr nz,+
	ld a,$a0
+
	ld c,b
	call setTile
	pop de
	pop bc
	inc b
	inc c
	pop af
	dec a
	jr nz,--
	ret

@fight:
	ld a,(wTextIsActive)
	or a
	ret nz
	; touchée : elle reste blanche un instant
	ld h,d
	ld l,Interaction.var34
	ld a,(hl)
	or a
	jr z,+
	dec (hl)
	call z,@palette
+
	ld h,d
	ld l,Interaction.var32
	ld a,(hl)
	or a
	jr z,@active
	; arrêtée : des étincelles ; une attaque tourbillon la touche
	ld a,(wFrameCounter)
	rrca
	jr c,+
	dec (hl)
	jp z,@palette
+
	ld a,(wFrameCounter)
	and $0f
	call z,@spark
	jp @checkSpin

@active:
	call @checkBomb
	ret c
	call interactionDecCounter1
	ret nz
	ld (hl),100
	ld l,Interaction.var33
	ld a,(hl)
	xor $01
	ld (hl),a
	jr z,@rocks

	; les missiles : deux, depuis le lance-missiles, vers Link
	ld a,SND_THROW
	call playSound
	ld hl,$2868
	call @missile
	ld hl,$2888
@missile:
	ld b,$0f
	jp createTerrierObjectAt

	; les rochers : elle frappe du pied ; trois rochers tombent, dont un sur Link
@rocks:
	ld a,SND_STRONG_POUND
	call playSound
	ld a,$20
	call setScreenShakeCounter
	ld a,(w1Link.yh)
	ld h,a
	ld a,(w1Link.xh)
	ld l,a
	call @rock
	call @randomFloor
	call @rock
	call @randomFloor
@rock:
	ld b,$0f
	jp createTerrierObjectAt

; hl = une position au hasard, devant la machine
@randomFloor:
	call getRandomNumber
	and $1f
	add REX_BOTTOM+$18
	ld h,a
	call getRandomNumber
	and $7f
	add $30
	ld l,a
	ret

; une étincelle, sur la machine
@spark:
	call getRandomNumber
	and $3f
	add $18
	ld h,a
	call getRandomNumber
	and $5f
	add REX_LEFT+8
	ld l,a
	ld b,$0f
	call createTerrierObjectAt
	ld a,SND_SHOCK
	jp playSound

;;
; Une bombe explose contre elle : elle s'arrête (cf : oui)
@checkBomb:
	ld h,FIRST_ITEM_INDEX
--
	ld l,Item.enabled
	ld a,(hl)
	or a
	jr z,@nextItem
	inc l
	ld a,(hl)
	cp ITEM_BOMB
	jr nz,@nextItem
	ld l,Item.var2f
	bit 4,(hl)
	jr z,@nextItem
	ld l,Item.yh
	ld a,(hl)
	cp REX_BOTTOM+$20
	jr nc,@nextItem
	ld l,Item.xh
	ld a,(hl)
	cp REX_LEFT-$10
	jr c,@nextItem
	cp REX_RIGHT+$10
	jr nc,@nextItem
	; arrêtée (var32 compte toutes les deux images)
	ld h,d
	ld l,Interaction.var32
	ld (hl),REX_STUN/2
	call @palette
	ld a,SND_SHOCK
	call playSound
	scf
	ret
@nextItem:
	inc h
	ld a,h
	cp LAST_ITEM_INDEX+1
	jr c,--
	xor a
	ret

;;
; Une attaque tourbillon contre elle (pendant qu'elle est arrêtée) : touchée
@checkSpin:
	ld a,(w1WeaponItem.enabled)
	or a
	ret z
	ld a,(w1WeaponItem.id)
	cp ITEM_SWORD
	ret nz
	ld a,(w1WeaponItem.state)
	cp $04
	ret nz
	ld a,(w1Link.yh)
	cp REX_BOTTOM+$20
	ret nc
	ld a,(w1Link.xh)
	cp REX_LEFT-$10
	ret c
	cp REX_RIGHT+$10
	ret nc
	; touchée
	ld h,d
	ld l,Interaction.var32
	ld (hl),$00
	ld l,Interaction.var34
	ld (hl),24
	ld l,Interaction.counter1
	ld (hl),60
	ld a,PALH_REX_HIT
	call loadPaletteHeader
	ld a,SND_BOSS_DAMAGE
	call playSound
	ld a,$10
	call setScreenShakeCounter
	ld h,d
	ld l,Interaction.var30
	dec (hl)
	ret nz
	; Cinq fois : elle explose
	ld l,Interaction.state
	ld (hl),$03
	ld l,Interaction.counter1
	ld (hl),80
	ld a,SNDCTRL_STOPMUSIC
	jp playSound

; Ses couleurs : les yeux éteints quand elle est arrêtée
@palette:
	ld e,Interaction.var32
	ld a,(de)
	or a
	ld a,PALH_REX
	jr z,+
	ld a,PALH_REX_STUN
+
	jp loadPaletteHeader

; Elle explose : des explosions partout sur elle
@explode:
	ld a,(wFrameCounter)
	and $07
	jr nz,+
	call getRandomNumber
	and $3f
	add $18
	ld h,a
	call getRandomNumber
	and $5f
	add REX_LEFT+8
	ld l,a
	call createTerrierPuffAt
	ld a,SND_EXPLOSION
	call playSound
	ld a,$08
	call setScreenShakeCounter
+
	call interactionDecCounter1
	ret nz
	ld l,Interaction.var31
	ld (hl),$00
	ld a,SND_BIG_EXPLOSION
	call playSound
	jp interactionIncState

; Elle disparaît : le sol, une rangée toutes les 8 images
@vanish:
	ld a,(wFrameCounter)
	and $07
	ret nz
	ld h,d
	ld l,Interaction.var31
	ld a,(hl)
	cp $05
	jr nc,@done
	inc (hl)
	push af
	ld b,a
	swap b
	; une explosion sur la rangée
	ld a,b
	add $18
	ld h,a
	ld l,$78
	call createTerrierPuffAt
	pop af
	ld e,$00
	jp @drawRow
@done:
	; Le gantelet absorbe l'âme du fantôme : la relique, le Bracelet des Âmes
	ld hl,wBalladeSoulState
	set 1,(hl)
	ld a,SND_SOLVEPUZZLE
	call playSound
	ld bc,TX_5a1d
	call showText
	call interactionIncState
	ld l,Interaction.counter1
	ld (hl),90
	ret

; Les textes finis (et la réplique de Marine, INTERAC_MARINE $08) : Link revient à l'entrée du
; Terrier (Denis : pas tout le chemin à l'envers)
@relic:
	ld a,(wTextIsActive)
	or a
	jr z,+
	ld e,Interaction.counter1
	ld a,90
	ld (de),a
	ret
+
	call interactionDecCounter1
	ret nz
	ld a,$84
	ld (wWarpDestGroup),a
	ld a,$d0
	ld (wWarpDestRoom),a
	ld a,$97
	ld (wWarpDestPos),a
	xor a
	ld (wWarpTransition),a
	ld a,$03 ; fondu
	ld (wWarpTransition2),a
	ld a,SND_TELEPORT
	call playSound
	jp interactionDelete


;;
; Les projectiles de la machine ($0f) : var3e 0 un missile (il file vers là où était Link), 1 un
; rocher (son ombre, puis il tombe), 2 une étincelle. Images (spr_ballade_rex, art/rex.txt) : 0-1 le
; missile, 2 le rocher, 3 son ombre, 4-5 l'étincelle
ghost:
	ld e,Interaction.state
	ld a,(de)
	or a
	jr nz,@run
	inc a
	ld (de),a
	call interactionInitGraphics
	; son type, d'après là où il apparaît (un objet tout neuf est vidé avant sa première image :
	; la machine ne peut pas le lui dire) : un rocher devant la machine, un missile au lance-missiles,
	; sinon une étincelle
	ld e,Interaction.yh
	ld a,(de)
	ld b,$01
	cp REX_BOTTOM+$08
	jr nc,++
	ld b,$02
	cp $28
	jr nz,++
	ld e,Interaction.xh
	ld a,(de)
	cp $68
	jr z,+
	cp $88
	jr nz,++
+
	ld b,$00
++
	ld e,Interaction.var3e
	ld a,b
	ld (de),a
	ld hl,@first
	rst_addAToHl
	ld b,(hl)
	ld a,(de)
	ld hl,@time
	rst_addAToHl
	ld c,(hl)
	ld h,d
	ld l,Interaction.counter1
	ld (hl),c
	ld a,b
	call @image
	ld e,Interaction.var3e
	ld a,(de)
	or a
	jr nz,+
	; le missile : vers Link
	call objectGetAngleTowardLink
	ld e,Interaction.angle
	ld (de),a
	ld e,Interaction.speed
	ld a,SPEED_180
	ld (de),a
+
	jp objectSetVisible81

@first:
	.db 0, 3, 4
@time:
	.db 120, 64, 20

; a = l'image
@image:
	add a
	add a
	ld h,d
	ld l,Interaction.var3f
	ld b,a
	ld a,(hl)
	or a
	jr nz,+
	ld l,Interaction.oamTileIndexBase
	ld a,(hl)
	ld l,Interaction.var3f
	ld (hl),a		; var3f : la première tuile (l'image 0)
+
	ld a,(hl)
	add b
	ld l,Interaction.oamTileIndexBase
	ld (hl),a
	ret

@run:
	ld a,(wTextIsActive)
	or a
	ret nz
	ld e,Interaction.var3e
	ld a,(de)
	rst_jumpTable
	.dw @missileRun
	.dw @rockRun
	.dw @sparkRun

@missileRun:
	call objectApplySpeed
	; la flamme : deux images
	ld a,(wFrameCounter)
	and $04
	rrca
	rrca
	call @image
	ld a,$0a
	call @touch
	ld a,$fc
	jr c,@hit
	call interactionDecCounter1
	jr z,@puff
	ld e,Interaction.yh
	ld a,(de)
	cp $a8
	jr nc,@puff
	ret

@rockRun:
	call interactionDecCounter1
	jr z,@landed
	ld a,(hl)
	cp 24
	jr nc,@shadow
	jr nz,+
	; il tombe, de haut
	ld a,2
	call @image
	ld h,d
	ld l,Interaction.zh
	ld (hl),-48
+
	ld h,d
	ld l,Interaction.zh
	ld a,(hl)
	add $02
	ld (hl),a
	ret
@shadow:
	; l'ombre, qui clignote
	ld h,d
	ld l,Interaction.visible
	set 7,(hl)
	ld a,(wFrameCounter)
	and $02
	ret z
	res 7,(hl)
	ret
@landed:
	ld a,SND_STRONG_POUND
	call playSound
	ld a,$06
	call setScreenShakeCounter
	ld a,$0c
	call @touch
	ld a,$f8
	jr c,@hit
	jr @puff

@sparkRun:
	ld a,(wFrameCounter)
	and $04
	rrca
	rrca
	add $04
	call @image
	call interactionDecCounter1
	ret nz
	jp interactionDelete

; Il touche Link : des dégâts (a), puis un nuage
@hit:
	ld b,a
	ld a,(w1Link.invincibilityCounter)
	or a
	jr nz,@puff
	ld a,b
	ld (w1Link.damageToApply),a
	ld a,$30
	ld (w1Link.invincibilityCounter),a
	ld a,SND_DAMAGE_LINK
	call playSound
@puff:
	ld h,d
	ld l,Interaction.yh
	ld a,(hl)
	ld l,Interaction.xh
	ld l,(hl)
	ld h,a
	call createTerrierPuffAt
	jp interactionDelete

; cf : Link est à moins de a pixels
@touch:
	ld b,a
	ld h,d
	ld l,Interaction.yh
	ld a,(w1Link.yh)
	sub (hl)
	call terrierAbs
	cp b
	ret nc
	ld l,Interaction.xh
	ld a,(w1Link.xh)
	sub (hl)
	call terrierAbs
	cp b
	ret


;;
; Le Bracelet des Âmes (Denis) : l'attaque tourbillon aspire l'âme des ennemis autour de Link (à
; moins de 40 pixels) : une âme vole de chacun jusqu'au gantelet ($0b) et il perd 6 points de vie
; (les petits en meurent, les gros sont blessés ; pas les boss). C'est tout : plus de rayon, plus de
; vie rendue à chaque coup (object_code/common/itemParents/swordParent.s appelle ceci quand le
; tourbillon part).
soulSpin:
	ld a,(wBalladeSoulState)
	bit 1,a
	ret z
	ld h,FIRST_ENEMY_INDEX
@next:
	ld l,Enemy.enabled
	ld a,(hl)
	or a
	jr z,@skip
	; Jamais un boss ni un mini-boss (ENEMY_$01-$08 : Ramrock et ses bras, Veran... ; $70 et
	; plus) : Givrolin n'a que 4 points de vie, ses phases se comptent ailleurs ; vidé, il ne
	; renvoyait plus ses bras (Denis, bloqué)
	ld l,Enemy.id
	ld a,(hl)
	cp ENEMY_RIVER_ZORA
	jr c,@skip
	cp $70
	jr nc,@skip
	ld l,Enemy.collisionType
	bit 7,(hl)
	jr z,@skip
	ld l,Enemy.health
	ld a,(hl)
	or a
	jr z,@skip
	cp 25
	jr nc,@skip		; (les boss)
	ld l,Enemy.yh
	ld a,(w1Link.yh)
	sub (hl)
	call terrierAbs
	cp 40
	jr nc,@skip
	ld l,Enemy.xh
	ld a,(w1Link.xh)
	sub (hl)
	call terrierAbs
	cp 40
	jr nc,@skip
	; son âme, aspirée
	ld l,Enemy.health
	ld a,(hl)
	sub 6
	jr nc,+
	xor a
+
	ld (hl),a
	push hl
	ld l,Enemy.yh
	ld a,(hl)
	ld l,Enemy.xh
	ld l,(hl)
	ld h,a
	ld b,$0b
	call createTerrierObjectAt
	pop hl
@skip:
	inc h
	ld a,h
	cp LAST_ENEMY_INDEX+1
	jr c,@next
	ret
