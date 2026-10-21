; FR: Farore's secret list (menu $0a), moved out of bank 2 (no room left there)
; with its names localized (code/crossworldSecretNames.s), and the secrets
; tracker (OPT_SECRETS_TRACKER).
;
; The tracker is the same menu opened from the inventory (A on the top icon of
; the third page), marked with wSubmenuState = FR_TRACKER_MARK. It lists the 10
; exchanges between the games, named after the character of the first
; adventure who gives the reward, with a symbol and a status in the bottom box:
;   -  no secret yet
;   !  something to do in this game (reward to collect / Farore has a gift)
;   >  something to do in the other game
;   <3 complete
; In the first adventure, it only opens once that adventure is finished.
;
; Placed in a free bank (ages.s / seasons.s), called from bank 2 with jpab.

.define FR_TRACKER_TXT_FINISH	$06

frRunSecretListMenu:
	call clearOam
	ld a,TEXT_BANK
	ld ($ff00+R_SVBK),a
	call @runState
	jp frSecretList_drawCursorSprite

@runState:
	ld a,(wSecretListMenu.state)
	rst_jumpTable
	.dw frSecretList_state0
	.dw frSecretList_state1
	.dw frSecretList_state2

;;
; State 0: initialization
frSecretList_state0:
	call disableLcd
	call stopTextThread

	ld a,$01
	ld (wSecretListMenu.state),a
	call @clearVramBank
	xor a
	call @clearVramBank

	ld a,GFXH_05
	call loadGfxHeader
	ld a,PALH_SECRET_LIST_MENU
	call loadPaletteHeader
	xor a
	ld (wFileSelect.fontXor),a
	call frSecretList_loadAllNames
	ld a,$ff
	call frSecretList_printSecret
	call fastFadeinFromWhite
	ld a,$16
	jp loadGfxRegisterStateIndex

;;
; @param	a	Vram bank to fill with $ff
@clearVramBank:
	ld ($ff00+R_VBK),a
	ld hl,$8000
	ld bc,$1000
	ld a,$ff
	jp fillMemoryBc

;;
; State 1: processing input
frSecretList_state1:
	ld a,(wPaletteThread_mode)
	or a
	ret nz

	call frCompletion_isOpen
	jr nz,+
	call frCompletion_input
	ret c
+
	ld a,(wKeysJustPressed)
	and (BTN_START|BTN_SELECT|BTN_B)
	jp nz,frSecretList_close

	call getInputWithAutofire
	ld c,a
	ld hl,wSecretListMenu.numEntries
	ldi a,(hl)
	ld b,a
	ld a,$ff

	bit BTN_BIT_UP,c
	jr nz,@upOrDown
	bit BTN_BIT_DOWN,c
	jr z,@end
	ld a,$01
@upOrDown:
	; Try to move cursor, stop if we're at the maximum
	add (hl) ; hl = wSecretListMenu.cursorIndex
	cp b
	jr nc,@end

	ldi (hl),a
	sub (hl) ; hl = wSecretListMenu.scroll
	cp $01
	jr c,@scrollUp
	cp $03
	jr c,@playSound

@scrollDown:
	ldi a,(hl) ; hl = wSecretListMenu.scroll
	sub b
	cp $fc
	jr nc,@playSound
	ld a,$02
	jr ++

@scrollUp:
	ldi a,(hl)
	or a
	jr z,@playSound
	ld a,$fe
++
	ld (wSecretListMenu.scrollSpeed),a
	ld l,<wSecretListMenu.state
	inc (hl) ; Go to state 2 (scrolling)

@playSound:
	ld a,SND_MENU_MOVE
	call playSound

@end:
	ld a,(wSaveQuitMenu.delayCounter)
	jp frSecretList_printSecret

;;
; State 2: scrolling
frSecretList_state2:
	ld hl,wSecretListMenu.scrollSpeed
	ld a,(wGfxRegs2.SCY)
	add (hl)
	ld (wGfxRegs2.SCY),a
	and $0f
	ret nz

	; Done scrolling
	ld a,(hl)
	sra a
	ld l,<wSecretListMenu.scroll
	add (hl)
	ld (hl),a
	ld l,<wSecretListMenu.state
	dec (hl) ; Go to state 1
	ret

