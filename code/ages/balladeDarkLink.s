; ==================================================================================================
; BALLADE: Dark Link (la Tour Sans-Nuit, 2F ; ENEMY_LINK_MIMIC, object_code/ages/enemies/linkMimic.s).
;
; Plus un reflet des gestes de Link, un vrai duel (Denis : « il faudrait qu'il soit autonome ») :
; il tourne autour de Link à bonne distance et esquive ses coups d'épée d'un bond en arrière ;
; aligné et assez près, il se met en garde, puis se fend sur Link ; après la fente, il rebondit en
; arrière et souffle un instant : c'est là qu'on le touche.
;
; Ici, il réfléchit (la banque des ennemis est pleine) ; linkMimic.s le fait bouger (bit 0 de var34)
; et l'anime (bit 1), et met var35 à 1 s'il a buté contre un mur.
;
; var30 : l'animation (la direction où il regarde) ; var31 : la phase ; var32 : le sens où il
; tourne ; var33 : l'épée de Link déjà vue pendant ce coup-ci ; var36 : le bond qui suit une fente.
; ==================================================================================================

;;
; @param	d	Dark Link
think:
	ld e,Enemy.var34
	xor a
	ld (de),a
	ld e,Enemy.var31
	ld a,(de)
	rst_jumpTable
	.dw @guard
	.dw @windup
	.dw @lunge
	.dw @recover
	.dw @hop

; En garde : il tourne autour de Link ; aligné et à moins de 48 pixels, il prépare sa fente
@guard:
	call @faceLink
	call @checkDodge
	ret c
	ld h,d
	ld l,Enemy.counter2
	ld a,(hl)
	or a
	jr z,+
	dec (hl)
	jr @move
+
	ld c,48
	call objectCheckLinkWithinDistance
	jr nc,@move
	call @aligned
	jr nc,@move
	; La garde (14 images, immobile)
	ld h,d
	ld l,Enemy.var31
	ld (hl),$01
	ld l,Enemy.counter1
	ld (hl),14
	ret

@move:
	; Trop près : il recule ; trop loin : il approche ; sinon, il tourne autour (le sens change
	; toutes les 64 images)
	ld c,24
	call objectCheckLinkWithinDistance
	ld b,$10
	jr c,@go
	ld c,56
	call objectCheckLinkWithinDistance
	ld b,$00
	jr nc,@go
	ld a,(wFrameCounter)
	and $3f
	jr nz,+
	ld e,Enemy.var32
	ld a,(de)
	xor $10
	ld (de),a
+
	ld e,Enemy.var32
	ld a,(de)
	add $08
	ld b,a
@go:
	call objectGetAngleTowardLink
	add $04
	and $18
	add b
	and $1f
	ld h,d
	ld l,Enemy.angle
	ld (hl),a
	ld l,Enemy.speed
	ld (hl),SPEED_100
	ld l,Enemy.var34
	ld (hl),$03
	ret

; La garde : il regarde Link, puis se fend droit sur lui
@windup:
	call @faceLink
	ld h,d
	ld l,Enemy.counter1
	dec (hl)
	ret nz
	call objectGetAngleTowardLink
	add $04
	and $18
	ld h,d
	ld l,Enemy.angle
	ld (hl),a
	ld l,Enemy.speed
	ld (hl),SPEED_300
	ld l,Enemy.counter1
	ld (hl),16
	ld l,Enemy.var35
	ld (hl),$00
	ld l,Enemy.var31
	ld (hl),$02
	ld a,SND_SWORDSLASH
	jp playSound

; La fente (16 images, ou jusqu'au mur), puis il souffle (40 images)
@lunge:
	ld h,d
	ld l,Enemy.var35
	ld a,(hl)
	or a
	jr nz,@stop
	ld l,Enemy.counter1
	dec (hl)
	jr z,@stop
	ld l,Enemy.var34
	ld (hl),$03
	ret
@stop:
	; Il rebondit en arrière (sans rester collé à Link), puis il souffle (var36 : après le bond)
	ld h,d
	ld l,Enemy.var36
	ld (hl),$01
	jp @hopAway

; Il souffle : immobile, sans esquive ; puis il se remet en garde (une seconde avant une autre fente)
@recover:
	ld h,d
	ld l,Enemy.counter1
	dec (hl)
	ret nz
	ld l,Enemy.var31
	ld (hl),$00
	ld l,Enemy.counter2
	ld (hl),60
	ret

; Le bond en arrière
@hop:
	ld e,Enemy.var34
	ld a,$01
	ld (de),a
	ld c,$20
	call objectUpdateSpeedZ_paramC
	ret nz
	; Posé : en garde, ou essoufflé après une fente (50 images)
	ld h,d
	ld l,Enemy.var36
	ld a,(hl)
	ld (hl),$00
	ld l,Enemy.var31
	or a
	jr nz,+
	ld (hl),a
	ret
+
	ld (hl),$03
	ld l,Enemy.counter1
	ld (hl),50
	ret

;;
; Quand l'épée de Link apparaît à moins de 28 pixels (une fois par coup), trois fois sur quatre il
; bondit en arrière.
; @param[out]	cflag	c s'il bondit
@checkDodge:
	ld a,(w1WeaponItem.enabled)
	or a
	jr z,@noSword
	ld a,(w1WeaponItem.id)
	cp ITEM_SWORD
	jr nz,@noSword
	ld e,Enemy.var33
	ld a,(de)
	or a
	ret nz			; (déjà vue : nc)
	ld h,d
	ld l,Enemy.yh
	ld a,(w1WeaponItem.yh)
	sub (hl)
	call @abs
	cp 28
	ret nc
	ld l,Enemy.xh
	ld a,(w1WeaponItem.xh)
	sub (hl)
	call @abs
	cp 28
	ret nc
	ld e,Enemy.var33
	ld a,$01
	ld (de),a
	call getRandomNumber
	and $03
	ret z			; (une fois sur quatre, il encaisse : nc)
	call @hopAway
	scf
	ret

;;
; Le bond : à l'opposé de Link
@hopAway:
	call objectGetAngleTowardLink
	add $04
	and $18
	xor $10
	ld h,d
	ld l,Enemy.angle
	ld (hl),a
	ld l,Enemy.speed
	ld (hl),SPEED_200
	ld l,Enemy.var31
	ld (hl),$04
	ld bc,-$200
	call objectSetSpeedZ
	ld a,SND_JUMP
	jp playSound
@noSword:
	ld e,Enemy.var33
	xor a
	ld (de),a
	ret

;;
; @param[out]	cflag	c si Link est sur la même ligne ou la même colonne (à 10 pixels près)
@aligned:
	ld h,d
	ld l,Enemy.yh
	ld a,(w1Link.yh)
	sub (hl)
	call @abs
	cp 10
	ret c
	ld l,Enemy.xh
	ld a,(w1Link.xh)
	sub (hl)
	call @abs
	cp 10
	ret

;;
; Il regarde Link (l'animation de la direction : 0 haut, 1 droite, 2 bas, 3 gauche)
@faceLink:
	call objectGetAngleTowardLink
	add $04
	and $18
	rrca
	rrca
	rrca
	ld h,d
	ld l,Enemy.var30
	cp (hl)
	ret z
	ld (hl),a
	jp enemySetAnimation

@abs:
	bit 7,a
	ret z
	cpl
	inc a
	ret
