; ==================================================================================================
; BALLADE: les options du jeu, un octet chacune, à une adresse fixe de la banque 0 (après la
; signature) : tools/options.py les retrouve et les change dans une ROM ou dans un patch, sans
; recompiler. 0 = comme d'habitude. Adresses : constants/common/version.s (BALLADE_OPT_*).
; ==================================================================================================

.BANK $00 SLOT 0
.ORGA BALLADE_OPTIONS_ADDR

.SECTION Ballade_Options FORCE

	.ASC "GULLSOPT"		; signature cherchée par tools/options.py
	.db $01			; version de la table
	.dsb 7 $00

	; Valeurs par défaut
	.db $00	; BALLADE_OPT_HUD_BAS : 0 la barre d'état en haut (comme Ages), 1 en bas
	.dsb 15 $00

.ENDS
