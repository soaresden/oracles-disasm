; ==================================================================================================
; INTERAC_BALLADE_RHYTHM (BALLADE) : prototype du boss de fin en rythme
; (appelé par interactionCodeea, object_code/ages/interactions/balladeRhythm.s)
;
; Le morceau MUS_BALLADE_RYTHME (music/rythme.txt) joue en entier, mais le jeu coupe ses voix avec
; le registre NR51 du Game Boy (le moteur son d'Ages ne l'écrit qu'au démarrage ; une nouvelle
; musique le remet à $ff, voir code/audio.s) :
;   le bruit (métronome) toujours ; la mélodie le temps d'une note après chaque coup juste ;
;   la harpe à partir de BALLADE_RHYTHM_HARP coups justes d'affilée, la basse à BALLADE_RHYTHM_BASS.
; Le temps vient de wBalladeRhythmClock, compté par le moteur son lui-même (il tourne sur
; l'interruption du minuteur, pas au rythme des images) : le jeu et la musique ne se décalent pas.
; Un appui sur A à BALLADE_RHYTHM_WINDOW images près d'une note de balladeRhythmNotes (table écrite
; par tools/make_music.py) = coup juste. Tolérant (Denis : « c'est pas un jeu de rythme ») : une
; note ratée divise l'enchaînement par deux, un coup dans le vide lui retire 2. À la fin d'un tour,
; si les notes justes du tour moins les coups dans le vide atteignent BALLADE_RHYTHM_GOAL, Marine
; prend son souffle et la chanson monte d'un niveau (MUS_BALLADE_RYTHME, _2 à _5 : un instrument de
; plus à chaque fois, comme les 5 étapes de Lorule Castle) ; après un bon tour au niveau 5, elle
; chante la suite
; (MUS_BALLADE_RYTHME_FIN) et donne le coup de grâce (prototype : tremblement + son de boss
; vaincu). Taper sans arrêt ne marche pas (trop de coups dans le vide).
; Marine encourage Link (TX_5a36-3d) : en arrivant (le morceau ne commence qu'après sa bulle), puis
; à la fin de chaque bon tour, pendant les mesures sans note à frapper. Ses bulles se ferment toutes
; seules (\wait, ~3 s). Pendant une bulle, Link ne bouge pas : pas de jugement.
; Une note se juge à BALLADE_RHYTHM_WINDOW images près ; un coup en retard mais plus près de la note
; suivante compte pour la suivante.
;
; Variables :
;   var30: numéro de la prochaine note à frapper
;   var31/32: horloge au début du tour en cours
;   var33/34: horloge où la note jouée se tait
;   var35: coups justes d'affilée (l'enchaînement)
;   var36: au début du tour suivant : 1 = monter d'un niveau, 2 = Marine chante
;   var37: 1 = Marine a parlé, le morceau a commencé (avant : on ne juge rien)
;   var38: notes justes dans le tour en cours
;   var39: coups dans le vide dans le tour en cours
;   var3a: niveau de la musique (0 à BALLADE_RHYTHM_LEVELS-1)
;   var3b: (Marine chante) 1 = le coup de grâce est lancé
; ==================================================================================================

.include "data/ages/balladeRhythmNotes.s"

main:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw @state0
	.dw @state1
	.dw @state2
	.dw @state3

