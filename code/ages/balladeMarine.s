; ==================================================================================================
; BALLADE: Marine parle depuis la tunique de Link.
;
; Un appui court sur Select l'appelle (b2_updateMenus, bank2.s) ; Select maintenu ouvre la carte.
; Elle a une réplique pour certaines salles ; ailleurs, une réplique au hasard.
; ==================================================================================================

;;
marineTalk:
	; Dans le Récif Murmurant (donjon 3) et la Fosse de Bulle (9), Link est seul : Marine l'attend
	; dehors
	ld a,(wDungeonIndex)
	cp $03
	ret z
	cp $09
	ret z
	; Dans le Songe (groupes 0 et 2, pas les donjons), Marine propose de réveiller Link
	; (INTERAC_MARINE $01)
	ld a,(wActiveGroup)
	cp $03
	jr nc,+
	and $01
	jr nz,+
	call getFreeInteractionSlot
	ret nz
	ld (hl),INTERAC_MARINE
	inc l
	ld (hl),$01
	ret
+
	ld a,(wActiveGroup)
	ld b,a
	ld a,(wActiveRoom)
	ld c,a
	ld hl,@roomTexts
@next:
	ldi a,(hl)
	cp $ff
	jr z,@anywhere
	cp b
	jr nz,@skip
	ld a,(hl)
	cp c
	jr nz,@skip
	inc hl
	ld c,(hl)
	jr @show
@skip:
	inc hl
	inc hl
	jr @next

@anywhere:
	call getRandomNumber
	and $03
	add <TX_5a10
	ld c,a
@show:
	ld b,>TX_5a00
	jp showText

; Répliques par salle : groupe, salle, texte (groupe de textes $5a)
@roomTexts:
	; (virgules : sinon « $aa <TX » est lu comme une comparaison)
	.db $01, $aa, <TX_5a07 ; la plage du réveil
	.db $01, $9a, <TX_5a08 ; Port-Veille, devant l'auberge
	.db $01, $9b, <TX_5a09 ; la place
	.db $01, $9c, <TX_5a0a ; la plage est
	.db $01, $ab, <TX_5a0b ; le port de pêche
	.db $01, $8a, <TX_5a0c ; le sentier au pont cassé
	.db $03, $9e, <TX_5a0d ; dans l'auberge
	.db $04, $24, <TX_5a0e ; le hall du Phare Éteint
	.db $ff