;;
; Same as _closeMenu in bank 2
frSecretList_close:
	ld hl,wMenuLoadState
	inc (hl)
	ld a,SND_CLOSEMENU
	call playSound
	xor a
	ld (wTextIsActive),a
	jp fastFadeoutToWhite

;;
frSecretList_drawCursorSprite:
	ld a,(wGfxRegs2.SCY)
	ld b,a
	ld a,(wSecretListMenu.cursorIndex)
	swap a
	sub b
	ld b,a
	ld c,$00
	ld hl,@cursor
	jp addSpritesToOam_withOffset

@cursor;
	.db $01
	.db $5a $14 $0c $24

;;
; @param	a	Index of secret to print (or $ff for nothing)
frSecretList_printSecret:
	ld hl,wTmpcbb9
	cp (hl)
	ret z

	ld (hl),a
	push af

	ld hl,w7d800
	ld bc,$0300
	call clearMemoryBc

	ld hl,w7SecretText1
	ld b,$c*2
	call clearMemory

	pop af
	cp $ff
	jr z,@end

	ld c,a
	call frTracker_isOpen
	jr z,@tracker
	call frCompletion_isOpen
	jp z,frCompletion_printBox

	ld a,c
	call frSecretList_getSecretData
	ldi a,(hl)
	rlca
	rlca
	and $03
	ld b,a
	ldi a,(hl)
	ld c,(hl)
	call checkGlobalFlag
	ld a,$ff
	ld (wFileSelect.fontXor),a
	jr z,frSecretList_printSecret

	call @getSecretText
	ld hl,w7SecretText1
@copyText:
	ld de,w7d800
	ld b,$c*2
	call frCopyTextCharacters
@end:
	ld a,UNCMP_GFXH_35
	jp loadUncompressedGfxHeader

@tracker:
	call frTracker_isAvailable
	ld a,FR_TRACKER_TXT_FINISH
	jr z,++
	call frTracker_getStatus
	ld b,a
	ld hl,frTrackerUnlinkedBoxes
	call checkIsLinkedGame
	jr z,+
	ld hl,frTrackerLinkedBoxes
+
	ld a,b
	rst_addAToHl
	ld a,(hl)
++
	ld hl,frTrackerBoxTexts
	rst_addDoubleIndex
	ldi a,(hl)
	ld h,(hl)
	ld l,a
	ld a,$ff
	ld (wFileSelect.fontXor),a
	jr @copyText

@getSecretText:
	ld a,b
	rst_jumpTable
	.dw @val0
	.dw @val1
	.dw @val2
	.dw @val3

@val0: ; game-transfer secret
@val1:
	jpab generateGameTransferSecret

@val2: ; ring secret
	ldbc $00,$02
	jp secretFunctionCaller

@val3: ; 5-letter secret
	ld a,c
	ld (wShortSecretIndex),a
	ld c,b
	ld b,$00
	jp secretFunctionCaller

;;
; Loads gfx for all secret names (or tracker rows) directly to vram starting at
; $8a00.
frSecretList_loadAllNames:
	xor a
	ld ($ff00+R_VBK),a

	ld de,$8a00
	call frTracker_isOpen
	jp z,frTracker_loadRows
	call frCompletion_isOpen
	jp z,frCompletion_loadRows

	ld b,$00
@nextSecret:
	ld a,b
	call frSecretList_getSecretData
	ldi a,(hl)
	or a
	jr z,frSecretList_setNumEntries

	push bc
	ld c,a
	ldi a,(hl)
	call checkGlobalFlag
	ld a,$01 ; If we don't have this secret, show a dashed line
	jr z,++

	ld a,c
	and $3f
	call frCopyName
	ld a,$02 ; Put " Secret" after every string
++
	call frCopyName
	pop bc
	call frSecretList_nextRow
	inc b
	jr @nextSecret

