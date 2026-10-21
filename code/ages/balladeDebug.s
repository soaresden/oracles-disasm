; ==================================================================================================
; BALLADE: le menu de test caché (pour tester les niveaux sans refaire tout le jeu).
;
; À l'écran titre, TENIR HAUT 5 secondes (BALLADE_DEBUG_HOLD_FRAMES) : petit son de secret, puis
; Start et un fichier (ou une nouvelle partie). La partie commence dans une salle vide (3:9f) où
; INTERAC_BALLADE_DEBUG ouvre des boîtes de choix : la langue, l'île (1-8), le moment (Plage,
; Ville, Donjon -> Entrée / M-boss / Boss, Fin). Link est envoyé là avec les objets et les drapeaux de
; l'histoire « comme s'il avait tout joué avant », sans sauvegarde d'état.
;
; Le code est en SRAM $bff2 (comme celui du boss en rythme en $bff1), effacé à chaque écran titre
; et à chaque début de partie : invisible pour un joueur normal.
;
; Pour ajouter une île : remplir sa ligne de debugEntries et ses étapes dans debugMilestones.
; ==================================================================================================

; Les ordres des listes (debugMilestones et listes en plus)
.enum 0
	DBG_END		db ; fin d'une étape (ou d'une liste)
	DBG_TREASURE	db ; trésor, paramètre : giveTreasure
	DBG_WRITE	db ; adresse (2 octets), valeur
	DBG_OR		db ; adresse (2 octets), masque
	DBG_ROOMFLAG	db ; groupe, salle, masque
	DBG_RHYTHM	db ; (rien) : le boss en rythme lancé comme par son code secret
	DBG_FULLHEALTH	db ; (rien) : cœurs remplis
	DBG_GLOBALFLAG	db ; drapeau global (GLOBALFLAG_*) mis à 1
.ende

;;
; À chaque image de l'écran titre (titleGull.s) : HAUT seul, tenu, compte les images
titleCheck:
	ld hl,wBalladeDebugHold
	ld a,(wKeysPressed)
	cp BTN_UP
	jr nz,@reset
	ld e,(hl)
	inc hl
	ld d,(hl)
	; Déjà déclenché : on attend qu'il lâche
	ld a,d
	cp >BALLADE_DEBUG_HOLD_FRAMES
	jr nz,+
	ld a,e
	cp <BALLADE_DEBUG_HOLD_FRAMES
	ret z
+
	inc de
	ld (hl),d
	dec hl
	ld (hl),e
	ld a,d
	cp >BALLADE_DEBUG_HOLD_FRAMES
	ret nz
	ld a,e
	cp <BALLADE_DEBUG_HOLD_FRAMES
	ret nz
	ld a,SND_SOLVEPUZZLE_2
	call playSound
	ld a,BALLADE_DEBUG_CODE
	jr writeCode
@reset:
	xor a
	ldi (hl),a
	ld (hl),a
	ret

;;
; Au chargement de l'écran titre : le code ne vaut que pour ce passage au titre
titleClear:
	xor a
	ld (wBalladeDebugHold),a
	ld (wBalladeDebugHold+1),a

;;
; @param	a	Valeur à écrire en SRAM $bff2
writeCode:
	ld b,a
	ld a,$0a
	ld ($1111),a
	ld a,b
	ld ($bff2),a
	xor a
	ld ($1111),a
	ret

;;
; Début d'une partie (initializeGame, bank1.s) : si le code a été fait, la partie commence dans la
; salle du menu (3:9f).
checkStart:
	ld a,$0a
	ld ($1111),a
	ld a,($bff2)
	ld b,a
	xor a
	ld ($bff2),a
	ld ($1111),a
	ld a,b
	cp BALLADE_DEBUG_CODE
	ret nz
	ld hl,@spawn
	ld de,wDeathRespawnBuffer
	ld b,$06
	jp copyMemory

; groupe, salle, (saison), direction, y, x
@spawn:
	.db $03 $9f $00 DIR_UP $58 $78


