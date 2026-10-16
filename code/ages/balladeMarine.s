; ==================================================================================================
; BALLADE: Marine parle depuis la tunique de Link.
;
; Un appui court sur Select l'appelle (b2_updateMenus, bank2.s) ; Select maintenu ouvre la carte.
; Elle a une réplique pour certaines salles ; ailleurs, une réplique au hasard.
; ==================================================================================================

;;
marineTalk:
	; Dans le Songe (groupes 0 et 2), Marine propose de réveiller Link (INTERAC_MARINE $01)
	ld a,(wActiveGroup)
	and $01
	jr nz,+
	call getFreeInteractionSlot
	ret nz
	ld (hl),INTERAC_MARINE
	inc l
	ld (hl),$01
	ret
+
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
	; (virgules : sinon « $aa <TX » est lu comme une comparaison)
	.db $01, $aa, <TX_5a07 ; la plage du réveil
	.db $01, $9a, <TX_5a08 ; Port-Veille, devant l'auberge
	.db $01, $9b, <TX_5a09 ; la place
	.db $01, $9c, <TX_5a0a ; la plage est
	.db $01, $ab, <TX_5a0b ; le port de pêche
	.db $01, $8a, <TX_5a0c ; le sentier au pont cassé
	.db $03, $9e, <TX_5a0d ; dans l'auberge
	.db $ff


; ==================================================================================================
; Passer du Réel au Songe et inversement, au même endroit (comme la harpe d'Ages) : groupe 1 <-> 0
; (dehors), 3 <-> 2 (dedans), même salle, même case.
; ==================================================================================================

;;
; Après avoir dormi dans le lit de l'auberge (LINK_STATE_SLEEPING) : Link se retrouve dans l'auberge
; du Songe, debout à côté du lit.
enterDreamFromBed:
	call switchDream
	ld a,$17
	ld (wWarpDestPos),a
	ret

;;
switchDream:
	ld a,(wActiveGroup)
	xor $01
	or $80
	ld (wWarpDestGroup),a
	ld a,(wActiveRoom)
	ld (wWarpDestRoom),a
	xor a
	ld (wWarpTransition),a
	; Case de Link : ligne (y / 16) et colonne (x / 16)
	ld a,(w1Link.yh)
	and $f0
	ld b,a
	ld a,(w1Link.xh)
	swap a
	and $0f
	or b
	ld (wWarpDestPos),a
	ld a,$03 ; fondu
	ld (wWarpTransition2),a
	ld a,SND_FADEOUT
	jp playSound

