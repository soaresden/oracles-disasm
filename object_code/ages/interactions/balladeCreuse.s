; ==================================================================================================
; INTERAC_BALLADE_CREUSE (BALLADE) : le Creuse-Rubis du forain. Le code est dans sa propre section
; (code/ages/balladeCreuse.s) : la banque $10 est presque pleine.
; ==================================================================================================
; Sous-type $01 : le Labyrinthe des Lynels (code/ages/balladePac.s) ; $02 : l'arène du Mamono
; (code/ages/balladeMamono.s) ; $03 : la carte au trésor (code/ages/balladeTresor.s).
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
	jpab balladeTresor.main
