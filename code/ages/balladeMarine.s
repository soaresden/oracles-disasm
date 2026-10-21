; ==================================================================================================
; BALLADE: Marine parle depuis la tunique de Link.
;
; Un appui court sur Select l'appelle (b2_updateMenus, bank2.s) ; Select maintenu ouvre la carte.
; Elle a une réplique pour certaines salles ; ailleurs, une réplique au hasard.
; ==================================================================================================

;;
marineTalk:
	; Dans le Songe (groupes 0 et 2, pas les donjons), Marine propose de réveiller Link
	; (INTERAC_MARINE $01)
	ld a,(wActiveGroup)
	cp $03
	jr nc,+
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
	.db $04, $24, <TX_5a0e ; le hall du Phare Éteint
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
	; Le temps du noctambule repart de zéro (il recommencera au prochain passage dans le Songe)
	ld hl,wBalladeNoctambule
	xor a
	ldi (hl),a
	ld (hl),a
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


;;
; Le noctambule : dans la barre d'état, les secondes qui restent dans le Songe (à la place du
; compteur de clés, qui n'apparaît que dans les donjons). Appelé par updateStatusBar_body
; (code/bank2.s), la banque 4 de la WRAM étant sélectionnée.
drawNoctambuleTimer:
	ld a,(wTilesetFlags)
	bit TILESETFLAG_BIT_DUNGEON,a
	ret nz

	; Secondes = images / 60, arrondi au-dessus
	ld hl,wBalladeNoctambule
	ldi a,(hl)
	ld c,a
	ld b,(hl)
	ld d,$00
@divide:
	ld a,b
	or c
	jr z,@gotSeconds
	inc d
	ld a,c
	sub 60
	ld c,a
	jr nc,@divide
	ld a,b
	or a
	jr z,@gotSeconds
	dec b
	jr @divide
@gotSeconds:
	; Une valeur nouvelle : la barre d'état sera redessinée
	ld hl,wBalladeNoctambuleShown
	ld a,d
	cp (hl)
	jr z,+
	ld (hl),a
	ld hl,wStatusBarNeedsRefresh
	set 4,(hl)
+
	; Une petite lune (tuile $03, tools/make_sprites.py) puis les secondes (écrites à chaque image :
	; la carte de la barre peut être rechargée)
	ld hl,w4StatusBarTileMap+$0b
	ld a,(wcbe8)
	rrca
	jr nc,+
	dec l
+
	ld a,d
	or a
	jr nz,+
	; Plus de compte à rebours : des cases vides
	ld a,$04
	ldi (hl),a
	ld (hl),a
	ret
+
	cp 10
	jr c,+
	ld a,9
+
	ld (hl),$03
	inc l
	add $10
	ld (hl),a
	ret


; ==================================================================================================
; Le pouvoir de Marine (île 2) : porter une bombe. Link tient une bombe au-dessus de sa tête et
; appuie sur Select : Marine sort de la tunique, prend la bombe et l'emporte droit devant, par-dessus
; les trous, l'eau et les murs bas, puis la lâche et revient dans la tunique.
; ==================================================================================================

;;
; Select, à la première image de l'appui (b2_updateMenus, bank2.s). Si le pouvoir est appris, que
; Link tient une bombe : Marine (INTERAC_MARINE $06) l'emporte ; wBalladeSelectTimer passe à $ff
; (ni carte, ni parole pour cet appui).
checkBombPower:
	ld a,GLOBALFLAG_BALLADE_MARINE_BOMB
	call checkGlobalFlag
	ret z
	ld a,(wLinkGrabState)
	and $07
	cp $03
	ret nz
	; L'objet tenu : un objet de type « item » (adresse $dX00) qui est une bombe
	ld hl,w1Link.relatedObj2
	ldi a,(hl)
	ld h,(hl)
	ld l,a
	or a
	ret nz
	ld a,h
	cp FIRST_ITEM_INDEX
	ret c
	inc l
	ld a,(hl)
	cp ITEM_BOMB
	ret nz
	dec l
	push hl
	call dropLinkHeldItem
	call getFreeInteractionSlot
	pop bc
	ret nz
	ld (hl),INTERAC_MARINE
	inc l
	ld (hl),$06
	ld l,Interaction.relatedObj1
	ld (hl),c
	inc l
	ld (hl),b
	ld l,Interaction.yh
	ld a,(w1Link.yh)
	ld (hl),a
	ld l,Interaction.xh
	ld a,(w1Link.xh)
	ld (hl),a
	ld l,Interaction.direction
	ld a,(w1Link.direction)
	ld (hl),a
	; En défilement latéral (Link ne regarde qu'à gauche ou à droite) : Marine monte (le boss du
	; Coffre à Jouets, Pantin-Sans-Fil, est hors de portée au-dessus de Link)
	ld a,(wTilesetFlags)
	and TILESETFLAG_SIDESCROLL
	jr z,+
	ld (hl),DIR_UP
