; ==================================================================================================
; BALLADE: les photos de Cocolint (CUTSCENE_BALLADE_PHOTOS ; idée de Denis). Lancée à l'auberge du Songe par
; INTERAC_BALLADE_OBJECT $37 (Marine trouve les photos dans la poche de Link) : les vraies photos de
; l'album de Link's Awakening DX, en sépia et en plein écran (tools/make_photos.py : GFXH_PHOTO_1-3,
; PALH_PHOTO, palette 2), une réplique de Marine sur chacune (la boîte de texte dessine dans
; w3VramTiles : la photo y est recopiée ; sa palette 0 reste celle d'origine), la Ballade du Poisson-Rêve en fond ; puis une téléportation sur place ramène Link à
; l'auberge (la salle et la barre d'état se rechargent). wTmpcbb9 : la photo ; wTmpcbb3 : un
; compteur ; wTmpcbbf : la case de Link (photoScene). Seulement des fonctions de la banque 0.
; ==================================================================================================
.define PHOTO_COUNT 3

run:
	ld a,(wCutsceneState)
	rst_jumpTable
	.dw @start
	.dw @load
	.dw @wait
	.dw @text
	.dw @next
	.dw @done

@start:
	ld hl,wCutsceneState
	inc (hl)
	xor a
	ld (wTmpcbb9),a
	ld a,MUS_TITLESCREEN
	call playSound
	jp fadeoutToWhite

	; Une photo : l'écran se recharge, puis le fondu depuis le blanc
@load:
	ld a,(wPaletteThread_mode)
	or a
	ret nz
	call disableLcd
	call clearOam
	ld a,(wTmpcbb9)
	add GFXH_PHOTO_1
	call loadGfxHeader
	ld a,PALH_PHOTO
	call loadPaletteHeader
	call copyVramMapToW3
	ld a,$15
	call loadGfxRegisterStateIndex
	xor a
	ldh (<hCameraX),a
	ldh (<hCameraY),a
	; (la boîte de texte se place aussi d'après ces décalages)
	ld (wScreenOffsetX),a
	ld (wScreenOffsetY),a
	ld a,60
	ld (wTmpcbb3),a
	ld hl,wCutsceneState
	inc (hl)
	jp fadeinFromWhite

	; On la regarde un instant, puis Marine en parle (la boîte en bas)
@wait:
	ld a,(wPaletteThread_mode)
	or a
	ret nz
	ld hl,wTmpcbb3
	dec (hl)
	ret nz
	ld hl,wCutsceneState
	inc (hl)
	ld a,TEXTBOXFLAG_DONTCHECKPOSITION
	ld (wTextboxFlags),a
	ld a,$02
	ld (wTextboxPosition),a
	ld a,(wTmpcbb9)
	ld hl,photoTexts
	rst_addAToHl
	ld c,(hl)
	ld b,>TX_5ae9
	jp showText

@text:
	ld a,(wTextIsActive)
	or a
	ret nz
	ld hl,wCutsceneState
	inc (hl)
	jp fadeoutToWhite

	; La suivante, ou le retour à l'auberge (sur la case de Link)
@next:
	ld a,(wPaletteThread_mode)
	or a
	ret nz
	ld hl,wTmpcbb9
	inc (hl)
	ld a,(hl)
	ld hl,wCutsceneState
	cp PHOTO_COUNT
	jr nc,+
	ld (hl),$01
	ret
+
	inc (hl)
	; (la musique de la salle : en y revenant, le jeu ne la relance pas, la Ballade continuerait)
	ld a,(wActiveMusic)
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
; La boîte de texte dessine (et efface) dans la copie de l'écran en WRAM (w3VramTiles,
; w3VramAttributes, textbox.s) : y mettre la photo (lue dans la VRAM, l'écran est éteint)
copyVramMapToW3:
	ld a,$03
	ld ($ff00+R_SVBK),a
	ld hl,$9800
	ld de,w3VramTiles
	call @copy
	ld a,$01
	ld ($ff00+R_VBK),a
	ld hl,$9800
	ld de,w3VramAttributes
	call @copy
	xor a
	ld ($ff00+R_VBK),a
	ld ($ff00+R_SVBK),a
	ret

@copy:
	ld bc,$0240
-
	ldi a,(hl)
	ld (de),a
	inc de
	dec bc
	ld a,b
	or c
	jr nz,-
	ret

; Marine : la chute (« On ne parle PAS de celle-là »), Tarkin et Bow Wow, la falaise (qui a pris la
; photo ?)
photoTexts:
	.db <TX_5ae9, <TX_5aea, <TX_5aeb
