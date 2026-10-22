; FR (ZeldaOracleCombinedFR): option switches read by the game, written by the web
; patcher. See constants/hudOptions.s and fr/options.json ("hudOffset").

.BANK $00 SLOT 0
.ORGA HUD_OPTIONS_SIGNATURE_ADDR

.SECTION "FR_HudOptions" FORCE

	.ASC "ZOCHUDOP"		; signature the patcher looks for
	.db $01			; table version
	.dsb 7 $00

; Default values
	.db $01	; OPT_HUD_BOTTOM
	.db $00	; OPT_GBA_SHOP
	.db $01	; OPT_MAP_HEARTS
	.db $01	; OPT_COMPLETION
	.dsb 12 $00

.ENDS
