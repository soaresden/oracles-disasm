; ==================================================================================================
; INTERAC_BALLADE_CREUSE (BALLADE) : le Creuse-Rubis du forain. Le code est dans sa propre section
; (code/ages/balladeCreuse.s) : la banque $10 est presque pleine.
; ==================================================================================================
; Sous-type $01 : le Labyrinthe des Lynels (code/ages/balladePac.s) ; $02 : l'arène du Mamono
; (code/ages/balladeMamono.s) ; $03 : la carte au trésor (code/ages/balladeTresor.s) ; $04-$09 :
; Ghost Babel (code/ages/balladeGhost.s).
interactionCodeeb:
	ld e,Interaction.subid
	ld a,(de)
	or a
	jr nz,+
	jpab balladeCreuse.main
+
	dec a
	jr nz,+
	jpab balladePac.main
+
	dec a
	jr nz,+
	jpab balladeMamono.main
+
	dec a
	jr nz,+
	jpab balladeTresor.main
+
	; Ghost Babel ($04-$09)
	dec a
	jr nz,+
	jpab balladeGhost.box
+
	dec a
	jr nz,+
	jpab balladeGhost.controller
+
	dec a
	jr nz,+
	jpab balladeGhost.gaze
+
	dec a
	jr nz,+
	jpab balladeGhost.question
+
	dec a
	jr nz,+
	jpab balladeGhost.radar
+
	jpab balladeGhost.radarDot
