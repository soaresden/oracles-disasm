; FR (ZeldaOracleCombinedFR): option switches of the separate games, one byte each
; in bank 0, set by the web patcher (fr/options.json, "hudOffset"). 0 = off.
.define HUD_OPTIONS_SIGNATURE_ADDR	$3fe0
.define OPT_HUD_BOTTOM			$3ff0
.define OPT_GBA_SHOP			$3ff1
.define OPT_MAP_HEARTS			$3ff2
.define OPT_COMPLETION			$3ff3

; wSubmenuState value marking Farore's secret list (menu $0a) as the completion
; menu opened from the heart pieces (openMenu clears it otherwise)
.define FR_COMPLETION_MARK		$fe
; Completion menu without the secret exchanges between the games
.define FR_COMP_NO_SECRETS
