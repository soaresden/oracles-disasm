; ==================================================================================================
; BALLADE: le Labyrinthe des Lynels, le 3e jeu du forain (salle 5:e9, à la façon de Pac-Man).
;
; « Un Pac-Man où c'est Link, et des Lynels le poursuivent et sont invincibles ; il faut ramasser un
; objet pour les terrasser, mais le but c'est de récupérer tous les rubis » (Denis).
;
; Le forain y envoie Link (TX_5a4c). Le labyrinthe (art/labyrinthe.txt, dessiné par
; tools/make_pacman.py) est semé de rubis (un rubis chacun) ; quatre gemmes de force clignotent dans
; les coins. Quatre Lynels (ENEMY_LYNEL $03-$06) sortent l'un après l'autre de leur enclos et
; poursuivent Link, chacun à sa façon (comme les fantômes de Pac-Man) : le rouge vise Link, le rose
; trois cases devant lui, le bleu le suit de loin mais retourne dans son coin quand il est trop près,
; l'orange hésite. Ils ne font jamais demi-tour, sauf quand Link prend une gemme : ils ont peur
; (bleu nuit, puis ils clignotent), fuient au hasard, plus lentement, et Link les terrasse en les
; touchant (5, 10, 20 puis 50 rubis d'affilée) ; ils retournent à l'enclos. Sans gemme, l'épée les
; traverse. Un Lynel qui attrape Link lui prend un cœur et tous retournent à l'enclos ; s'il ne
; reste qu'un cœur à Link, c'est perdu. Tous les rubis ramassés : gagné (50 rubis de plus). Dans les
; deux cas, retour chez le forain.
;
; Le contrôleur : INTERAC_BALLADE_CREUSE $01 (object_code/ages/interactions/balladeCreuse.s) ; les
; Lynels : object_code/common/enemies/lynel.s appelle « lynel » ci-dessous.
; ==================================================================================================

.define PAC_FLOOR	$a0
.define PAC_RUPEE	$a3
.define PAC_GEM		$a4
.define PAC_GEM_FLASH	$a5
.define PAC_POWER_TIME	210	; la peur : 210 x 2 images (7 secondes)
.define PAC_FLASH_TIME	60	; ses 2 dernières secondes : ils clignotent

;;
; Le contrôleur, à chaque image (d = l'interaction)
main:
	; Pas de Lanterne dans le labyrinthe
	ld a,$02
	ld (wInstrumentsDisabledCounter),a
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw @init
	.dw @playing
	.dw @ending
	.dw @done
	.dw @winText
	.dw @lostText

@init:
	ld a,$01
	ld (de),a
	; Les rubis du plan (le plan est neuf à chaque arrivée)
	ld hl,wRoomLayout
	ld bc,$b000
-
	ld a,(hl)
	cp PAC_RUPEE
	jr nz,+
	inc c
+
	inc l
	dec b
	jr nz,-
	ld a,c
	ld (wBalladePacLeft),a
	xor a
	ld (wBalladePacPower),a
	ld (wBalladePacCombo),a
	ld (wBalladePacCaught),a
	inc a
	ld (wBalladePacState),a
	ld a,PALH_LABYRINTHE
	jp loadPaletteHeader

@playing:
	ld a,(wTextIsActive)
	or a
	ret nz

	; Les gemmes clignotent
	ld a,(wFrameCounter)
	and $0f
	call z,@flashGems

	; La peur s'use (une image sur deux)
	ld a,(wFrameCounter)
	rrca
	jr c,+
	ld hl,wBalladePacPower
	ld a,(hl)
	or a
	jr z,+
	dec (hl)
+
	; Un Lynel a attrapé Link
	ld a,(wBalladePacCaught)
	or a
	jp nz,@caught

	; Ce que Link ramasse : sa case
	ld a,(w1Link.yh)
	and $f0
	ld c,a
	ld a,(w1Link.xh)
	swap a
	and $0f
	or c
	ld c,a
	ld h,>wRoomLayout
	ld l,a
	ld a,(hl)
	cp PAC_RUPEE
	jr z,@rupee
	cp PAC_GEM
	jr z,@gem
	cp PAC_GEM_FLASH
	ret nz

@gem:
	; Une gemme de force : les Lynels ont peur
	ld a,PAC_FLOOR
	call setTile
	ld a,PAC_POWER_TIME
	ld (wBalladePacPower),a
	xor a
	ld (wBalladePacCombo),a
	ld hl,wBalladePacPowerGen
	inc (hl)
	ld a,SND_MAGIC_POWDER
	jp playSound

@rupee:
	ld a,PAC_FLOOR
	call setTile
	push de
	ld a,TREASURE_RUPEES
	ld c,RUPEEVAL_001
	call giveTreasure
	pop de
	ld a,SND_RUPEE
	call playSound
	ld hl,wBalladePacLeft
	dec (hl)
	ret nz

	; Gagné : tous les rubis ! Les Lynels s'en vont, puis le forain parle
	ld a,$02
	ld (wBalladePacState),a
	ld e,Interaction.state
	ld a,$04
	ld (de),a
	ld e,Interaction.counter1
	ld a,40
	ld (de),a
	push de
	ld a,TREASURE_RUPEES
	ld c,RUPEEVAL_050
	call giveTreasure
	pop de
	ld a,SND_SOLVEPUZZLE
	jp playSound

@winText:
	call @wait
	ret nz
	ld bc,TX_5a4e
	jp showText

@lostText:
	call @wait
	ret nz
	ld bc,TX_5a4f
	jp showText

;;
; Attendre que les Lynels soient partis (counter1), puis passer à @ending
@wait:
	ld h,d
	ld l,Interaction.counter1
	dec (hl)
	ret nz
	ld l,Interaction.state
	ld (hl),$02
	xor a
	ret

@caught:
	; Attrapé : tous les Lynels retournent à l'enclos ; un cœur en moins, ou perdu s'il n'en reste
	; qu'un
	xor a
	ld (wBalladePacCaught),a
	ld hl,wBalladePacResetGen
	inc (hl)
	ld a,SND_DAMAGE_LINK
	call playSound
	ld a,$60
	ld (w1Link.invincibilityCounter),a
	ld a,(wLinkHealth)
	cp $05
	jr c,@lost
	ld a,$f8
	ld (w1Link.damageToApply),a
	ret
@lost:
	ld a,$03
	ld (wBalladePacState),a
	ld e,Interaction.state
	ld a,$05
	ld (de),a
	ld e,Interaction.counter1
	ld a,40
	ld (de),a
	ret

@ending:
	; Le texte lu : retour chez le forain (1:ac, au-dessus de lui)
	ld a,(wTextIsActive)
	or a
	ret nz
	ld a,$03
	ld (de),a
	ld a,$81
	ld (wWarpDestGroup),a
	ld a,$ac
	ld (wWarpDestRoom),a
	ld a,$27
	ld (wWarpDestPos),a
	xor a
	ld (wWarpTransition),a
	ld a,$03 ; fondu
	ld (wWarpTransition2),a
	ret

@done:
	ret

;;
; Les gemmes qui restent changent d'image
@flashGems:
	ld hl,wRoomLayout
--
	ld a,(hl)
	ld b,PAC_GEM_FLASH
	cp PAC_GEM
	jr z,+
	ld b,PAC_GEM
	cp PAC_GEM_FLASH
	jr nz,++
+
	push hl
	ld c,l
	ld a,b
	call setTile
	pop hl
++
	inc l
	ld a,l
	cp $b0
	jr c,--
	ret


;;
; Un Lynel du labyrinthe (ENEMY_LYNEL $03 rouge, $04 rose, $05 bleu, $06 orange), à chaque image.
; d = le Lynel. Variables : var30 0 dans l'enclos, 1 il en sort, 2 dehors ; counter1 l'attente dans
; l'enclos (x 4 images) ; var32 il a peur ; var33 / var34 les compteurs « gemme » et « à l'enclos »
; déjà vus ; var35 ses couleurs ; var36 / var37 la case visée ; var38 / var39 / var3a pour choisir
; sa direction.
lynel:
	ld e,Enemy.state
	ld a,(de)
	or a
	jr nz,@running

	; Au début : visible, à sa place
	ld a,$08
	ld (de),a
	call objectSetVisiblec2
	ld h,d
	ld l,Enemy.oamFlags
	ld a,(hl)
	ld l,Enemy.var35
	ld (hl),a
	ld a,(wBalladePacPowerGen)
	ld l,Enemy.var33
	ldi (hl),a
	ld a,(wBalladePacResetGen)
	ld (hl),a
	ld l,Enemy.direction
	ld (hl),$ff
	call @toStart
	jp @animation

@running:
	; Invincible : ni l'épée ni rien ne le touche (il attrape Link lui-même, voir @checkLink)
	ld h,d
	ld l,Enemy.collisionType
	res 7,(hl)
	ld a,(wBalladePacState)
	cp $02
	jr c,+
	; La partie est finie : il s'en va
	call objectCreatePuff
	jp enemyDelete
+
	or a
	ret z
	ld a,(wTextIsActive)
	or a
	ret nz

	; Tout le monde à l'enclos (Link vient d'être attrapé)
	ld a,(wBalladePacResetGen)
	ld h,d
	ld l,Enemy.var34
	cp (hl)
	jr z,+
	ld (hl),a
	call @toStart
	jp @animation
+
	; Une gemme : il a peur, et fait demi-tour s'il est dehors
	ld a,(wBalladePacPowerGen)
	ld l,Enemy.var33
	cp (hl)
	jr z,+
	ld (hl),a
	ld l,Enemy.var32
	ld (hl),$01
	ld l,Enemy.var30
	ld a,(hl)
	cp $02
	jr nz,+
	ld l,Enemy.angle
	ld a,(hl)
	xor $10
	ld (hl),a
+
	ld a,(wBalladePacPower)
	or a
	jr nz,+
	ld h,d
	ld l,Enemy.var32
	ld (hl),a
+
	call @updatePalette
	call @checkLink
	ret c

	ld e,Enemy.var30
	ld a,(de)
	rst_jumpTable
	.dw @waiting
	.dw @leaving
	.dw @roaming

@waiting:
	ld a,(wFrameCounter)
	and $03
	jp nz,@animation
	ld h,d
	ld l,Enemy.counter1
	dec (hl)
	jp nz,@animation
	ld l,Enemy.var30
	inc (hl)
	jp @animation

@leaving:
	; Jusqu'à la colonne de la porte, puis on monte jusqu'au couloir au-dessus
	ld h,d
	ld l,Enemy.xh
	ld a,(hl)
	cp $78
	jr z,@leaveUp
	jr c,+
	dec (hl)
	ld a,$18
	jr ++
+
	inc (hl)
	ld a,$08
++
	ld l,Enemy.angle
	ld (hl),a
	jp @animation
@leaveUp:
	ld l,Enemy.yh
	ld a,(hl)
	cp $38
	jr z,@outside
	dec (hl)
	ld l,Enemy.angle
	ld (hl),$00
	jp @animation
@outside:
	ld l,Enemy.var30
	ld (hl),$02
	call getRandomNumber
	and $10
	add $08			; à droite ou à gauche
	ld l,Enemy.angle
	ld (hl),a
	jp @animation

@roaming:
	; Sa vitesse : 3 pas sur 4 ; 1 sur 2 s'il a peur ; le rouge à fond quand il reste peu de rubis
	ld a,(wFrameCounter)
	ld b,a
	ld h,d
	ld l,Enemy.var32
	ld a,(hl)
	or a
	jr z,+
	bit 0,b
	jp nz,@animation
	jr @step
+
	ld l,Enemy.subid
	ld a,(hl)
	cp $03
	jr nz,+
	ld a,(wBalladePacLeft)
	cp 20
	jr c,@step
+
	ld a,b
	and $03
	jp z,@animation
@step:
	; Au milieu d'une case : il choisit sa direction
	ld h,d
	ld l,Enemy.yh
	ld a,(hl)
	and $0f
	cp $08
	jr nz,@move
	ld l,Enemy.xh
	ld a,(hl)
	and $0f
	cp $08
	call z,@chooseDirection
@move:
	ld h,d
	ld l,Enemy.angle
	ld a,(hl)
	ld l,Enemy.yh
	or a
	jr nz,+
	dec (hl)
	jp @animation
+
	cp $10
	jr nz,+
	inc (hl)
	jp @animation
+
	ld l,Enemy.xh
	cp $08
	jr nz,+
	inc (hl)
	jp @animation
+
	dec (hl)

@animation:
	; Il court quand il chasse, il marche sinon
	ld b,$00
	ld h,d
	ld l,Enemy.var30
	ld a,(hl)
	cp $02
	jr nz,+
	ld l,Enemy.var32
	ld a,(hl)
	or a
	jr nz,+
	ld b,$04
+
	ld l,Enemy.angle
	ldd a,(hl)
	swap a
	rlca
	add b
	cp (hl)
	jr z,+
	ld (hl),a
	call enemySetAnimation
+
	jp enemyAnimate

;;
; Au milieu d'une case : la direction qui le rapproche le plus de sa cible (ou au hasard s'il a
; peur), sans demi-tour ni mur ; à égalité : haut, gauche, bas, droite (comme dans Pac-Man)
@chooseDirection:
	call @target
	ld h,d
	ld l,Enemy.var38
	ld (hl),$ff
	inc l
	ld (hl),$ff
	inc l
	ld (hl),$00
