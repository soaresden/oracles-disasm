; ==================================================================================================
; BALLADE: Ghost Babel au 4F de la Tour Sans-Nuit (5:c8), en hommage à Metal Gear Solid: Ghost Babel
; (idée de Denis ; dessins faits à la main : art/ghost_babel.txt, maquette validée par Denis).
;
; - La boîte en carton (INTERAC_BALLADE_CREUSE $04) : A devant une boîte, Link entre dedans ; elle
;   le suit, ses bottes dépassent ; Link est caché, sans collisions (bit 2 de
;   wDisableLinkCollisionsAndMenu : les fantômes ne le voient pas) et sans objets (wccd8). A : il en sort, la boîte reste par terre (wBalladeGhostBox : la boîte
;   portée, 0 sinon).
; - Le contrôleur ($05) crée le regard des fantômes (deux points rouges devant chacun, $06) et le
;   radar (un petit écran dans le coin, $08, avec un point par fantôme et un vert pour Link, $09).
;   Quand un fantôme aurait vu Link dans sa boîte, un « ? » apparaît au-dessus de lui ($07).
; ==================================================================================================

.define GHOST_RADAR_Y	$18	; le radar : à l'écran, en haut à droite de la salle
.define GHOST_RADAR_X	$90

;;
; La boîte en carton (d = la boîte)
box:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw @init
	.dw @onFloor
	.dw @worn

@init:
	call interactionInitGraphics
	call interactionIncState
	ld h,d
	ld l,Interaction.collisionRadiusY
	ld (hl),$06
	inc l
	ld (hl),$06
	ld e,Interaction.pressedAButton
	call objectAddToAButtonSensitiveObjectList
	xor a
	ld (wBalladeGhostBox),a
	jp objectSetVisiblec2

@onFloor:
	ld e,Interaction.pressedAButton
	ld a,(de)
	or a
	ret z
	xor a
	ld (de),a
	ld a,(wBalladeGhostBox)
	or a
	ret nz
	; Link entre dans la boîte : l'image avec ses bottes
	ld a,d
	ld (wBalladeGhostBox),a
	call interactionIncState
	ld e,Interaction.oamTileIndexBase
	ld a,(de)
	sub $04
	ld (de),a
	call @hideLink
	ld a,SND_PICKUP
	jp playSound

@worn:
	; La boîte suit Link ; Link reste caché
	ld hl,w1Link
	call objectTakePosition
	call @hideLink
	ld a,(wTextIsActive)
	or a
	ret nz
	ld a,(wGameKeysJustPressed)
	and BTN_A
	ret z
	; A : Link sort ; la boîte reste par terre
	ld hl,wDisableLinkCollisionsAndMenu
	res 2,(hl)
	xor a
	ld (wccd8),a
	ld (wBalladeGhostBox),a
	ld hl,w1Link.visible
	set 7,(hl)
	ld l,<w1Link.collisionType
	set 7,(hl)
	ld e,Interaction.oamTileIndexBase
	ld a,(de)
	add $04
	ld (de),a
	ld e,Interaction.pressedAButton
	xor a
	ld (de),a
	ld e,Interaction.state
	ld a,$01
	ld (de),a
	ld a,SND_DOORCLOSE
	jp playSound

@hideLink:
	ld hl,w1Link.visible
	res 7,(hl)
	ld l,<w1Link.collisionType
	res 7,(hl)
	; (le code de Link remet ses collisions à chaque image : celles-ci, les fantômes les lisent
	; aussi, checkLinkCollisionsEnabled)
	ld hl,wDisableLinkCollisionsAndMenu
	set 2,(hl)
	ld a,$01
	ld (wccd8),a
	ret


