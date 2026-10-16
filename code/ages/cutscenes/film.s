; ==================================================================================================
; BALLADE: Film d'ouverture, avant l'écran titre (remplace la chevauchée et le temple d'Ages).
;
; À l'aube, Link dérive sur un rondin. Il lève les yeux : une mouette arrive et se pose au bout du
; rondin. Link ne comprend pas (« ? »), elle lui fait un clin d'œil, il la reconnaît (« ! ») et
; saute de joie, et Marine aussi ; son cœur s'envole, puis celui de Marine lui répond. Puis on passe
; à la montée de l'arbre et à l'écran titre (introCinematic_preTitlescreen).
;
; Graphismes : tools/make_film.py (dépôt ZeldaGullsOfLife), GFXH_FILM et PALH_FILM.
; Ce code est dans sa propre section (appelée depuis la banque 3 par introCinematic_filmCaller) :
; il n'utilise que des fonctions de la banque 0.
;
; Variables :
;   wTmpcbb3: compteur d'images de l'étape en cours
;   wTmpcbb4: balancement du rondin (décalage vertical)
;   wTmpcbb6: étape du saut de Marine (0 = pas de saut)
;   wTmpcbb8: X de la mouette (écran)
;   wTmpcbb9: Y de la mouette (écran)
;   wTmpcbba: étape du saut de Link (0 = pas de saut)
;   wTmpcbbb: hauteur du cœur de Link qui s'envole (0 = pas de cœur)
;   wTmpcbbc: hauteur du cœur de Marine, qui répond juste après
;   wTmpcbbd: pose de Link (FILM_LINK_*)
;   wTmpcbbe: image de la mouette (FILM_GULL_*)
;   wTmpcbbf: bulle au-dessus de Link (FILM_BUBBLE_*)
; ==================================================================================================

.enum 0
	FILM_LINK_SIDE	db
	FILM_LINK_BACK	db
	FILM_LINK_JOY	db
.ende

.enum 0
	FILM_GULL_HIDDEN	db
	FILM_GULL_FLYING	db
	FILM_GULL_PERCHED	db
	FILM_GULL_WINK		db
.ende

.enum 0
	FILM_BUBBLE_NONE	db
	FILM_BUBBLE_EXCLAIM	db
	FILM_BUBBLE_QUESTION	db
.ende

.define FILM_GULL_LAND_X	78
.define FILM_GULL_LAND_Y	88

introCinematic_film:
	call @runState
	jp introCinematic_film_draw

@runState:
	ld a,(wIntroVar)
	rst_jumpTable
	.dw introCinematic_film_state0
	.dw introCinematic_film_state1
	.dw introCinematic_film_state2
	.dw introCinematic_film_state3
	.dw introCinematic_film_state4
	.dw introCinematic_film_state4b
	.dw introCinematic_film_state5
	.dw introCinematic_film_state6
	.dw introCinematic_film_state7
	.dw introCinematic_film_state8
	.dw introCinematic_film_state9

;;
; Lance l'étape suivante avec un compteur de a images.
introCinematic_film_nextState:
	ld (wTmpcbb3),a
introCinematic_film_incState:
	ld hl,wIntroVar
	inc (hl)
	ret

;;
; State 0: chargement du décor, fondu depuis le blanc
introCinematic_film_state0:
	call disableLcd
	ld hl,wOamEnd
	ld bc,$d000-wOamEnd
	call clearMemoryBc
	call clearOam

	ld a,GFXH_FILM
	call loadGfxHeader
	ld a,PALH_FILM
	call loadPaletteHeader
	ld a,$04
	call loadGfxRegisterStateIndex

	xor a
	ldh (<hCameraX),a
	ldh (<hCameraY),a
	ld (wTmpcbba),a
	ld (wTmpcbbb),a
	ld (wTmpcbbc),a
	ld (wTmpcbb6),a
	ld (wTmpcbbf),a
	ld (wTmpcbbd),a ; FILM_LINK_SIDE
	ld (wTmpcbbe),a ; FILM_GULL_HIDDEN
	ld a,168
	ld (wTmpcbb8),a
	ld a,20
	ld (wTmpcbb9),a

	ld a,MUS_INTRO_1
	call playSound
	ld a,$04
	call fadeinFromWhiteWithDelay
	ld a,150
	jp introCinematic_film_nextState

;;
; State 1: Link dérive, il regarde devant lui
introCinematic_film_state1:
	call decCbb3
	ret nz
	ld a,FILM_LINK_BACK
	ld (wTmpcbbd),a
	ld a,50
	jp introCinematic_film_nextState

;;
; State 2: Link lève les yeux vers le ciel
introCinematic_film_state2:
	call decCbb3
	ret nz
	ld a,FILM_GULL_FLYING
	ld (wTmpcbbe),a
	ld a,SND_WAVE
	call playSound
	xor a
	jp introCinematic_film_nextState

;;
; State 3: la mouette descend en diagonale vers le bout du rondin
introCinematic_film_state3:
	ld hl,wTmpcbb8
	dec (hl)
	ld a,(hl)
	; Link la suit des yeux : il se tourne vers elle quand elle approche
	cp 120
	jr nc,+
	ld a,FILM_LINK_SIDE
	ld (wTmpcbbd),a
+
	ld a,(wIntro.frameCounter)
	and $03
	jr z,+
	ld hl,wTmpcbb9
	ld a,(hl)
	cp FILM_GULL_LAND_Y
	jr nc,+
	inc (hl)
+
	ld a,(wTmpcbb8)
	cp FILM_GULL_LAND_X
	ret nz

	ld a,FILM_GULL_LAND_Y
	ld (wTmpcbb9),a
	ld a,FILM_GULL_PERCHED
	ld (wTmpcbbe),a
	ld a,50
	jp introCinematic_film_nextState

;;
; State 4: elle est posée, elle regarde Link ; il ne comprend pas (« ? »)
introCinematic_film_state4:
	call decCbb3
	ret nz
	ld a,FILM_BUBBLE_QUESTION
	ld (wTmpcbbf),a
	ld a,50
	jp introCinematic_film_nextState

;;
; State 4b: elle lui fait un clin d'œil
introCinematic_film_state4b:
	call decCbb3
	ret nz
	ld a,FILM_BUBBLE_NONE
	ld (wTmpcbbf),a
	ld a,FILM_GULL_WINK
	ld (wTmpcbbe),a
	ld a,SND_CLINK2
	call playSound
	ld a,30
	jp introCinematic_film_nextState

;;
; State 5: clin d'œil
introCinematic_film_state5:
	call decCbb3
	ret nz
	ld a,FILM_GULL_PERCHED
	ld (wTmpcbbe),a
	ld a,30
	jp introCinematic_film_nextState

;;
; State 6: un temps, puis Link la reconnaît (« ! »)
introCinematic_film_state6:
	call decCbb3
	ret nz
	ld a,FILM_BUBBLE_EXCLAIM
	ld (wTmpcbbf),a
	ld a,SND_COMPASS
	call playSound
	ld a,50
	jp introCinematic_film_nextState

;;
; State 7: c'est Marine ! Il saute de joie, son cœur s'envole
introCinematic_film_state7:
	call decCbb3
	ret nz
	ld a,FILM_BUBBLE_NONE
	ld (wTmpcbbf),a
	ld a,FILM_LINK_JOY
	ld (wTmpcbbd),a
	ld a,$01
	ld (wTmpcbba),a
	ld (wTmpcbbb),a
	ld a,SND_SOLVEPUZZLE
	call playSound
	ld a,170
	jp introCinematic_film_nextState

;;
; State 8: la joie, puis fondu au blanc
introCinematic_film_state8:
	call decCbb3
	ret nz
	call fadeoutToWhite
	jp introCinematic_film_incState

;;
; State 9: à la fin du fondu, montée de l'arbre jusqu'à l'écran titre
introCinematic_film_state9:
	ld a,(wPaletteThread_mode)
	or a
	ret nz
	call clearOam
	ld a,$02
	ld (wIntro.cinematicState),a
	xor a
	ld (wIntroVar),a
	ret

;;
; Dessine les sprites et fait avancer la mer, à chaque image.
introCinematic_film_draw:
	ld a,(wIntro.cinematicState)
	or a
	ret nz ; le film est fini

	call clearOam

	; Les vagues défilent (tout le décor glisse ; le ciel est uni sur chaque ligne). Pas de
	; 2 pixels pour garder la trame du ciel en place.
	ld a,(wIntro.frameCounter)
	and $07
	jr nz,+
	ld hl,wGfxRegs1.SCX
	inc (hl)
	inc (hl)
+
	; Balancement du rondin : décalage vertical toutes les 16 images
	ld a,(wIntro.frameCounter)
	swap a
	and $07
	ld hl,@bobOffsets
	rst_addAToHl
	ld a,(hl)
	ld (wTmpcbb4),a

	; Sur Game Boy, le premier sprite écrit passe devant les suivants : on dessine du premier
	; plan vers le fond.
	call @drawHearts
	call @drawGull
	call @drawLink

	; Rondin
	ld a,(wTmpcbb4)
	add 100+16
	ld b,a
	ld c,48+8
	ld hl,@logSprites
	call addSpritesToOam_withOffset

	; Soleil (ne bouge pas), tout au fond
	ldbc 64+16, 104+8
	ld hl,@sunSprites
	jp addSpritesToOam_withOffset

;;
; Link (avec son saut éventuel), et la bulle « ! » au-dessus de lui
@drawLink:
	ld hl,wTmpcbba
	call @updateJump
	ld a,(wTmpcbb4)
	add b
	add 88+16
	ld b,a
	ld c,54+8
	ld a,(wTmpcbbf)
	or a
	jr z,+
	push bc
	ld hl,@bubbleSprites
	cp FILM_BUBBLE_EXCLAIM
	jr z,++
	ld hl,@questionSprites
++
	ld a,b
	sub 20
	ld b,a
	call addSpritesToOam_withOffset
	pop bc
+
	ld a,(wTmpcbbd)
	ld hl,@linkSprites
	rst_addDoubleIndex
	ldi a,(hl)
	ld h,(hl)
	ld l,a
	jp addSpritesToOam_withOffset

;;
; Le cœur de Link s'envole ; un peu après, celui de Marine lui répond
@drawHearts:
	ld hl,wTmpcbbb
	ld a,(hl)
	cp 24
	jr nz,+
	ld a,(wTmpcbbc)
	or a
	jr nz,+
	inc a
	ld (wTmpcbbc),a
	ld a,SND_GAINHEART
	call playSound
+
	ld hl,wTmpcbbb
	ld c,54+8
	call @drawHeart
	ld hl,wTmpcbbc
	ld c,FILM_GULL_LAND_X+8
	; Fall through

;;
; @param	c	X du cœur (OAM)
; @param	hl	Hauteur du cœur (0 = pas de cœur)
@drawHeart:
	ld a,(hl)
	or a
	ret z
	ld a,(wIntro.frameCounter)
	and $01
	jr nz,+
	inc (hl)
+
	ld a,(hl)
	cp 60
	ret nc
	ld a,84+16
	sub (hl)
	ld b,a
	ld hl,@heartSprites
	jp addSpritesToOam_withOffset

;;
; Marine
@drawGull:
	ld a,(wTmpcbbe)
	or a
	ret z
	ld d,a ; d = image
	ld a,(wTmpcbb4)
	ld e,a ; e = balancement (posée, elle bouge avec le rondin)
	ld a,d
	cp FILM_GULL_FLYING
	jr nz,@notFlying
	ld e,$00
	; en vol, elle bat des ailes : alterne avec les ailes repliées
	ld a,(wIntro.frameCounter)
	and $08
	jr z,@position
	ld d,FILM_GULL_PERCHED
	jr @position

@notFlying:
	; Elle saute de joie juste après Link, en battant des ailes
	ld hl,wTmpcbb6
	ld a,(hl)
	or a
	jr nz,++
	ld a,(wTmpcbba)
	cp 8
	jr nz,@position
	inc (hl)
++
	push de
	call @updateJump
	pop de
	ld a,e
	add b
	ld e,a
	ld a,b
	or a
	jr z,@position
	ld d,FILM_GULL_FLYING
	ld a,(wIntro.frameCounter)
	and $04
	jr z,@position
	ld d,FILM_GULL_PERCHED

@position:
	ld a,(wTmpcbb9)
	add e
	add 16
	ld b,a
	ld a,(wTmpcbb8)
	add 8
	ld c,a
	ld a,d
	ld hl,@gullSprites
	rst_addDoubleIndex
	ldi a,(hl)
	ld h,(hl)
	ld l,a
	jp addSpritesToOam_withOffset

;;
; @param	hl	Étape du saut (wTmpcbba pour Link, wTmpcbb6 pour Marine ; 0 = pas de saut)
; @param[out]	b	Décalage vertical du saut
@updateJump:
	ld b,$00
	ld a,(hl)
	or a
	ret z
	inc (hl)
	cp @jumpOffsetsEnd-@jumpOffsets
	jr c,+
	; trois sauts, puis on reste comme ça
	ld (hl),$00
	ret
+
	ld hl,@jumpOffsets
	rst_addAToHl
	ld b,(hl)
	ret

@jumpOffsets: ; (valeurs négatives = vers le haut)
	.db $00 $fe $fc $fa $f9 $f8 $f7 $f7 $f7 $f8 $f9 $fa $fc $fe $00 $00 $00 $00
	.db $00 $fe $fc $fa $f9 $f8 $f7 $f7 $f7 $f8 $f9 $fa $fc $fe $00 $00 $00 $00
	.db $00 $fe $fc $fa $f9 $f8 $f7 $f7 $f7 $f8 $f9 $fa $fc $fe $00
@jumpOffsetsEnd:

@bobOffsets:
	.db 0 0 1 1 1 0 0 $ff

; Listes de sprites : nombre, puis (y, x, tuile, attributs). Tuiles : voir spr_film.png
; (ligne 0 : Link profil/dos/face/joie, Marine posée/vol/clin d'œil, bulle ;
;  ligne 1 : rondin, soleil, cœur). Palettes : 0 Link, 1 Marine, 2 bois, 3 soleil, 4 bulle.
@linkSprites:
	.dw @linkSide
	.dw @linkBack
	.dw @linkJoy

@linkSide: ; de profil, tourné vers la droite (miroir)
	.db $02
	.db $00 $00 $02 $20
	.db $00 $08 $00 $20
@linkBack:
	.db $02
	.db $00 $00 $04 $00
	.db $00 $08 $06 $00
@linkJoy:
	.db $02
	.db $00 $00 $0c $00
	.db $00 $08 $0e $00

@gullSprites:
	.dw @gullPerched ; (FILM_GULL_HIDDEN, jamais dessinée)
	.dw @gullFlying
	.dw @gullPerched
	.dw @gullWink

@gullPerched:
	.db $02
	.db $00 $00 $10 $01
	.db $00 $08 $12 $01
@gullFlying:
	.db $02
	.db $00 $00 $14 $01
	.db $00 $08 $16 $01
@gullWink:
	.db $02
	.db $00 $00 $18 $01
	.db $00 $08 $1a $01

@bubbleSprites:
	.db $02
	.db $00 $00 $1c $04
	.db $00 $08 $1e $04

@questionSprites:
	.db $02
	.db $00 $00 $38 $04
	.db $00 $08 $3a $04

@logSprites:
	.db $06
	.db $00 $00 $20 $02
	.db $00 $08 $22 $02
	.db $00 $10 $24 $02
	.db $00 $18 $26 $02
	.db $00 $20 $28 $02
	.db $00 $28 $2a $02

@sunSprites:
	.db $04
	.db $00 $00 $2c $03
	.db $00 $08 $2e $03
	.db $00 $10 $30 $03
	.db $00 $18 $32 $03

@heartSprites:
	.db $02
	.db $00 $00 $34 $04
	.db $00 $08 $36 $04