;;
; INTERAC_BALLADE_DEBUG : les boîtes de choix, puis le départ. Les boîtes d'Ages n'affichent que
; deux lignes : la langue ; l'île (1-8) ; Plage / Ville / Donjon / Fin ; pour Donjon : Entrée /
; M-boss / Boss. Le moment (0-5) : Plage, Ville, Donjon (l'entrée), M-boss, Boss, Fin.
main:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw @state0
	.dw @state1
	.dw @state2
	.dw @state3
	.dw @state4
	.dw @state5

; Arrivée : on attend la fin du fondu et une demi-seconde (avant, Link n'est pas encore en place
; et la boîte de texte serait effacée aussitôt) ; puis la langue
@state0:
	ld a,(wPaletteThread_mode)
	or a
	ret nz
	; (textThreadStart refuse les textes tant que wScrollMode n'a pas le bit 0)
	ld a,(wScrollMode)
	rrca
	ret nc
	ld e,Interaction.counter1
	ld a,(de)
	inc a
	ld (de),a
	cp 30
	ret c
	call interactionIncState
	ld a,$91
	ld (wDisabledObjects),a
	ld bc,TX_5af0
	jp showText

; La langue choisie (0 = Français, 1 = English) ; puis l'île
@state1:
	ld a,(wTextIsActive)
	or a
	ret nz
	call interactionIncState
	ld a,(wSelectedTextOption)
	xor $01
	ld (wActiveLanguage),a
	ld bc,TX_5af1
	jp showText

; L'île (0-7) ; puis le moment
@state2:
	ld a,(wTextIsActive)
	or a
	ret nz
	call interactionIncState
	ld a,(wSelectedTextOption)
	ld e,Interaction.var30
	ld (de),a
	ld bc,TX_5af2
	jp showText

; Plage (0), Ville (1), Donjon (2 : une boîte de plus), Fin (3 -> moment 5)
@state3:
	ld a,(wTextIsActive)
	or a
	ret nz
	ld a,(wSelectedTextOption)
	cp $02
	jr nz,+
	call interactionIncState
	ld bc,TX_5af3
	jp showText
+
	cp $03
	jr nz,@go
	ld a,$05
	jr @go

; Dans le donjon : Entrée (2), M-boss (3), Boss (4)
@state4:
	ld a,(wTextIsActive)
	or a
	ret nz
	ld a,(wSelectedTextOption)
	add $02

; @param	a	Le moment (0-5) : on applique les étapes, puis on part
@go:
	; Entrée = debugEntries + (île * 6 + moment) * 6
	ld c,a
	ld e,Interaction.var30
	ld a,(de)
	ld b,a
	add a
	add b
	add a ; île * 6
	add c
	ld l,a
	ld h,$00
	ld b,h
	ld c,l
	add hl,hl
	add hl,bc
	add hl,hl ; * 6
	ld bc,debugEntries
	add hl,bc

	; Pas encore construit : un son d'erreur, et on recommence au choix de l'île
	ld a,(hl)
	cp $ff
	jr nz,+
	ld a,SND_ERROR
	call playSound
	ld e,Interaction.state
	ld a,$02
	ld (de),a
	ld bc,TX_5af1
	jp showText
+
	ld e,Interaction.state
	ld a,$05
	ld (de),a
	push hl
	; Les étapes de l'histoire : les (a) premières de debugMilestones
	ld a,(hl)
	ld b,a
	ld hl,debugMilestones
@nextMilestone:
	ld a,b
	or a
	jr z,@milestonesDone
	push bc
	call runList
	pop bc
	dec b
	jr @nextMilestone
@milestonesDone:
	pop hl
	inc hl

	; La destination : groupe, salle, case ; puis la liste en plus (clés du donjon...)
	ld de,wTmpcbb3
	ldi a,(hl)
	ld (de),a
	inc de
	ldi a,(hl)
	ld (de),a
	inc de
	ldi a,(hl)
	ld (de),a
	ldi a,(hl)
	ld h,(hl)
	ld l,a
	call runList

	ld a,(wTmpcbb3)
	or $80
	ld (wWarpDestGroup),a
	ld a,(wTmpcbb3+1)
	ld (wWarpDestRoom),a
	ld a,(wTmpcbb3+2)
	ld (wWarpDestPos),a
	; case $ff : l'entrée d'un donjon, comme par sa porte (transition $93, départ « instantané » :
	; le nom du donjon s'affiche, le donjon s'initialise)
	ld b,$03 ; fondu
	inc a
	ld a,$00
	jr nz,+
	ld b,TRANSITION_SRC_INSTANT
	ld a,$93
+
	ld (wWarpTransition),a
	ld a,b
	ld (wTmpcbb3+3),a
	ld a,(wTmpcbb3+3)
	ld (wWarpTransition2),a
	xor a
	ld (wDisabledObjects),a
	ld a,SND_SOLVEPUZZLE_2
	jp playSound

@state5:
	ret


;;
; Exécute une liste d'ordres DBG_* jusqu'à DBG_END
; @param	hl	La liste
; @param[out]	hl	Juste après le DBG_END
runList:
	ldi a,(hl)
	or a
	ret z
	push hl
	rst_jumpTable
	.dw $0000
	.dw @treasure
	.dw @write
	.dw @or
	.dw @roomFlag
	.dw @rhythm
	.dw @fullHealth
	.dw @globalFlag

@treasure:
	pop hl
	ldi a,(hl)
	ld c,(hl)
	inc hl
	push hl
	call giveTreasure
	pop hl
	jr runList

@write:
	pop hl
	call @readAddress
	ldi a,(hl)
	ld (de),a
	jr runList

@or:
	pop hl
	call @readAddress
	ld a,(de)
	or (hl)
	inc hl
	ld (de),a
	jr runList

@roomFlag:
	pop hl
	ldi a,(hl)
	ld c,a
	ldi a,(hl)
	ld b,a
	push hl
	ld a,c
	call getRoomFlags
	ld d,h
	ld e,l
	pop hl
	ld a,(de)
	or (hl)
	inc hl
	ld (de),a
	jr runList

@rhythm:
	; Comme balladeRhythm.checkTestStart : on revient au titre après le boss
	ld a,BALLADE_RHYTHM_TEST_CODE
	ld (wBalladeRhythmTest),a
	ld hl,wDeathRespawnBuffer
	ld de,wBalladeRhythmSpawn
	ld b,$06
	call copyMemory
	pop hl
	jr runList

@fullHealth:
	ld a,(wLinkMaxHealth)
	ld (wLinkHealth),a
	pop hl
	jr runList

@globalFlag:
	pop hl
	ldi a,(hl)
	push hl
	call setGlobalFlag
	pop hl
	jr runList

; @param	hl	L'adresse (2 octets)
; @param[out]	de	L'adresse
@readAddress:
	ldi a,(hl)
	ld e,a
	ldi a,(hl)
	ld d,a
	ret


; Les entrées du menu : 8 îles x 6 moments (Plage, Ville, Donjon, M-boss, Boss, Fin).
; Chaque entrée : nombre d'étapes de debugMilestones à appliquer ($ff = pas encore construit), groupe,
; salle, case (YX) d'arrivée, liste en plus (pointeur).
debugEntries:
	; 1. L'île de la Brume
	.db $00, $01, $aa, $42 ; la plage du réveil (Marine arrive)
	.dw debugNone
	.db $01, $01, $9b, $65 ; la place de Port-Veille, l'épée en main
	.dw debugNone
	.db $01, $04, $24, $97 ; le hall du Phare Éteint
	.dw debugNone
	.db $02, $04, $18, $97 ; le mini-boss (le Ghini géant), avec la Lanterne
	.dw debugNone
	.db $02, $04, $12, $27 ; sous la porte de Jack, avec la clé du boss
	.dw debugPhareBossKey
	.db $03, $01, $7b, $58 ; le cap : l'essence est là, la fin du chapitre 1
	.dw debugNone
	; 2. Hameau-Grelot
	.db $05, $01, $31, $44 ; la jetée, en arrivant avec le Bateau-Rondin
	.dw debugNone
	.db $05, $01, $11, $44 ; la place du Grelot
	.dw debugNone
	.db $07, $04, $39, $97 ; l'entrée du Coffre à Jouets (bombes, Marine les porte, Lila dort)
	.dw debugNone
	.db $08, $04, $2d, $52 ; devant le volet du Soldat de Plomb (le cristal touché, le boomerang)
	.dw debugCoffreCrystal
	.db $08, $04, $2e, $96 ; l'antichambre de Pantin-Sans-Fil, avec la clé du boss
	.dw debugCoffreBossKey
	.db $09, $03, $21, $46 ; chez Lila, l'essence en poche : la fin du chapitre 2
	.dw debugNone
	; 3. Lagune des Serments
	.db $0a, $01, $24, $33 ; le ponton, en arrivant (la fin du chapitre 2 vue)
	.dw debugNone
	.db $0a, $01, $06, $44 ; devant la maison d'Héloïse et Gaspard
	.dw debugNone
	.db $0b, $05, $44, $97 ; le Récif Murmurant, l'entrée (les Palmes)
	.dw debugNone
	.db $0b, $05, $37, $97 ; Vire (la petite clé 1 utilisée)
	.dw debugNone
	.db $0c, $05, $38, $87 ; l'antichambre (les Écailles, la clé du boss)
	.dw debugRecifBossKey
	.db $0d, $01, $35, $34 ; la plage des bouteilles, l'essence en poche : la fin du chapitre 3
	.dw debugNone
	; 4. Mont-Braise
	.db $ff, $00, $00, $00
	.dw debugNone
	.db $ff, $00, $00, $00
	.dw debugNone
	.db $ff, $00, $00, $00
	.dw debugNone
	.db $ff, $00, $00, $00
	.dw debugNone
	.db $ff, $00, $00, $00
	.dw debugNone
	.db $ff, $00, $00, $00
	.dw debugNone
	; 5. Île des Échos
	.db $ff, $00, $00, $00
	.dw debugNone
	.db $ff, $00, $00, $00
	.dw debugNone
	.db $ff, $00, $00, $00
	.dw debugNone
	.db $ff, $00, $00, $00
	.dw debugNone
	.db $ff, $00, $00, $00
	.dw debugNone
	.db $ff, $00, $00, $00
	.dw debugNone
	; 6. Nid des Vents
	.db $ff, $00, $00, $00
	.dw debugNone
	.db $ff, $00, $00, $00
	.dw debugNone
	.db $ff, $00, $00, $00
	.dw debugNone
	.db $ff, $00, $00, $00
	.dw debugNone
	.db $ff, $00, $00, $00
	.dw debugNone
	.db $ff, $00, $00, $00
	.dw debugNone
	; 7. Grand Sommeil
	.db $ff, $00, $00, $00
	.dw debugNone
	.db $ff, $00, $00, $00
	.dw debugNone
	.db $ff, $00, $00, $00
	.dw debugNone
	.db $ff, $00, $00, $00
	.dw debugNone
	.db $ff, $00, $00, $00
	.dw debugNone
	.db $ff, $00, $00, $00
	.dw debugNone
	; 8. Œil de l'Insomnis (seul le boss en rythme existe, dans sa salle de test)
	.db $ff, $00, $00, $00
	.dw debugNone
	.db $ff, $00, $00, $00
	.dw debugNone
	.db $ff, $00, $00, $00
	.dw debugNone
	.db $ff, $00, $00, $00
	.dw debugNone
	.db $03, $04, $4a, $77 ; le boss en rythme (prototype)
	.dw debugRhythmTest
	.db $ff, $00, $00, $00
	.dw debugNone

; Les étapes de l'histoire, dans l'ordre du jeu (chacune finit par DBG_END)
debugMilestones:
	; 1. Le réveil sur la plage : Marine est venue, l'épée du vieux pêcheur
	.db DBG_ROOMFLAG, $01, $aa, $40
	.db DBG_TREASURE, TREASURE_SWORD, $01
	.db DBG_END
	; 2. Dans le Phare : la Lanterne des Songes
	.db DBG_TREASURE, TREASURE_HARP, $03
	.db DBG_END
	; 3. Jack est battu : l'essence et un cœur de plus
	.db DBG_TREASURE, TREASURE_ESSENCE, $00
	.db DBG_TREASURE, TREASURE_HEART_CONTAINER, $04
	.db DBG_FULLHEALTH
	.db DBG_END
	; 4. La fin du chapitre 1 a été vue (le cap) ; l'aubergiste a donné le Carnet des Rêves
	.db DBG_ROOMFLAG, $01, $7b, $40
	.db DBG_TREASURE, TREASURE_12, $00
	.db DBG_END
	; 5. Marine a lu le vent : le Bateau-Rondin, Hameau-Grelot ; 100 rubis (ceux du Phare)
	.db DBG_GLOBALFLAG, GLOBALFLAG_BALLADE_RAFT
	.db DBG_GLOBALFLAG, GLOBALFLAG_BALLADE_ISLAND2
	.db DBG_WRITE
	.dw wNumRupees
	.db $00
	.db DBG_WRITE
	.dw wNumRupees+1
	.db $01
	.db DBG_END
	; 6. Les bombes de Pépin ; Marine sait les porter (la grotte de la Boîte)
	.db DBG_TREASURE, TREASURE_BOMBS, $10
	.db DBG_GLOBALFLAG, GLOBALFLAG_BALLADE_MARINE_BOMB
	.db DBG_ROOMFLAG, $05, $b0, $40
	.db DBG_END
	; 7. Sire Bouchon rendu : Lila dort, son rêve est ouvert
	.db DBG_GLOBALFLAG, GLOBALFLAG_BALLADE_LILA_ASLEEP
	.db DBG_END
	; 8. Le Boomerang-Toupie
	.db DBG_TREASURE, TREASURE_BOOMERANG, $01
	.db DBG_END
	; 9. Pantin-Sans-Fil est battu : l'essence (le 2e couplet), un cœur de plus
	.db DBG_TREASURE, TREASURE_ESSENCE, $01
	.db DBG_TREASURE, TREASURE_HEART_CONTAINER, $04
	.db DBG_FULLHEALTH
	.db DBG_END
	; 10. La fin du chapitre 2 a été vue (chez Lila, la place) : la Lagune des Serments est repérée
	.db DBG_ROOMFLAG, $03, $21, $40
	.db DBG_GLOBALFLAG, GLOBALFLAG_BALLADE_ISLAND3
	.db DBG_END
	; 11. Gaspard a eu sa bouteille : les Palmes de Zora
	.db DBG_TREASURE, TREASURE_FLIPPERS, $00
	.db DBG_END
	; 12. Vire est battu : les Écailles de Sirène
	.db DBG_TREASURE, TREASURE_MERMAID_SUIT, $00
	.db DBG_END
	; 13. La Murène du Silence est battue : l'essence (le 3e couplet), un cœur de plus
	.db DBG_TREASURE, TREASURE_ESSENCE, $02
	.db DBG_TREASURE, TREASURE_HEART_CONTAINER, $04
	.db DBG_FULLHEALTH
	.db DBG_END

debugNone:
	.db DBG_END

debugPhareBossKey:
	.db DBG_OR
	.dw wDungeonBossKeys
	.db $02
	.db DBG_END

debugCoffreCrystal:
	.db DBG_WRITE
	.dw wSwitchState
	.db $01
	.db DBG_END

debugCoffreBossKey:
	.db DBG_OR
	.dw wDungeonBossKeys
	.db $04
	.db DBG_END

debugRecifBossKey:
	.db DBG_OR
	.dw wDungeonBossKeys
	.db $08
	.db DBG_END

debugRhythmTest:
	.db DBG_RHYTHM
	.db DBG_END