;;
; Le contrôleur : crée le regard et le radar, puis surveille les fantômes (d = le contrôleur ;
; var30-var3f : l'attente avant un autre « ? », un octet par emplacement d'ennemi)
controller:
	ld e,Interaction.state
	ld a,(de)
	or a
	jr nz,@watch
	inc a
	ld (de),a
	; L'écran de Ghost Babel : la barre d'état en bas, « NO ITEM » dans les cases B et A (Link entre
	; sans rien en main : seulement les boîtes)
	ld a,$01
	ld (wBalladeGhostHud),a
	ld a,$ff
	ld (wStatusBarNeedsRefresh),a
	ld bc,$2300
	call @create
	; Le radar, et le point de Link
	ld bc,$0800
	call @create
	ld bc,$09d0
	call @create
	; Pour chaque fantôme : deux points de regard et un point du radar
	ld h,FIRST_ENEMY_INDEX
@nextGuard:
	ld l,Enemy.enabled
	ld a,(hl)
	or a
	jr z,@skipGuard
	inc l
	ld a,(hl)
	cp ENEMY_AMBI_GUARD
	jr nz,@skipGuard
	push hl
	ld b,$06
	ld c,h
	ld e,$01
	call @createK
	pop hl
	push hl
	ld b,$06
	ld c,h
	ld e,$02
	call @createK
	pop hl
	push hl
	ld b,$09
	ld c,h
	call @create
	pop hl
@skipGuard:
	inc h
	ld a,h
	cp LAST_ENEMY_INDEX+1
	jr c,@nextGuard
	ret

@watch:
	; Link dans sa boîte : un fantôme qui le « voit » ne voit qu'une boîte : « ? »
	ld h,FIRST_ENEMY_INDEX
@nextEnemy:
	ld l,Enemy.enabled
	ld a,(hl)
	or a
	jr z,@nextOne
	inc l
	ld a,(hl)
	cp ENEMY_AMBI_GUARD
	jr nz,@nextOne
	; son attente
	push hl
	ld a,h
	and $0f
	add Interaction.var30
	ld l,a
	ld h,d
	ld a,(hl)
	or a
	jr z,+
	dec (hl)
+
	ld b,(hl)
	ld c,l
	pop hl
	ld a,(wBalladeGhostBox)
	or a
	jr z,@nextOne
	ld l,Enemy.var34
	bit 0,(hl)
	jr z,@nextOne
	res 0,(hl)
	ld a,b
	or a
	jr nz,@nextOne
	; « ? » au-dessus de lui, et il attend un peu avant le prochain
	push hl
	ld l,c
	ld h,d
	ld (hl),90
	pop hl
	push hl
	call getFreeInteractionSlot
	jr nz,++
	ld (hl),INTERAC_BALLADE_CREUSE
	inc l
	ld (hl),$07
	ld b,h
	pop hl
	push hl
	ld l,Enemy.yh
	ld a,(hl)
	sub $14
	ld c,a
	ld l,Enemy.xh
	ld a,(hl)
	ld h,b
	ld l,Interaction.xh
	ld (hl),a
	ld l,Interaction.yh
	ld (hl),c
++
	pop hl
@nextOne:
	inc h
	ld a,h
	cp LAST_ENEMY_INDEX+1
	jr c,@nextEnemy
	ret

;;
; Crée un objet de Ghost Babel : b = son sous-type, c = sa cible (emplacement), e = sa distance
@create:
	ld e,$00
@createK:
	push bc
	push de
	call getFreeInteractionSlot
	pop de
	pop bc
	ret nz
	ld (hl),INTERAC_BALLADE_CREUSE
	inc l
	ld (hl),b
	inc l
	ld (hl),c		; var03 : la cible
	ld l,Interaction.var30
	ld (hl),e		; la distance (le regard)
	ret


;;
; Un point du regard ($06) : devant son fantôme (var03), à var30 x 14 pixels
gaze:
	call ghostObjectInit
	ld e,Interaction.var03
	ld a,(de)
	ld h,a
	ld l,Enemy.enabled
	ld a,(hl)
	or a
	jp z,interactionDelete
	; caché quand le fantôme a vu Link, ou quand il scintille
	ld l,Enemy.visible
	ld a,(hl)
	ld e,Interaction.visible
	and $80
	ld b,a
	ld l,Enemy.state
	ld a,(hl)
	cp $0f
	jr c,+
	ld b,$00
