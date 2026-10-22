; ==================================================================================================
; BALLADE: les Songes des Héros (INTERAC_BALLADE_CREUSE $1c-$22). Au Nid des Vents, dans le Songe
; (0:48), passent les rêves de ceux qui voulaient voler, et ceux des héros d'avant Link. Une bulle
; de rêve : Link la touche, il y est. Trois rêves, dans l'ordre :
;   1. le héros du temps (5:eb) : une fée le suit et l'interrompt tout le temps ;
;   2. les masques (5:ec) : trois masques à essayer, Marine commente chacun ;
;   3. Célesbourg (5:ed) : la princesse le pousse dans le vide ; Marine le rattrape, comme l'oiseau
;      du héros du ciel : le Sifflet de Marine (GLOBALFLAG_BALLADE_SIFFLET, code/ages/balladeMarine.s).
; Après chaque rêve, Link revient au Nid (0:48).
; Dessins : art/ile_marine.txt (images 2 à 7 de spr_ballade_ile) ; salles : story/salles/songes.txt.
; ==================================================================================================

;;
; Au Nid, dans le Songe ($1c) : Marine explique (avant le premier rêve) ; la bulle du prochain rêve
nest:
	ld e,Interaction.state
	ld a,(de)
	or a
	jr nz,@talk
	ld a,GLOBALFLAG_BALLADE_SIFFLET
	call checkGlobalFlag
	jp nz,interactionDelete
	call interactionIncState
	ld hl,$4868
	ld b,$1d
	jp createSongesObjectAt

