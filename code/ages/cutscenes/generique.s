; ==================================================================================================
; BALLADE: le générique de fin (CUTSCENE_BALLADE_GENERIQUE), qui défile comme celui de Link's
; Awakening (Denis : « le générique, il fallait reprendre celui de Link's Awakening ! pas de barre
; de texte ! »). Lancé par l'épilogue (balladeFin.epilogue), après Marine. Un écran noir ; les
; crédits (story/generique.txt, tools/make_credits.py : la police du jeu, les titres en or) montent
; doucement sur la musique de fin (MUS_BALLADE_GENERIQUE), « FIN » s'arrête au milieu ; à la fin de
; la musique, un fondu au blanc et une téléportation sur place ramènent Link sur la plage (comme
; les photos, code/ages/cutscenes/photos.s).
; La carte de l'écran (32 x 32 tuiles) tourne : la rangée L des crédits va dans la rangée L & 31 ;
; quand une rangée sort par le haut, la suivante prend sa place (queueDmaTransfer, copiée au
; prochain vblank).
; wTmpcbb3-b4 : les images depuis le début ; wTmpcbb5 : la fraction de pixel ; wTmpcbb6-b7 : le
; défilement (pixels) ; wTmpcbb8 : les rangées chargées ; wTmpcbbf : la case de Link (le retour).
; ==================================================================================================

run:
	ld a,(wCutsceneState)
	rst_jumpTable
	.dw @start
	.dw @load
	.dw @roll
	.dw @back
	.dw @done

@start:
	ld hl,wCutsceneState
	inc (hl)
	jp fadeoutToBlack

	; L'écran noir, les tuiles des lettres, les 32 premières rangées ; la musique
@load:
	ld a,(wPaletteThread_mode)
	or a
	ret nz
	call disableLcd
	call clearOam
	ld hl,creditsTiles
	ld de,$8800
	ld b,CREDITS_TILES-1
	ld c,:creditsTiles
	call queueDmaTransfer
	ld hl,wTmpcbb3
	ld b,6
	call clearMemory