;;
; @param	b	Number of rows
frSecretList_setNumEntries:
	ld a,b
	ld (wSecretListMenu.numEntries),a
	ret

;;
; Adjust de to point to the next row
frSecretList_nextRow:
	dec de
	ld e,$00
	ld a,d
	and $fe
	add $02

	; If we've reached address 0:9000, loop around to 1:8000.
	cp $90
	jr c,++
	ld a,$01
	ld ($ff00+R_VBK),a
	ld a,$80
++
	ld d,a
	ret

;;
; @param	a	Index
frSecretList_getSecretData:
	ld hl,wFileIsLinkedGame
	bit 0,(hl)
	ld hl,@unlinked
	jr z,+
	ld hl,@linked
+
	push bc

	ld c,a ; a *= 3
	add a
	add c

	rst_addAToHl
	pop bc
	ret


; The following data is the list of secrets to be displayed on farore's secret list.
;   b0: bits 0-5: Index for name from frSecretTextTable
;       bits 6-7: secret "mode" (0/1=game-transfer, 2=ring secret, 3=other)
;   b1: global flag which, if set, means the secret is unlocked
;   b2: Index of secret data?

.ifdef ROM_AGES
	@unlinked:
		.db $03, GLOBALFLAG_FINISHEDGAME,		$00
		.db $85, GLOBALFLAG_RING_SECRET_GENERATED,	$02
		.db $d0, GLOBALFLAG_DONE_KING_ZORA_SECRET,	$10
		.db $d4, GLOBALFLAG_DONE_LIBRARY_SECRET,	$14
		.db $d5, GLOBALFLAG_DONE_TROY_SECRET,		$12
		.db $d7, GLOBALFLAG_DONE_TINGLE_SECRET,		$17
		.db $d9, GLOBALFLAG_DONE_SYMMETRY_SECRET,	$19
		.db $d1, GLOBALFLAG_DONE_FAIRY_SECRET,		$11
		.db $d8, GLOBALFLAG_DONE_ELDER_SECRET,		$18
		.db $d2, GLOBALFLAG_DONE_TOKAY_SECRET,		$15
		; Don't display plen secret or mamamu secret, since rings can be exchanged
		; through vasu instead.
		.db $00

	@linked:
		.db $85, GLOBALFLAG_RING_SECRET_GENERATED,	$02
		.db $c6, GLOBALFLAG_BEGAN_CLOCK_SHOP_SECRET, 	$20
		.db $ca, GLOBALFLAG_BEGAN_SMITH_SECRET, 	$24
		.db $cb, GLOBALFLAG_BEGAN_PIRATE_SECRET, 	$25
		.db $cd, GLOBALFLAG_BEGAN_DEKU_SECRET, 		$27
		.db $cf, GLOBALFLAG_BEGAN_RUUL_SECRET,	 	$29
		.db $c7, GLOBALFLAG_BEGAN_GRAVEYARD_SECRET, 	$21
		.db $ce, GLOBALFLAG_BEGAN_BIGGORON_SECRET, 	$28
		.db $c8, GLOBALFLAG_BEGAN_SUBROSIAN_SECRET, 	$22
		.db $c9, GLOBALFLAG_BEGAN_DIVER_SECRET, 	$23
		.db $cc, GLOBALFLAG_BEGAN_TEMPLE_SECRET, 	$26
		.db $00