+
	ld a,(de)
	and $7f
	or b
	ld (de),a
	; sa direction (la plus proche des quatre)
	ld l,Enemy.angle
	ld a,(hl)
	add $04
	and $18
	rrca
	rrca
	ld c,a			; 0 haut, 2 droite, 4 bas, 6 gauche
	ld e,Interaction.var30
	ld a,(de)
	ld b,a			; 1 ou 2
	push hl
	ld hl,@offsets
	ld a,c
	rst_addAToHl
	ld c,(hl)		; dy
	inc hl
	ld e,(hl)		; dx
	pop hl
	ld a,c
	dec b
	jr z,+
	add c
	ld c,a
	ld a,e
	add e
	ld e,a
	jr ++
+
	ld a,e
++
	; a = dx, c = dy
	ld b,a
	ld l,Enemy.xh
	ld a,(hl)
	add b
	ld b,a
	ld l,Enemy.yh
	ld a,(hl)
	add c
	ld e,Interaction.yh
	ld (de),a
	ld e,Interaction.xh
	ld a,b
	ld (de),a
	ret

@offsets:
	.db -14, 0,  0, 14,  14, 0,  0, -14	; haut, droite, bas, gauche (dy, dx)

;;
; La première image : son dessin, visible au-dessus de tout
ghostObjectInit:
	ld e,Interaction.state
	ld a,(de)
	or a
	ret nz
	inc a
	ld (de),a
	call interactionInitGraphics
	jp objectSetVisible80


;;
; « ? » ($07) : une seconde, puis il s'en va
question:
	ld e,Interaction.state
	ld a,(de)
	or a
	jr nz,+
	call ghostObjectInit
	ld e,Interaction.counter1
	ld a,60
	ld (de),a
	ret
+
	call interactionDecCounter1
	ret nz
	jp interactionDelete


;;
; Le radar ($08) : fixe à l'écran, en haut à droite
radar:
	call ghostObjectInit
	ldh a,(<hCameraY)
	add GHOST_RADAR_Y
	ld e,Interaction.yh
	ld (de),a
	ldh a,(<hCameraX)
	add GHOST_RADAR_X
	ld e,Interaction.xh
	ld (de),a
	ret


;;
; Un point du radar ($09) : sa cible (var03 : $d0 = Link, sinon l'emplacement d'un fantôme) ;
; une case de la salle = un pixel du radar
radarDot:
	ld e,Interaction.state
	ld a,(de)
	or a
	jr nz,+
	call ghostObjectInit
	; le point de Link : vert (palette 0)
	ld e,Interaction.var03
	ld a,(de)
	cp $d0
	jr nz,+
	ld e,Interaction.oamFlags
	ld a,(de)
	and $f8
	ld (de),a
	ld e,Interaction.oamFlagsBackup
	ld (de),a
+
	ld e,Interaction.var03
	ld a,(de)
	ld h,a
	ld l,$00		; Link (w1Link)
	cp $d0
	jr z,+
	ld l,Enemy.enabled
	ld a,(hl)
	or a
	jp z,interactionDelete
+
	ld a,l
	add Object.yh - Object.enabled
	ld l,a
	ld a,(hl)
	swap a
	and $0f
	sub $05
	ld b,a
	ldh a,(<hCameraY)
	add GHOST_RADAR_Y
	add b
	ld e,Interaction.yh
	ld (de),a
	inc l
	inc l
	ld a,(hl)		; xh
	swap a
	and $0f
	sub $07
	ld b,a
	ldh a,(<hCameraX)
	add GHOST_RADAR_X
	add b
	ld e,Interaction.xh
	ld (de),a
	ret


