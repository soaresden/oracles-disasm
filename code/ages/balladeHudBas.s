; ==================================================================================================
; BALLADE: la barre d'état en bas de l'écran (option BALLADE_OPT_HUD_BAS), comme dans Link's
; Awakening. Reprise de la barre du projet « Zelda Oracles combined » (même auteur).
;
; vblankBody est appelé par vblankInterrupt (balladeHudBasVblank, banque 0) une fois écrits les
; registres du haut de l'écran (wGfxRegsFinal).
;
; Quand l'écran a la barre en haut (wGfxRegsFinal jusqu'à la ligne $0f, ou $17 dans le menu des
; bagues) avec le mode d'interruption 2 (ondulation, le Songe), 3 ou 5 (menu des bagues), tout ce que
; fait lcdInterrupt est fait 16 lignes plus haut avec le défilement 16 pixels plus bas, et la barre
; prend les 16 dernières lignes (à partir de la ligne $80). balladeHudBasLcd (banque 0) joue les
; événements dans l'ordre (wBalladeHudPhase) :
;   BALLADE_HUD_PHASE_GAME       fin du haut : registres du jeu (wGfxRegs3)
;   BALLADE_HUD_PHASE_LCDC_A7    mode 3 : lcdInterrupt_setLcdcToA7
;   BALLADE_HUD_PHASE_RING_TEXT  mode 5 : lcdInterrupt_ringMenu, début de la boîte de texte
;   BALLADE_HUD_PHASE_RING_END   mode 5 : fin de la boîte de texte (liste des bagues)
;   BALLADE_HUD_PHASE_WAVE       mode 2 : une valeur de SCX par ligne, depuis wBigBuffer
;   BALLADE_HUD_PHASE_STATUS     ligne $7f : la barre d'état
; Les objets sont dessinés 16 pixels plus haut (balladeHudCameraY), les sprites des menus aussi
; (balladeHudMenuSpriteY).
;
; wBalladeHudBas : 1 en jeu, 2 dans un menu, 0 si la barre est en haut (ou absente) cette image.
; ==================================================================================================

;;
vblankBody:
	push hl
	push bc
	ld hl,wBalladeHudBas
	ld (hl),$00
	ld a,(BALLADE_OPT_HUD_BAS)
	; (et toujours pendant Ghost Babel, comme dans le jeu : code/ages/balladeGhost.s)
	ld b,a
	ld a,(wBalladeGhostHud)
	or b
	jr z,@end
	ld a,(wGfxRegsFinal.LYC)
	cp $18
	jr nc,@end
	ldh a,(<hLcdInterruptBehaviour)
	cp $02
	jr z,+
	cp $03
	jr z,+
	cp $05
	jr nz,@end
+
	ld a,(wOpenedMenuType)
	or a
	ld a,$01
	jr z,+
	inc a
+
	ld (hl),a
	call moveItemsDown
	ld b,$00

	ld a,(wGfxRegsFinal.LYC)
	sub $10
	jr c,@gameNow

	; Le haut (wGfxRegsFinal) continue jusqu'à la ligne LYC-$10
	ld c,a
	ld hl,wGfxRegsFinal
	call writeShiftedRegs
	ld a,c
	ld ($ff00+R_LYC),a
	ld a,BALLADE_HUD_PHASE_GAME
	ld (wBalladeHudPhase),a
	jr @end

@gameNow:
	; Registres du jeu : wGfxRegs2 quand cette vblank les recopie dans wGfxRegs3
	ld hl,wGfxRegs3
	ld a,(wVBlankChecker)
	inc a
	jr nz,+
	ld hl,wGfxRegs2
+
	call writeShiftedRegs
	call afterGameRegs
@end:
	pop bc
	pop hl
	ret

;;
; Écrit LCDC, SCY, SCX, WY, WX depuis un GfxRegsStruct, 16 lignes plus haut
; @param	hl	GfxRegsStruct
; @param[out]	hl	Son LYC
writeShiftedRegs:
	ldi a,(hl)
	ld ($ff00+R_LCDC),a
	ldi a,(hl)
	add $10
	ld ($ff00+R_SCY),a
	ldi a,(hl)
	ld ($ff00+R_SCX),a
	ldi a,(hl)
	cp $90
	jr nc,+
	sub $10
	jr nc,+
	xor a
+
	ld ($ff00+R_WY),a
	ldi a,(hl)
	ld ($ff00+R_WX),a
	ret

