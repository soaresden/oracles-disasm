; FR: automatic secrets between the two games, see code/scripting.s
; (_scriptCmd_showPasswordScreen). Placed in a free bank (ages.s / seasons.s).

;;
; FR: automatic secrets between the two games (OPT_AUTO_SECRETS).
;
; A secret asked by an NPC is accepted without the input menu when the other
; game's save shows it was handed out:
; - first secret ($0x in Ages, $2x in Seasons): the other game's BEGAN flag;
; - return secret ($3x in Ages, $1x in Seasons): the other game's DONE flag.
; The results are the same as a correct secret typed in the menu.
;
; @param	wSecretInputType	Secret index; bit 7 gets set if given automatically
frAutoAskSecret:
	ld a,(wSecretInputType)
	ld b,a
	ld a,(OPT_AUTO_SECRETS)
	or a
	jr z,@notGiven
	ld a,b
	and $0f
	cp $0a
	jr nc,@notGiven
	ld c,a
	ld a,b
	swap a
	and $03
.ifdef ROM_AGES
	or a
	ld a,GLOBALFLAG_FIRST_SEASONS_BEGAN_SECRET
	jr z,+
	ld a,GLOBALFLAG_FIRST_AGES_DONE_SECRET
+
.else
	cp $02
	ld a,GLOBALFLAG_FIRST_AGES_BEGAN_SECRET
	jr z,+
	ld a,GLOBALFLAG_FIRST_SEASONS_DONE_SECRET
+
.endif
	add c
	call frCheckOtherGameFlag
	jr z,@notGiven

	ld a,b
	or $80
	ld (wSecretInputType),a
	xor a
	ld (wTextInputResult),a
	ld a,SND_SOLVEPUZZLE
	jp playSound

@notGiven:
	ret

;;
; FR: Farore takes the first return secret that is available: the other game
; finished the exchange (its DONE flag), this game started it (own BEGAN flag)
; but didn't get the reward yet (own DONE flag). Exchanges 3 and 6 have no
; return secret.
; @param[out]	wSecretInputType	0 if a secret was given automatically
frAutoFaroreSecret:
	ld a,(OPT_AUTO_SECRETS)
	or a
	jr z,@none
	ld c,$00
@next:
	ld a,c
	cp $03
	jr z,@skip
	cp $06
	jr z,@skip
.ifdef ROM_AGES
	add GLOBALFLAG_FIRST_AGES_DONE_SECRET
.else
	add GLOBALFLAG_FIRST_SEASONS_DONE_SECRET
.endif
	push af
	call frCheckOtherGameFlag
	pop de
	jr z,@skip
	ld a,d
	call checkGlobalFlag
	jr nz,@skip
	ld a,c
.ifdef ROM_AGES
	add GLOBALFLAG_FIRST_AGES_BEGAN_SECRET
.else
	add GLOBALFLAG_FIRST_SEASONS_BEGAN_SECRET
.endif
	call checkGlobalFlag
	jr z,@skip

	; Same results as the menu for a valid return secret
	xor a
	ld (wSecretInputType),a
	ld a,c
.ifdef ROM_AGES
	add $30
.else
	add $10
.endif
	ld (wTextInputResult),a
	ld a,SND_SOLVEPUZZLE
	jp playSound
@skip:
	inc c
	ld a,c
	cp $0a
	jr c,@next
@none:
	ret

;;
; FR: checks a global flag in the other game's save.
; @param	a	Flag
; @param[out]	zflag	nz if set
frCheckOtherGameFlag:
	ld hl,FR_OTHER_GAME_GLOBALFLAGS
	di
	push af
	ld a,SRAMBANK_OTHERGAME_BACKUP
	ld ($4444),a
	pop af
	call checkFlag
	push af
	ld a,SRAMBANK_BOOTSTRAP
	ld ($4444),a
	pop af
	ei
	ret