; Début : la salle est silencieuse (sa musique = SNDCTRL_STOPMUSIC, make_music.py) ; Marine parle,
; puis le morceau commence
@state0:
	call interactionSetAlwaysUpdateBit
	call interactionIncState
	; Venu par le code secret : le fichier retrouve son vrai point de départ (s'il est sauvé)
	ld a,(wBalladeRhythmTest)
	or a
	jr z,+
	push de
	ld hl,wBalladeRhythmSpawn
	ld de,wDeathRespawnBuffer
	ld b,$06
	call copyMemory
	pop de
+
	xor a
	ld (wBalladeRhythmHits),a
	ld h,d
	ld l,Interaction.var30
	ldi (hl),a
	ld (hl),<BALLADE_RHYTHM_INTRO
	inc l
	ld (hl),>BALLADE_RHYTHM_INTRO
	inc l
	ld b,Interaction.var3b-Interaction.var33+1
-
	ldi (hl),a
	dec b
	jr nz,-
	inc a
	ld (wBalladeRhythmStage),a
	ld a,$88
	ld ($ff00+R_NR51),a
	; une demi-seconde avant que Marine parle (l'arrivée dans la salle efface les bulles et
	; redessine la barre d'état)
	ld e,Interaction.counter1
	ld a,30
	ld (de),a
	ret

; Le combat en rythme
@state1:
	ld e,Interaction.var37
	ld a,(de)
	or a
	jr nz,@playing

	; Avant le morceau : l'épée sur A (salle de test), « Allez, donne-moi le La ! »
	ld h,d
	ld l,Interaction.counter1
	ld a,(hl)
	or a
	jr z,+
	dec (hl)
	ret nz
	call giveSword
	ld bc,TX_5a36
	jp showText
+
	; Sa bulle s'est fermée : le morceau commence (deux mesures de métronome, puis la phrase)
	ld a,(wTextIsActive)
	or a
	ret nz
	ld a,$01
	ld (de),a
	ld a,MUS_BALLADE_RYTHME
	jp startMusic

@playing:
	ld e,Interaction.var36
	ld a,(de)
	or a
	jr z,@noChange

	; Au début du tour suivant : un niveau de plus, ou Marine chante
	call getTime
	bit 7,h
	jr nz,@noChange
	ld e,Interaction.var36
	ld a,(de)
	cp $02
	jp z,startFinale
	xor a
	ld (de),a
	call levelUp

@noChange:
	; Marine parle : Link ne bouge pas, on ne juge pas
	ld a,(wTextIsActive)
	or a
	jp nz,updateVoices

@judge:
	call getNoteEntry
	ldi a,(hl)
	ld c,a
	ld b,(hl)
	call getTime
	ld a,l
	sub c
	ld l,a
	ld a,h
	sbc b
	ld h,a
	; hl = écart avec la note (négatif = en avance) ; + la fenêtre : 0 à 2*fenêtre = juste
	ld bc,BALLADE_RHYTHM_WINDOW
	add hl,bc
	ld a,h
	or a
	jr nz,@outside
	ld a,l
	cp BALLADE_RHYTHM_WINDOW*2+1
	jr nc,@outside

	call checkPressedA
	jp z,updateVoices
	; En retard : si la note suivante est plus près, cette note est ratée et le coup est pour elle
	ld a,l
	sub BALLADE_RHYTHM_WINDOW+1
	jr c,@hit
	inc a
	ld c,a
	call getNextGap
	sub c
	cp c
	jr nc,@hit
	call breakCombo
	call nextNote
	jp @judge

@outside:
	bit 7,h
	jr nz,@early
	; Trop tard : la note est ratée ; on juge aussitôt la suivante (un appui à cette image est
	; peut-être pour elle)
	call breakCombo
	call nextNote
	jp @judge

@early:
	; Un coup dans le vide
	call checkPressedA
	call nz,wildSwing
	jp updateVoices

@hit:
	ld hl,wBalladeRhythmHits
	inc (hl)
	jr nz,+
	dec (hl)
+
	ld e,Interaction.var35
	ld a,(de)
	inc a
	jr z,+
	ld (de),a
+
	ld e,Interaction.var38
	ld a,(de)
	inc a
	ld (de),a
	; La note sonne jusqu'à sa fin : début du tour + début de la note + sa durée
	call getNoteEntry
	ldi a,(hl)
	ld c,a
	ldi a,(hl)
	ld b,a
	ld l,(hl)
	ld h,$00
	add hl,bc
	ld b,h
	ld c,l
	ld h,d
	ld l,Interaction.var31
	ldi a,(hl)
	ld h,(hl)
	ld l,a
	add hl,bc
	ld e,Interaction.var33
	ld a,l
	ld (de),a
	inc e
	ld a,h
	ld (de),a
	call nextNote
	jp updateVoices

; Marine chante : toutes les voix ; à la fin de son chant, le coup de grâce, puis le boss meurt
@state2:
	ld a,$ff
	ld ($ff00+R_NR51),a
	ld e,Interaction.var3b
	ld a,(de)
	or a
	jr nz,@finishingBlow

	call readClock
	ld a,c
	sub <BALLADE_RHYTHM_FIN_INTRO
	ld a,b
	sbc >BALLADE_RHYTHM_FIN_INTRO
	ret c
	; « RETOURNE D'OÙ TU VIENS ! »
	ld a,$01
	ld (de),a
	ld bc,TX_5a3b
	jp showText

@finishingBlow:
	ld a,(wTextIsActive)
	or a
	ret nz
	call interactionIncState
	ld a,$03
	ld (wBalladeRhythmStage),a
	ld a,SND_BOSS_DEAD
	call playSound
	ld a,30
	jp setScreenShakeCounter

; Le boss est vaincu ; venu par le code secret : retour à l'écran titre 4 secondes plus tard
@state3:
	ld a,(wBalladeRhythmTest)
	or a
	ret z
	ld h,d
	ld l,Interaction.counter1
	inc (hl)
	ld a,(hl)
	cp 240
	ret c
	jp resetGame

;;
; Un niveau de plus : le morceau suivant, au début du tour (sans intro : l'horloge vaut 1 au début)
levelUp:
	ld e,Interaction.var3a
	ld a,(de)
	inc a
	ld (de),a
	ld hl,@music
	rst_addAToHl
	ld a,(hl)
	ld h,d
	ld l,Interaction.var31
	ld (hl),$01
	inc l
	ld (hl),$00
	jr startMusic

@music:
	.db MUS_BALLADE_RYTHME, MUS_BALLADE_RYTHME_2, MUS_BALLADE_RYTHME_3, MUS_BALLADE_RYTHME_4
	.db MUS_BALLADE_RYTHME_5

;;
startFinale:
	call interactionIncState
	ld a,$02
	ld (wBalladeRhythmStage),a
	ld a,$ff
	ld ($ff00+R_NR51),a
	; « Je vais me le faire ! »
	ld bc,TX_5a3a
	call showText
	ld a,MUS_BALLADE_RYTHME_FIN

;;
; Lance la musique a et remet l'horloge à zéro (le moteur lance la musique à sa prochaine
; interruption, et l'horloge vaut alors 1 à son premier pas)
startMusic:
	ld (wActiveMusic),a
	di
	call playSound
	xor a
	ld (wBalladeRhythmClock),a
	ld (wBalladeRhythmClock+1),a
	ei
	ret

;;
; Salle de test : l'épée, sur A
giveSword:
	ld a,TREASURE_SWORD
	call checkTreasureObtained
	jr c,+
	ld a,TREASURE_SWORD
	ld c,$01
	call giveTreasure
+
	ld hl,wInventoryB
	ld a,(hl)
	cp ITEM_SWORD
	jr nz,+
	ld (hl),$00
+
	ld a,ITEM_SWORD
	ld (wInventoryA),a
	ld hl,wStatusBarNeedsRefresh
	set 0,(hl)
	ret

;;
; @param[out]	bc	wBalladeRhythmClock
readClock:
	di
	ld a,(wBalladeRhythmClock)
	ld c,a
	ld a,(wBalladeRhythmClock+1)
	ei
	ld b,a
	ret

;;
; @param[out]	hl	Horloge - début du tour en cours (négatif avant le début)
getTime:
	push bc
	call readClock
	ld h,d
	ld l,Interaction.var31
	ld a,c
	sub (hl)
	ld c,a
	inc l
	ld a,b
	sbc (hl)
	ld h,a
	ld l,c
	pop bc
	ret

;;
; @param[out]	a	Images entre la note à frapper et la suivante ($ff si c'est la dernière du tour)
getNextGap:
	push bc
	call getNoteEntry
	ldi a,(hl)
	ld c,a
	ldi a,(hl)
	ld b,a
	inc hl
	ldi a,(hl)
	and (hl)
	inc a
	jr z,@last
	dec hl
	ld a,(hl)
	sub c
	pop bc
	ret
@last:
	pop bc
	ld a,$ff
	ret

;;
; @param[out]	hl	balladeRhythmNotes + 3 * var30
getNoteEntry:
	ld e,Interaction.var30
	ld a,(de)
	ld c,a
	add a
	add c
	ld c,a
	ld b,$00
	ld hl,balladeRhythmNotes
	add hl,bc
	ret

;;
; Note suivante ; à la fin du tour, la phrase recommence un tour plus loin
nextNote:
	ld e,Interaction.var30
	ld a,(de)
	inc a
	ld (de),a
	call getNoteEntry
	ldi a,(hl)
	and (hl)
	inc a
	ret nz

	ld e,Interaction.var30
	ld (de),a
	ld h,d
	ld l,Interaction.var31
	ld a,(hl)
	add <BALLADE_RHYTHM_LOOP
	ldi (hl),a
	ld a,(hl)
	adc >BALLADE_RHYTHM_LOOP
	ld (hl),a

	; Le tour est fini : notes justes - coups dans le vide ; on remet les deux à zéro
	xor a
	ld h,d
	ld l,Interaction.var38
	ld c,(hl)
	ld (hl),a
	inc l
	ld b,(hl)
	ld (hl),a
	ld a,c
	sub b
	ret c
	cp BALLADE_RHYTHM_GOAL
	ret c

	; Un bon tour : Marine reprend son souffle (un niveau de plus), ou chante après le niveau 3
	ld e,Interaction.var3a
	ld a,(de)
	cp BALLADE_RHYTHM_LEVELS-1
	ld a,$01
	jr c,+
	inc a
+
	ld e,Interaction.var36
	ld (de),a
	ld e,Interaction.var3a
	ld a,(de)
	ld hl,@texts
	rst_addDoubleIndex
	ldi a,(hl)
	ld c,a
	ld b,(hl)
	jp showText

; Après les niveaux 1 à 5 : « Ouais... Je reconnais !... », « C'est ça ! Plus fort ! »,
; « Encore ! Je reprends mon souffle... », « Ma voix... Elle revient ! », « Tu as retenu ♥ ! »
@texts:
	.dw TX_5a37, TX_5a3c, TX_5a38, TX_5a3d, TX_5a39

;;
; @param[out]	zflag	Clair si A vient d'être appuyé
checkPressedA:
	ld a,(wGameKeysJustPressed)
	and BTN_A
	ret

;;
; Un coup dans le vide : l'enchaînement perd 2, et il compte contre le tour
wildSwing:
	ld e,Interaction.var39
	ld a,(de)
	inc a
	jr z,+
	ld (de),a
+
	ld e,Interaction.var35
	ld a,(de)
	sub $02
	jr nc,+
	xor a
+
	ld (de),a
	ret

;;
; Une note ratée : l'enchaînement est divisé par deux
breakCombo:
	ld e,Interaction.var35
	ld a,(de)
	srl a
	ld (de),a
	ret

;;
; Les voix qu'on entend (NR51 : bits 0-3 à droite, 4-7 à gauche ; carré 1 = harpe,
; carré 2 = mélodie, onde = basse, bruit = métronome)
updateVoices:
	ld b,$88
	; La mélodie tant que la note jouée n'est pas finie (fin - horloge > 0)
	push bc
	call readClock
	ld h,b
	ld l,c
	pop bc
	ld e,Interaction.var33
	ld a,(de)
	sub l
	ld c,a
	inc e
	ld a,(de)
	sbc h
	bit 7,a
	jr nz,+
	or c
	jr z,+
	ld a,b
	or $22
	ld b,a
+
	ld e,Interaction.var35
	ld a,(de)
	cp BALLADE_RHYTHM_HARP
	jr c,+
	set 0,b
	set 4,b
+
	cp BALLADE_RHYTHM_BASS
	jr c,+
	set 2,b
	set 6,b
+
	ld a,b
	ld ($ff00+R_NR51),a
	ret

;;
; Accès secret au test, depuis l'écran titre (titleGull.s) : Select tenu + Start écrit
; BALLADE_RHYTHM_TEST_CODE en SRAM $bff1 (libre, après les fichiers et la langue en $bff0) ; le
; titre l'efface en s'affichant (titleClearCode).
titleCheckCode:
	ld a,(wKeysJustPressed)
	and BTN_START
	ret z
	ld a,(wKeysPressed)
	and BTN_SELECT
	ret z
	ld a,SND_SOLVEPUZZLE
	call playSound
	ld a,BALLADE_RHYTHM_TEST_CODE
	jr writeTestCode

titleClearCode:
	xor a

;;
; @param	a	Valeur à écrire en SRAM $bff1
writeTestCode:
	ld b,a
	ld a,$0a
	ld ($1111),a
	ld a,b
	ld ($bff1),a
	xor a
	ld ($1111),a
	ret

;;
; Début d'une partie (initializeGame, bank1.s) : si le code secret a été fait, la partie commence
; dans la salle de test (4:4a). Le vrai point de départ est gardé dans wBalladeRhythmSpawn.
checkTestStart:
	ld a,$0a
	ld ($1111),a
	ld a,($bff1)
	ld b,a
	xor a
	ld ($bff1),a
	ld ($1111),a
	ld a,b
	cp BALLADE_RHYTHM_TEST_CODE
	ret nz

	ld (wBalladeRhythmTest),a
	ld hl,wDeathRespawnBuffer
	ld de,wBalladeRhythmSpawn
	ld b,$06
	call copyMemory
	ld hl,@spawn
	ld de,wDeathRespawnBuffer
	ld b,$06
	jp copyMemory

; groupe, salle, (saison), direction, y, x
@spawn:
	.db $04 $4a $00 DIR_UP $78 $78
