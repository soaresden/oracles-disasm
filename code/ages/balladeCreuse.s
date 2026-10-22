; ==================================================================================================
; BALLADE: le Creuse-Rubis, le mini-jeu du forain (INTERAC_BALLADE_CREUSE, salle 1:ac).
;
; Un champ de sable de 6 x 4 cases (lignes 2-5, colonnes 1-6 de la salle) cache des bombes. Link
; creuse la case devant lui avec A ; chaque case sans bombe donne un rubis dont la couleur dit
; combien de bombes il y a autour : vert (aucune, 1 rubis), bleu (une, 5), rouge (deux, 20),
; doré (trois ou plus, 50). Une bombe : BOUM, c'est perdu. Toutes les cases sûres creusées :
; gagné, et la première victoire en Moyen et en Difficile donne un quart de cœur (drapeaux $40 et
; $80 de la salle).
;
; Le Mamono (l'autre jeu du forain, comme dans Xplosive Adventures, le jeu de Denis) : chaque
; case cache peut-être un monstre d'un niveau (1 Keese, 2 Octorok, 3 Moblin, 4 Darknut, 5 Lynel) ;
; une case vide montre la somme des niveaux des monstres autour (tools/make_mamono.py dessine ces
; chiffres et ces monstres dans le décor $68 de la plage). Un monstre vaincu donne autant
; d'expérience que son niveau, et Link monte de niveau ; un monstre plus fort que lui enlève un
; demi-cœur par niveau d'écart, et tout son niveau s'il est découvert à l'aveugle (aucune case
; ouverte autour). Gagné quand tous les monstres sont vaincus ; à bout de forces, perdu. Quarts de
; cœur : drapeaux $04 (Moyen) et $08 (Dur) de la salle.
;
; Le forain (INTERAC_BALLADE_NPC $08) propose ses deux jeux (TX_5a43 : Creuse, Mamono, Non) ; ce
; contrôleur voit ce texte se fermer et lit le choix (wSelectedTextOption), propose le niveau
; (TX_5a4b), fait payer et prépare le champ. Pendant la partie, la Lanterne ne marche pas
; (wInstrumentsDisabledCounter).
; ==================================================================================================

.define CREUSE_CELLS		24
.define CREUSE_UNDUG_TILE	$12	; sable meuble
.define CREUSE_DUG_TILE		$bf	; sable lisse
.define CREUSE_FIRST_ROW	2
.define CREUSE_FIRST_COL	1
.define MAMONO_FIRST_NUMBER	$40	; brique $40 + n : le chiffre n (tools/make_mamono.py)
.define MAMONO_FIRST_MONSTER	$58	; brique $58 + niveau : le monstre vaincu

; wBalladeCreuseState : 0 rien, 1 en jeu
; Interaction.var30 : 1 pendant que le texte du forain (TX_5a43) est affiché

