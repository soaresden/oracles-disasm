; ==================================================================================================
; BALLADE: le Terrier des Serpents (donjon facultatif, index $0b, salles 4:d0-d7 ; idée de Denis : le
; gantelet des âmes d'Onimusha, le nom en clin d'œil à Snake). Voir story/salles/terrier.txt.
;
; - Le Gantelet des âmes ($0d), sur son socle (4:d1) : A devant, Link le prend (bit 0 de
;   wBalladeSoulState). Ensuite, chaque ennemi battu laisse une âme ($0b) qui vole jusqu'à Link :
;   le gantelet l'absorbe (wBalladeSouls). Une jarre ($0e), dans le coin de l'écran, se remplit.
; - Le contrôleur de chaque salle ($0a) : les âmes des ennemis qui meurent ; les ennemis qui
;   reviennent toujours (@config) ; les portes des âmes (le volet du haut, $07) qui s'ouvrent à 6, 12
;   et 18 âmes ; dans l'arène (4:d7), à 24 âmes, le boss.
; - Le boss ($0c) : une machine de guerre à deux pattes (clin d'œil à Metal Gear REX), possédée
;   par un fantôme (art/rex.txt). Chaque coup d'épée lui arrache une âme ; à moitié, son blindage
;   tombe, il « maigrit », va plus vite et s'efface (il clignote) ; à zéro, le fantôme ($0f) s'en
;   échappe, très vite ; trois coups, et le gantelet absorbe son âme : il devient une relique, le
;   Bracelet des Âmes (bit 1) : l'épée lance toujours un rayon, et chaque ennemi touché rend un
;   peu de vie à Link (object_code/common/itemParents/swordParent.s, items/swordBeam.s).
; ==================================================================================================

.define TERRIER_BOSS_SOULS	24	; les âmes qu'il faut pour que le boss apparaisse
.define TERRIER_BOSS_HP		12
.define TERRIER_GHOST_HP	3
.define TERRIER_RESPAWN		150	; un ennemi revient toutes les 150 images (s'il en manque)

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
	call @absorb
	call @respawn
	call @gate
	ld a,(wActiveRoom)
	cp $d7
	ret nz
	jp @arena

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
	; (le nombre, en BCD, pour \num1)
	ld a,b
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
	.db $d2, ENEMY_STALFOS, 3, 6
	.db $d4, ENEMY_GHINI, 2, 12
	.db $d6, ENEMY_KEESE, 3, 18
	.db $d7, ENEMY_GHINI, 3, 0
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
; porte des âmes (6, 12, 18) et pour le boss (24). var30 : le dessin de la jarre vide
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
-
	cp 6
	jr c,+
	sub 6
	jr -
+
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
	.db 0, 0, 1, 2, 2, 3


;;
; Le boss ($0c) : la machine possédée. var30 sa vie, var31 son temps d'invincibilité après un coup,
; var32 1 quand son blindage est tombé
rex:
	ld e,Interaction.state
	ld a,(de)
	or a
	jr nz,@run
	inc a
	ld (de),a
	call interactionInitGraphics
	call objectSetVisible82
	ld e,Interaction.var30
	ld a,TERRIER_BOSS_HP
	ld (de),a
	ld a,MUS_MINIBOSS
	jp playSound

@run:
	ld a,(wTextIsActive)
	or a
	ret nz
	ld h,d
	ld l,Interaction.var31
	ld a,(hl)
	or a
	jr z,+
	dec (hl)
+
	call @visibility
	call @move
	call @hurtLink
	jp @checkSword

; Visible ; il clignote après un coup ; blessé, il s'efface de plus en plus (il « maigrit »)
@visibility:
	ld h,d
	ld l,Interaction.visible
	set 7,(hl)
	ld l,Interaction.var31
	ld a,(hl)
	or a
	jr z,+
	ld a,(wFrameCounter)
	and $02
	jr nz,@hide
+
	ld l,Interaction.var32
	ld a,(hl)
	or a
	ret z
	ld l,Interaction.var30
	ld a,(hl)
	ld b,$07
	cp $05
	jr nc,+
	ld b,$03
	cp $03
	jr nc,+
	ld b,$01
+
	ld a,(wFrameCounter)
	and b
	ret nz
@hide:
	ld h,d
	ld l,Interaction.visible
	res 7,(hl)
	ret

; Il marche vers Link : une image sur deux, puis à chaque image quand il a maigri ; ses pas font
; trembler le sol
@move:
	ld e,Interaction.var32
	ld a,(de)
	or a
	jr nz,+
	ld a,(wFrameCounter)
	rrca
	ret c
	and $1f
	jr nz,+
	ld a,$06
	call setScreenShakeCounter
+
	ld h,d
	ld l,Interaction.yh
	ld a,(w1Link.yh)
	sub $08
	call @toward
	ld a,(hl)
	cp $30
	jr nc,+
	ld (hl),$30
+
	cp $80
	jr c,+
	ld (hl),$80
+
	ld l,Interaction.xh
	ld a,(w1Link.xh)
	call @toward
	ld a,(hl)
	cp $30
	jr nc,+
	ld (hl),$30
+
	cp $c0
	ret c
	ld (hl),$c0
	ret

@toward:
	sub (hl)
	ret z
	jr c,+
	inc (hl)
	ret
+
	dec (hl)
	ret

; Il touche Link : un cœur en moins
@hurtLink:
	ld h,d
	ld l,Interaction.yh
	ld a,(w1Link.yh)
	sub (hl)
	sub $08
	call terrierAbs
	cp $0e
	ret nc
	ld l,Interaction.xh
	ld a,(w1Link.xh)
	sub (hl)
	call terrierAbs
	cp $0e
	ret nc
	ld a,(w1Link.invincibilityCounter)
	or a
	ret nz
	ld a,$f8
	ld (w1Link.damageToApply),a
	ld a,$30
	ld (w1Link.invincibilityCounter),a
	ld a,SND_DAMAGE_LINK
	jp playSound

; L'épée le touche : une âme lui est arrachée
@checkSword:
	ld e,Interaction.var31
	ld a,(de)
	or a
	ret nz
	ld a,(w1WeaponItem.enabled)
	or a
	ret z
	ld h,d
	ld l,Interaction.yh
	ld a,(w1WeaponItem.yh)
	sub (hl)
	call terrierAbs
	cp $12
	ret nc
	ld l,Interaction.xh
	ld a,(w1WeaponItem.xh)
	sub (hl)
	call terrierAbs
	cp $12
	ret nc
	; touché
	ld l,Interaction.var31
	ld (hl),$20
	ld a,SND_BOSS_DAMAGE
	call playSound
	ld h,d
	ld l,Interaction.yh
	ld a,(hl)
	ld l,Interaction.xh
	ld l,(hl)
	ld h,a
	ld b,$0b
	call createTerrierObjectAt
	ld h,d
	ld l,Interaction.var30
	dec (hl)
	ld a,(hl)
	jr z,@defeated
	cp TERRIER_BOSS_HP / 2
	ret nz
	; Son blindage tombe : le fantôme brille à travers, il va plus vite
	ld l,Interaction.var32
	ld (hl),$01
	ld l,Interaction.oamTileIndexBase
	ld a,(hl)
	add $10
	ld (hl),a
	ld a,$10
	call setScreenShakeCounter
	ld a,SND_BIG_EXPLOSION
	jp playSound

@defeated:
	; La machine tombe en morceaux ; le fantôme s'en échappe
	ld a,$20
	call setScreenShakeCounter
	ld a,SND_BOSS_DEAD
	call playSound
	ld h,d
	ld l,Interaction.yh
	ld a,(hl)
	ld l,Interaction.xh
	ld l,(hl)
	ld h,a
	push hl
	call createTerrierPuffAt
	pop hl
	push hl
	ld a,l
	add $08
	ld l,a
	call createTerrierPuffAt
	pop hl
	ld b,$0f
	call createTerrierObjectAt
	jp interactionDelete


;;
; Le fantôme ($0f), échappé de la machine : il file en diagonale et rebondit sur les murs ; trois
; coups, et le gantelet absorbe son âme : la relique. var30 sa vie, var31 son invincibilité, var32
; dy, var33 dx
ghost:
	ld e,Interaction.state
	ld a,(de)
	or a
	jr nz,@run
	call terrierObjectInit
	ld h,d
	ld l,Interaction.var30
	ld (hl),TERRIER_GHOST_HP
	ld l,Interaction.var32
	ld (hl),$02
	inc l
	ld (hl),$02
	ret

@run:
	ld a,(wTextIsActive)
	or a
	ret nz
	ld h,d
	ld l,Interaction.visible
	set 7,(hl)
	ld l,Interaction.var31
	ld a,(hl)
	or a
	jr z,+
	dec (hl)
	ld a,(wFrameCounter)
	and $02
	jr z,+
	ld l,Interaction.visible
	res 7,(hl)
+
	; il file et rebondit
	ld h,d
	ld l,Interaction.var32
	ld b,(hl)
	ld l,Interaction.yh
	ld a,(hl)
	add b
	ld (hl),a
	cp $28
	jr c,@bounceY
	cp $89
	jr c,+
@bounceY:
	ld l,Interaction.var32
	ld a,(hl)
	cpl
	inc a
	ld (hl),a
+
	ld h,d
	ld l,Interaction.var33
	ld b,(hl)
	ld l,Interaction.xh
	ld a,(hl)
	add b
	ld (hl),a
	cp $28
	jr c,@bounceX
	cp $c9
	jr c,+
@bounceX:
	ld l,Interaction.var33
	ld a,(hl)
	cpl
	inc a
	ld (hl),a
+
	; il touche Link : un demi-cœur
	ld h,d
	ld l,Interaction.yh
	ld a,(w1Link.yh)
	sub (hl)
	call terrierAbs
	cp $0a
	jr nc,@sword
	ld l,Interaction.xh
	ld a,(w1Link.xh)
	sub (hl)
	call terrierAbs
	cp $0a
	jr nc,@sword
	ld a,(w1Link.invincibilityCounter)
	or a
	jr nz,@sword
	ld a,$fc
	ld (w1Link.damageToApply),a
	ld a,$30
	ld (w1Link.invincibilityCounter),a
	ld a,SND_DAMAGE_LINK
	call playSound
@sword:
	ld e,Interaction.var31
	ld a,(de)
	or a
	ret nz
	ld a,(w1WeaponItem.enabled)
	or a
	ret z
	ld h,d
	ld l,Interaction.yh
	ld a,(w1WeaponItem.yh)
	sub (hl)
	call terrierAbs
	cp $0c
	ret nc
	ld l,Interaction.xh
	ld a,(w1WeaponItem.xh)
	sub (hl)
	call terrierAbs
	cp $0c
	ret nc
	ld l,Interaction.var31
	ld (hl),$20
	ld a,SND_BOSS_DAMAGE
	call playSound
	ld h,d
	ld l,Interaction.var30
	dec (hl)
	ret nz
	; Le gantelet absorbe son âme : la relique, le Bracelet des Âmes
	ld hl,wBalladeSoulState
	set 1,(hl)
	ld a,SNDCTRL_STOPMUSIC
	call playSound
	ld a,SND_SOLVEPUZZLE
	call playSound
	ld bc,TX_5a1d
	call showText
	jp interactionDelete
