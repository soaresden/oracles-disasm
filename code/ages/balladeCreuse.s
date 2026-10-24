; ==================================================================================================
; BALLADE: le Creuse-Rubis, le mini-jeu du forain (INTERAC_BALLADE_CREUSE, salle 1:ac).
;
; Un champ de sable de 6 x 4 cases (lignes 2-5, colonnes 1-6 de la salle) cache des bombes. Link
; creuse la case devant lui avec A ; chaque case sans bombe montre le nombre de bombes autour (les
; chiffres 1 à 8 sur le sable, tools/make_mamono.py) et donne un rubis : vert (aucune ou une, 1
; rubis), bleu (deux, 5), rouge (trois ou plus, 20) ; Denis : on gagnait trop. Une bombe : BOUM, c'est
; perdu. Toutes les cases sûres creusées : gagné. Denis : les bombes ne se placent qu'au premier coup,
; jamais sur cette case ni autour, ni dans les quatre coins ; une case sans bombe autour découvre
; ses voisines toute seule (@flood, 4 par image ; leurs rubis vont droit dans la bourse). Deux niveaux (Denis) : Facile, Difficile ; la
; première victoire en Difficile donne un quart de cœur (drapeau $80 de la salle).
;
; B sur une case pas creusée : un drapeau (Denis : « ici, une bombe ! » ; B de nouveau l'enlève) ; une
; case avec un drapeau ne se creuse pas.
;
; Le forain (INTERAC_BALLADE_NPC $08) propose ses trois jeux (TX_5a43 : Creuse, Mamono, Lynels,
; Non) ; ce contrôleur voit ce texte se fermer et lit le choix (wSelectedTextOption), propose le
; niveau (TX_5a4b), fait payer et prépare le champ. Le Mamono se joue dans l'arène du forain (5:ea,
; code/ages/balladeMamono.s) et le Labyrinthe des Lynels en 5:e9 (code/ages/balladePac.s) : ce
; contrôleur y envoie Link. Pendant la partie, la Lanterne ne marche pas
; (wInstrumentsDisabledCounter).
; ==================================================================================================

.define CREUSE_CELLS		24
.define CREUSE_UNDUG_TILE	$12	; sable meuble
.define CREUSE_DUG_TILE		$bf	; sable lisse
.define CREUSE_FIRST_NUMBER	$40	; brique $40 + n : le chiffre n (1-8), sur le sable
.define CREUSE_FLAG_TILE	$49	; le drapeau du joueur, sur le sable meuble
.define CREUSE_FIRST_ROW	2
.define CREUSE_FIRST_COL	1

; wBalladeCreuseState : 0 rien, 1 en jeu
; Interaction.var30 : 1 pendant que le texte du forain (TX_5a43) est affiché

;;
; Pendant les jeux du forain (Denis) : rien que la Pelle (sur A ; le Creuse-Rubis, le Mamono : A
; creuse) ou rien que l'épée (sur B, à son niveau ; les Lynels). Les objets d'avant sont gardés
; (wBalladeLoadoutA/B) et reviennent la partie finie, ou en changeant de salle (objectLoading.s) ;
; pas d'inventaire pendant ce temps (bank2.s) et la Pelle ne sert pas (parentItemUsage.s). Appelés
; à chaque image du jeu ; d est gardé.
setShovelLoadout:
	ld b,$01
	jr setLoadout

setSwordLoadout:
	ld b,$02

