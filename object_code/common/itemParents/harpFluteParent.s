;;
; ITEM_FLUTE ($0e)
; ITEM_HARP ($11)
parentItemCode_flute:
parentItemCode_harp:
	ld e,Item.state
	ld a,(de)
	rst_jumpTable
	.dw @state0
	.dw @state1

@state0:
	call checkLinkOnGround
	jp nz,clearParentItem
	ld a,(wInstrumentsDisabledCounter)
	or a
	jp nz,clearParentItem
	call isLinkInHole
	jp c,clearParentItem
	call checkNoOtherParentItemsInUse
	jp nz,clearParentItem

	ld a,$80
	ld (wcc95),a
	ld a,$ff ~ DISABLE_LINK ~ DISABLE_ALL_BUT_INTERACTIONS
	ld (wDisabledObjects),a

	call parentItemLoadAnimationAndIncState

	; Determine what sound to play
	ld b,$00
	call @getSelectedSongAddr
	jr z,+
	ld b,$03
+
	ld a,(hl)
	add b
	ld hl,@sfxList
	rst_addAToHl
	ld a,(hl)
	call playSound

@state1:
	ld hl,w1Link.collisionType
	res 7,(hl)

	; Create floating music note every $20 frames
	call itemDecCounter1
	ld a,(hl)
	and $1f
	jr nz,++

	ld l,Item.animParameter
	bit 0,(hl)
	ld bc,$fcf8
	jr z,+
	ld c,$08
+
	call getRandomNumber
	and $01
	push de
	ld d,>w1Link
	call objectCreateFloatingMusicNote
	pop de
++
	call specialObjectAnimate_optimized
	call @getSelectedSongAddr

	ld a,$ff
	jr z,+
	ld a,(hl)
+
	ld (wLinkPlayingInstrument),a
	ld (wLinkRidingObject),a
	ld c,$80
	jr nz,++

	ld a,(hl)
	or a
	jr nz,++
	ld c,$40
++
	ld e,Item.animParameter
	ld a,(de)
	and c
	ret z

; Done playing song

	ld hl,w1Link.collisionType
	set 7,(hl)

	call @getSelectedSongAddr
	jr nz,@harp

	; Flute: try to spawn companion
	ldbc INTERAC_COMPANION_SPAWNER, $80
	call objectCreateInteraction

@clearSelf:
	xor a
	ld (wDisabledObjects),a
	ld (wcc95),a
	jp clearParentItem


.ifdef ROM_AGES ; Harp code

@tuneEchoesInVain:
	ld bc,TX_5110
	call showText
	jr @clearSelf

.endif

@harp:
.ifdef ROM_SEASONS
	jr @clearSelf
.else
	; Only allow harp playing on overworld, non-maku tree screens
	ld a,(wTilesetFlags)
	and (TILESETFLAG_UNDERWATER|TILESETFLAG_SIDESCROLL|TILESETFLAG_LARGE_INDOORS|TILESETFLAG_DUNGEON|TILESETFLAG_INDOORS|TILESETFLAG_MAKU)
	jr nz,@clearSelf

	; BALLADE: la Lanterne des Songes. Dehors, n'importe quel air fait passer du Réel (groupe 1) au
	; Songe (groupe 0) et retour : un fondu, puis l'arrivée du voyage dans le temps d'Ages (le
	; rayon de lumière ; si la case d'arrivée est bloquée, Link est renvoyé d'où il vient). Sans la
	; cinématique de départ d'Ages, qui laissait une trace dans le décor.
	; Comme elle, on garde la salle de départ de côté (pour y renvoyer Link si besoin)
	callab tilesets.func_04_6f07
	callab tilesets.func_04_6e9b
	; Le temps du noctambule repart de zéro
	ld hl,wBalladeNoctambule
	xor a
	ldi (hl),a
	ld (hl),a
	ld hl,wWarpDestGroup
	ld a,(wActiveGroup)
	xor $01
	or $80
	ldi (hl),a
	ld a,(wActiveRoom)
	ldi (hl),a
	ld a,TRANSITION_DEST_TIMEWARP
	ldi (hl),a
	ld a,(wActiveTilePos)
	ldi (hl),a
	ld (hl),$03 ; wWarpTransition2 : fondu
	ld a,$01 ; couleur de l'animation d'arrivée
	ld (wcc50),a
	ld a,$10 ; garde les drapeaux de la salle tels quels (voir warpTransition6@substate7)
	ld (wLinkStateParameter),a
	ld a,SND_TIMEWARP_INITIATED
	call playSound
	jp @clearSelf

	ld a,(hl)
	rst_jumpTable
	.dw @clearSelf
	.dw @tuneOfEchoes
	.dw @tuneOfCurrents
	.dw @tuneOfAges

@tuneOfEchoes:
	call getThisRoomFlags
	bit ROOMFLAG_BIT_PORTALSPOT_DISCOVERED,(hl)
	jr nz,@clearSelf
	jr @tuneEchoesInVain

@tuneOfCurrents:
	; Test TILESETFLAG_BIT_PAST
	ld a,(wTilesetFlags)
	rlca
	jr nc,@tuneEchoesInVain

@tuneOfAges:
	call restartSound

	ld a,CUTSCENE_TIMEWARP
	ld (wCutsceneTrigger),a

	ld a,DISABLE_LINK|DISABLE_ENEMIES|DISABLE_8|DISABLE_COMPANION|DISABLE_40
	ld (wDisabledObjects),a
	ld (wDisableLinkCollisionsAndMenu),a
	ld (wcde0),a
	call clearAllItemsAndPutLinkOnGround
	jp specialObjectAnimate_optimized
.endif


@sfxList:
	.db SND_FILLED_HEART_CONTAINER
	.db SND_FLUTE_RICKY
	.db SND_FLUTE_DIMITRI
	.db SND_FLUTE_MOOSH
.ifdef ROM_AGES
	.db SND_TUNE_OF_ECHOES
	.db SND_TUNE_OF_CURRENTS
	.db SND_TUNE_OF_AGES
.else
	; CROSSITEMS: For now we're putting placeholder sounds for the harp songs in seasons
	.db SND_FILLED_HEART_CONTAINER
	.db SND_FILLED_HEART_CONTAINER
	.db SND_FILLED_HEART_CONTAINER
.endif

;;
; @param[out]	hl	wFluteIcon or wSelectedHarpSong
; @param[out]	zflag	Set if using flute, unset for harp
@getSelectedSongAddr:
	ld hl,wFluteIcon
	ld e,Item.id
	ld a,(de)
	cp ITEM_FLUTE

	ret z
	ld l,<wSelectedHarpSong
	ret