@dirLoop:
	ld h,d
	ld l,Enemy.var3a
	ld a,(hl)
	ld hl,@dirAngles
	rst_addAToHl
	ld b,(hl)
	ld e,Enemy.angle
	ld a,(de)
	xor $10
	cp b
	jr z,@dirNext
	; La case voisine : un mur ?
	call @cellOfSelf
	ld a,b
	call @offsetFor
	add c
	ld c,a
	ld h,>wRoomCollisions
	ld l,a
	ld a,(hl)
	or a
	jr nz,@dirNext
	; Sa distance à la cible (au hasard s'il a peur)
	ld h,d
	ld l,Enemy.var32
	ld a,(hl)
	or a
	jr z,+
	call getRandomNumber
	and $3f
	jr ++
+
	ld a,c
	swap a
	and $0f
	ld l,Enemy.var36
	sub (hl)
	call @abs
	ld e,a
	ld a,c
	and $0f
	ld l,Enemy.var37
	sub (hl)
	call @abs
	add e
++
	ld h,d
	ld l,Enemy.var38
	cp (hl)
	jr nc,@dirNext
	ld (hl),a
	inc l
	ld (hl),b
@dirNext:
	ld h,d
	ld l,Enemy.var3a
	inc (hl)
	ld a,(hl)
	cp $04
	jr c,@dirLoop
	; Aucune : demi-tour
	ld l,Enemy.var39
	ld a,(hl)
	cp $ff
	jr nz,+
	ld l,Enemy.angle
	ld a,(hl)
	xor $10
+
	ld l,Enemy.angle
	ld (hl),a
	ret

;;
; La case visée (var36 ligne, var37 colonne)
@target:
	ld a,(w1Link.yh)
	swap a
	and $0f
	ld b,a
	ld a,(w1Link.xh)
	swap a
	and $0f
	ld c,a
	ld e,Enemy.subid
	ld a,(de)
	sub $03
	jr z,@setTarget		; rouge : Link
	dec a
	jr z,@ahead		; rose : trois cases devant Link
	dec a
	jr z,@shy		; bleu : Link de loin, son coin de près
	; Orange : Link une fois sur deux, sinon son coin (en haut à droite)
	call getRandomNumber
	rrca
	jr c,@setTarget
	ld bc,$010d
	jr @setTarget
@ahead:
	ld a,(w1Link.direction)
	and $03
	add a
	ld hl,@aheadOffsets
	rst_addAToHl
	ldi a,(hl)
	add b
	ld b,a
	ld a,(hl)
	add c
	ld c,a
	jr @setTarget
@shy:
	ld h,d
	ld l,Enemy.yh
	ld a,(hl)
	swap a
	and $0f
	sub b
	call @abs
	ld e,a
	ld l,Enemy.xh
	ld a,(hl)
	swap a
	and $0f
	sub c
	call @abs
	add e
	cp $06
	jr nc,@setTarget
	ld bc,$0901		; son coin : en bas à gauche
@setTarget:
	ld h,d
	ld l,Enemy.var36
	ld (hl),b
	inc l
	ld (hl),c
	ret

;;
; c = la case du Lynel (YX)
@cellOfSelf:
	ld h,d
	ld l,Enemy.yh
	ld a,(hl)
	and $f0
	ld c,a
	ld l,Enemy.xh
	ld a,(hl)
	swap a
	and $0f
	or c
	ld c,a
	ret

;;
; a = la direction ($00 haut, $08 droite, $10 bas, $18 gauche) -> le pas d'une case
@offsetFor:
	rrca
	rrca
	rrca
	ld hl,@angleOffsets
	rst_addAToHl
	ld a,(hl)
	ret

@abs:
	bit 7,a
	ret z
	cpl
	inc a
	ret

;;
; Link touche le Lynel : s'il a peur, Link le terrasse (carry) ; sinon il attrape Link
@checkLink:
	ld h,d
	ld l,Enemy.yh
	ld a,(w1Link.yh)
	sub (hl)
	call @abs
	cp $0b
	ret nc
	ld l,Enemy.xh
	ld a,(w1Link.xh)
	sub (hl)
	call @abs
	cp $0b
	ret nc
	ld l,Enemy.var32
	ld a,(hl)
	or a
	jr nz,@eaten
	ld a,(w1Link.invincibilityCounter)
	or a
	jr nz,+
	inc a
	ld (wBalladePacCaught),a
+
	xor a
	ret
@eaten:
	call objectCreatePuff
	ld a,SND_KILLENEMY
	call playSound
	; 5, 10, 20, puis 50 rubis d'affilée
	ld hl,wBalladePacCombo
	ld a,(hl)
	cp $03
	jr nc,+
	inc (hl)
+
	ld hl,@comboRupees
	rst_addAToHl
	ld c,(hl)
	push de
	ld a,TREASURE_RUPEES
	call giveTreasure
	pop de
	; Retour au milieu de l'enclos, 2 secondes
	ld h,d
	ld l,Enemy.yh
	ld (hl),$58
	ld l,Enemy.xh
	ld (hl),$78
	ld l,Enemy.var30
	ld (hl),$00
	ld l,Enemy.counter1
	ld (hl),30
	ld l,Enemy.var32
	ld (hl),$00
	ld l,Enemy.oamFlags
	ld e,Enemy.var35
	ld a,(de)
	ld (hl),a
	scf
	ret

;;
; Ses couleurs : les siennes, ou bleu nuit (palette 6 des sprites) s'il a peur ; à la fin de la
; peur, il clignote
@updatePalette:
	ld h,d
	ld l,Enemy.var35
	ld b,(hl)
	ld l,Enemy.var32
	ld a,(hl)
	or a
	jr z,@setPal
	ld a,(wBalladePacPower)
	cp PAC_FLASH_TIME
	jr nc,+
	ld a,(wFrameCounter)
	and $08
	jr nz,@setPal
+
	ld a,b
	and $f8
	or $06
	ld b,a
@setPal:
	ld l,Enemy.oamFlags
	ld (hl),b
	ret

;;
; À sa place de départ (et ses couleurs)
@toStart:
	ld e,Enemy.subid
	ld a,(de)
	sub $03
	and $03
	ld b,a
	add a
	add a
	add b
	ld hl,@starts
	rst_addAToHl
	ld e,Enemy.yh
	ldi a,(hl)
	ld (de),a
	ld e,Enemy.xh
	ldi a,(hl)
	ld (de),a
	ld e,Enemy.var30
	ldi a,(hl)
	ld (de),a
	ld e,Enemy.counter1
	ldi a,(hl)
	ld (de),a
	ld e,Enemy.angle
	ld a,(hl)
	ld (de),a
	ld e,Enemy.var32
	xor a
	ld (de),a
	ld h,d
	ld l,Enemy.var35
	ld a,(hl)
	ld l,Enemy.oamFlags
	ld (hl),a
	ret

; y, x, état (0 dans l'enclos, 2 dehors), attente (x 4 images), direction
@starts:
	.db $38 $78 $02 $01 $18		; rouge : dehors, au-dessus de la porte
	.db $58 $78 $00 15  $00		; rose : 1 seconde
	.db $58 $68 $00 75  $00		; bleu : 5 secondes
	.db $58 $88 $00 135 $00		; orange : 9 secondes

@dirAngles:
	.db $00 $18 $10 $08		; haut, gauche, bas, droite
@angleOffsets:
	.db $f0 $01 $10 $ff		; haut, droite, bas, gauche
@aheadOffsets:
	.db $fd $00, $00 $03, $03 $00, $00 $fd
@comboRupees:
	.db RUPEEVAL_005, RUPEEVAL_010, RUPEEVAL_020, RUPEEVAL_050
