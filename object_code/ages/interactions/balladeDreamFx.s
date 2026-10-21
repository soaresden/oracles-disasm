; ==================================================================================================
; INTERAC_BALLADE_DREAM_FX (BALLADE)
;
; Placée dans chaque salle du Songe.
; - Sous-type 0 (dehors) : l'écran ondule doucement, comme sous l'eau. Même procédé que
;   INTERAC_SCREEN_DISTORTION, en beaucoup plus doux et sans fin. L'affichage redevient normal au
;   chargement d'une salle (fondu) : en sortant du Songe, il n'y a rien à défaire.
;   Le mode « vague » de l'interruption d'affichage remplace celui qui affiche les boîtes de texte :
;   l'ondulation se met donc en pause tant qu'un texte est à l'écran.
; - Sous-type 1 (l'auberge du Songe) : pas d'ondulation.
;
; Dans les deux cas : le noctambule. Link ne reste qu'un temps dans le Songe
; (BALLADE_NOCTAMBULE_FRAMES, compté dans wBalladeNoctambule, en pause pendant les textes et les
; cinématiques) ; Marine prévient peu avant, puis il se réveille là où il est (sauf au fond de la mer
; ouverte : il se réveille juste après en être sorti).
;
; Variables :
;   var30: valeur normale de wGfxRegs2.LYC (rendue pendant les textes)
; ==================================================================================================
interactionCodee9:
	call checkInteractionState
	jr nz,@state1

@state0:
	; Rien à afficher (sinon une image au hasard apparaît en haut à gauche de l'écran)
	call objectSetInvisible
	call interactionSetAlwaysUpdateBit
	call interactionIncState

	; Arrivée dans le Songe (le compteur est à zéro) : le temps du noctambule commence
	ld hl,wBalladeNoctambule
	ldi a,(hl)
	or (hl)
	jr nz,+
	ld (hl),>BALLADE_NOCTAMBULE_FRAMES
	dec l
	ld (hl),<BALLADE_NOCTAMBULE_FRAMES
+
	ld e,Interaction.subid
	ld a,(de)
	or a
	ret nz
	ld a,(wGfxRegs2.LYC)
	ld e,Interaction.var30
	ld (de),a
	ld a,BALLADE_DREAM_WAVE
	jp initWaveScrollValues

@state1:
	call @noctambule
	ld e,Interaction.subid
	ld a,(de)
	or a
	ret nz

	ld a,(wTextIsActive)
	or a
	jr z,@wave

	; Un texte est affiché : affichage normal
	ld e,Interaction.var30
	ld a,(de)
	ld (wGfxRegs2.LYC),a
	ld a,$03
	ldh (<hNextLcdInterruptBehaviour),a
	ret

@wave:
	ld a,$10
	ld (wGfxRegs2.LYC),a
	ld a,$02
	ldh (<hNextLcdInterruptBehaviour),a
	; Comme loadBigBufferScrollValues, mais en ajoutant le défilement horizontal de la caméra :
	; les valeurs de la vague remplacent celui de chaque ligne, et sans lui l'écran resterait figé
	; pendant (et après) le passage d'une salle à l'autre. Une seule passe, pour que l'écran ne se
	; déchire pas pendant qu'il est lu.
	ld a,(wGfxRegs2.SCX)
	ld c,a
	ld a,:w2WaveScrollValues
	ld ($ff00+R_SVBK),a
	ld a,(wFrameCounter)
	and $7f
	ld de,w2WaveScrollValues
	call addAToDe
	ld hl,wBigBuffer
-
	ld a,(de)
	add c
	ldi (hl),a
	inc e
	res 7,e
	ld a,l
	or a
	jr nz,-
	xor a
	ld ($ff00+R_SVBK),a
	ret

;;
; Le temps du noctambule s'écoule (pas pendant un texte ni une cinématique)
@noctambule:
	ld a,(wTextIsActive)
	ld b,a
	ld a,(wDisabledObjects)
	or b
	ret nz
	; Ni pendant que l'écran défile vers la salle voisine (la case sous Link n'est pas encore la
	; bonne : il pourrait se réveiller dans l'eau profonde)
	ld a,(wScrollMode)
	rrca
	ret nc
	ld hl,wBalladeNoctambule
	ldi a,(hl)
	or (hl)
	ret z ; déjà réveillé (le réveil est en cours)

	; Compteur - 1
	dec l
	ld a,(hl)
	sub $01
	ldi (hl),a
	ld a,(hl)
	sbc $00
	ld (hl),a
	dec l

	; Marine prévient un peu avant
	ld a,(hl)
	cp <BALLADE_NOCTAMBULE_WARNING
	jr nz,+
	inc l
	ld a,(hl)
	cp >BALLADE_NOCTAMBULE_WARNING
	ret nz
	ld bc,TX_5a33
	jp showText
+
	; À zéro : le réveil
	ldi a,(hl)
	or (hl)
	ret nz

	; Pas au fond de la mer ouverte (dans le Réel, c'est l'eau) : on attend qu'il en sorte
	ld a,(wActiveTilePos)
	ld l,a
	ld h,>wRoomLayout
	ld a,(hl)
	cp $1a
	jr z,@notYet
	cp $1b
	jr z,@notYet
	callab balladeMarine.switchDream
	ret
@notYet:
	ld hl,wBalladeNoctambule
	ld (hl),$01
	ret
