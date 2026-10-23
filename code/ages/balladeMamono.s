; ==================================================================================================
; BALLADE: le Mamono du forain, dans son arène (salle 5:ea, INTERAC_BALLADE_CREUSE $02).
;
; Comme dans Xplosive Adventures (le jeu de Denis) : un grand champ de sable de 13 x 8 cases (lignes
; 2-9, colonnes 1-13 de la salle) cache des monstres d'un niveau de 1 à 5 (Keese, Octorok, Moblin,
; Darknut, Lynel). Link creuse la case devant lui avec A. Une case vide montre la somme des niveaux
; des monstres qui l'entourent (les chiffres de 1 à 40 : tools/make_mamono.py, décor $6a). Un
; monstre déterré apparaît, figé sur sa case (le vrai ennemi), puis s'en va en fumée et laisse son
; niveau dans un cadre (on voit qu'il y avait là un monstre, pour continuer à compter) : s'il n'est
; pas plus fort que Link, Link le bat ; sinon Link perd un demi-cœur par niveau d'écart, et tout son
; niveau si le monstre est découvert à l'aveugle (aucune case creusée autour). Chaque monstre battu
; donne autant d'expérience que son niveau, et Link monte de niveau (« L-n » dans la barre d'état,
; balladeMarine.drawNoctambuleTimer). Une case sans rien autour découvre ses voisines toute seule
; (quatre par image). Gagné quand tous les monstres sont déterrés ; à bout de forces, perdu. Deux
; niveaux (Denis) : Facile, Dur ; le gros lot en Dur sans une égratignure (un « perfect » :
; wBalladeMamonoHurt) : un quart de cœur la première fois (drapeau $80 de l'arène), 30 rubis
; ensuite. On sort par le haut, chez le forain.
;
; Les ennemis modèles : un de chaque niveau dans les objets de la salle (story/salles/objets.txt),
; pour que leurs images soient chargées ; après quelques images, ce contrôleur les cache, coupe leurs
; collisions, supprime leurs objets à part (l'épée du Darknut) et les fige tous (DISABLE_ENEMIES) ; un monstre déterré, c'est son modèle qu'on montre.
; Les niveaux cachés : un demi-octet par case à $cfc0 (les variables de scripts de la salle ; aucun
; script ne tourne dans l'arène).
; ==================================================================================================

.define MAMONO_UNDUG		$12	; sable à creuser
.define MAMONO_SAND		$bf	; sable lisse : rien autour
.define MAMONO_FIRST_NUMBER	$40	; brique $40 + n : le chiffre n (1-40)
.define MAMONO_FIRST_BOXED	$68	; brique $68 + n : un monstre vaincu de niveau n, dans un cadre
.define MAMONO_FLOOD_PER_FRAME	4
.define MAMONO_ROWS		8
.define MAMONO_COLS		13
.define MAMONO_CELLS		104
.define MAMONO_LEVELS		$cfc0	; 52 octets
.define MAMONO_SHOW_TIME	45

;;
; Le contrôleur (d = l'interaction)
main:
	ld a,$02
	ld (wInstrumentsDisabledCounter),a
	; En jeu : rien que la Pelle (balladeCreuse.setShovelLoadout) ; la partie finie, tout revient
	push de
	ld a,(wBalladeMamonoState)
	cp $01
	jr nz,+
	callab balladeCreuse.setShovelLoadout
	jr ++
+
	callab balladeCreuse.restoreLoadout
++
	pop de
	ld e,Interaction.state
	ld a,(de)
	or a
	jr z,@capture
	; Les monstres restent figés
	ld hl,wDisabledObjects
	set 2,(hl)		; DISABLE_ENEMIES
	; et leurs objets à part ne reviennent pas (l'épée du Darknut, recréée quand on le montre)
	ld h,FIRST_ENEMY_INDEX
-
	ld l,Part.enabled
	ld (hl),$00
	inc h
	ld a,h
	cp LAST_ENEMY_INDEX+1
	jr c,-
	ld e,Interaction.state
	ld a,(de)
	; On sort par le haut : chez le forain ; pas pendant la partie (Denis : on s'en allait)
	cp $04
	ret z
	ld a,(w1Link.yh)
	cp $0c
	jr nc,+
	ld a,(wBalladeMamonoState)
	cp $01
	jp nz,@leave
	ld a,$0c
	ld (w1Link.yh),a
+
	ld a,(de)
	dec a
	jr z,@arrival
	call @updateShow
	ld e,Interaction.state
	ld a,(de)
	cp $02
	ret nz
	jp @playing

@capture:
	; Les ennemis modèles se préparent (quelques images), puis on les cache
	ld h,d
	ld l,Interaction.counter1
	inc (hl)
	ld a,(hl)
	cp $06
	ret c
	ld l,Interaction.state
	inc (hl)
	ld hl,wBalladeMamonoSlots
	xor a
	ldi (hl),a
	ldi (hl),a
	ldi (hl),a
	ldi (hl),a
	ld (hl),a
	ld b,$d0
@nextSlot:
	ld h,b
	ld l,Enemy.enabled
	ld a,(hl)
	or a
	jr z,@slotDone
	inc l
	ld a,(hl)		; Enemy.id
	ld e,a
	ld c,$00
	ld hl,@monsterIds
-
	ld a,e
	cp (hl)
	jr z,@found
	inc hl
	inc c
	ld a,c
	cp $05
	jr nz,-
	jr @slotDone
@found:
	ld a,c
	ld hl,wBalladeMamonoSlots
	rst_addAToHl
	ld (hl),b
	ld h,b
	ld l,Enemy.visible
	res 7,(hl)
	ld l,Enemy.collisionType
	res 7,(hl)
@slotDone:
	; Leurs objets à part (l'épée du Darknut...) s'en vont
	ld h,b
	ld l,Part.enabled
	ld (hl),$00
	inc b
	ld a,b
	cp $e0
	jr nz,@nextSlot
	ld hl,wDisabledObjects
	set 2,(hl)
	ret

@arrival:
	; Une partie commence : Link au niveau 1 ; le forain explique, Marine conseille
	ld a,$02
	ld (de),a
	xor a
	ld (wBalladeMamonoXp),a
	ld (wBalladeMamonoPlaced),a
	ld (wBalladeMamonoLeft),a
	ld (wBalladeMamonoShow),a
	ld (wBalladeMamonoHurt),a
	ld (wBalladeMamonoFlood),a
	inc a
	ld (wBalladeMamonoLevel),a
	ld (wBalladeMamonoState),a
	ld bc,TX_5a4a
	jp showText

@leave:
	ld a,$04
	ld (de),a
	xor a
	ld (wBalladeMamonoState),a
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

;;
; Le monstre montré : au bout d'un moment, il s'en va en fumée et laisse son chiffre
@updateShow:
	ld hl,wBalladeMamonoShow
	ld a,(hl)
	or a
	ret z
	dec (hl)
	ret nz
	ld a,(wBalladeMamonoShowSlot)
	or a
	jr z,+
	ld h,a
	ld l,Enemy.visible
	res 7,(hl)
+
	ld a,(wBalladeMamonoShowPos)
	ld c,a
	call @puffAt
	ld a,SND_POOF
	call playSound
	ld a,(wBalladeMamonoShowPos)
	ld c,a
	ld a,(wBalladeMamonoTmp)
	add MAMONO_FIRST_BOXED
	jp setTile

@playing:
	ld a,(wBalladeMamonoState)
	cp $01
	ret nz
	ld a,(wTextIsActive)
	or a
	ret nz
	ld a,(wBalladeMamonoShow)
	or a
	ret nz
	ld a,(wBalladeMamonoFlood)
	or a
	jp nz,@flood
	ld a,(wGameKeysJustPressed)
	and BTN_A
	ret z

	; La case devant Link : la sienne, plus un pas dans la direction où il regarde
	ld a,(w1Link.yh)
	and $f0
	ld c,a
	ld a,(w1Link.xh)
	swap a
	and $0f
	or c
	ld c,a
	ld a,(w1Link.direction)
	and $03
	ld hl,@frontOffsets
	rst_addAToHl
	ld a,c
	add (hl)
	ld c,a			; c = position de la case (YX)
	call @cellIndex
	ret c			; hors du champ
	ld b,a			; b = numéro de la case
	ld h,>wRoomLayout
	ld l,c
	ld a,(hl)
	cp MAMONO_UNDUG
	ret nz			; déjà creusée

	; Au premier coup de pelle, les monstres se cachent (jamais autour de cette case)
	ld a,(wBalladeMamonoPlaced)
	or a
	jr nz,+
	inc a
	ld (wBalladeMamonoPlaced),a
	push bc
	ld a,b
	call @place
	pop bc
+
	ld a,b
	call @levelAt
	or a
	jp nz,@monster
	; Rien : son chiffre
	push bc
	ld a,SND_DIG
	call playSound
	pop bc
	ld a,b

;;
; La case c (numéro a) montre son chiffre (la somme des niveaux autour) ; rien autour : ses voisines
; se découvriront toutes seules (@flood)
@reveal:
	call @sum
	or a
	jr nz,+
	ld a,$01
	ld (wBalladeMamonoFlood),a
	ld a,MAMONO_SAND
	jp setTile
+
	ld a,(wBalladeMamonoTmp+2)
	add MAMONO_FIRST_NUMBER
	jp setTile

;;
; Les cases sans rien autour (le sable lisse) découvrent leurs voisines, quelques-unes par image ;
; un tour sans rien à découvrir : c'est fini
@flood:
	xor a
	ld (wBalladeMamonoScan),a
	ld a,MAMONO_FLOOD_PER_FRAME
	ld (wBalladeMamonoBudget),a
@floodCell:
	ld a,(wBalladeMamonoScan)
	call @positionOf
	ld h,>wRoomLayout
	ld l,a
	ld a,(hl)
	cp MAMONO_SAND
	jr nz,@floodNextCell
	ld a,(wBalladeMamonoScan)
	call @rowCol
	ld d,$ff
@floodRow:
	ld e,$ff
@floodCol:
	call @neighbourIndex
	jr c,@floodNext
	push bc
	ld (wBalladeMamonoTmp+1),a
	call @positionOf
	ld c,a
	ld h,>wRoomLayout
	ld l,a
	ld a,(hl)
	cp MAMONO_UNDUG
	jr nz,@floodSkip
	push de
	ld a,(wBalladeMamonoTmp+1)
	call @reveal
	pop de
	pop bc
	ld hl,wBalladeMamonoBudget
	dec (hl)
	ret z
	jr @floodNext
@floodSkip:
	pop bc
@floodNext:
	inc e
	ld a,e
	cp $02
	jr nz,@floodCol
	inc d
	ld a,d
	cp $02
	jr nz,@floodRow
@floodNextCell:
	ld hl,wBalladeMamonoScan
	inc (hl)
	ld a,(hl)
	cp MAMONO_CELLS
	jr c,@floodCell
	; un tour entier sans rien découvrir : plus rien à faire
	ld a,(wBalladeMamonoBudget)
	cp MAMONO_FLOOD_PER_FRAME
	ret nz
	xor a
	ld (wBalladeMamonoFlood),a
	ret

;;
; Un monstre déterré (a = son niveau, b = sa case, c = sa position)
@monster:
	ld (wBalladeMamonoTmp),a
	ld a,c
	ld (wBalladeMamonoShowPos),a
	ld a,b
	ld (wBalladeMamonoShowIndex),a
	; Son modèle, figé sur la case
	ld a,(wBalladeMamonoTmp)
	dec a
	ld hl,wBalladeMamonoSlots
	rst_addAToHl
	ld a,(hl)
	ld (wBalladeMamonoShowSlot),a
	or a
	jr z,+
	ld h,a
	ld l,Enemy.yh
	ld a,c
	and $f0
	add $08
	ld (hl),a
	ld l,Enemy.xh
	ld a,c
	swap a
	and $f0
	add $08
	ld (hl),a
	ld l,Enemy.visible
	set 7,(hl)
+
	ld a,MAMONO_SHOW_TIME
	ld (wBalladeMamonoShow),a
	; Le combat : plus fort que Link ?
	ld a,(wBalladeMamonoLevel)
	ld b,a
	ld a,(wBalladeMamonoTmp)
	sub b
	jr c,@beaten
	jr z,@beaten
	; Oui : un demi-cœur par niveau d'écart ; tout son niveau s'il est découvert à l'aveugle
	ld (wBalladeMamonoTmp+1),a
	ld a,(wBalladeMamonoShowIndex)
	call @anyOpenNeighbour
	ld a,(wBalladeMamonoTmp+1)
	jr nz,+
	ld a,(wBalladeMamonoTmp)
+
	add a			; quarts de cœur
	ld b,a
	ld a,(wLinkHealth)
	cp b
	jr z,@tooHurt
	jr c,@tooHurt
	ld a,b
	add a			; damageToApply : en huitièmes de cœur
	cpl
	inc a
	ld (w1Link.damageToApply),a
	ld a,$01
	ld (wBalladeMamonoHurt),a
	ld a,SND_DAMAGE_LINK
	call playSound
	jr @defeated

@beaten:
	; (pas le bruit de l'épée : Link n'a que la Pelle ; Denis)
	ld a,SND_KILLENEMY
	call playSound

@defeated:
	; Vaincu (même s'il a blessé Link) : l'expérience, autant que son niveau
	ld a,(wBalladeMamonoTmp)
	ld hl,wBalladeMamonoXp
	add (hl)
	ld (hl),a
	call @checkLevelUp
	ld hl,wBalladeMamonoLeft
	dec (hl)
	ret nz

	; Gagné : tous les monstres
	ld a,$02
	ld (wBalladeMamonoState),a
	ld a,SND_SOLVEPUZZLE
	call playSound
	; En Dur, sans une égratignure : le gros lot ; blessé : presque !
	ld a,(wBalladeCreuseLevel)
	or a
	ld bc,TX_5a48
	jp z,showText
	ld a,(wBalladeMamonoHurt)
	or a
	ld bc,TX_5b3e
	jp nz,@ringReward
	ld bc,TX_5b3f
	call showText
	call @ring
	; Le quart de cœur, la première fois (drapeau $80) ; ensuite, 30 rubis
	call getThisRoomFlags
	ld a,(hl)
	and $80
	ld bc,TREASURE_OBJECT_RUPEES_04	; (30 rubis)
	jr nz,+
	set 7,(hl)
	ldbc TREASURE_HEART_PIECE, $00
+
	call createTreasure
	ret nz
	ld de,w1Link.yh
	jp objectCopyPosition_rawAddress

; BALLADE: l'Anneau Tornade, la première victoire en Normal ou en Dur (Denis)
@ringReward:
	call showText
@ring:
	ld a,CHARGE_RING
	ld bc,TREASURE_OBJECT_RING_2b
	jp balladeRingReward

@tooHurt:
	; À bout de forces : perdu (Link garde un quart de cœur)
	ld a,$01
	ld (wLinkHealth),a
	ld a,$02
	ld (wBalladeMamonoState),a
	ld a,SND_EXPLOSION
	call playSound
	ld bc,TX_5a4d
	jp showText

;;
; Link monte de niveau quand il a assez d'expérience
@checkLevelUp:
	ld a,(wBalladeMamonoLevel)
	cp $05
	ret nc
	dec a
	ld b,a
	ld a,(wBalladeCreuseLevel)
	add a
	add a
	add b
	ld hl,@thresholds
	rst_addAToHl
	ld a,(wBalladeMamonoXp)
	cp (hl)
	ret c
	ld hl,wBalladeMamonoLevel
	inc (hl)
	ld a,SND_GETSEED
	call playSound
	ld bc,TX_5a44
	jp showText

;;
; Cache les monstres (a = la première case creusée : ni elle ni ses voisines, ni les quatre coins)
@place:
	ld (wBalladeMamonoFirst),a
	ld hl,MAMONO_LEVELS
	ld b,MAMONO_CELLS / 2
	xor a
	ld (wBalladeMamonoLeft),a
-
	ldi (hl),a
	dec b
	jr nz,-
	ld a,(wBalladeCreuseLevel)
	ld b,a
	add a
	add a
	add b
	ld hl,@counts
	rst_addAToHl
	ld b,$01		; b = le niveau
@placeLevel:
	ld a,(hl)
	or a
	jr z,@placeNextLevel
	ld c,a			; c = combien
@placeOne:
	push bc
	push hl
--
	call getRandomNumber
	and $7f
	cp MAMONO_CELLS
	jr nc,--
	; jamais dans les coins (Denis)
	or a
	jr z,--
	cp MAMONO_COLS - 1
	jr z,--
	cp MAMONO_CELLS - MAMONO_COLS
	jr z,--
	cp MAMONO_CELLS - 1
	jr z,--
	ld (wBalladeMamonoTmp),a
	call @nearFirst
	jr c,--
	ld a,(wBalladeMamonoTmp)
	call @levelAt
	or a
	jr nz,--
	pop hl
	pop bc
	push bc
	push hl
	ld a,(wBalladeMamonoTmp)
	call @setLevel
	pop hl
	pop bc
	ld a,(wBalladeMamonoLeft)
	inc a
	ld (wBalladeMamonoLeft),a
	dec c
	jr nz,@placeOne
@placeNextLevel:
	inc hl
	inc b
	ld a,b
	cp $06
	jr c,@placeLevel
	ret

;;
; @param	a	Une case
; @param[out]	cflag	Set si c'est la première case creusée ou une de ses voisines
@nearFirst:
	call @rowCol
	push bc
	ld a,(wBalladeMamonoFirst)
	call @rowCol
	pop hl
	ld a,h
	sub b
	inc a
	cp $03
	ret nc
	ld a,l
	sub c
	inc a
	cp $03
	ret

;;
; @param	a	Une case
; @param[out]	a	La somme des niveaux des monstres autour (aussi dans wBalladeMamonoTmp+2)
; Garde c et de.
@sum:
	push de
	push bc
	call @rowCol
	xor a
	ld (wBalladeMamonoTmp+2),a
	ld d,$ff
@sumRow:
	ld e,$ff
@sumCol:
	call @neighbourIndex
	jr c,@sumNext
	call @levelAt
	ld hl,wBalladeMamonoTmp+2
	add (hl)
	ld (hl),a
@sumNext:
	inc e
	ld a,e
	cp $02
	jr nz,@sumCol
	inc d
	ld a,d
	cp $02
	jr nz,@sumRow
	pop bc
	pop de
	ld a,(wBalladeMamonoTmp+2)
	ret

;;
; @param	a	Une case
; @param[out]	zflag	Unset si une case autour est déjà creusée
@anyOpenNeighbour:
	push de
	call @rowCol
	ld d,$ff
@openRow:
	ld e,$ff
@openCol:
	call @neighbourIndex
	jr c,@openNext
	call @positionOf
	ld h,>wRoomLayout
	ld l,a
	ld a,(hl)
	cp MAMONO_UNDUG
	jr nz,@openFound
@openNext:
	inc e
	ld a,e
	cp $02
	jr nz,@openCol
	inc d
	ld a,d
	cp $02
	jr nz,@openRow
	pop de
	xor a
	ret
@openFound:
	pop de
	or $01
	ret

;;
; La voisine (b + d, c + e) de la case (b, c) : son numéro
; @param[out]	a	Son numéro
; @param[out]	cflag	Set si c'est la case elle-même ou si elle est hors du champ
@neighbourIndex:
	ld a,d
	or e
	scf
	ret z
	ld a,b
	add d
	cp MAMONO_ROWS
	ccf
	ret c
	call @times13
	ld l,a
	ld a,c
	add e
	cp MAMONO_COLS
	ccf
	ret c
	add l
	ret

;;
; @param	a	Ligne
; @param[out]	a	Ligne x 13 (garde bc, de, l)
@times13:
	ld h,a
	add a
	add h
	add a
	add a
	add h
	ret

;;
; @param	a	Une case
; @param[out]	b	Sa ligne (0-7)
; @param[out]	c	Sa colonne (0-12)
@rowCol:
	ld b,$00
-
	cp MAMONO_COLS
	jr c,+
	sub MAMONO_COLS
	inc b
	jr -
+
	ld c,a
	ret

;;
; @param	a	Une case
; @param[out]	a	Sa position (YX) dans la salle (garde bc, de)
@positionOf:
	push bc
	call @rowCol
	ld a,b
	add $02
	swap a
	inc c
	or c
	pop bc
	ret

;;
; @param	c	Position (YX)
; @param[out]	a	La case
; @param[out]	cflag	Set hors du champ (garde bc, de)
@cellIndex:
	push bc
	ld a,c
	swap a
	and $0f
	sub $02
	cp MAMONO_ROWS
	jr nc,@outside
	call @times13
	ld b,a
	ld a,c
	and $0f
	dec a
	cp MAMONO_COLS
	jr nc,@outside
	add b
	pop bc
	and a
	ret
@outside:
	pop bc
	scf
	ret

;;
; @param	a	Une case
; @param[out]	a	Le niveau de son monstre (0 : rien) ; garde bc, de
@levelAt:
	srl a
	push af
	add <MAMONO_LEVELS
	ld l,a
	ld h,>MAMONO_LEVELS
	pop af
	ld a,(hl)
	jr nc,+
	swap a
+
	and $0f
	ret

;;
; @param	a	Une case
; @param	b	Le niveau de son monstre
@setLevel:
	srl a
	push af
	add <MAMONO_LEVELS
	ld l,a
	ld h,>MAMONO_LEVELS
	pop af
	ld a,(hl)
	jr c,+
	and $f0
	or b
	ld (hl),a
	ret
+
	and $0f
	ld c,a
	ld a,b
	swap a
	or c
	ld (hl),a
	ret

;;
; Un nuage de fumée sur la case c
@puffAt:
	push bc
	call getFreeInteractionSlot
	pop bc
	ret nz
	ld (hl),INTERAC_PUFF
	ld a,l
	and $c0
	add Object.yh - Object.enabled
	ld l,a
	ld a,c
	and $f0
	add $08
	ldi (hl),a
	inc l
	ld a,c
	swap a
	and $f0
	add $08
	ld (hl),a
	ret

@frontOffsets:
	.db $f0 $01 $10 $ff ; haut, droite, bas, gauche

; Les ennemis des niveaux 1 à 5
@monsterIds:
	.db ENEMY_KEESE, ENEMY_OCTOROK, ENEMY_MASKED_MOBLIN, ENEMY_SWORD_DARKNUT, ENEMY_LYNEL

; Combien de monstres de chaque niveau (1 à 5) : Facile, Dur
@counts:
	.db 6, 4, 3, 1, 0
	.db 8, 6, 5, 3, 2
; L'expérience pour passer aux niveaux 2, 3, 4, 5 : Facile, Dur
@thresholds:
	.db 5, 12, 20, $ff
	.db 7, 16, 28, 44
