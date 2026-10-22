; ==================================================================================================
; BALLADE: la carte au trésor (INTERAC_BALLADE_CREUSE $03, au rocher de la veuve, île des Échos 1:74).
;
; Le facteur des bouteilles (la Lagune, 1:35) donne à Link une bouteille sans nom, avec une carte :
; une croix entre deux rochers, devant le rocher de la veuve, au large de l'île des Échos (TX_5a79).
; Là, une petite crique : il faut plonger (B, avec les Palmes) dans le chenal entre les deux rochers
; (ligne 6, colonnes 4-5) et y rester plus de 10 secondes. Sans les Écailles de Sirène, Link remonte
; au bout de 2 secondes (le moteur d'Ages) ; avec, il respire sous l'eau et ne remonte que quand il
; veut. Au bout de 10 secondes : un quart de cœur (drapeau $40 de la salle). S'il remonte avant,
; Marine dit qu'il faut rester plus longtemps (TX_5a5f, une fois par visite).
; ==================================================================================================

.define TRESOR_ROW	$60	; la ligne du chenal (y $60-$6f)
.define TRESOR_X	$40	; ses deux cases (x $40-$5f)
.define TRESOR_SECONDS	10

;;
; d = l'interaction ; counter1 les images, counter2 les secondes, var30 Marine a parlé
main:
	ld e,Interaction.state
	ld a,(de)
	or a
	jr nz,@watching
	inc a
	ld (de),a
	call getThisRoomFlags
	ld a,(hl)
	and $40
	ret z
	jp interactionDelete

@watching:
	cp $01
	ret nz
	; Link plonge-t-il dans le chenal ?
	ld a,(wLinkSwimmingState)
	rlca
	jr nc,@surfaced
	ld a,(w1Link.yh)
	and $f0
	cp TRESOR_ROW
	jr nz,@reset
	ld a,(w1Link.xh)
	and $e0
	cp TRESOR_X
	jr nz,@reset

	; Avec les Écailles de Sirène, il respire sous l'eau : il ne remonte pas tout seul
	ld a,TREASURE_MERMAID_SUIT
	call checkTreasureObtained
	jr nc,+
	ld a,$78
	ld (w1Link.counter2),a
+
	; Une seconde de plus
	ld h,d
	ld l,Interaction.counter1
	inc (hl)
	ld a,(hl)
	cp 60
	ret c
	ld (hl),$00
	inc l
	inc (hl)
	ld a,(hl)
	cp TRESOR_SECONDS
	ret c

	; Le trésor : Link remonte, avec un quart de cœur
	ld l,Interaction.state
	ld (hl),$02
	call getThisRoomFlags
	set 6,(hl)
	ld a,$01
	ld (w1Link.counter2),a
	ld a,SND_SOLVEPUZZLE
	call playSound
	ldbc TREASURE_HEART_PIECE, $00
	call createTreasure
	ret nz
	ld de,w1Link.yh
	jp objectCopyPosition_rawAddress

@surfaced:
	; Remonté trop tôt après une plongée dans le chenal : Marine (une fois)
	ld e,Interaction.counter2
	ld a,(de)
	or a
	jr z,@reset
	ld e,Interaction.var30
	ld a,(de)
	or a
	jr nz,@reset
	inc a
	ld (de),a
	call @reset
	ld bc,TX_5a5f
	jp showText

@reset:
	ld h,d
	ld l,Interaction.counter1
	xor a
	ldi (hl),a
	ld (hl),a
	ret