;;
; « NO ITEM » ($23, invisible) : dans les cases B et A de la barre d'état, à la place des icônes des
; objets. Le contrôleur vide les cases (wBalladeGhostHud : balladeGhostInventoryB / A, banque 0) ;
; une fois la barre redessinée (les deux cases vides : wBItemTreasure = $ff), on met « NO ITEM »
; dans les images des icônes (w4ItemIconGfx), on les fait dessiner (attributs, décalage), on retire
; la priorité du décor sur ces cases (comme func_02_52f6, banque 2) et on envoie le tout à l'écran.
; La barre redessinée (un menu, un objet...) : on recommence.
noItem:
	ld e,Interaction.state
	ld a,(de)
	or a
	jr nz,+
	inc a
	ld (de),a
	call objectSetInvisible
	call interactionSetAlwaysUpdateBit
+
	; La barre montre encore un objet : elle se redessine (sans rien en main)
	ld a,(wBItemTreasure)
	ld b,a
	ld a,(wAItemTreasure)
	and b
	inc a
	jr z,+
	ld hl,wStatusBarNeedsRefresh
	set 0,(hl)
	ret
+
	; Déjà « NO ITEM » ?
	ld a,(wBItemSpriteXOffset)
	cp $08
	ret z

	; Les icônes de B et A : leurs attributs (palette 0, images en banque 1), deux sprites chacune
	ld hl,wBItemSpriteAttribute1
	call @setSprite
	ld hl,wAItemSpriteAttribute1
	call @setSprite

	ld a,$04
	ld ($ff00+R_SVBK),a
	; Leurs images
	ld de,w4ItemIconGfx
	call @copyGfx
	ld de,w4ItemIconGfx+$40
	call @copyGfx
	; Le décor des cases ne passe plus devant les sprites (colonnes 1-2 et 6-7, deux lignes)
	ld hl,w4StatusBarAttributeMap+$01
	call @clearTwo
	ld l,<w4StatusBarAttributeMap+$06
	call @clearTwo
	xor a
	ld ($ff00+R_SVBK),a
	ld a,UNCMP_GFXH_02
	jp loadUncompressedGfxHeader

; hl : wB/AItemSpriteAttribute1 -> attributs, décalage du 2e sprite, pas de nombre
@setSprite:
	ld a,$08
	ldi (hl),a
	ldi (hl),a
	ldi (hl),a
	ld (hl),$ff
	ret

; hl, hl+1, hl+$20, hl+$21 : 0
@clearTwo:
	xor a
	ldi (hl),a
	ld (hl),a
	ld a,l
	add $1f
	ld l,a
	xor a
	ldi (hl),a
	ld (hl),a
	ret

@copyGfx:
	ld hl,@gfx
	ld b,$40
-
	ldi a,(hl)
	ld (de),a
	inc de
	dec b
	jr nz,-
	ret

; « NO ITEM » (16 x 16, deux sprites de 8 x 16 : gauche puis droite ; k = couleur 1)
;   ................
;   ................
;   ...k..k..kk.....
;   ...kk.k.k..k....
;   ...k.kk.k..k....
;   ...k..k.k..k....
;   ...k..k..kk.....
;   ................
;   ................
;   .k.kkk.kkk.k...k
;   .k..k..k...kk.kk
;   .k..k..kk..k.k.k
;   .k..k..k...k...k
;   .k..k..kkk.k...k
;   ................
;   ................
@gfx:
	.db $00 $00 $00 $00 $12 $00 $1a $00 $16 $00 $12 $00 $12 $00 $00 $00
	.db $00 $00 $5d $00 $49 $00 $49 $00 $49 $00 $49 $00 $00 $00 $00 $00
	.db $00 $00 $00 $00 $60 $00 $90 $00 $90 $00 $90 $00 $60 $00 $00 $00
	.db $00 $00 $d1 $00 $1b $00 $95 $00 $11 $00 $d1 $00 $00 $00 $00 $00