;;
; Appelé à chaque image par INTERAC_BALLADE_CREUSE (d = l'interaction)
main:
	ld e,Interaction.state
	ld a,(de)
	or a
	jr nz,+
	; En arrivant dans la salle : pas de partie en cours (le champ est redessiné neuf)
	inc a
	ld (de),a
	xor a
	ld (wBalladeCreuseState),a
	ret
+
	; Les textes du forain : le jeu (TX_5a43), puis le niveau (TX_5a4b) ; on attend que le texte
	; se ferme pour lire le choix (Interaction.var30 : 1 le jeu, 2 le niveau)
	ld a,(wTextIsActive)
	or a
	jr z,@textClosed
	ld e,Interaction.var30
	ld a,(de)
	or a
	jr nz,@playing
	ld a,(wTextIndexH)
	cp >(TX_5a43 + $400)
	jr nz,@playing
	ld a,(wTextIndexL)
	cp <TX_5a43
	jr nz,@playing
	ld a,$01
	ld (de),a
	jr @playing
@textClosed:
	ld e,Interaction.var30
	ld a,(de)
	or a
	jr z,@playing
	ld b,a
	xor a
	ld (de),a
	dec b
	jp nz,@offer		; le niveau vient d'être choisi
	; Le jeu : 0 le Creuse-Rubis, 1 le Mamono, 2 non
	ld a,(wSelectedTextOption)
	cp $02
	ret nc
	ld (wBalladeCreuseMode),a
	ld bc,TX_5a4b
	call showText
	ld e,Interaction.var30
	ld a,$02
	ld (de),a
	ret

@playing:
	ld a,(wBalladeCreuseState)
	cp $01
	ret nz

	; En jeu : pas de Lanterne
	ld a,$02
	ld (wInstrumentsDisabledCounter),a

	ld a,(wTextIsActive)
	or a
	ret nz
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
	ld hl,@frontOffsets
	rst_addAToHl
	ld a,c
	add (hl)
	ld c,a			; c = position de la case (YX)
	call @cellIndex
	ret c			; hors du champ
	ld b,a			; b = numéro de la case
	ld a,(wBalladeCreuseMode)
	or a
	jp nz,@mamonoDig

	ld hl,wBalladeCreuseDug
	call @testBit
	ret nz			; déjà creusée
	ld hl,wBalladeCreuseDug
	ld a,b
	call @setBit

	push bc
	ld a,CREUSE_DUG_TILE
	call setTile
	pop bc

	ld hl,wBalladeCreuseMines
	ld a,b
	call @testBit
	jr nz,@boom

	; Pas de bombe : un rubis de la couleur du nombre de bombes autour
	call @countNeighbours
	ld hl,@rupeeDrops
	rst_addAToHl
	ld a,(hl)
	push bc
	call @dropAt
	pop bc
	ld a,SND_DIG
	call playSound

	ld hl,wBalladeCreuseLeft
	dec (hl)
	ret nz

	; Gagné : toutes les cases sûres sont creusées
@win:
	xor a
	ld (wBalladeCreuseState),a
	ld a,SND_SOLVEPUZZLE
	call playSound
	ld bc,TX_5a48
	call showText
	; Le quart de cœur : Moyen (drapeau $40), Difficile (drapeau $80), la première fois
	ld a,(wBalladeCreuseLevel)
	or a
	ret z
	dec a
	ld b,$40
	jr z,+
	ld b,$80
+
	; (le Mamono : drapeaux $04 et $08)
	ld a,(wBalladeCreuseMode)
	or a
	jr z,+
	swap b
+
	call getThisRoomFlags
	ld a,(hl)
	and b
	ret nz
	ld a,(hl)
	or b
	ld (hl),a
	ldbc TREASURE_HEART_PIECE, $00
	call createTreasure
	ret nz
	ld de,w1Link.yh
	jp objectCopyPosition_rawAddress

@boom:
	; Une bombe : l'explosion, deux cœurs en moins, perdu
	xor a
	ld (wBalladeCreuseState),a
	push bc
	call getFreeInteractionSlot
	pop bc
	jr nz,+
	ld (hl),INTERAC_EXPLOSION
	call @setPositionHl
+
	ld a,SND_EXPLOSION
	call playSound
	ld a,$f8
	ld (w1Link.damageToApply),a
	ld bc,TX_5a47
	jp showText

;;
; Le forain vient de proposer une partie : le choix (0 Facile, 1 Moyen, 2 Difficile, 3 Non)
@offer:
	ld a,(wSelectedTextOption)
	cp $03
	ret nc			; « Non » : rien ne change
	push af
	xor a
	ld (wBalladeCreuseState),a
	pop af
	ld (wBalladeCreuseLevel),a
	ld hl,@prices
	rst_addAToHl
	ld a,(hl)
	push af
	call cpRupeeValue
	jr z,+
	pop af
	ld bc,TX_5a45		; pas assez de rubis
	jp showText
+
	pop af
	call removeRupeeValue

	; Le champ : tout est à creuser
	xor a
	ld hl,wBalladeCreuseMines
	ldi (hl),a
	ldi (hl),a
	ldi (hl),a
	ldi (hl),a		; wBalladeCreuseDug
	ldi (hl),a
	ldi (hl),a
	ld b,CREUSE_CELLS
-
	push bc
	ld a,b
	dec a
	call @cellPosition
	ld a,CREUSE_UNDUG_TILE
	call setTile
	pop bc
	dec b
	jr nz,-

	ld a,(wBalladeCreuseMode)
	or a
	jp nz,@mamonoStart

	; Les bombes, au hasard
	ld a,(wBalladeCreuseLevel)
	ld hl,@mineCounts
	rst_addAToHl
	ld a,(hl)
	ld c,a
	ld a,CREUSE_CELLS
	sub c
	ld (wBalladeCreuseLeft),a
--
	call getRandomNumber
	and $1f
	cp CREUSE_CELLS
	jr nc,--
	ld b,a
	ld hl,wBalladeCreuseMines
	call @testBit
	jr nz,--
	ld hl,wBalladeCreuseMines
	ld a,b
	call @setBit
	dec c
	jr nz,--

	ld a,$01
	ld (wBalladeCreuseState),a
	; Marine explique les couleurs
	ld bc,TX_5a46
	jp showText

;;
; @param	c	Position (YX) d'une case de la salle
; @param[out]	a	Numéro de la case dans le champ
; @param[out]	cflag	Set si la case est hors du champ (bc, de gardés)
@cellIndex:
	push bc
	ld a,c
	swap a
	and $0f
	sub CREUSE_FIRST_ROW
	cp $04
	jr nc,@outside
	ld b,a			; la ligne
	ld a,c
	and $0f
	sub CREUSE_FIRST_COL
	cp $06
	jr nc,@outside
	ld c,a			; la colonne
	ld a,b
	add a
	add b
	add a			; 6 x ligne
	add c
	pop bc
	or a			; (pas de retenue)
	ret
@outside:
	pop bc
	scf
	ret

;;
; @param	a	Numéro de la case
; @param[out]	c	Sa position (YX)
@cellPosition:
	ld b,$00
-
	cp $06
	jr c,+
	sub $06
	inc b
	jr -
+
	add CREUSE_FIRST_COL
	ld c,a
	ld a,b
	add CREUSE_FIRST_ROW
	swap a
	or c
	ld c,a
	ret

;;
; @param	a	Numéro de bit (0-23)
; @param	hl	Le masque (3 octets)
@setBit:
	call @bitAddress
	or (hl)
	ld (hl),a
	ret

;;
; @param	b	Numéro de bit (0-23)
; @param	hl	Le masque (3 octets)
; @param[out]	zflag	Set si le bit est à 0
@testBit:
	ld a,b
	call @bitAddress
	and (hl)
	ret

;;
; @param	a	Numéro de bit ; hl : le masque
; @param[out]	a	Le masque du bit ; hl : son octet
@bitAddress:
	push bc
	ld c,a
	srl a
	srl a
	srl a
	rst_addAToHl
	ld a,c
	and $07
	ld b,a
	ld a,$01
	inc b
-
	dec b
	jr z,+
	add a
	jr -
+
	pop bc
	ret

;;
; Le nombre de bombes autour d'une case (les 8 voisines dans le champ), 3 au plus
; @param	c	Sa position (YX)
; @param[out]	a	0 à 3 (bc, de gardés)
@countNeighbours:
	push bc
	push de
	ld e,$00		; le compte
	ld hl,@neighbourOffsets
-
	ldi a,(hl)
	cp $80
	jr z,@counted
	push hl
	push bc
	add c			; la position de la voisine (hors du champ : ignorée par @cellIndex)
	ld c,a
	call @cellIndex
	jr c,+
	ld b,a
	ld hl,wBalladeCreuseMines
	call @testBit
	jr z,+
	inc e
+
	pop bc
	pop hl
	jr -
@counted:
	ld a,e
	pop de
	pop bc
	cp $04
	ret c
	ld a,$03
	ret

; Décalages des 8 voisines (en position YX : ±$10 par ligne, ±1 par colonne)
@neighbourOffsets:
	.db $ef $f0 $f1 $ff $01 $0f $10 $11 $80

;;
; Crée l'objet tombé a (PART_ITEM_DROP) au centre de la case c
@dropAt:
	ld b,a
	push bc
	call getFreePartSlot
	pop bc
	ret nz
	ld (hl),PART_ITEM_DROP
	inc l
	ld (hl),b
	; (position : comme pour l'explosion)

;;
; Place l'objet hl au centre de la case c
@setPositionHl:
	ld a,l
	and $c0
	ld l,a
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

; Rubis selon le nombre de bombes autour : vert, bleu, rouge, doré
@rupeeDrops:
	.db ITEM_DROP_1_RUPEE, ITEM_DROP_5_RUPEES, ITEM_DROP_0a, ITEM_DROP_0b

; Facile, Moyen, Difficile
@prices:
	.db RUPEEVAL_010, RUPEEVAL_020, RUPEEVAL_030
@mineCounts:
	.db 4, 6, 8

; ==================================================================================================
; Le Mamono
; ==================================================================================================

;;
; Une partie de Mamono commence : aucun monstre placé (ils le seront au premier coup de pelle, loin
; de la case creusée), Link au niveau 1
@mamonoStart:
	ld hl,wBalladeMamonoLevels
	ld b,CREUSE_CELLS
	xor a
-
	ldi (hl),a
	dec b
	jr nz,-
	ld (wBalladeMamonoXp),a
	ld (wBalladeMamonoPlaced),a
	inc a
	ld (wBalladeMamonoLevel),a
	ld (wBalladeCreuseState),a
	ld bc,TX_5a4a		; le forain explique, Marine conseille
	jp showText

;;
; Link creuse la case b (position c)
@mamonoDig:
	ld hl,wBalladeCreuseDug
	call @testBit
	ret nz			; déjà ouverte
	ld a,(wBalladeMamonoPlaced)
	or a
	call z,@mamonoPlace
	ld hl,wBalladeCreuseDug
	ld a,b
	call @setBit

	ld hl,wBalladeMamonoLevels
	ld a,b
	rst_addAToHl
	ld a,(hl)
	or a
	jr nz,@mamonoMonster

	; Pas de monstre : le chiffre, la somme des niveaux autour (rien : le sable lisse)
	call @mamonoSum
	or a
	ld a,CREUSE_DUG_TILE
	jr z,++
	ld a,e
	cp 20
	jr c,+
	ld a,19
+
	add MAMONO_FIRST_NUMBER
++
	push bc
	call setTile
	pop bc
	ld a,SND_DIG
	jp playSound

;;
; Un monstre de niveau a (case b, position c)
@mamonoMonster:
	ld (wBalladeMamonoTmp),a
	ld hl,wBalladeMamonoLevel
	sub (hl)
	jr c,@mamonoBeaten
	jr z,@mamonoBeaten
	; Plus fort que Link : un demi-cœur par niveau d'écart, tout son niveau s'il est découvert à
	; l'aveugle (aucune case ouverte autour)
	ld e,a
	call @mamonoAnyOpenNeighbour
	jr nz,+
	ld a,(wBalladeMamonoTmp)
	ld e,a
+
	ld a,e
	add a
	ld e,a			; quarts de cœur
	ld a,(wLinkHealth)
	cp e
	jr z,@mamonoTooHurt
	jr c,@mamonoTooHurt
	ld a,e
	add a			; damageToApply : en huitièmes de cœur
	cpl
	inc a
	ld (w1Link.damageToApply),a

@mamonoBeaten:
	; Le monstre vaincu reste dessiné dans le sable
	ld a,(wBalladeMamonoTmp)
	add MAMONO_FIRST_MONSTER
	push bc
	call setTile
	pop bc
	ld a,SND_KILLENEMY
	call playSound
	; L'expérience : autant que son niveau
	ld a,(wBalladeMamonoTmp)
	ld hl,wBalladeMamonoXp
	add (hl)
	ld (hl),a
	call @mamonoCheckLevelUp
	ld hl,wBalladeCreuseLeft
	dec (hl)
	jp z,@win
	ret

@mamonoTooHurt:
	; À bout de forces : perdu (Link garde un quart de cœur)
	ld a,$01
	ld (wLinkHealth),a
	xor a
	ld (wBalladeCreuseState),a
	ld a,(wBalladeMamonoTmp)
	add MAMONO_FIRST_MONSTER
	push bc
	call setTile
	pop bc
	ld a,SND_EXPLOSION
	call playSound
	ld bc,TX_5a4d
	jp showText

;;
; Le niveau de Link selon son expérience (les seuils du niveau de jeu) ; « Niveau supérieur ! »
@mamonoCheckLevelUp:
	push bc
	ld a,(wBalladeCreuseLevel)
	ld b,a
	add a
	add b
	add a			; 6 x le niveau de jeu
	ld hl,@mamonoThresholds
	rst_addAToHl
	ld a,(wBalladeMamonoXp)
	ld c,a
	ld b,$01
-
	ldi a,(hl)
	cp $ff
	jr z,+
	cp c
	jr z,++
	jr nc,+
++
	inc b
	jr -
+
	ld a,(wBalladeMamonoLevel)
	cp b
	ld a,b
	ld (wBalladeMamonoLevel),a
	pop bc
	ret nc			; pas de nouveau niveau
	ld a,SND_GETSEED
	call playSound
	ld bc,TX_5a44
	jp showText

;;
; Place les monstres, loin de la case b (ni elle ni ses voisines) ; garde bc
@mamonoPlace:
	push bc
	ld a,$01
	ld (wBalladeMamonoPlaced),a
	; Les cases interdites : b et ses voisines
	xor a
	ld hl,wBalladeMamonoBanned
	ldi (hl),a
	ldi (hl),a
	ld (hl),a
	ld hl,wBalladeMamonoBanned
	ld a,b
	call @setBit
	ld hl,@neighbourOffsets
-
	ldi a,(hl)
	cp $80
	jr z,+
	push hl
	push bc
	add c
	ld c,a
	call @cellIndex
	jr c,++
	ld hl,wBalladeMamonoBanned
	call @setBit
++
	pop bc
	pop hl
	jr -
+
	; Les monstres de chaque niveau : 5 nombres par niveau de jeu
	ld a,(wBalladeCreuseLevel)
	ld b,a
	add a
	add a
	add b			; 5 x le niveau de jeu
	ld hl,@mamonoCounts
	rst_addAToHl
	ld c,$01		; le niveau du monstre
	xor a
	ld (wBalladeCreuseLeft),a
--
	ldi a,(hl)
	push hl
	ld e,a			; combien de monstres de ce niveau
	ld hl,wBalladeCreuseLeft
	add (hl)
	ld (hl),a
	inc e
---
	dec e
	jr z,+++
-
	call getRandomNumber
	and $1f
	cp CREUSE_CELLS
	jr nc,-
	ld b,a
	ld hl,wBalladeMamonoBanned
	call @testBit
	jr nz,-
	ld hl,wBalladeMamonoLevels
	ld a,b
	rst_addAToHl
	ld a,(hl)
	or a
	jr nz,-
	ld (hl),c
	jr ---
+++
	pop hl
	inc c
	ld a,c
	cp $06
	jr c,--
	pop bc
	ret

;;
; La somme des niveaux des monstres autour de la position c ; garde bc
; @param[out]	a, e	La somme
@mamonoSum:
	push bc
	ld e,$00
	ld hl,@neighbourOffsets
-
	ldi a,(hl)
	cp $80
	jr z,+
	push hl
	push bc
	add c
	ld c,a
	call @cellIndex
	jr c,++
	ld hl,wBalladeMamonoLevels
	rst_addAToHl
	ld a,(hl)
	add e
	ld e,a
++
	pop bc
	pop hl
	jr -
+
	pop bc
	ld a,e
	ret

;;
; Une case ouverte autour de la position c ? ; garde bc et e
; @param[out]	zflag	Set si aucune
@mamonoAnyOpenNeighbour:
	push bc
	push de
	ld e,$00
	ld hl,@neighbourOffsets
-
	ldi a,(hl)
	cp $80
	jr z,+
	push hl
	push bc
	add c
	ld c,a
	call @cellIndex
	jr c,++
	ld b,a
	ld hl,wBalladeCreuseDug
	call @testBit
	jr z,++
	inc e
++
	pop bc
	pop hl
	jr -
+
	ld a,e
	pop de
	pop bc
	or a
	ret

; Le nombre de monstres de chaque niveau (1 à 5), selon le niveau de jeu (Facile, Moyen, Dur)
@mamonoCounts:
	.db 2, 2, 1, 0, 0
	.db 3, 2, 2, 0, 0
	.db 3, 2, 2, 1, 1

; L'expérience pour passer au niveau 2, 3, ... ($ff : plus de niveau), comme dans Xplosive
; Adventures : pour chaque niveau L, le cumul précédent + 70 % de (monstres de niveau L x L)
@mamonoThresholds:
	.db 2, 5, 9, $ff, $ff, $ff
	.db 3, 6, 12, $ff, $ff, $ff
	.db 3, 6, 12, 16, 21, $ff
