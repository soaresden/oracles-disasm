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
.define OPT_REWARD_MARKERS		$3ff7
.define OPT_SECRETS_TRACKER		$3ff8
.define OPT_GBA_SHOP			$3ff9

; FR: wSubmenuState value marking Farore's secret list (menu $0a) as the
; secrets tracker opened from the inventory (openMenu clears it otherwise)
.define FR_TRACKER_MARK			$ff

; FR: wFrHudPhase values (see frHudBottomVblank)
.define FRHUD_PHASE_GAME		1
.define FRHUD_PHASE_LCDC_A7		2
.define FRHUD_PHASE_RING_TEXT		3
.define FRHUD_PHASE_RING_END		4
.define FRHUD_PHASE_WAVE		5
.define FRHUD_PHASE_STATUS		6

; FR: Ages' GLOBALFLAG_RETURNED_DOG, also read from Seasons: Mamamu (exchange 6
; of the secrets that begin in Seasons) never sets her DONE flag
.define FR_AGES_GLOBALFLAG_RETURNED_DOG	$3b

; FR: original Ages titlescreen, used when OPT_TITLE_COMBINED is off
.define FR_GFXH_TITLE_ORIG		$bb
.define FR_PALH_TITLE_ORIG		$cb

; FR: BG palette of the icons above Vasu's doors
.define FR_DOOR_ICON_PALETTE		$00

; FR: Vasu's shop, where the door to the other game is
.ifdef ROM_AGES
.define VASU_MAP_ROOM			$58
.define VASU_GROUP			$02
.define VASU_ROOM			$ee
.define VASU_OTHER_GAME_DOOR_POS	$57	; a bit in front of the right door
.else
.define VASU_MAP_ROOM			$e8
.define VASU_GROUP			$03
.define VASU_ROOM			$91
.define VASU_OTHER_GAME_DOOR_POS	$53	; a bit in front of the left door
.endif
.define VASU_POS			$55	; map shortcut destination

; FR: set once the player agreed to enter the linked game before finishing the
; first one (OPT_LINKED_WARNING)
.define GLOBALFLAG_FR_LINKED_WARNING_OK	GLOBALFLAG_7f

; FR: the other game's global flags, in its save copy (SRAMBANK_OTHERGAME_BACKUP).
; wFileStart is $c5b0 in both games; wGlobalFlags is $c6d0 (Ages) / $c6ca (Seasons).
.ifdef ROM_AGES
.define FR_OTHER_GAME_GLOBALFLAGS	SEASONS_BACKUP + $c6ca - $c5b0
.else
.define FR_OTHER_GAME_GLOBALFLAGS	AGES_BACKUP + $c6d0 - $c5b0
.endif

; FR: Farore's square on the overworld map (reward markers)
.ifdef ROM_AGES
.define FR_FARORE_MAP_GROUP		$00
.define FR_FARORE_MAP_ROOM		$38
.else
.define FR_FARORE_MAP_GROUP		$00
.define FR_FARORE_MAP_ROOM		$c9
.endif