.else; ROM_SEASONS

	@unlinked:
		.db $04, GLOBALFLAG_FINISHEDGAME,		$00
		.db $85, GLOBALFLAG_RING_SECRET_GENERATED,	$02
		.db $c6, GLOBALFLAG_DONE_CLOCK_SHOP_SECRET,	$30
		.db $ca, GLOBALFLAG_DONE_SMITH_SECRET,		$34
		.db $cb, GLOBALFLAG_DONE_PIRATE_SECRET,		$35
		.db $cd, GLOBALFLAG_DONE_DEKU_SECRET,		$37
		.db $cf, GLOBALFLAG_DONE_RUUL_SECRET,		$39
		.db $c7, GLOBALFLAG_DONE_GRAVEYARD_SECRET,	$31
		.db $ce, GLOBALFLAG_DONE_BIGGORON_SECRET,	$38
		.db $c8, GLOBALFLAG_DONE_SUBROSIAN_SECRET,	$32
		.db $00

	@linked:
		.db $85, GLOBALFLAG_RING_SECRET_GENERATED,	$02
		.db $d0, GLOBALFLAG_BEGAN_KING_ZORA_SECRET,	$00
		.db $d4, GLOBALFLAG_BEGAN_LIBRARY_SECRET,	$04
		.db $d5, GLOBALFLAG_BEGAN_TROY_SECRET,		$02
		.db $d7, GLOBALFLAG_BEGAN_TINGLE_SECRET,	$07
		.db $d9, GLOBALFLAG_BEGAN_SYMMETRY_SECRET,	$09
		.db $d1, GLOBALFLAG_BEGAN_FAIRY_SECRET,		$01
		.db $d8, GLOBALFLAG_BEGAN_ELDER_SECRET,		$08
		.db $d2, GLOBALFLAG_BEGAN_TOKAY_SECRET,		$05
		.db $d3, GLOBALFLAG_BEGAN_PLEN_SECRET,		$03
		.db $d6, GLOBALFLAG_BEGAN_MAMAMU_SECRET,	$06
		.db $00

.endif; ROM_SEASONS

;;
; @param	a	Index in frSecretTextTable
; @param	de	Destination
frCopyName:
	ld hl,frSecretTextTable
	rst_addDoubleIndex
	ldi a,(hl)
	ld h,(hl)
	ld l,a

;;
; Same as _copyTextCharactersFromHlUntilNull in bank 2
frCopyTextCharactersUntilNull:
	ldi a,(hl)
	or a
	ret z
	cp $01
	jr z,frCopyTextCharactersUntilNull
	ld c,$00
	cp $06
	jr nz,+
	inc c
	ldi a,(hl)
+
	call copyTextCharacterGfx
	jr frCopyTextCharactersUntilNull

;;
; @param	b	Number of characters to copy
; @param	de	Destination
; @param	hl	Characters
frCopyTextCharacters:
	ldi a,(hl)
	ld c,$00
	cp $06
	jr nz,+
	inc c
	ldi a,(hl)
+
	call copyTextCharacterGfx
	dec b
	jr nz,frCopyTextCharacters
	ret


; ==============================================================================
; Secrets tracker
; ==============================================================================

;;
; @param[out]	zflag	z if the secret list was opened as the tracker
frTracker_isOpen:
	ld a,(wSubmenuState)
	cp FR_TRACKER_MARK
	ret

;;
; The tracker opens in the linked game, and in the first game once finished.
; @param[out]	zflag	z if not available
frTracker_isAvailable:
	call checkIsLinkedGame
	ret nz
	ld a,GLOBALFLAG_FINISHEDGAME
	jp checkGlobalFlag

;;
; @param	de	Vram destination of the first row
frTracker_loadRows:
	call frTracker_isAvailable
	jr nz,+
	ld hl,frTrackerUnavailableRow
	call frCopyTextCharactersUntilNull
	ld b,$01
	jp frSecretList_setNumEntries
+
	ld b,$00
@nextRow:
	push bc
	ld c,b
	call frTracker_getStatus
	ld b,a
	ld hl,frTrackerUnlinkedSymbols
	call checkIsLinkedGame
	jr z,+
	ld hl,frTrackerLinkedSymbols
+
	ld a,b
	rst_addAToHl
	ld a,(hl)
	ld c,$00
	call copyTextCharacterGfx
	ld a,' '
	call copyTextCharacterGfx

	; Name of the character who gives the reward in the first game
	pop bc
	push bc
	ld hl,frTrackerAgesNames
	call checkIsLinkedGame
.ifdef ROM_AGES
	jr z,+
.else
	jr nz,+
.endif
	ld hl,frTrackerSeasonsNames