setLoadout:
	; On ne quitte pas la partie (Denis : on pouvait s'en aller avec la Pelle)
	ld a,$01
	ld (wDisableScreenTransitions),a
	ld (wWarpsDisabled),a
	ld hl,wBalladeLoadout
	ld a,(hl)
	cp b
	ret z
	or a
	jr nz,+
	ld a,(wInventoryA)
	ld (wBalladeLoadoutA),a
	ld a,(wInventoryB)
	ld (wBalladeLoadoutB),a
+
	ld (hl),b
	dec b
	jr nz,@sword
	ld a,ITEM_SHOVEL
	ld (wInventoryA),a
	xor a
	ld (wInventoryB),a
	jr @refresh
@sword:
	xor a
	ld (wInventoryA),a
	ld a,TREASURE_SWORD
	call checkTreasureObtained
	ld a,ITEM_SWORD
	jr c,+
	xor a
+
	ld (wInventoryB),a
@refresh:
	ld a,$ff
	ld (wStatusBarNeedsRefresh),a
	ret

;;
; Les objets d'avant reviennent (s'il y a lieu)
restoreLoadout:
	ld hl,wBalladeLoadout
	ld a,(hl)
	or a
	ret z
	ld (hl),$00
	xor a
	ld (wDisableScreenTransitions),a
	ld (wWarpsDisabled),a
	ld a,(wBalladeLoadoutA)
	ld (wInventoryA),a
	ld a,(wBalladeLoadoutB)
	ld (wInventoryB),a
	ld a,$ff
	ld (wStatusBarNeedsRefresh),a
	ret

;;
; Appelé à chaque image par INTERAC_BALLADE_CREUSE (d = l'interaction)
main:
	; En jeu : rien que la Pelle
	ld a,(wBalladeCreuseState)
	cp $01
	call z,setShovelLoadout
	ld a,(wBalladeCreuseState)
	cp $01
	call nz,restoreLoadout
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
	jr z,@gameChosen
	dec b
	jp z,@offer		; le niveau vient d'être choisi
	; Le Labyrinthe des Lynels (TX_5a4c) : « J'y vais » -> la salle 5:e9 (code/ages/balladePac.s)
	ld a,(wSelectedTextOption)
	or a
	ret nz
	ld a,$85
	ld (wWarpDestGroup),a
	ld a,$e9
	ld (wWarpDestRoom),a
	ld a,$77
	ld (wWarpDestPos),a
	xor a
	ld (wWarpTransition),a
	ld a,$03 ; fondu
	ld (wWarpTransition2),a
	ld a,SND_ENTERCAVE
	jp playSound

@gameChosen:
	; Le jeu : 0 le Creuse-Rubis, 1 le Mamono, 2 le Labyrinthe des Lynels, 3 non
	ld a,(wSelectedTextOption)
	cp $02
	jr z,@lynels
	ret nc
	ld (wBalladeCreuseMode),a
	ld bc,TX_5a4b
	call showText
	ld e,Interaction.var30
	ld a,$02
	ld (de),a
	ret

@lynels:
	ld bc,TX_5a4c
	call showText
	ld e,Interaction.var30
	ld a,$03
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
	ld a,(wBalladeMamonoFlood)
	or a
	jp nz,@flood
	ld a,(wGameKeysJustPressed)
	bit BTN_BIT_B,a
	jp nz,@flag
	and BTN_A
	ret z

	call @frontCell
	ret c			; hors du champ
	ld b,a			; b = numéro de la case
	; (un drapeau : on ne creuse pas là)
	ld h,>wRoomLayout
	ld l,c
	ld a,(hl)
	cp CREUSE_FLAG_TILE
	ret z

	ld hl,wBalladeCreuseDug
	call @testBit
	ret nz			; déjà creusée
	; Le premier coup : les bombes se placent maintenant
	ld hl,wBalladeCreuseDug
	ldi a,(hl)
	or (hl)
	inc hl
	or (hl)
	call z,@placeMines
	ld hl,wBalladeCreuseDug
	ld a,b
	call @setBit

	ld hl,wBalladeCreuseMines
	call @testBit
	jr z,+
	push bc
	ld a,CREUSE_DUG_TILE
	call setTile
	pop bc
	jp @boom
+
	; Pas de bombe : le chiffre, un rubis qui tombe
	ld e,$01
	call @reveal
	ld a,SND_DIG
	call playSound
	ld a,(wBalladeCreuseLeft)
	or a
	ret nz

	; Gagné : toutes les cases sûres sont creusées
@win:
	xor a
	ld (wBalladeCreuseState),a
	ld a,SND_SOLVEPUZZLE
	call playSound
	ld bc,TX_5a48
	call showText
	; BALLADE: l'Anneau Caméléon, la première victoire (Denis)
	ld a,BALLADE_CAMELEON_RING
	ld bc,TREASURE_OBJECT_RING_2c
	call balladeRingReward
	; Le quart de cœur : en Difficile (drapeau $80), la première fois
	ld a,(wBalladeCreuseLevel)
	or a
	ret z
	ld b,$80
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

;;
; Découvre la case b (position c), qui n'a pas de bombe : le nombre de bombes autour (sable lisse
; s'il n'y en a pas : ses voisines se découvriront toutes seules, @flood), un rubis
; @param	e	1 : le rubis tombe sur la case ; 0 : il va droit dans la bourse
@reveal:
	call @countNeighbours
	push af
	ld a,(wBalladeMamonoTmp+2)
	or a
	jr nz,+
	ld a,$01
	ld (wBalladeMamonoFlood),a
	ld a,CREUSE_DUG_TILE
	jr ++
