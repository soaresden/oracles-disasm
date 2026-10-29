; ==================================================================================================
; BALLADE: INTERAC_BALLADE_CREUSE ($eb) : chaque sous-type a son code, dans sa propre section
; (object_code/ages/interactions/balladeCreuse.s saute ici : la banque $10 est presque pleine).
; ==================================================================================================
dispatch:
	ld e,Interaction.subid
	ld a,(de)
	rst_jumpTable
	.dw @creuse		; $00 le Creuse-Rubis du forain (code/ages/balladeCreuse.s)
	.dw @pac		; $01 le Labyrinthe des Lynels (balladePac.s)
	.dw @mamono		; $02 l'arène du Mamono (balladeMamono.s)
	.dw @tresor		; $03 la carte au trésor (balladeTresor.s)
	.dw @box		; $04-$09 Ghost Babel (balladeGhost.s)
	.dw @ghostController
	.dw @gaze
	.dw @question
	.dw @radar
	.dw @radarDot
	.dw @terrier		; $0a-$0f le Terrier des Serpents (balladeTerrier.s)
	.dw @soul
	.dw @rex
	.dw @gauntlet
	.dw @jar
	.dw @terrierGhost
	.dw @fin		; $10-$1f la fin du jeu et l'après-jeu (balladeFin.s)
	.dw @zelda
	.dw @epilogue
	.dw @marine
	.dw @islandMarine
	.dw @shell
	.dw @volley
	.dw @volleyBall
	.dw @volleyMarine
	.dw @follower		; $19-$1b Marine suit Link, avec son épée (balladeFin.s)
	.dw @followSpawner
	.dw @marineSword
	.dw @songesNest		; $1c-$22 les Songes des Héros (balladeSonges.s)
	.dw @songesBubble
	.dw @songesForest
	.dw @songesFairy
	.dw @songesMasks
	.dw @songesMask
	.dw @songesSky
	.dw @noItem		; $23 Ghost Babel : « NO ITEM » (balladeGhost.s)
	.dw @zeldaVisit		; $24 Zelda en visite sur l'île de Marine (balladeFin.s)
	.dw @tarkinNeighbor	; $25 Tarkin, le voisin de Marine (balladeFin.s)
	.dw @ringGiver		; $26 un anneau gagné, donné quand la voie est libre (balladeFin.s)

@creuse:
	jpab balladeCreuse.main
@pac:
	jpab balladePac.main
@mamono:
	jpab balladeMamono.main
@tresor:
	jpab balladeTresor.main
@box:
	jpab balladeGhost.box
@ghostController:
	jpab balladeGhost.controller
@gaze:
	jpab balladeGhost.gaze
@question:
	jpab balladeGhost.question
@radar:
	jpab balladeGhost.radar
@radarDot:
	jpab balladeGhost.radarDot
@terrier:
	jpab balladeTerrier.controller
@soul:
	jpab balladeTerrier.soul
@rex:
	jpab balladeTerrier.rex
@gauntlet:
	jpab balladeTerrier.gauntlet
@jar:
	jpab balladeTerrier.jar
@terrierGhost:
	jpab balladeTerrier.ghost
@fin:
	jpab balladeFin.towerEnding
@zelda:
	jpab balladeFin.zelda
@epilogue:
	jpab balladeFin.epilogue
@marine:
	jpab balladeFin.marine
@islandMarine:
	jpab balladeFin.islandMarine
@shell:
	jpab balladeFin.shell
@volley:
	jpab balladeFin.volley
@volleyBall:
	jpab balladeFin.volleyBall
@volleyMarine:
	jpab balladeFin.volleyMarine
@follower:
	jpab balladeFin.follower
@followSpawner:
	jpab balladeFin.followSpawner
@marineSword:
	jpab balladeFin.marineSword
@songesNest:
	jpab balladeSonges.nest
@songesBubble:
	jpab balladeSonges.bubble
@songesForest:
	jpab balladeSonges.forest
@songesFairy:
	jpab balladeSonges.fairy
@songesMasks:
	jpab balladeSonges.masks
@songesMask:
	jpab balladeSonges.mask
@songesSky:
	jpab balladeSonges.sky
@noItem:
	jpab balladeGhost.noItem
@zeldaVisit:
	jpab balladeFin.zeldaVisit
@tarkinNeighbor:
	jpab balladeFin.tarkinNeighbor
@ringGiver:
	jpab balladeFin.ringGiver
