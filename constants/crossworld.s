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

; FR: option switches, one byte each in bank 0 (shared by both games), set by
; the web patcher (fr/options.json must match). 0 = off, anything else = on.
.define OPTIONS_SIGNATURE_ADDR		$3fe0
.define OPT_TITLE_COMBINED		$3ff0
.define OPT_VASU_SHORTCUT		$3ff1
.define OPT_DOOR_ICONS			$3ff2
.define OPT_HUD_GAME_ICON		$3ff3
.define OPT_LINKED_WARNING		$3ff4
.define OPT_AUTO_SECRETS		$3ff5
.define OPT_HUD_BOTTOM			$3ff6

; FR: original Ages titlescreen, used when OPT_TITLE_COMBINED is off
.define FR_GFXH_TITLE_ORIG		$bb
.define FR_PALH_TITLE_ORIG		$cb
