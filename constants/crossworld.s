.define SRAMBANK_OTHERGAME_BACKUP	$00
.define SRAMBANK_BOOTSTRAP		$01
.define SRAMBANK_AGES			$02
.define SRAMBANK_SEASONS		$03

; SRAMBANK_OTHERGAME_BACKUP
.define AGES_BACKUP			$a000
.define SEASONS_BACKUP			$a550
.define CURRENT_SAVED_GAME_START	$aaa0 ; $0 for ages, $1 for seasons

; FR: Ages-only wram used by the shared bank 0 code (must stay identical in both games)
.define AGES_wPirateShipY		$c6ed
.define AGES_wPirateShipX		$c6ee