; ==================================================================================================
; Passer du Réel au Songe et inversement, au même endroit (comme la harpe d'Ages) : groupe 1 <-> 0
; (dehors), 3 <-> 2 (dedans), même salle, même case.
; ==================================================================================================

;;
; Après avoir dormi dans le lit de l'auberge (LINK_STATE_SLEEPING) : Link se retrouve dans l'auberge
; du Songe, debout à côté du lit.
enterDreamFromBed:
	call switchDream
	ld a,$17
	ld (wWarpDestPos),a
	ret

;;
switchDream:
	; Le temps du noctambule repart de zéro (il recommencera au prochain passage dans le Songe)
	ld hl,wBalladeNoctambule
	xor a
	ldi (hl),a
	ld (hl),a
	; (et pas de salle à « remettre comme au départ » : voir harpFluteParent.s, wcddf)
	ld (wcddf),a
	ld a,(wActiveGroup)
	xor $01
	or $80
	ld (wWarpDestGroup),a
	ld a,(wActiveRoom)
	ld (wWarpDestRoom),a
	xor a
	ld (wWarpTransition),a
	; Case de Link : ligne (y / 16) et colonne (x / 16)
	ld a,(w1Link.yh)
	and $f0
	ld b,a
	ld a,(w1Link.xh)
	swap a
	and $0f
	or b
	ld (wWarpDestPos),a
	ld a,$03 ; fondu
	ld (wWarpTransition2),a
	ld a,SND_FADEOUT
	jp playSound


;;
; Le noctambule : dans la barre d'état, les secondes qui restent dans le Songe (à la place du
; compteur de clés, qui n'apparaît que dans les donjons). Appelé par updateStatusBar_body
; (code/bank2.s), la banque 4 de la WRAM étant sélectionnée.
drawNoctambuleTimer:
	; Le Mamono (code/ages/balladeMamono.s) : le niveau de Link, « L-n », à la même place
	ld a,(wBalladeMamonoState)
	or a
	jr z,++
	ld hl,w4StatusBarTileMap+$0b
	ld a,(wcbe8)
	rrca
	jr nc,+
	dec l
+
	ld (hl),$1a		; « L- »
	inc l
	ld a,(wBalladeMamonoLevel)
	add $10
	ld (hl),a
	; un niveau nouveau : la barre d'état sera redessinée
	ld hl,wBalladeNoctambuleShown
	or $80
	cp (hl)
	ret z
	ld (hl),a
	ld hl,wStatusBarNeedsRefresh
	set 4,(hl)
	ret
++
	ld a,(wTilesetFlags)
	bit TILESETFLAG_BIT_DUNGEON,a
	ret nz

	; Secondes = images / 60, arrondi au-dessus
	ld hl,wBalladeNoctambule
	ldi a,(hl)
	ld c,a
	ld b,(hl)
	ld d,$00
@divide:
	ld a,b
	or c
	jr z,@gotSeconds
	inc d
	ld a,c
	sub 60
	ld c,a
	jr nc,@divide
	ld a,b
	or a
	jr z,@gotSeconds
	dec b
	jr @divide
@gotSeconds:
	; Une valeur nouvelle : la barre d'état sera redessinée
	ld hl,wBalladeNoctambuleShown
	ld a,d
	cp (hl)
	jr z,+
	ld (hl),a
	ld hl,wStatusBarNeedsRefresh
	set 4,(hl)
+
	; Une petite lune (tuile $03, tools/make_sprites.py) puis les secondes (écrites à chaque image :
	; la carte de la barre peut être rechargée)
	ld hl,w4StatusBarTileMap+$0b
	ld a,(wcbe8)
	rrca
	jr nc,+
	dec l
+
	ld a,d
	or a
	jr nz,+
	; Plus de compte à rebours : des cases vides
	ld a,$04
	ldi (hl),a
	ld (hl),a
	ret
+
	cp 10
	jr c,+
	ld a,9
+
	ld (hl),$03
	inc l
	add $10
	ld (hl),a
	ret


; ==================================================================================================
; Le pouvoir de Marine (île 2) : porter une bombe. Link tient une bombe au-dessus de sa tête et
; appuie sur Select : Marine sort de la tunique, prend la bombe et l'emporte droit devant, par-dessus
; les trous, l'eau et les murs bas, puis la lâche et revient dans la tunique.
; ==================================================================================================

;;
; Select, à la première image de l'appui (b2_updateMenus, bank2.s). Si le pouvoir est appris, que
; Link tient une bombe : Marine (INTERAC_MARINE $06) l'emporte ; wBalladeSelectTimer passe à $ff
; (ni carte, ni parole pour cet appui).
checkBombPower:
	ld a,(wDungeonIndex)
	cp $03
	ret z
	cp $09
	ret z
	ld a,GLOBALFLAG_BALLADE_MARINE_BOMB
	call checkGlobalFlag
	ret z
	ld a,(wLinkGrabState)
	and $07
	cp $03
	ret nz
	; L'objet tenu : un objet de type « item » (adresse $dX00) qui est une bombe
	ld hl,w1Link.relatedObj2
	ldi a,(hl)
	ld h,(hl)
	ld l,a
	or a
	ret nz
	ld a,h
	cp FIRST_ITEM_INDEX
	ret c
	inc l
	ld a,(hl)
	cp ITEM_BOMB
	ret nz
	dec l
	push hl
	call dropLinkHeldItem
	call getFreeInteractionSlot
	pop bc
	ret nz
	ld (hl),INTERAC_MARINE
	inc l
	ld (hl),$06
	ld l,Interaction.relatedObj1
	ld (hl),c
	inc l
	ld (hl),b
	ld l,Interaction.yh
	ld a,(w1Link.yh)
	ld (hl),a
	ld l,Interaction.xh
	ld a,(w1Link.xh)
	ld (hl),a
	ld l,Interaction.direction
	ld a,(w1Link.direction)
	ld (hl),a
	; En défilement latéral (Link ne regarde qu'à gauche ou à droite) : Marine monte (le boss du
	; Coffre à Jouets, Pantin-Sans-Fil, est hors de portée au-dessus de Link)
	ld a,(wTilesetFlags)
	and TILESETFLAG_SIDESCROLL
	jr z,+
	ld (hl),DIR_UP
+
	ld a,$ff
	ld (wBalladeSelectTimer),a
	ret

;;
; INTERAC_MARINE $06 : Marine emporte la bombe (relatedObj1) dans la direction de Link, pendant
; BALLADE_CARRY_FRAMES images (2 pixels par image), puis la lâche et revient vers Link.
bombCarrier:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw @init
	.dw @carry
	.dw @return

@init:
	call interactionInitGraphics
	call interactionSetAlwaysUpdateBit
	call interactionIncState
	ld h,d
	ld l,Interaction.zh
	ld (hl),$f0
	ld l,Interaction.counter1
	ld (hl),BALLADE_CARRY_FRAMES
	; En vol : 2 = vers la gauche, 3 = vers la droite (vers le haut ou le bas : vers la droite)
	ld l,Interaction.direction
	ld a,(hl)
	cp DIR_LEFT
	ld a,$02
	jr z,+
	inc a
+
	call interactionSetAnimation
	ld a,SND_BALLADE_GULL
	call playSound
	jp objectSetVisible80

@carry:
	call interactionAnimate
	; La bombe est-elle toujours là (et pas en train d'exploser) ?
	call @getBomb
	jr nz,@release
	; Deux pixels droit devant
	ld e,Interaction.direction
	ld a,(de)
	add a
	ld hl,@moves
	rst_addAToHl
	ld e,Interaction.yh
	ld a,(de)
	add (hl)
	ld (de),a
	inc hl
	ld e,Interaction.xh
	ld a,(de)
	add (hl)
	ld (de),a
	; En défilement latéral, elle monte plus vite (3 pixels par image : Pantin-Sans-Fil)
	ld a,(wTilesetFlags)
	and TILESETFLAG_SIDESCROLL
	jr z,+
	ld e,Interaction.yh
	ld a,(de)
	dec a
	ld (de),a
+
	call objectCheckWithinRoomBoundary
	jr nc,@release
	; La bombe pend sous Marine
	call @getBomb
	ld l,Item.yh
	ld e,Interaction.yh
	ld a,(de)
	ld (hl),a
	ld l,Item.xh
	ld e,Interaction.xh
	ld a,(de)
	ld (hl),a
	ld l,Item.zh
	ld (hl),$f8
	ld l,Item.speedZ
	xor a
	ldi (hl),a
	ld (hl),a
	ld e,Interaction.counter1
	ld a,(de)
	dec a
	ld (de),a
	ret nz

; Elle lâche la bombe (qui tombe là où elle est) et revient
@release:
	ld e,Interaction.state
	ld a,$02
	ld (de),a
	ret

; Retour vers Link, deux pixels par image sur chaque axe ; arrivée : dans la tunique
@return:
	call interactionAnimate
	ld c,$00
	ld e,Interaction.yh
	ld a,(w1Link.yh)
	call @approach
	ld e,Interaction.xh
	ld a,(w1Link.xh)
	call @approach
	ld a,c
	cp $02
	ret nz
	jp interactionDelete

; @param	a	Cible
; @param	e	Coordonnée de Marine
; @param	c	+1 si elle est arrivée sur cet axe
@approach:
	ld b,a
	ld a,(de)
	sub b
	jr z,@arrived
	cp $03
	jr c,@arrivedNear
	cp $fe
	jr nc,@arrivedNear
	bit 7,a
	ld a,(de)
	jr nz,+
	sub $02
	ld (de),a
	ret
+
	add $02
	ld (de),a
	ret
@arrivedNear:
	ld a,b
	ld (de),a
@arrived:
	inc c
	ret

; @param[out]	hl	La bombe (début de l'objet)
; @param[out]	zflag	z si c'est toujours une bombe en vie, pas en train d'exploser
@getBomb:
	ld e,Interaction.relatedObj1
	ld a,(de)
	ld l,a
	inc e
	ld a,(de)
	ld h,a
	ld a,(hl)
	or a
	jr z,@notBomb
	inc l
	ld a,(hl)
	dec l
	cp ITEM_BOMB
	ret nz
	push hl
	ld a,l
	add Item.var2f
	ld l,a
	bit 4,(hl)
	pop hl
	ret
@notBomb:
	or $01
	ret

; dy, dx pour haut, droite, bas, gauche
@moves:
	.db $fe $00
	.db $00 $02
	.db $02 $00
	.db $00 $fe


; ==================================================================================================
; Le Sifflet de Marine (le 3e Songe des Héros, code/ages/balladeSonges.s) : quand Link tombe dans un
; trou ou dans le vide, Marine plonge du haut de l'écran et le rattrape, comme l'oiseau du ciel du
; héros de Célesbourg. Il réapparaît sous elle, sans perdre de cœur. (Pas quand il se noie.)
; object_code/common/specialObjects/link.s (linkState02) appelle checkSifflet à la fin de la chute,
; puis siffletUpdate tant que wBalladeCatch vaut 1 ou 2 ; à 3, Link réapparaît sans dégâts.
; ==================================================================================================

;;
; Link vient de tomber : Marine va-t-elle le rattraper ?
checkSifflet:
	ld a,GLOBALFLAG_BALLADE_SIFFLET
	call checkGlobalFlag
	jr nz,+
	; la première fois : dans le rêve de Célesbourg (5:ed), quand la princesse le pousse
	ld a,(wActiveGroup)
	cp $05
	ret nz
	ld a,(wActiveRoom)
	cp $ed
	ret nz
+
	; (pas dans les salles vues de côté)
	ld a,(wTilesetFlags)
	and TILESETFLAG_SIDESCROLL
	ret nz
	ld a,$01
	ld (wBalladeCatch),a
	ret

;;
; Link attend de réapparaître (il est déjà à sa place) : Marine arrive (INTERAC_MARINE $07)
siffletUpdate:
	ld a,(wBalladeCatch)
	cp $01
	ret nz
	inc a
	ld (wBalladeCatch),a
	call getFreeInteractionSlot
	jr nz,@noSlot
	ld (hl),INTERAC_MARINE
	inc l
	ld (hl),$07
	ld l,Interaction.yh
	ld a,(w1Link.yh)
	ld (hl),a
	ld l,Interaction.xh
	ld a,(w1Link.xh)
	ld (hl),a
	ret
@noSlot:
	ld a,$03
	ld (wBalladeCatch),a
	ret

;;
; INTERAC_MARINE $07 : Marine plonge du haut de l'écran jusqu'à Link (var30 : où il réapparaît),
; le tient un instant au-dessus du sol, puis repart vers le ciel
catcher:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw @init
	.dw @dive
	.dw @hold
	.dw @leave

@init:
	call interactionInitGraphics
	call interactionSetAlwaysUpdateBit
	call interactionIncState
	ld h,d
	ld l,Interaction.yh
	ld a,(hl)
	ld l,Interaction.var30
	ld (hl),a
	; elle part du haut de l'écran (au moins 16 pixels au-dessus de Link)
	ld b,a
	ldh a,(<hCameraY)
	ld c,a
	ld a,b
	sub 16
	jr c,++
	cp c
	jr c,+
	ld a,c
+
	ld l,Interaction.yh
	ld (hl),a
++
	ld l,Interaction.zh
	ld (hl),$f4
	ld a,$03		; en vol
	call interactionSetAnimation
	ld a,SND_BALLADE_GULL
	call playSound
	jp objectSetVisible80

; Elle plonge, 3 pixels par image
@dive:
	call interactionAnimate
	ld h,d
	ld l,Interaction.var30
	ld b,(hl)
	ld l,Interaction.yh
	ld a,(hl)
	add $03
	ld (hl),a
	cp b
	ret c
	ld (hl),b
	; elle le tient : il réapparaît sous elle
	call interactionIncState
	ld l,Interaction.counter1
	ld (hl),40
	ld a,$03
	ld (wBalladeCatch),a
	ret

; Elle bat des ailes au-dessus de lui
@hold:
	call interactionAnimate
	ld a,(w1Link.yh)
	ld e,Interaction.yh
	ld (de),a
	ld a,(w1Link.xh)
	ld e,Interaction.xh
	ld (de),a
	call interactionDecCounter1
	ret nz
	call interactionIncState
	ld l,Interaction.counter1
	ld (hl),60
	ld a,SND_BALLADE_GULL
	jp playSound

; Elle remonte vers le ciel, et s'en va
@leave:
	call interactionAnimate
	ld h,d
	ld l,Interaction.yh
	dec (hl)
	dec (hl)
	ld l,Interaction.xh
	inc (hl)
	call interactionDecCounter1
	ret nz
	jp interactionDelete


;;
; INTERAC_MARINE $08 : dans la salle d'un boss, une fois le boss battu (le drapeau $80 de la salle ;
; au Terrier, le Bracelet des Âmes), et les textes finis depuis un instant, Marine félicite Link :
; une réplique par boss (Denis : « pour encourager et donner de la valeur au joueur »). Rien si le
; boss était déjà battu en entrant.
praise:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw @init
	.dw @fight
	.dw @wait

@init:
	call @isBeaten
	jp nz,interactionDelete
	call objectSetInvisible
	jp interactionIncState

@fight:
	call @isBeaten
	ret z
	call interactionIncState
	ld l,Interaction.counter1
	ld (hl),45
	ret

; nz : le boss de cette salle est battu
@isBeaten:
	ld a,(wActiveGroup)
	cp $04
	jr nz,+
	ld a,(wActiveRoom)
	cp $d7
	jr nz,+
	ld a,(wBalladeSoulState)
	and $02
	ret
+
	call getThisRoomFlags
	and $80
	ret

; Les textes finis (le réceptacle, le boss...) depuis 45 images : Marine parle
@wait:
	ld a,(wTextIsActive)
	or a
	jr z,+
	ld e,Interaction.counter1
	ld a,45
	ld (de),a
	ret
+
	call interactionDecCounter1
	ret nz
	; sa réplique : selon la salle
	ld a,(wActiveGroup)
	ld b,a
	ld a,(wActiveRoom)
	ld c,a
	ld hl,@texts
-
	ldi a,(hl)
	cp $ff
	jp z,interactionDelete
	cp b
	ldi a,(hl)
	jr nz,+
	cp c
	jr nz,+
	ld c,(hl)
	ld b,>TX_5b35
	call showText
	jp interactionDelete
+
	inc hl
	jr -

; groupe, salle, texte (TX_5bxx)
@texts:
	.db $04, $13, <TX_5b35	; Jack (le Phare)
	.db $04, $2b, <TX_5b36	; Pantin-Sans-Fil (le Coffre à Jouets)
	.db $04, $bf, <TX_5b37	; Grisaille (la Forge Endormie)
	.db $04, $54, <TX_5b38	; l'Ombre de Marine (la Spirale Céleste)
	.db $04, $64, <TX_5b39	; Givrolin (le Palais Givré)
	.db $05, $c4, <TX_5b3a	; Dark Link (la Tour, 2F)
	.db $05, $c7, <TX_5b3b	; Ganon (la Tour, 3F)
	.db $05, $ca, <TX_5b3c	; le Cauchemar de Cocolint (la Tour, 4F)
	.db $04, $d7, <TX_5b3d	; la machine possédée (le Terrier des Serpents)
	.db $ff


;;
; Le bip des cœurs (Denis) : quand il bippe (presque plus de vie : comme playHeartBeepAtInterval,
; bank2.s) et que Link ne fait rien depuis 15 secondes (aucun bouton), Marine en a assez : « C'est
; chiant ce bruit ! Tiens, un bisou » (TX_5b4e), et Link a juste assez de vie pour que ça ne bippe
; plus. Pas pendant un texte, un menu, une scène, ni un jeu du forain (on y garde un seul cœur
; exprès). Appelé à chaque image.
kissCheck:
	ld hl,wBalladeBeepIdle
	; Ça bippe ? (4 x (vie - 1) < vie maximum)
	ld a,(wLinkHealth)
	dec a
	add a
	jr c,@reset
	add a
	ld b,a
	ld a,(wLinkMaxHealth)
	dec a
	cp b
	jr c,@reset
	; Link ne fait rien, rien d'autre en cours
	ld a,(wKeysPressed)
	ld b,a
	ld a,(wTextIsActive)
	or b
	ld b,a
	ld a,(wDisabledObjects)
	or b
	ld b,a
	ld a,(wMenuDisabled)
	or b
	ld b,a
	ld a,(wOpenedMenuType)
	or b
	ld b,a
	ld a,(wBalladeLoadout)
	or b
	ld b,a
	ld a,(wBalladePacState)
	or b
	jr nz,@reset
	ld a,(wFrameCounter)
	and $3f
	ret nz
	inc (hl)
	ld a,(hl)
	cp 14			; 14 bips : 15 secondes
	ret c
	; Le bisou : juste assez de vie (le quart de la vie maximum, arrondi, plus un quart de cœur)
	ld (hl),$00
	ld a,(wLinkMaxHealth)
	add $03
	srl a
	srl a
	inc a
	ld (wLinkHealth),a
	ld a,SND_GAINHEART
	call playSound
	ld bc,TX_5b4e
	jp showText

@reset:
	ld (hl),$00
	ret
