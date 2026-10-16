; FR: option switches read by the game, written by the web patcher.
; Bank 0 is shared by both games (and must stay identical in both builds), so
; one copy serves Ages and Seasons. See constants/crossworld.s and fr/options.json.

.BANK $00 SLOT 0
.ORGA OPTIONS_SIGNATURE_ADDR

.SECTION "FR_Options" FORCE

	.ASC "ZOCFROPT"		; signature the patcher looks for
	.db $01			; table version
	.dsb 7 $00

; Default values (all on, except the bottom status bar: top by default)
	.db $01	; OPT_TITLE_COMBINED
	.db $01	; OPT_VASU_SHORTCUT
	.db $01	; OPT_DOOR_ICONS
	.db $01	; OPT_HUD_GAME_ICON
	.db $01	; OPT_LINKED_WARNING
	.db $01	; OPT_AUTO_SECRETS
	.db $00	; OPT_HUD_BOTTOM
	.db $01	; OPT_REWARD_MARKERS
	.db $01	; OPT_SECRETS_TRACKER
	.db $00	; OPT_GBA_SHOP
	.dsb 6 $00

.ENDS