+
	add CREUSE_FIRST_NUMBER
++
	push bc
	push de
	call setTile
	pop de
	pop bc
	pop af
	dec e
	jr nz,+
	ld hl,@rupeeDrops
	rst_addAToHl
	ld a,(hl)
	push bc
	call @dropAt
	pop bc
	jr ++
+
	ld hl,@rupeeValues
	rst_addAToHl
	push bc
	ld c,(hl)
	ld a,TREASURE_RUPEES
	call giveTreasure
	pop bc
++
	ld hl,wBalladeCreuseLeft
	dec (hl)
	ret

;;
; Les cases vides découvrent leurs voisines (au plus 4 par image : setTile)
@flood:
	ld a,$04
	ld (wBalladeMamonoBudget),a
	ld b,$00
@floodCell:
	push bc
	ld hl,wBalladeCreuseDug
	call @testBit
	jr z,@floodNext
	ld hl,wBalladeCreuseMines
	call @testBit
	jr nz,@floodNext
	ld a,b
	call @cellPosition
	call @countNeighbours
	ld a,(wBalladeMamonoTmp+2)
	or a
	jr nz,@floodNext
	ld hl,@neighbourOffsets
@floodNeighbour:
	ldi a,(hl)
	cp $80
	jr z,@floodNext
	push hl
	push bc
	add c
	ld c,a
	call @cellIndex
	jr c,@floodSkip
	ld b,a
	ld hl,wBalladeCreuseDug
	call @testBit
	jr nz,@floodSkip
	ld hl,wBalladeCreuseDug
	ld a,b
	call @setBit
	ld e,$00
	call @reveal
	ld hl,wBalladeMamonoBudget
	dec (hl)
	jr nz,@floodSkip
	; La suite à la prochaine image
	pop bc
	pop hl
	pop bc
	ret
@floodSkip:
	pop bc
	pop hl
	jr @floodNeighbour
@floodNext:
	pop bc
	inc b
	ld a,b
	cp CREUSE_CELLS
	jr c,@floodCell
	; Plus rien à découvrir
	xor a
	ld (wBalladeMamonoFlood),a
	ld a,(wBalladeCreuseLeft)
	or a
	ret nz
	jp @win

;;
; Le premier coup (case b) : les bombes, au hasard, jamais sur cette case ni autour, ni dans les
; coins (bc gardés)
@placeMines:
	push bc
	ld a,b
	ld (wBalladeMamonoTmp),a
	ld a,(wBalladeCreuseLevel)
	ld hl,@mineCounts
	rst_addAToHl
	ld c,(hl)
