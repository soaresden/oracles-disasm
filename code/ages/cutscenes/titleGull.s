; ==================================================================================================
; BALLADE: Marine en mouette sur l'écran titre de Gulls of Life.
;
; Elle arrive en volant de la droite, puis ne quitte plus l'écran : un petit programme en boucle
; (@program) la fait se poser sur le « s » de « Gulls », regarder à gauche et à droite, sautiller,
; faire un clin d'œil en envoyant un cœur, voler jusqu'au « L » de « of Life », aller tremper le bec
; dans la mer, puis revenir.
;
; Graphismes : spr_title_gull (tools/make_title.py), chargés en $8000 par GFXH_TITLE ; palettes de
; sprites 1 (Marine) et 2 (le cœur) de PALH_TITLE. Ce code est dans sa propre section, appelé
; depuis la banque 3 (intro_titlescreen) ; il n'utilise que des fonctions de la banque 0.
;
; Variables (libres pendant l'écran titre) :
;   TITLE_GULL_STEP  : étape du programme
;   TITLE_GULL_TIMER : compteur d'images de l'étape
;   TITLE_GULL_X/Y   : position à l'écran (coin haut gauche du sprite 16x16)
;   TITLE_GULL_HEART : hauteur du cœur qui monte (0 = pas de cœur)
;   TITLE_GULL_FACE  : 0 = tournée vers la gauche (le dessin), 1 = vers la droite (miroir)
; ==================================================================================================

.define TITLE_GULL_STEP		$cbc0
.define TITLE_GULL_TIMER	$cbc1
.define TITLE_GULL_X		$cbc2
.define TITLE_GULL_Y		$cbc3
.define TITLE_GULL_HEART	$cbc4
.define TITLE_GULL_FACE		$cbc5

; Elle arrive de la droite
.define TITLE_GULL_START_X	176
.define TITLE_GULL_START_Y	40

.enum 0
	TITLE_GULL_PERCHED	db
	TITLE_GULL_CROUCH	db
	TITLE_GULL_WINGS_UP	db
	TITLE_GULL_WINGS_DOWN	db
	TITLE_GULL_WINK		db
.ende

; Commandes du programme (3 octets : commande, paramètre 1, paramètre 2)
.enum 0
	GULL_FLY	db ; x, y : voler jusque-là (en battant des ailes)
	GULL_WAIT	db ; images : posée, elle respire
	GULL_TURN	db ; se retourner
	GULL_HOP	db ; nombre de petits sauts
	GULL_WINK	db ; images : clin d'œil, et un cœur s'envole
	GULL_DIP	db ; images : ailes baissées, le bec dans l'eau
	GULL_GOTO	db ; étape où reprendre
.ende

;;
; Au chargement de l'écran titre
titleGull_init:
	; BALLADE: efface le code secret du boss en rythme (il ne vaut que pour ce passage au titre)
	callab balladeRhythm.titleClearCode
	callab balladeDebug.titleClear
	ld hl,TITLE_GULL_STEP
	ld b,$06
	call clearMemory
	ld a,TITLE_GULL_START_X
	ld (TITLE_GULL_X),a
	ld a,TITLE_GULL_START_Y
	ld (TITLE_GULL_Y),a
	ret

;;
; À chaque image de l'écran titre (après les autres sprites)
titleGull_update:
	; BALLADE: Select tenu + Start = code secret du boss en rythme
	callab balladeRhythm.titleCheckCode
	; BALLADE: HAUT tenu 5 s = menu de test caché
	callab balladeDebug.titleCheck
	call @updateHeart

	; Commande de l'étape en cours : b = paramètre 1, c = paramètre 2
	ld a,(TITLE_GULL_STEP)
	ld l,a
	add a
	add l
	ld hl,@program
	rst_addAToHl
	ldi a,(hl)
	ld b,(hl)
	inc hl
	ld c,(hl)
	rst_jumpTable
	.dw @fly
	.dw @wait
	.dw @turn
	.dw @hop
	.dw @wink
	.dw @dip
	.dw @goto

@nextStep:
	ld hl,TITLE_GULL_STEP
	inc (hl)
	xor a
	ld (TITLE_GULL_TIMER),a
	ret

@goto:
	ld a,b
	ld (TITLE_GULL_STEP),a
	xor a
	ld (TITLE_GULL_TIMER),a
	jp @drawPerched

; Voler jusqu'à (b, c), un pixel par image sur chaque axe, tournée du côté où elle va
@fly:
	ld hl,TITLE_GULL_X
	ld a,(hl)
	cp b
	jr z,@flyY
	jr c,+
	dec (hl)
	xor a
	ld (TITLE_GULL_FACE),a
	jr @flyY
+
	inc (hl)
	ld a,$01
	ld (TITLE_GULL_FACE),a
@flyY:
	ld hl,TITLE_GULL_Y
	ld a,(hl)
	cp c
	jr z,@flyCheck
	jr c,+
	dec (hl)
	jr @flyCheck
+
	inc (hl)
@flyCheck:
	ld a,(TITLE_GULL_X)
	cp b
	jr nz,@flapping
	ld a,(TITLE_GULL_Y)
	cp c
	jr nz,@flapping
	call @nextStep
	jp @drawPerched

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

; Posée : elle respire (elle se tasse un instant toutes les 64 images)
@wait:
	call @countTo
	ld a,(TITLE_GULL_TIMER)
	and $3f
	cp $30
	jp nc,@drawCrouch
	jp @drawPerched

@turn:
	ld a,(TITLE_GULL_FACE)
	xor $01
	ld (TITLE_GULL_FACE),a
	call @nextStep
	jp @drawPerched

; b petits sauts de 8 images
@hop:
	sla b
	sla b
	sla b
	call @countTo
	ld a,(TITLE_GULL_TIMER)
	dec a
	and $07
	ld hl,@hopHeights
	rst_addAToHl
	ld a,(TITLE_GULL_Y)
	sub (hl)
	ld b,a
	ld a,TITLE_GULL_CROUCH
	jp @drawAtY

@hopHeights:
	.db 1, 3, 5, 6, 6, 5, 3, 1

; Clin d'œil, et un cœur s'envole au début
@wink:
	ld a,(TITLE_GULL_TIMER)
	or a
	jr nz,+
	ld a,$01
	ld (TITLE_GULL_HEART),a
+
	call @countTo
	ld a,TITLE_GULL_WINK
	jp @draw

; Le bec dans l'eau : ailes baissées, elle oscille d'un pixel
@dip:
	call @countTo
	ld a,(TITLE_GULL_TIMER)
	and $10
	swap a
	ld b,a
	ld a,(TITLE_GULL_Y)
	add b
	ld b,a
	ld a,TITLE_GULL_WINGS_DOWN
	jp @drawAtY

;;
; Compteur de l'étape + 1 ; à b images, étape suivante
@countTo:
	ld hl,TITLE_GULL_TIMER
	inc (hl)
	ld a,(hl)
	cp b
	ret c
	jp @nextStep

;;
; Le cœur monte au-dessus d'elle, puis disparaît
@updateHeart:
	ld a,(TITLE_GULL_HEART)
	or a
	ret z
	inc a
	ld (TITLE_GULL_HEART),a
	cp 40
	jr c,+
	xor a
	ld (TITLE_GULL_HEART),a
	ret
+
	srl a
	ld b,a
	ld a,(TITLE_GULL_Y)
	sub 6
	sub b
	ld b,a
	ld a,(TITLE_GULL_X)
	sub 6
	ld c,a
	ld hl,@heartSprite
	jp addSpritesToOam_withOffset

@drawCrouch:
	ld a,TITLE_GULL_CROUCH
	jr @draw
@drawPerched:
	ld a,TITLE_GULL_PERCHED

; @param	a	Image (TITLE_GULL_*), à la position de Marine
@draw:
	ld c,a
	ld a,(TITLE_GULL_Y)
	ld b,a
	ld a,c

; @param	a	Image
; @param	b	Y à l'écran
@drawAtY:
	ld hl,@spritesLeft
	ld c,a
	ld a,(TITLE_GULL_FACE)
	or a
	ld a,c
	jr z,+
	ld hl,@spritesRight
+
	rst_addDoubleIndex
	ldi a,(hl)
	ld h,(hl)
	ld l,a
	ld a,(TITLE_GULL_X)
	ld c,a
	jp addSpritesToOam_withOffset

; Le programme, en boucle à partir de l'étape 1
@program:
	.db GULL_FLY,  109, 18	; 0 : sur le « s » de « Gulls »
	.db GULL_WAIT,  50,  0	; 1
	.db GULL_TURN,   0,  0	; 2 : elle regarde à droite...
	.db GULL_WAIT,  25,  0	; 3
	.db GULL_TURN,   0,  0	; 4 : ... puis à gauche
	.db GULL_WAIT,  20,  0	; 5
	.db GULL_HOP,    2,  0	; 6 : deux petits sauts
	.db GULL_WINK,  50,  0	; 7 : clin d'œil, et un cœur
	.db GULL_WAIT,  30,  0	; 8
	.db GULL_FLY,   86, 44	; 9 : sur le « L » de « of Life »
	.db GULL_WAIT,  40,  0	; 10
	.db GULL_HOP,    1,  0	; 11
	.db GULL_TURN,   0,  0	; 12
	.db GULL_WAIT,  30,  0	; 13
	.db GULL_FLY,   40, 90	; 14 : vers la mer...
	.db GULL_DIP,   48,  0	; 15 : ... le bec dans l'eau
	.db GULL_FLY,   24, 56	; 16 : elle remonte
	.db GULL_FLY,  109, 18	; 17 : et revient sur le « s »
	.db GULL_GOTO,   1,  0	; 18

; 2 sprites de 8x16 par image : la case n de spr_title_gull a les tuiles 4n et 4n+2
@spritesLeft:
	.dw @perchedL
	.dw @crouchL
	.dw @wingsUpL
	.dw @wingsDownL
	.dw @winkL
@spritesRight:
	.dw @perchedR
	.dw @crouchR
	.dw @wingsUpR
	.dw @wingsDownR
	.dw @winkR

@perchedL:
	.db $02
	.db $10 $08 $00 $01
	.db $10 $10 $02 $01
@crouchL:
	.db $02
	.db $10 $08 $04 $01
	.db $10 $10 $06 $01
@wingsUpL:
	.db $02
	.db $10 $08 $08 $01
	.db $10 $10 $0a $01
@wingsDownL:
	.db $02
	.db $10 $08 $0c $01
	.db $10 $10 $0e $01
@winkL:
	.db $02
	.db $10 $08 $10 $01
	.db $10 $10 $12 $01

; Miroir : les deux moitiés échangées, retournées (attribut $20)
@perchedR:
	.db $02
	.db $10 $08 $02 $21
	.db $10 $10 $00 $21
@crouchR:
	.db $02
	.db $10 $08 $06 $21
	.db $10 $10 $04 $21
@wingsUpR:
	.db $02
	.db $10 $08 $0a $21
	.db $10 $10 $08 $21
@wingsDownR:
	.db $02
	.db $10 $08 $0e $21
	.db $10 $10 $0c $21
@winkR:
	.db $02
	.db $10 $08 $12 $21
	.db $10 $10 $10 $21

@heartSprite:
	.db $02
	.db $10 $08 $14 $02
	.db $10 $10 $16 $02
