; ==================================================================================================
; INTERAC_BALLADE_CREUSE (BALLADE) : le Creuse-Rubis du forain. Le code est dans sa propre section
; (code/ages/balladeCreuse.s) : la banque $10 est presque pleine.
; ==================================================================================================
; Sous-type $01 : le Labyrinthe des Lynels (code/ages/balladePac.s).
interactionCodeeb:
	ld e,Interaction.subid
	ld a,(de)
	or a
	jr nz,+
	jpab balladeCreuse.main
+
	jpab balladePac.main