@talk:
	; (pas de texte pendant l'arrivée dans la salle)
	ld a,(wScrollMode)
	and $01
	ret z
	ld a,GLOBALFLAG_BALLADE_SONGE1
	call checkGlobalFlag
	jp nz,interactionDelete
	ld bc,TX_5b26
	call showText
	jp interactionDelete

;;
; Une bulle de rêve ($1d) : elle flotte ; Link la touche : il entre dans le prochain rêve
bubble:
	call songesObjectInit
	ld a,(wFrameCounter)
	and $20
	ld a,$fc
	jr z,+
	ld a,$fa
+
	ld e,Interaction.zh
	ld (de),a
	ld a,(wTextIsActive)
	or a
	ret nz
	ld b,12
	call songesNearLink
	ret nc
	; Le prochain rêve (b la salle, c la case d'arrivée)
	call nextDream
	ld a,$85
	ld (wWarpDestGroup),a
	ld a,b
	ld (wWarpDestRoom),a
	ld a,c
	ld (wWarpDestPos),a
	xor a
	ld (wWarpTransition),a
	ld (wBalladeSongesMasks),a
	ld (wBalladeSongesWorn),a
	ld a,$03 ; fondu
	ld (wWarpTransition2),a
	ld a,SND_FAIRYCUTSCENE
	call playSound
	jp interactionDelete

;;
; Le prochain rêve : b la salle (groupe 5), c la case où Link arrive
nextDream:
	ld a,GLOBALFLAG_BALLADE_SONGE1
	call checkGlobalFlag
	ld bc,$eb97
	ret z
	ld a,GLOBALFLAG_BALLADE_SONGE2
	call checkGlobalFlag
	ld bc,$ec87
	ret z
	ld bc,$ed52
	ret

;;
; Le rêve est fini : Link revient au Nid, dans le Songe (0:48), avec tout le temps du noctambule
backToNest:
	ld hl,wBalladeNoctambule
	xor a
	ldi (hl),a
	ld (hl),a
	ld (wBalladeSongesWorn),a
	ld a,$80
	ld (wWarpDestGroup),a
	ld a,$48
	ld (wWarpDestRoom),a
	ld a,$54
	ld (wWarpDestPos),a
	xor a
	ld (wWarpTransition),a
	ld a,$03 ; fondu
	ld (wWarpTransition2),a
	ld a,SND_FADEOUT
	jp playSound


; ==================================================================================================
; 1. Le héros du temps (5:eb) : une forêt ; une fée suit Link et l'interrompt sans arrêt ; en haut
; de la forêt, le rêve est fini.
; ==================================================================================================

;;
; La forêt ($1e)
forest:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw @init
	.dw @walk
	.dw @end
	.dw @done

@init:
	call interactionIncState
	; la fée, près de Link
	ld a,(w1Link.yh)
	ld h,a
	ld a,(w1Link.xh)
	ld l,a
	ld b,$1f
	jp createSongesObjectAt

@walk:
	ld a,(wTextIsActive)
	or a
	ret nz
	ld a,(w1Link.yh)
	cp $1c
	ret nc
	call interactionIncState
	ld bc,TX_5b2b
	jp showText

@end:
	ld a,(wTextIsActive)
	or a
	ret nz
	call interactionIncState
	ld a,GLOBALFLAG_BALLADE_SONGE1
	call setGlobalFlag
	jp backToNest

@done:
	ret

;;
; La fée ($1f) : elle vole près de la tête de Link, et toutes les deux secondes : « Hé ! Ho ! »
; var32 : son premier dessin ; var33 : combien de fois elle a parlé
fairy:
	ld e,Interaction.state
	ld a,(de)
	or a
	jr nz,@run
	inc a
	ld (de),a
	call interactionInitGraphics
	call interactionSetAlwaysUpdateBit
	ld h,d
	ld l,Interaction.oamTileIndexBase
	ld a,(hl)
	ld l,Interaction.var32
	ld (hl),a
	ld l,Interaction.counter1
	ld (hl),40
	ld l,Interaction.zh
	ld (hl),$f8
	jp objectSetVisible80

@run:
	; ses ailes battent
	ld e,Interaction.var32
	ld a,(de)
	ld b,a
	ld a,(wFrameCounter)
	and $08
	rrca
	add b
	ld e,Interaction.oamTileIndexBase
	ld (de),a
	; elle vole vers la tête de Link (un peu au-dessus, à droite)
	ld a,(w1Link.yh)
	sub 14
	ld b,a
	ld h,d
	ld l,Interaction.yh
	call @step
	ld a,(w1Link.xh)
	add 12
	ld b,a
	ld l,Interaction.xh
	call @step
	; elle parle (pas pendant l'arrivée, ni tout en haut de la forêt : le rêve finit)
	ld a,(wScrollMode)
	and $01
	ret z
	ld a,(wTextIsActive)
	or a
	ret nz
	ld a,(w1Link.yh)
	cp $28
	ret c
	call interactionDecCounter1
	ret nz
	ld (hl),100
	ld l,Interaction.var33
	ld a,(hl)
	inc (hl)
	and $03
	add <TX_5b27
	ld c,a
	ld b,>TX_5b27
	push bc
	ld a,SND_FAIRY_HEAL
	call playSound
	pop bc
	jp showText

; (hl) va d'un pixel vers b
@step:
	ld a,b
	sub (hl)
	ret z
	bit 7,a
	jr nz,+
	inc (hl)
	ret
+
	dec (hl)
	ret


; ==================================================================================================
; 2. Les masques (5:ec) : une clairière, trois masques posés (le masque de la Pousse, du Roc, des
; Eaux). A devant l'un d'eux : Link le met (un seul à la fois) et Marine commente. Les trois
; essayés : « rends-les ! », le rêve est fini.
; ==================================================================================================

;;
; La clairière ($20)
masks:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw @init
	.dw @intro
	.dw @try
	.dw @end
	.dw @done

@init:
	call interactionIncState
	xor a
	ld (wBalladeSongesMasks),a
	ld (wBalladeSongesWorn),a
	ld bc,$0048
	call @createMask
	ld bc,$0178
	call @createMask
	ld bc,$02a8

; b = le numéro du masque, c = x
@createMask:
	call getFreeInteractionSlot
	ret nz
	ld (hl),INTERAC_BALLADE_CREUSE
	inc l
	ld (hl),$21
	inc l
	ld (hl),b		; var03
	ld l,Interaction.yh
	ld (hl),$48
	ld l,Interaction.xh
	ld (hl),c
	ret

@intro:
	ld a,(wScrollMode)
	and $01
	ret z
	call interactionIncState
	ld bc,TX_5b2c
	jp showText

@try:
	ld a,(wTextIsActive)
	or a
	ret nz
	ld a,(wBalladeSongesMasks)
	cp $07
	ret nz
	call interactionIncState
	ld bc,TX_5b30
	jp showText

@end:
	ld a,(wTextIsActive)
	or a
	ret nz
	call interactionIncState
	ld a,GLOBALFLAG_BALLADE_SONGE2
	call setGlobalFlag
	jp backToNest

@done:
	ret

;;
; Un masque ($21 ; var03 : 0 la Pousse, 1 le Roc, 2 les Eaux) : posé (A : Link le met) ou sur la
; tête de Link. var33, var34 : sa place
mask:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw @init
	.dw @onStand
	.dw @worn

@init:
	call interactionInitGraphics
	call interactionIncState
	; son dessin : l'image 5, 6 ou 7
	ld h,d
	ld l,Interaction.var03
	ld a,(hl)
	add a
	add a
	ld l,Interaction.oamTileIndexBase
	add (hl)
	ld (hl),a
	; le masque des Eaux est bleu (palette 1)
	ld l,Interaction.var03
	ld a,(hl)
	cp $02
	jr nz,+
	ld l,Interaction.oamFlagsBackup
	ld a,(hl)
	and $f8
	or $01
	ldi (hl),a
	ld (hl),a
+
	ld l,Interaction.collisionRadiusY
	ld (hl),$06
	inc l
	ld (hl),$06
	ld l,Interaction.yh
	ld a,(hl)
	ld l,Interaction.var33
	ld (hl),a
	ld l,Interaction.xh
	ld a,(hl)
	ld l,Interaction.var34
	ld (hl),a
	call @putDown
	jp objectSetVisiblec2

@putDown:
	call objectMarkSolidPosition
	ld e,Interaction.pressedAButton
	jp objectAddToAButtonSensitiveObjectList

@onStand:
	ld e,Interaction.pressedAButton
	ld a,(de)
	or a
	ret z
	xor a
	ld (de),a
	; Link le met
	call objectUnmarkSolidPosition
	ld e,Interaction.start
	call objectRemoveFromAButtonSensitiveObjectList
	call interactionIncState
	ld e,Interaction.var03
	ld a,(de)
	ld b,a
	inc a
	ld (wBalladeSongesWorn),a
	; essayé (un bit par masque)
	ld c,$01
	ld a,b
	or a
	jr z,++
-
	sla c
	dec a
	jr nz,-
++
	ld a,(wBalladeSongesMasks)
	or c
	ld (wBalladeSongesMasks),a
	call @onHead
	call objectSetVisible80
	ld a,SND_GETSEED
	call playSound
	ld e,Interaction.var03
	ld a,(de)
	add <TX_5b2d
	ld c,a
	ld b,>TX_5b2d
	jp showText

@worn:
	ld e,Interaction.var03
	ld a,(de)
	inc a
	ld b,a
	ld a,(wBalladeSongesWorn)
	cp b
	jr nz,@takeOff

; Sur le visage de Link
@onHead:
	ld a,(w1Link.yh)
	sub $06
	ld e,Interaction.yh
	ld (de),a
	ld a,(w1Link.xh)
	ld e,Interaction.xh
	ld (de),a
	ld a,(w1Link.zh)
	ld e,Interaction.zh
	ld (de),a
	ret

; Il en a mis un autre : celui-ci retourne à sa place
@takeOff:
	ld h,d
	ld l,Interaction.var33
	ld a,(hl)
	ld l,Interaction.yh
	ld (hl),a
	ld l,Interaction.var34
	ld a,(hl)
	ld l,Interaction.xh
	ld (hl),a
	ld l,Interaction.zh
	ld (hl),$00
	ld l,Interaction.state
	ld (hl),$01
	call @putDown
	jp objectSetVisiblec2


; ==================================================================================================
; 3. Célesbourg (5:ed) : une île dans le ciel ; la princesse (INTERAC_BALLADE_CREUSE $11, blonde)
; attend au bord. Link s'approche : « Allez, saute ! » ; elle le pousse dans le vide ; Marine le
; rattrape (balladeMarine.checkSifflet : la première fois, dans cette salle) ; le Sifflet.
; ==================================================================================================

;;
; L'île dans le ciel ($22) ; var34 : Marine l'a rattrapé
sky:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw @approach
	.dw @talk
	.dw @push
	.dw @fall
	.dw @caught
	.dw @learn
	.dw @done

@approach:
	ld a,(wScrollMode)
	and $01
	ret z
	ld a,(wTextIsActive)
	or a
	ret nz
	; Link arrive près de la princesse (au bord, à droite)
	ld a,(w1Link.xh)
	cp $78
	ret c
	call interactionIncState
	ld bc,TX_5b31
	jp showText

@talk:
	ld a,(wTextIsActive)
	or a
	ret nz
	call interactionIncState
@startPush:
	ld e,Interaction.counter1
	ld a,24
	ld (de),a
	ld a,SND_POOF
	jp playSound

; Elle le pousse vers le vide (à droite), deux pixels par image
@push:
	ld a,(w1Link.state)
	cp LINK_STATE_RESPAWNING
	jr z,@pushed
	ld hl,w1Link.xh
	inc (hl)
	inc (hl)
	call interactionDecCounter1
	ret nz
@pushed:
	ld e,Interaction.state
	ld a,$03
	ld (de),a
	ret

; Il tombe ; Marine le rattrape (wBalladeCatch passe à 1, 2, 3, puis revient à 0)
@fall:
	ld a,(wBalladeCatch)
	or a
	jr z,+
	ld e,Interaction.var34
	ld a,$01
	ld (de),a
	ret
+
	ld e,Interaction.var34
	ld a,(de)
	or a
	jr z,@notYet
	ld a,(w1Link.state)
	cp LINK_STATE_NORMAL
	ret nz
	call interactionIncState
	ld bc,TX_5b32
	jp showText
@notYet:
	; pas encore tombé (en train de tomber, ou pas assez poussé) : elle pousse encore
	ld a,(w1Link.state)
	cp LINK_STATE_RESPAWNING
	ret z
	ld e,Interaction.state
	ld a,$02
	ld (de),a
	jr @startPush

@caught:
	ld a,(wTextIsActive)
	or a
	ret nz
	call interactionIncState
	ld a,SND_GETITEM
	call playSound
	ld bc,TX_5b33
	jp showText

@learn:
	ld a,(wTextIsActive)
	or a
	ret nz
	call interactionIncState
	ld a,GLOBALFLAG_BALLADE_SIFFLET
	call setGlobalFlag
	jp backToNest

@done:
	ret


; ==================================================================================================
; Petits outils
; ==================================================================================================

;;
; La première image d'un objet : son dessin, visible
songesObjectInit:
	ld e,Interaction.state
	ld a,(de)
	or a
	ret nz
	inc a
	ld (de),a
	call interactionInitGraphics
	jp objectSetVisiblec2

;;
; Crée un objet INTERAC_BALLADE_CREUSE (b = son sous-type) à la position h (y), l (x)
createSongesObjectAt:
	ld a,b
	ld (wBalladeTerrierTmp),a
	push hl
	call getFreeInteractionSlot
	pop bc
	ret nz
	ld (hl),INTERAC_BALLADE_CREUSE
	inc l
	ld a,(wBalladeTerrierTmp)
	ld (hl),a
	ld l,Interaction.yh
	ld (hl),b
	ld l,Interaction.xh
	ld (hl),c
	ret

;;
; Link est-il à moins de b pixels, sur chaque axe ? (carry : oui)
songesNearLink:
	ld h,d
	ld l,Interaction.yh
	ld a,(w1Link.yh)
	sub (hl)
	call songesAbs
	cp b
	ret nc
	ld l,Interaction.xh
	ld a,(w1Link.xh)
	sub (hl)
	call songesAbs
	cp b
	ret

songesAbs:
	bit 7,a
	ret z
	cpl
	inc a
	ret
