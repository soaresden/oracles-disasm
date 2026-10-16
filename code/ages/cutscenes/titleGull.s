; ==================================================================================================
; BALLADE: Marine en mouette sur l'écran titre de Gulls of Life.
;
; Elle arrive en volant de la droite, se pose sur le « s » de « Gulls », respire, sautille deux
; fois, fait un clin d'œil et envoie un cœur, puis repart vers la gauche ; et ça recommence.
;
; Graphismes : spr_title_gull (tools/make_title.py), chargés en $8000 par GFXH_TITLE ; palettes de
; sprites 1 (Marine) et 2 (le cœur) de PALH_TITLE. Ce code est dans sa propre section, appelé
; depuis la banque 3 (intro_titlescreen) ; il n'utilise que des fonctions de la banque 0.
;
; Variables (libres pendant l'écran titre) :
;   TITLE_GULL_STATE : étape (attendre, arriver, posée, repartir)
;   TITLE_GULL_TIMER : compteur d'images de l'étape
;   TITLE_GULL_X/Y   : position à l'écran (coin haut gauche du sprite 16x16)
;   TITLE_GULL_HEART : hauteur du cœur qui monte (0 = pas de cœur)
; ==================================================================================================

.define TITLE_GULL_STATE	$cbc0
.define TITLE_GULL_TIMER	$cbc1
.define TITLE_GULL_X		$cbc2
.define TITLE_GULL_Y		$cbc3
.define TITLE_GULL_HEART	$cbc4

; Sur le « s » de « Gulls » (doit suivre LAND_X/LAND_Y de tools/make_title.py)
.define TITLE_GULL_LAND_X	109
.define TITLE_GULL_LAND_Y	18
; Elle arrive de la droite, un peu plus bas
.define TITLE_GULL_START_X	176

.enum 0
	TITLE_GULL_PERCHED	db
	TITLE_GULL_CROUCH	db
	TITLE_GULL_WINGS_UP	db
	TITLE_GULL_WINGS_DOWN	db
	TITLE_GULL_WINK		db
	TITLE_GULL_HEART_SPRITE	db
.ende

;;
; Au chargement de l'écran titre
titleGull_init:
	ld hl,TITLE_GULL_STATE
	ld b,$05
	jp clearMemory

;;
; À chaque image de l'écran titre (après les autres sprites)
titleGull_update:
	ld a,(TITLE_GULL_STATE)
	rst_jumpTable
	.dw @wait
	.dw @flyIn
	.dw @perched
	.dw @flyOut

; Étape 0 : un moment sans elle
@wait:
	ld hl,TITLE_GULL_TIMER
	inc (hl)
	ld a,(hl)
	cp 90
	ret c
	ld (hl),$00
	ld a,TITLE_GULL_START_X
	ld (TITLE_GULL_X),a
	ld a,$01
	ld (TITLE_GULL_STATE),a
	ret

; Étape 1 : elle arrive en battant des ailes et descend vers le logo
@flyIn:
	ld hl,TITLE_GULL_X
	dec (hl)
	ld a,(hl)
	cp TITLE_GULL_LAND_X
	jr nz,+
	ld a,$02
	ld (TITLE_GULL_STATE),a
	xor a
	ld (TITLE_GULL_TIMER),a
	ld a,TITLE_GULL_LAND_Y
	ld (TITLE_GULL_Y),a
	jp @drawPerched
+
	; Y = LAND_Y + (X - LAND_X) / 4 : une descente en pente douce
	sub TITLE_GULL_LAND_X
	srl a
	srl a
	add TITLE_GULL_LAND_Y
	ld (TITLE_GULL_Y),a
	jp @flapping

; Étape 3 : elle repart vers la gauche en remontant
@flyOut:
	ld hl,TITLE_GULL_X
	dec (hl)
	dec (hl)
	ld a,(hl)
	cp 4
	jr nc,+
	; Partie : on attend, puis elle revient
	xor a
	ld (TITLE_GULL_STATE),a
	ld (TITLE_GULL_TIMER),a
	ret
+
	ld a,(TITLE_GULL_TIMER)
	inc a
	ld (TITLE_GULL_TIMER),a
	rrca
	jp nc,@flapping
	ld hl,TITLE_GULL_Y
	dec (hl)

; Ailes levées puis baissées, toutes les 8 images
@flapping:
	ld hl,TITLE_GULL_TIMER
	inc (hl)
	ld a,(hl)
	and $08
	ld a,TITLE_GULL_WINGS_UP
	jp z,@draw
	ld a,TITLE_GULL_WINGS_DOWN
	jp @draw

; Étape 2 : posée sur le logo
@perched:
	ld hl,TITLE_GULL_TIMER
	inc (hl)
	ld a,(hl)
	ld b,a

	; Le cœur monte au-dessus d'elle, puis disparaît
	ld a,(TITLE_GULL_HEART)
	or a
	jr z,++
	inc a
	ld (TITLE_GULL_HEART),a
	cp 40
	jr c,+
	xor a
	ld (TITLE_GULL_HEART),a
	jr ++
+
	call @drawHeart
++
	ld a,b
	cp 30
	jp c,@drawPerched
	cp 40
	jr c,@drawCrouch	; elle respire
	cp 70
	jp c,@drawPerched
	cp 86
	jr c,@hop		; deux petits sauts
	cp 110
	jp c,@drawPerched
	jr nz,+
	ld a,$01		; clin d'œil, et un cœur
	ld (TITLE_GULL_HEART),a
+
	ld a,b
	cp 160
	jp c,@drawWink
	cp 190
	jp c,@drawPerched
	; Elle repart
	ld a,$03
	ld (TITLE_GULL_STATE),a
	xor a
	ld (TITLE_GULL_TIMER),a
	jp @drawPerched

@hop:
	sub 70
	and $07
	ld hl,@hopHeights
	rst_addAToHl
	ld a,TITLE_GULL_LAND_Y
	sub (hl)
	ld (TITLE_GULL_Y),a
	ld a,TITLE_GULL_CROUCH
	jp @draw

@hopHeights:
	.db 0, 3, 5, 6, 6, 5, 3, 0

@drawCrouch:
	ld a,TITLE_GULL_CROUCH
	jp @draw
@drawWink:
	ld a,TITLE_GULL_WINK
	jp @draw
@drawPerched:
	ld a,TITLE_GULL_LAND_Y
	ld (TITLE_GULL_Y),a
	ld a,TITLE_GULL_PERCHED

; @param	a	Image (TITLE_GULL_*)
@draw:
	ld hl,@sprites
	rst_addDoubleIndex
	ldi a,(hl)
	ld h,(hl)
	ld l,a
	ld a,(TITLE_GULL_Y)
	ld b,a
	ld a,(TITLE_GULL_X)
	ld c,a
	jp addSpritesToOam_withOffset

; Le cœur, au-dessus de sa tête
@drawHeart:
	push bc
	ld a,(TITLE_GULL_HEART)
	srl a
	ld b,a
	ld a,TITLE_GULL_LAND_Y - 6
	sub b
	ld b,a
	ld a,(TITLE_GULL_X)
	sub 6
	ld c,a
	ld hl,@heartSprite
	call addSpritesToOam_withOffset
	pop bc
	ret

@sprites:
	.dw @perchedSprite
	.dw @crouchSprite
	.dw @wingsUpSprite
	.dw @wingsDownSprite
	.dw @winkSprite

; 2 sprites de 8x16 par image : la case n de spr_title_gull a les tuiles 4n et 4n+2
@perchedSprite:
	.db $02
	.db $10 $08 $00 $01
	.db $10 $10 $02 $01
@crouchSprite:
	.db $02
	.db $10 $08 $04 $01
	.db $10 $10 $06 $01
@wingsUpSprite:
	.db $02
	.db $10 $08 $08 $01
	.db $10 $10 $0a $01
@wingsDownSprite:
	.db $02
	.db $10 $08 $0c $01
	.db $10 $10 $0e $01
@winkSprite:
	.db $02
	.db $10 $08 $10 $01
	.db $10 $10 $12 $01
@heartSprite:
	.db $02
	.db $10 $08 $14 $02
	.db $10 $10 $16 $02