-
	call loadRow
	ld a,(wTmpcbb8)
	cp 32
	jr c,-
	call setPalettes
	ld a,$15
	call loadGfxRegisterStateIndex
	xor a
	ldh (<hCameraX),a
	ldh (<hCameraY),a
	ld (wScreenOffsetX),a
	ld (wScreenOffsetY),a
	ld a,MUS_BALLADE_GENERIQUE
	ld (wActiveMusic),a
	call playSound
	ld hl,wCutsceneState
	inc (hl)
	jp fadeinFromBlack

	; Une image : le texte monte (jusqu'à FIN au milieu) ; une rangée de plus quand il le faut ; à la
	; fin de la musique, le fondu
@roll:
	ld hl,wTmpcbb3
	inc (hl)
	jr nz,+
	inc hl
	inc (hl)
+
	; arrivé au bout ?
	call getLanguageData
	ld hl,wTmpcbb6
	ldi a,(hl)
	ld e,a
	ld d,(hl)
	ld a,e
	sub c
	ld a,d
	sbc b
	jr nc,@scrolled
	ld hl,wTmpcbb5
	ld a,(hl)
	add CREDITS_STEP_FR		; (la même vitesse en anglais : vérifié par make_credits)
	ld (hl),a
	jr nc,@scrolled
	inc de
	ld hl,wTmpcbb6
	ld (hl),e
	inc hl
	ld (hl),d
	ld a,e
	ld (wGfxRegs1.SCY),a
	ld (wGfxRegs2.SCY),a
	; la rangée suivante, quand la plus haute est sortie : défilement >= (L - 31) * 8
	ld a,(wTmpcbb8)
	sub 31
	ld l,a
	ld h,$00
	add hl,hl
	add hl,hl
	add hl,hl
	ld a,e
	sub l
	ld a,d
	sbc h
	call nc,loadRow
@scrolled:
	ld hl,wTmpcbb3
	ldi a,(hl)
	sub <CREDITS_FADE_FRAME
	ld a,(hl)
	sbc >CREDITS_FADE_FRAME
	ret c
	ld hl,wCutsceneState
	inc (hl)
	ld a,SNDCTRL_MEDIUM_FADEOUT
	call playSound
	jp fadeoutToWhite

	; Le retour sur la plage (la salle et la barre d'état se rechargent), la musique de l'île
@back:
	ld hl,wTmpcbb3
	inc (hl)
	jr nz,+
	inc hl
	inc (hl)
+
	ld a,(wPaletteThread_mode)
	or a
	ret nz
	ld hl,wTmpcbb3
	ldi a,(hl)
	sub <CREDITS_END_FRAME
	ld a,(hl)
	sbc >CREDITS_END_FRAME
	ret c
	ld hl,wCutsceneState
	inc (hl)
	ld a,MUS_BALLADE_ILE
	ld (wActiveMusic),a
	call playSound
	ld a,(wActiveGroup)
	or $80
	ld (wWarpDestGroup),a
	ld a,(wActiveRoom)
	ld (wWarpDestRoom),a
	ld a,(wTmpcbbf)
	ld (wWarpDestPos),a
	xor a
	ld (wWarpTransition),a
	ld a,$03 ; fondu
	ld (wWarpTransition2),a
	ret

@done:
	ret

;;
; La langue : en anglais (wActiveLanguage = 0), la carte anglaise
; @param[out]	bc	Le défilement final (FIN au milieu)
; @param[out]	de	La carte
; @param[out]	hl	Les palettes des rangées
; @param[out]	a	La banque de la carte
getLanguageData:
	ld a,(wActiveLanguage)
	or a
	jr nz,+
	ld bc,CREDITS_SCROLL_END_EN
	ld de,creditsMapEn
	ld hl,creditsPalettesEn
	ld a,:creditsMapEn
	ret
+
	ld bc,CREDITS_SCROLL_END_FR
	ld de,creditsMapFr
	ld hl,creditsPalettesFr
	ld a,:creditsMapFr
	ret

;;
; Charge la rangée L (wTmpcbb8) des crédits dans la rangée L & 31 de l'écran (ses tuiles, puis ses
; attributs : la palette), et passe à la suivante
loadRow:
	call getLanguageData
	push af
	; la palette de la rangée
	ld a,(wTmpcbb8)
	rst_addAToHl
	ld a,(hl)
	ld (wTmpcbbe),a
	; la source : la carte + L * 32
	ld a,(wTmpcbb8)
	ld l,a
	ld h,$00
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,de
	; la destination : $9800 + (L & 31) * 32
	ld a,(wTmpcbb8)
	and $1f
	ld e,a
	ld d,$00
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	ld a,d
	add $98
	ld d,a
	pop af
	ld c,a
	ld b,$01
	push de
	call queueDmaTransfer
	pop de
	; ses attributs (VRAM 1)
	inc e
	ld hl,creditsAttr0
	ld a,(wTmpcbbe)
	or a
	jr z,+
	ld hl,creditsAttr1
+
	ld b,$01
	ld c,:creditsAttr0
	call queueDmaTransfer
	ld hl,wTmpcbb8
	inc (hl)
	ret

;;
; Les couleurs : le fond noir ; palette 0 les noms en blanc, palette 1 les titres en or (les
; palettes « de base », w2TilesetBgPalettes : le fondu part de là)
setPalettes:
	ld a,$02
	ld ($ff00+R_SVBK),a
	ld hl,@colors
	ld de,w2TilesetBgPalettes
	ld b,16
-
	ldi a,(hl)
	ld (de),a
	inc de
	dec b
	jr nz,-
	xor a
	ld ($ff00+R_SVBK),a
	ret

@colors:
	m_RGB16 $00 $00 $00
	m_RGB16 $08 $08 $0a
	m_RGB16 $14 $14 $16
	m_RGB16 $1f $1f $1f
	m_RGB16 $00 $00 $00
	m_RGB16 $0a $07 $02
	m_RGB16 $18 $12 $04
	m_RGB16 $1f $19 $08

.include "code/ages/balladeCreditsData.s"
