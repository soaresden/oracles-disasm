; This file should be the first thing included in any of the main code files (ages.s, seasons.s, and
; audio.s). It is included at the top of "constants.s" for this reason.


; Pick one. (For now, the regions other than "US" only activate code changes, not asset changes, and
; they aren't complete.)
;.define REGION_JP
.define REGION_US
;.define REGION_EU


; FORCE_SECTIONS causes all sections to be of type "FORCE", preventing the linker from moving them.
; This will allow us to build a vanilla ROM.
.if defined(BUILD_VANILLA) && !defined(FORCE_SECTIONS)
	.define FORCE_SECTIONS
.endif


; "AGES_ENGINE" is like "ROM_AGES", but anything wrapped in this define could potentially be used in
; Seasons as well. Generally this enables extra engine features added in Ages. However, it could
; also cause subtle differences in how certain things work. In general though I'm trying to be
; conservative with using this, so as not to risk breaking anything.
;
; This is enabled by default in the hack-base branch for seasons.
.if defined(ROM_AGES) && !defined(AGES_ENGINE)
	.define AGES_ENGINE
.endif


; Uncomment this to enable bugfixes (even some that weren't in any release).
;.define ENABLE_BUGFIXES


; US/EU versions had many bugfixes. Enable them with either the "REGION_US"/REGION_EU" defines, or
; the "ENABLE_BUGFIXES" define. "ENABLE_BUGFIXES" will also enable bugfixes that were not present
; in any release.
.ifdef REGION_US
	.define ENABLE_US_BUGFIXES
.endif
.ifdef REGION_EU
	.define ENABLE_EU_BUGFIXES
.endif
.ifdef ENABLE_BUGFIXES
	.ifndef ENABLE_US_BUGFIXES
		.define ENABLE_US_BUGFIXES
	.endif
	.ifndef ENABLE_EU_BUGFIXES
		.define ENABLE_EU_BUGFIXES
	.endif
.endif


; Oracle of Ages has some "garbage" data, possibly a side-effect of the build process that caused
; data from previous builds (even from seasons!) to leak into the final ROM. We'll include that data
; only when building vanilla ROMs.
.if defined(BUILD_VANILLA) && defined(REGION_US)
	.define INCLUDE_GARBAGE
.endif



; BALLADE: nombre d'images où il faut garder Select enfoncé pour que Marine parle (un appui plus
; court ouvre la carte)
.define BALLADE_SELECT_HOLD_FRAMES 20
; BALLADE: le noctambule : temps dehors dans le Songe avant de se réveiller (images, 60 par seconde ;
; il commence en sortant de l'auberge ou en jouant de la Lanterne), et quand Marine prévient.
; Trajet parfait de la porte de l'auberge du Songe à l'autre côté de la mer ouverte : 360 images
; (6,0 s, mesuré par tools/test_noctambule.py) ; on laisse 1 seconde de marge.
.define BALLADE_NOCTAMBULE_FRAMES 420
.define BALLADE_NOCTAMBULE_WARNING 120

; BALLADE: les options du jeu (code/ages/balladeOptions.s) : un octet chacune dans la banque 0,
; après la signature « GULLSOPT » ($3fe0) ; tools/options.py les change dans une ROM ou un patch.
; 0 = comme d'habitude.
.define BALLADE_OPTIONS_ADDR		$3fe0
.define BALLADE_OPT_HUD_BAS		$3ff0 ; 1 = la barre d'état en bas de l'écran

; BALLADE: la barre d'état en bas (code/ages/balladeHudBas.s) : prochain événement de l'interruption
; d'affichage (wBalladeHudPhase)
.define BALLADE_HUD_PHASE_GAME		1
.define BALLADE_HUD_PHASE_LCDC_A7	2
.define BALLADE_HUD_PHASE_RING_TEXT	3
.define BALLADE_HUD_PHASE_RING_END	4
.define BALLADE_HUD_PHASE_WAVE		5
.define BALLADE_HUD_PHASE_STATUS	6

; BALLADE: amplitude de l'ondulation de l'écran dans le Songe (en pixels)
.define BALLADE_DREAM_WAVE 2

; BALLADE: boss de fin en rythme (prototype, INTERAC_BALLADE_RHYTHM), réglé tolérant :
; fenêtre d'un coup juste (en images, avant ou après la note ; 12 = 0,2 s)
.define BALLADE_RHYTHM_WINDOW 12
; coups justes d'affilée pour que la harpe revienne, puis la basse
.define BALLADE_RHYTHM_HARP 6
.define BALLADE_RHYTHM_BASS 12
; Marine chante à la fin d'un tour où notes justes - coups dans le vide >= ce nombre (sur 18)
.define BALLADE_RHYTHM_GOAL 14
; nombre de niveaux de musique (un bon tour = un niveau de plus ; après le dernier, Marine chante)
.define BALLADE_RHYTHM_LEVELS 5
; code secret de l'écran titre (Select tenu + Start) écrit en SRAM $bff1 : la partie suivante
; commence dans la salle de test du boss en rythme (balladeRhythm.checkTestStart)
.define BALLADE_RHYTHM_TEST_CODE $a5
; menu de test caché (code/ages/balladeDebug.s) : HAUT tenu ce nombre d'images à l'écran titre
; écrit BALLADE_DEBUG_CODE en SRAM $bff2 ; la partie suivante commence dans la salle du menu
.define BALLADE_DEBUG_HOLD_FRAMES 300
.define BALLADE_DEBUG_CODE $d7
; Marine emporte une bombe (balladeMarine.bombCarrier) : images de vol (2 pixels par image)
.define BALLADE_CARRY_FRAMES 40
; le contre parfait (code/ages/balladeParry.s) : l'épée sortie moins de ce nombre d'images avant
; qu'un ennemi touche Link (6 = un dixième de seconde : difficile, comme l'Issen d'Onimusha) ; un
; boss perd ce nombre de points de vie
.define BALLADE_PARRY_WINDOW 6
.define BALLADE_PARRY_BOSS_DAMAGE 8


; Define to help with building directory strings, maybe other stuff
.ifdef ROM_SEASONS
	.define GAME "seasons"
.else
	.define GAME "ages"
.endif

; Game-specific data directory location
.define GAME_DATA_DIR "data/" GAME "/"


; HACK-BASE: Disable intro locks (on menus, etc) when quickstart is enabled.
; Allows quickstart to work even on files that haven't cleared the intro.
.if defined(QUICKSTART_ENABLE) && !defined(HACK_DISABLE_INTRO_LOCKS)
	.define HACK_DISABLE_INTRO_LOCKS
.endif
