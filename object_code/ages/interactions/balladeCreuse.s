; ==================================================================================================
; INTERAC_BALLADE_CREUSE (BALLADE) : les jeux du forain, la carte au trésor, Ghost Babel, le Terrier des
; Serpents, la fin du jeu. Chaque sous-type a son code dans sa propre section (la banque $10 est
; presque pleine) : code/ages/balladeDispatch.s les répartit.
; ==================================================================================================
; Sous-type $01 : le Labyrinthe des Lynels (code/ages/balladePac.s) ; $02 : l'arène du Mamono
; (code/ages/balladeMamono.s) ; $03 : la carte au trésor (code/ages/balladeTresor.s) ; $04-$09 :
; Ghost Babel (code/ages/balladeGhost.s) ; $0a-$0f : le Terrier des Serpents (code/ages/balladeTerrier.s).
interactionCodeeb:
	jpab balladeDispatch.dispatch