--
	call getRandomNumber
	and $1f
	cp CREUSE_CELLS
	jr nc,--
	or a
	jr z,--
	cp $05
	jr z,--
	cp CREUSE_CELLS - 6
	jr z,--
	cp CREUSE_CELLS - 1
	jr z,--
	ld b,a
	call @nearFirst
	jr z,--
	ld hl,wBalladeCreuseMines
	call @testBit
	jr nz,--
	ld hl,wBalladeCreuseMines
	ld a,b
	call @setBit
	dec c
	jr nz,--
	pop bc
	ret

;;
; @param	a	Une case
; @param[out]	zflag	Set si c'est la case du premier coup (wBalladeMamonoTmp) ou une voisine
; (bc, de gardés)
@nearFirst:
	push bc
	push de
	call @cellPosition
	ld e,c
	ld a,(wBalladeMamonoTmp)
	call @cellPosition
	ld a,e
	sub c
	jr z,@nearYes
	ld b,a
	ld hl,@neighbourOffsets
-
	ldi a,(hl)
	cp $80
	jr z,@nearNo
	cp b
	jr nz,-
@nearYes:
	pop de
	pop bc
	xor a
	ret
@nearNo:
	pop de
	pop bc
	or a
	ret

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
; Le forain vient de proposer une partie : le choix (0 Facile, 1 Difficile, 2 Non)
@offer:
	ld a,(wSelectedTextOption)
	cp $02
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
	ld a,(wBalladeCreuseMode)
	or a
	jp nz,@mamonoGo

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

	; Les bombes : au premier coup (@placeMines)
	ld a,(wBalladeCreuseLevel)
	ld hl,@mineCounts
	rst_addAToHl
	ld c,(hl)
	ld a,CREUSE_CELLS
	sub c
	ld (wBalladeCreuseLeft),a
	xor a
	ld (wBalladeMamonoFlood),a

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
	ld (wBalladeMamonoTmp+2),a	; (le vrai compte, pour le chiffre)
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

;;
; B : un drapeau sur la case devant Link, pas creusée ; ou on l'enlève
@flag:
	call @frontCell
	ret c
	ld h,>wRoomLayout
	ld l,c
	ld a,(hl)
	ld b,CREUSE_FLAG_TILE
	cp CREUSE_UNDUG_TILE
	jr z,+
	cp CREUSE_FLAG_TILE
	ret nz			; creusée
	ld b,CREUSE_UNDUG_TILE
+
	ld a,SND_MENU_MOVE
	call playSound
	ld a,b
	jp setTile

;;
; La case devant Link : la sienne, plus un pas dans la direction où il regarde
; @param[out]	a	son numéro
; @param[out]	c	sa position (YX)
; @param[out]	cflag	hors du champ
@frontCell:
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
	ld c,a
	jp @cellIndex

; Rubis selon le nombre de bombes autour (0, 1, 2, 3 ou plus) : vert, vert, bleu, rouge
@rupeeDrops:
	.db ITEM_DROP_1_RUPEE, ITEM_DROP_1_RUPEE, ITEM_DROP_5_RUPEES, ITEM_DROP_0a
; (les mêmes, droit dans la bourse : les cases découvertes toutes seules)
@rupeeValues:
	.db RUPEEVAL_001, RUPEEVAL_001, RUPEEVAL_005, RUPEEVAL_020

; Facile, Difficile
@prices:
	.db RUPEEVAL_010, RUPEEVAL_030
@mineCounts:
	.db 4, 8

;;
; Le Mamono : dans l'arène du forain (5:ea, code/ages/balladeMamono.s lit wBalladeCreuseLevel)
@mamonoGo:
	ld a,$85
	ld (wWarpDestGroup),a
	ld a,$ea
	ld (wWarpDestRoom),a
	ld a,$17
	ld (wWarpDestPos),a
	xor a
	ld (wWarpTransition),a
	ld a,$03 ; fondu
	ld (wWarpTransition2),a
	ld a,SND_ENTERCAVE
	jp playSound
