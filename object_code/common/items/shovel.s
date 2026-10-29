;;
; ITEM_SHOVEL
itemCode15:
	ld e,Item.state
	ld a,(de)
	or a
	jr nz,@state1

	; Initialization (state 0)

	call itemLoadAttributesAndGraphics
	call itemIncState
	ld l,Item.counter1
	ld (hl),$04

.ifdef ROM_AGES
	; BALLADE: les jeux du forain : Link sort la Pelle (Denis : « qu'on voie quand même qu'on utilise
	; une pelle »), mais c'est le jeu qui creuse (balladeMamono.s) : ni la case, ni le bruit. Tant
	; qu'on est dans l'arène (une partie, ou sa fin : le dernier coup de pelle gagnant laissait un trou)
	ld a,(wBalladeMamonoState)
	or a
	ret nz
.endif

	ld a,BREAKABLETILESOURCE_SHOVEL
	call itemTryToBreakTile
	ld a,SND_CLINK
	jr nc,+

	; Dig succeeded
	ld a,$01
	call addToGashaMaturity
	ld a,SND_DIG
+
	jp playSound

; State 1: does nothing for 4 frames?
@state1:
	call itemDecCounter1
	ret nz
	jp itemDelete