;;
; Prochain événement, une fois les registres du jeu en place
; @param	b	Première ligne où un événement peut encore arriver
; @param	hl	LYC des registres du jeu (là où était le prochain événement de lcdInterrupt)
afterGameRegs:
	ldh a,(<hLcdInterruptBehaviour)
	cp $02
	jr z,@wave
	cp $05
	ld c,BALLADE_HUD_PHASE_RING_TEXT
	jr z,+
	ld c,BALLADE_HUD_PHASE_LCDC_A7
+
	ld a,(hl)
	jr schedule

@wave:
	ld a,b
	or a
	jr nz,+
	inc b
+
	jp waveLine

;;
; Programme l'événement c, qui arrivait à la ligne a sur l'écran d'origine, 16 lignes plus haut ;
; le joue tout de suite si cette ligne est déjà passée.
; @param	a	Ligne d'origine
; @param	b	Première ligne où un événement peut encore arriver
; @param	c	Événement (BALLADE_HUD_PHASE_*)
schedule:
	sub $10
	jr c,@now
	cp b
	jr c,@now
	cp $7f
	jr nc,scheduleStatus
	ld ($ff00+R_LYC),a
	ld a,c
	ld (wBalladeHudPhase),a
	ret
@now:
	ld a,c
	jr runPhase

;;
scheduleStatus:
	ld a,$7f
	ld ($ff00+R_LYC),a
	ld a,BALLADE_HUD_PHASE_STATUS
	ld (wBalladeHudPhase),a
	ret

;;
; Appelé par balladeHudBasLcd (banque 0).
; @param	a	Événement (BALLADE_HUD_PHASE_*)
; @param	b	Première ligne où un événement peut encore arriver
runPhase:
	dec a
	rst_jumpTable
	.dw @game
	.dw @lcdcA7
	.dw @ringText
	.dw @ringEnd
	.dw waveLine
	.dw @statusBar

@game:
	ld hl,wGfxRegs3
	call writeShiftedRegs
	jr afterGameRegs

@lcdcA7:
	ld a,$a7
	ld ($ff00+R_LCDC),a
	jr scheduleStatus

@ringText:
	xor a
	ld ($ff00+R_SCX),a
	ld a,$87
	ld ($ff00+R_LCDC),a
	ld a,(wRingMenu_mode)
	or a
	jr z,scheduleStatus
	ld a,$87
	ld c,BALLADE_HUD_PHASE_RING_END
	jr schedule

@ringEnd:
	ld a,$80+$10
	ld ($ff00+R_SCY),a
	ld a,$c7
	ld ($ff00+R_WY),a
	ld ($ff00+R_WX),a
	jr scheduleStatus

@statusBar:
	ld hl,wGfxRegsFinal
	ldi a,(hl)
	and $df ; Pas de fenêtre (une boîte de texte ou un menu pourrait encore la dessiner)
	ld ($ff00+R_LCDC),a
	ldi a,(hl)
	sub $80
	ld ($ff00+R_SCY),a
	ldi a,(hl)
	ld ($ff00+R_SCX),a
	ld a,$c7
	ld ($ff00+R_LYC),a
	xor a
	ld (wBalladeHudPhase),a
	inc a
	ldh (<hLcdInterruptCounter),a
	ret

;;
; Ondulation (mode 0 après le 2) : SCX de la ligne b-1, qui était la ligne b+$0f, puis la suivante
; @param	b	Ligne suivante
waveLine:
	ld a,b
	add $0f
	ld l,a
	ld h,>wBigBuffer
	ld a,(hl)
	ld ($ff00+R_SCX),a
	ld a,b
	cp $7f
	jp nc,scheduleStatus
	ld ($ff00+R_LYC),a
	ld a,BALLADE_HUD_PHASE_WAVE
	ld (wBalladeHudPhase),a
	ret

;;
; Les icônes A/B (wOam 0-3) peuvent être encore en haut, dessinées avant que la barre passe en bas
; (les cinématiques ne les redessinent pas) : les descendre avant la copie de l'OAM.
moveItemsDown:
	push hl
	ld hl,wOam
	ld c,$04
@next:
	ld a,(hl)
	cp $10
	jr nz,+
	inc l
	ld a,(hl)
	dec l
	cp $50
	jr nc,+
	ld (hl),$90
+
	ld a,l
	add $04
	ld l,a
	dec c
	jr nz,@next
	pop hl
	ret
