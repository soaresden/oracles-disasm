; Généré par tools/make_music.py depuis music/rythme.txt : ne pas éditer à la main.

; Horloge au début du premier tour de la boucle (pas du moteur son)
.define BALLADE_RHYTHM_INTRO $00f1
; Durée d'un tour (la section A de la boucle)
.define BALLADE_RHYTHM_LOOP $03c0
; Fin du chant de Marine (MUS_BALLADE_RYTHME_FIN) : le boss meurt
.define BALLADE_RHYTHM_FIN_INTRO $04b1

; .dw début de la note (images depuis le début du tour), .db durée ; $ffff = fin du tour
balladeRhythmNotes:
	.dw $0000
	.db $5a ; d5
	.dw $005a
	.db $0f ; b4
	.dw $0069
	.db $0f ; cs5
	.dw $0078
	.db $5a ; d5
	.dw $00d2
	.db $0f ; cs5
	.dw $00e1
	.db $0f ; b4
	.dw $00f0
	.db $0f ; fs4
	.dw $00ff
	.db $2d ; a4
	.dw $012c
	.db $78 ; b4
	.dw $01c2
	.db $0f ; b4
	.dw $01d1
	.db $0f ; cs5
	.dw $01e0
	.db $5a ; d5
	.dw $023a
	.db $0f ; a4
	.dw $0249
	.db $0f ; d5
	.dw $0258
	.db $5a ; g5
	.dw $02b2
	.db $0f ; fs5
	.dw $02c1
	.db $0f ; e5
	.dw $02d0
	.db $78 ; fs5
	.dw $ffff
