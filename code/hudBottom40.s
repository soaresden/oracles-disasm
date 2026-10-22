; FR: status bar at the bottom of the screen (ported from ZeldaOracleCombinedFR,
; see frHudBottomVblank in bank 0), option OPT_HUD_BOTTOM.

;;
; FR: status bar at the bottom of the screen (OPT_HUD_BOTTOM), like Link's
; Awakening. Called by vblankInterrupt once it wrote the registers of the top of
; the screen (wGfxRegsFinal).
;
; When the screen has the status bar on top (wGfxRegsFinal until line $0f, or
; $17 in the ring menu) with LCD interrupt behaviour 2 (wave effect), 3 or 5
; (ring menu), everything lcdInterrupt does is done 16 lines higher with the
; scroll 16 pixels lower, and the status bar takes the last 16 lines (from line
; $80). frHudBottomLcd runs the events, in order (wFrHudPhase):
;   FRHUD_PHASE_GAME       end of the top part: game registers (wGfxRegs3)
;   FRHUD_PHASE_LCDC_A7    behaviour 3: lcdInterrupt_setLcdcToA7
;   FRHUD_PHASE_RING_TEXT  behaviour 5: lcdInterrupt_ringMenu, textbox start
;   FRHUD_PHASE_RING_END   behaviour 5: textbox end (list menu)
;   FRHUD_PHASE_WAVE       behaviour 2: one SCX value per line from wBigBuffer
;   FRHUD_PHASE_STATUS     line $7f: status bar
; Objects are drawn 16 pixels higher (frGetSpriteCameraY), and so are menu
; sprites (frMenuSpriteYOffset).
;
; wFrHudBottom: 1 in gameplay, 2 in a menu.
frHudBottomVblank_body:
	push hl
	push bc
	ld hl,wFrHudBottom
	ld (hl),$00
	ld a,(OPT_HUD_BOTTOM)
	or a
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
	call frMoveStatusBarItemsDown
	ld b,$00

	ld a,(wGfxRegsFinal.LYC)
	sub $10
	jr c,@gameNow

	; The top part (wGfxRegsFinal) goes on until line LYC-$10
	ld c,a
	ld hl,wGfxRegsFinal
	call frHudWriteShiftedRegs
	ld a,c
	ld ($ff00+R_LYC),a
	ld a,FRHUD_PHASE_GAME
	ld (wFrHudPhase),a
	jr @end

@gameNow:
	; Game registers: wGfxRegs2 when this vblank copies them to wGfxRegs3
	ld hl,wGfxRegs3
	ld a,(wVBlankChecker)
	inc a
	jr nz,+
	ld hl,wGfxRegs2
+
	call frHudWriteShiftedRegs
	call frHudAfterGameRegs
@end:
	pop bc
	pop hl
	ret

;;
; FR: writes LCDC, SCY, SCX, WY, WX from a GfxRegsStruct, 16 lines higher
; @param	hl	GfxRegsStruct
; @param[out]	hl	Its LYC
frHudWriteShiftedRegs:
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
; FR: next event once the game registers are on
; @param	b	First line where an event can still happen
; @param	hl	Game registers' LYC (where lcdInterrupt's next event was)
frHudAfterGameRegs:
	ldh a,(<hLcdInterruptBehaviour)
	cp $02
	jr z,@wave
	cp $05
	ld c,FRHUD_PHASE_RING_TEXT
	jr z,+
	ld c,FRHUD_PHASE_LCDC_A7
+
	ld a,(hl)
	jr frHudSchedule

@wave:
	ld a,b
	or a
	jr nz,+
	inc b
+
	jp frHudWaveLine

;;
; FR: schedules event c, which happened on line a on the original screen, 16
; lines higher; runs it right away if that line is already past.
; @param	a	Original line
; @param	b	First line where an event can still happen
; @param	c	Phase (FRHUD_PHASE_*)
frHudSchedule:
	sub $10
	jr c,@now
	cp b
	jr c,@now
	cp $7f
	jr nc,frHudScheduleStatus
	ld ($ff00+R_LYC),a
	ld a,c
	ld (wFrHudPhase),a
	ret
@now:
	ld a,c
	jr frHudRunPhase

;;
frHudScheduleStatus:
	ld a,$7f
	ld ($ff00+R_LYC),a
	ld a,FRHUD_PHASE_STATUS
	ld (wFrHudPhase),a
	ret

;;
; @param	a	Phase (FRHUD_PHASE_*)
; @param	b	First line where an event can still happen
frHudRunPhase:
	dec a
	rst_jumpTable
	.dw @game
	.dw @lcdcA7
	.dw @ringText
	.dw @ringEnd
	.dw frHudWaveLine
	.dw @statusBar

@game:
	ld hl,wGfxRegs3
	call frHudWriteShiftedRegs
	jr frHudAfterGameRegs

@lcdcA7:
	ld a,$a7
	ld ($ff00+R_LCDC),a
	jr frHudScheduleStatus

@ringText:
	xor a
	ld ($ff00+R_SCX),a
	ld a,$87
	ld ($ff00+R_LCDC),a
	ld a,(wRingMenu_mode)
	or a
	jr z,frHudScheduleStatus
	ld a,$87
	ld c,FRHUD_PHASE_RING_END
	jr frHudSchedule

@ringEnd:
	ld a,$80+$10
	ld ($ff00+R_SCY),a
	ld a,$c7
	ld ($ff00+R_WY),a
	ld ($ff00+R_WX),a
	jr frHudScheduleStatus

@statusBar:
	ld hl,wGfxRegsFinal
	ldi a,(hl)
	and $df ; No window (a textbox or a menu could still be drawing it)
	ld ($ff00+R_LCDC),a
	ldi a,(hl)
	sub $80
	ld ($ff00+R_SCY),a
	ldi a,(hl)
	ld ($ff00+R_SCX),a
	ld a,$c7
	ld ($ff00+R_LYC),a
	xor a
	ld (wFrHudPhase),a
	inc a
	ldh (<hLcdInterruptCounter),a
	ret

;;
; FR: wave effect (lcdInterrupt behaviour 0 after 2): SCX for line b-1, which was
; line b+$0f, then the next line
; @param	b	Next line
frHudWaveLine:
	ld a,b
	add $0f
	ld l,a
	ld h,>wBigBuffer
	ld a,(hl)
	ld ($ff00+R_SCX),a
	ld a,b
	cp $7f
	jp nc,frHudScheduleStatus
	ld ($ff00+R_LYC),a
	ld a,FRHUD_PHASE_WAVE
	ld (wFrHudPhase),a
	ret

;;
; FR: the A/B item sprites (wOam 0-3) may still be at the top, drawn before
; the status bar went to the bottom (cutscenes don't redraw them): move them
; down before the OAM gets copied.
frMoveStatusBarItemsDown:
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
