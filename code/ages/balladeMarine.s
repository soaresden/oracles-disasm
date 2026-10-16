; ==================================================================================================
; BALLADE: Marine parle depuis la tunique de Link.
;
; Un appui court sur Select l'appelle (b2_updateMenus, bank2.s) ; Select maintenu ouvre la carte.
; Elle a une réplique pour certaines salles ; ailleurs, une réplique au hasard.
; ==================================================================================================

;;
marineTalk:
	ld a,(wActiveGroup)
	ld b,a
	ld a,(wActiveRoom)
	ld c,a
	ld hl,@roomTexts
@next:
	ldi a,(hl)
	cp $ff
	jr z,@anywhere
	cp b
	jr nz,@skip
	ld a,(hl)
	cp c
	jr nz,@skip
	inc hl
	ld c,(hl)
	jr @show
@skip:
	inc hl
	inc hl
	jr @next

@anywhere:
	call getRandomNumber
	and $03
	add <TX_5a10
	ld c,a
@show:
	ld b,>TX_5a00
	jp showText

; Répliques par salle : groupe, salle, texte (groupe de textes $5a)
@roomTexts:
	.db $01, $aa, <TX_5a07 ; la plage du réveil (virgules : sinon « $aa <TX » est lu comme une comparaison)
	.db $ff