+
	ld a,$ff
	ld (wBalladeSelectTimer),a
	ret

;;
; INTERAC_MARINE $06 : Marine emporte la bombe (relatedObj1) dans la direction de Link, pendant
; BALLADE_CARRY_FRAMES images (2 pixels par image), puis la lâche et revient vers Link.
bombCarrier:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw @init
	.dw @carry
	.dw @return

@init:
	call interactionInitGraphics
	call interactionSetAlwaysUpdateBit
	call interactionIncState
	ld h,d
	ld l,Interaction.zh
	ld (hl),$f0
	ld l,Interaction.counter1
	ld (hl),BALLADE_CARRY_FRAMES
	; En vol : 2 = vers la gauche, 3 = vers la droite (vers le haut ou le bas : vers la droite)
	ld l,Interaction.direction
	ld a,(hl)
	cp DIR_LEFT
	ld a,$02
	jr z,+
	inc a
+
	call interactionSetAnimation
	ld a,SND_BALLADE_GULL
	call playSound
	jp objectSetVisible80

@carry:
	call interactionAnimate
	; La bombe est-elle toujours là (et pas en train d'exploser) ?
	call @getBomb
	jr nz,@release
	; Deux pixels droit devant
	ld e,Interaction.direction
	ld a,(de)
	add a
	ld hl,@moves
	rst_addAToHl
	ld e,Interaction.yh
	ld a,(de)
	add (hl)
	ld (de),a
	inc hl
	ld e,Interaction.xh
	ld a,(de)
	add (hl)
	ld (de),a
	; En défilement latéral, elle monte plus vite (3 pixels par image : Pantin-Sans-Fil)
	ld a,(wTilesetFlags)
	and TILESETFLAG_SIDESCROLL
	jr z,+
	ld e,Interaction.yh
	ld a,(de)
	dec a
	ld (de),a
+
	call objectCheckWithinRoomBoundary
	jr nc,@release
	; La bombe pend sous Marine
	call @getBomb
	ld l,Item.yh
	ld e,Interaction.yh
	ld a,(de)
	ld (hl),a
	ld l,Item.xh
	ld e,Interaction.xh
	ld a,(de)
	ld (hl),a
	ld l,Item.zh
	ld (hl),$f8
	ld l,Item.speedZ
	xor a
	ldi (hl),a
	ld (hl),a
	ld e,Interaction.counter1
	ld a,(de)
	dec a
	ld (de),a
	ret nz

; Elle lâche la bombe (qui tombe là où elle est) et revient
@release:
	ld e,Interaction.state
	ld a,$02
	ld (de),a
	ret

; Retour vers Link, deux pixels par image sur chaque axe ; arrivée : dans la tunique
@return:
	call interactionAnimate
	ld c,$00
	ld e,Interaction.yh
	ld a,(w1Link.yh)
	call @approach
	ld e,Interaction.xh
	ld a,(w1Link.xh)
	call @approach
	ld a,c
	cp $02
	ret nz
	jp interactionDelete

; @param	a	Cible
; @param	e	Coordonnée de Marine
; @param	c	+1 si elle est arrivée sur cet axe
@approach:
	ld b,a
	ld a,(de)
	sub b
	jr z,@arrived
	cp $03
	jr c,@arrivedNear
	cp $fe
	jr nc,@arrivedNear
	bit 7,a
	ld a,(de)
	jr nz,+
	sub $02
	ld (de),a
	ret
+
	add $02
	ld (de),a
	ret
@arrivedNear:
	ld a,b
	ld (de),a
@arrived:
	inc c
	ret

; @param[out]	hl	La bombe (début de l'objet)
; @param[out]	zflag	z si c'est toujours une bombe en vie, pas en train d'exploser
@getBomb:
	ld e,Interaction.relatedObj1
	ld a,(de)
	ld l,a
	inc e
	ld a,(de)
	ld h,a
	ld a,(hl)
	or a
	jr z,@notBomb
	inc l
	ld a,(hl)
	dec l
	cp ITEM_BOMB
	ret nz
	push hl
	ld a,l
	add Item.var2f
	ld l,a
	bit 4,(hl)
	pop hl
	ret
@notBomb:
	or $01
	ret

; dy, dx pour haut, droite, bas, gauche
@moves:
	.db $fe $00
	.db $00 $02
	.db $02 $00
	.db $00 $fe