+
	ld a,b
	rst_addAToHl
	ld a,(hl)
	call frCopyName
	pop bc
	call frSecretList_nextRow
	inc b
	ld a,b
	cp $0a
	jr c,@nextRow
	jp frSecretList_setNumEntries

;;
; State of exchange c. Its flags are named after the game where it begins (the
; linked game): BEGAN when that game gives the secret, DONE in the first game
; when the reward is given, DONE in the linked game when Farore gives hers.
;
; @param	c	Exchange (0-9)
; @param[out]	a	0: no secret yet; 1: secret given, reward waiting in the
;			first game; 2: reward taken, Farore waiting in the linked
;			game; 3: complete
frTracker_getStatus:
	call checkIsLinkedGame
	jr nz,@linked

.ifdef ROM_AGES
	ld b,GLOBALFLAG_FIRST_SEASONS_BEGAN_SECRET
.else
	ld b,GLOBALFLAG_FIRST_AGES_BEGAN_SECRET
.endif
	ld a,b
	add c
	call frCheckOtherGameFlag
	jr z,@ret0
.ifdef ROM_AGES
	call @checkMamamu
	jr nc,+
	call checkGlobalFlag
	jr @mamamu
+
.endif
	ld a,b
	add GLOBALFLAG_FIRST_AGES_DONE_SECRET-GLOBALFLAG_FIRST_AGES_BEGAN_SECRET
	add c
	ld b,a
	call checkGlobalFlag
	jr z,@ret1
	ld a,b
	call frCheckOtherGameFlag
	jr @checkFarore

@linked:
.ifdef ROM_AGES
	ld b,GLOBALFLAG_FIRST_AGES_BEGAN_SECRET
.else
	ld b,GLOBALFLAG_FIRST_SEASONS_BEGAN_SECRET
.endif
	ld a,b
	add c
	call checkGlobalFlag
	jr z,@ret0
.ifdef ROM_SEASONS
	call @checkMamamu
	jr nc,+
	call frCheckOtherGameFlag
	jr @mamamu
+
.endif
	ld a,b
	add GLOBALFLAG_FIRST_AGES_DONE_SECRET-GLOBALFLAG_FIRST_AGES_BEGAN_SECRET
	add c
	ld b,a
	call frCheckOtherGameFlag
	jr z,@ret1
	ld a,b
	call checkGlobalFlag

@checkFarore:
	jr nz,@ret3
	; Exchanges 3 and 6 have no return secret
	ld a,c
	cp $03
	jr z,@ret3
	cp $06
	jr z,@ret3
	ld a,$02
	ret
@mamamu:
	jr z,@ret1
@ret3:
	ld a,$03
	ret

; Mamamu (exchange 6 of the secrets that begin in Seasons) never sets her DONE
; flag: the reward is given once the dog is back.
; @param[out]	cflag	c if exchange 6, a = flag to check in Ages
@checkMamamu:
	ld a,c
	cp $06
	scf
	ccf
	ret nz
	ld a,FR_AGES_GLOBALFLAG_RETURNED_DOG
	scf
	ret
@ret1:
	ld a,$01
	ret
@ret0:
	xor a
	ret

; Status symbol (font characters), by status
frTrackerUnlinkedSymbols:
	.db '-' '!' $18 $14
frTrackerLinkedSymbols:
	.db '-' $18 '!' $14

; Bottom box text (frTrackerBoxTexts), by status
frTrackerUnlinkedBoxes:
	.db $00 $01 $02 $05
frTrackerLinkedBoxes:
	.db $00 $03 $04 $05

; Names (frSecretTextTable) of the characters who give the rewards, by exchange
frTrackerAgesNames:	; King Zora, Fairy, Troy, Plen, Library, Tokay, Mamamu, Tingle, Elder, Symmetry
	.db $10 $11 $15 $13 $14 $12 $16 $17 $18 $19
frTrackerSeasonsNames:	; Clock shop, Graveyard, Subrosian, Diver, Smith, Pirate, Temple, Deku, Biggoron, Ruul
	.db $06 $07 $08 $09 $0a $0b $0c $0d $0e $0f
