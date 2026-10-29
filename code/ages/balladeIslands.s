; ==================================================================================================
; BALLADE: pas d'une île à l'autre par les bords de l'écran. Nos îles sont voisines sur la carte
; d'Ages : à pied ou à la nage, on passait dans l'île d'à côté (Denis : de Hameau-Grelot 1:32 vers le
; bas, la montagne des Échos 1:42 ; « quand on sait nager on peut se balader partout »). Ni dans un
; mur ou l'eau de la salle d'à côté (Denis, 29/10 : « si on passe un écran en faisant une direction,
; on peut finir dans l'eau ou bloqué »). Appelé par bank1.s (le changement d'écran, dehors) ; les
; tables viennent de tools/make_islands.py.
; ==================================================================================================
.include "code/ages/balladeIslandTable.s"

;;
; @param	c	La direction du changement d'écran (DIR_UP, DIR_RIGHT, DIR_DOWN, DIR_LEFT)
; @param[out]	b	1 si le changement est refusé : la salle d'à côté n'est pas de la même île ; ou
;			Link y arriverait dans un mur (il y resterait coincé), ou dans l'eau profonde
;			sans les Palmes (il s'y noierait, et reviendrait... dans l'eau) : Denis, 29/10
blockedCrossing:
	ld b,$00
	ld a,(wActiveGroup)
	cp $02
	ret nc
	; l'île de cette salle (aucune : pas de frontière)
	ld a,(wActiveRoom)
	ld e,a
	ld hl,islandOfRoom
	rst_addAToHl
	ld a,(hl)
	or a
	jr z,@edge
	push af
	; la salle d'à côté
	ld a,c
	and $03
	ld hl,@moves
	rst_addAToHl
	ld a,e
	add (hl)
	ld hl,islandOfRoom
	rst_addAToHl
	pop af
	cp (hl)
	jr z,@edge
@refuse:
	ld b,$01
	ret

	; La case d'arrivée (edgeBlocked, edgeWater : tools/make_islands.py) : l'entrée
	; ((groupe * 256 + salle) * 4 + direction) * 2
@edge:
	ld a,(wActiveGroup)
	ld h,a
	ld l,e
	add hl,hl
	add hl,hl
	ld a,c
	and $03
	or l
	ld l,a
	add hl,hl
	push hl
	ld de,edgeBlocked
	add hl,de
	call @linkBit
	pop hl
	jr nz,@refuse
	ld de,edgeWater
	add hl,de
	call @linkBit
	ret z
	ld a,TREASURE_FLIPPERS
	call checkTreasureObtained
	ret c
	jr @refuse

;;
; @param	hl	Le masque des places du bord (un mot)
; @param	c	La direction
; @param[out]	zflag	nz si le bit de la place de Link est mis (sa colonne en montant ou en
;			descendant, sa rangée à droite ou à gauche)
@linkBit:
	ldi a,(hl)
	ld h,(hl)
	ld l,a
	ld a,c
	and $01
	ld a,(w1Link.xh)
	jr z,+
	ld a,(w1Link.yh)
+
	swap a
	and $0f
	jr z,++
-
	srl h
	rr l
	dec a
	jr nz,-
++
	bit 0,l
	ret

@moves:
	.db $f0 $01 $10 $ff
