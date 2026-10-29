; Généré par tools/make_credits.py depuis story/generique.txt (ne pas modifier à la main) :
; le générique qui défile (code/ages/cutscenes/generique.s).
.define CREDITS_TILES 71
.define CREDITS_FADE_FRAME 5550 ; la musique finit : fondu
.define CREDITS_END_FRAME 5670 ; puis le retour au jeu
.define CREDITS_SCROLL_END_FR 1424 ; FIN au milieu de l'écran (en pixels)
.define CREDITS_STEP_FR $45 ; la vitesse, en 1/256 de pixel par image
.define CREDITS_SCROLL_END_EN 1424 ; FIN au milieu de l'écran (en pixels)
.define CREDITS_STEP_EN $45 ; la vitesse, en 1/256 de pixel par image

; La palette de chaque rangée (fr)
creditsPalettesFr:
	.db 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0 0 0
	.db 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 1 1
	.db 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0
	.db 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 1 1
	.db 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.db 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0
	.db 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

; La palette de chaque rangée (en)
creditsPalettesEn:
	.db 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0 0 0
	.db 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 1 1
	.db 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0
	.db 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 1 1
	.db 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.db 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0
	.db 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
