; ==================================================================================================
; BALLADE: pas d'une île à l'autre par les bords de l'écran. Nos îles sont voisines sur la carte
; d'Ages : à pied ou à la nage, on passait dans l'île d'à côté (Denis : de Hameau-Grelot 1:32 vers le
; bas, la montagne des Échos 1:42 ; « quand on sait nager on peut se balader partout »). Appelé par
; bank1.s (le changement d'écran, dehors) ; la table vient de tools/make_islands.py.
; ==================================================================================================
.include "code/ages/balladeIslandTable.s"

;;
; @param	c	La direction du changement d'écran (DIR_UP, DIR_RIGHT, DIR_DOWN, DIR_LEFT)
; @param[out]	b	1 si la salle d'à côté n'est pas de la même île (le changement est refusé)
blockedCrossing:
	ld b,$00
	ld a,(wActiveGroup)
	cp $02
	ret nc
	; l'île de cette salle (aucune : rien à refuser)
	ld a,(wActiveRoom)
	ld e,a
	ld hl,islandOfRoom
	rst_addAToHl
	ld a,(hl)
	or a
	ret z
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
	ret z
	inc b
	ret

@moves:
	.db $f0 $01 $10 $ff
