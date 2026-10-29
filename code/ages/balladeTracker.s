; ==================================================================================================
; BALLADE: la progression (INTERAC_BALLADE_OBJECT $53, balladeObjects.progressTracker ; Denis : « un tracker pour savoir si on est près des 100 % : quarts de
; cœur, anneaux, objets »). Dans le menu, 3e page, B : le menu se ferme et l'écran de la progression
; s'ouvre (CUTSCENE_BALLADE_PROGRESS ; Denis : « l'écran comme les secrets d'Ages »).
; - les couplets (les essences, 7, + le 8e, chanté à Zelda à la fin : GLOBALFLAG_BALLADE_FIN) ;
; - les cœurs (11 au plus : 3 + 6 réceptacles + 10 quarts, les deux derniers restent des quarts) et les quarts
;   du cœur suivant ;
; - les objets (@items, 15, et 3 améliorations : la Cape, l'Épée de Légende, le Bracelet des Âmes) ;
; - les anneaux (les 5 de la Ballade) ;
; - les coffres (balladeTrackerChests.s, tools/make_tracker.py : le drapeau $20 de leur salle).
; Le pour cent : 20 points par sorte, au prorata (les cœurs : les quarts gagnés depuis les 3 du
; départ, sur 34 : 6 réceptacles et 10 quarts (le 10e enterré en 1:89) ; Denis lisait « 15/12 » : trois boss sans le mot
; « boss » dans leur plan revenaient après la fin et redonnaient leur réceptacle). (Avant le 29/10 :
; deux boîtes de Marine, TX_5b78 et TX_5b79, plus affichées.)
; var30-36 : couplets, cœurs, quarts, objets, anneaux, coffres, pour cent.
; ==================================================================================================
.include "code/ages/balladeTrackerChests.s"

main:
	ld e,Interaction.state
	ld a,(de)
	rst_jumpTable
	.dw @count
	.dw @second
	.dw @end

@count:
	call interactionIncState
	; Les couplets
	ld a,(wEssencesObtained)
	ld c,$00
	ld b,$08
-
	rrca
	jr nc,+
	inc c
+
	dec b
	jr nz,-
	; Le 8e couplet n'est pas une essence : Marine le chante à Zelda, à la fin (Denis lisait
	; « 7/8 » après la fin et croyait le jeu infinissable)
	ld a,GLOBALFLAG_BALLADE_FIN
	push bc
	call checkGlobalFlag
	pop bc
	jr z,+
	ld a,c
	cp $08
	jr nc,+
	inc c
+
	ld e,Interaction.var30
	ld a,c
	ld (de),a
	; Les cœurs, et les quarts du suivant
	ld a,(wLinkMaxHealth)
	srl a
	srl a
	inc e
	ld (de),a
	ld a,(wNumHeartPieces)
	inc e
	ld (de),a
	; Les objets
	ld hl,@items
	ld c,$00
-
	ldi a,(hl)
	or a
	jr z,+
	push hl
	push bc
	call checkTreasureObtained
	pop bc
	pop hl
	jr nc,-
	inc c
	jr -
+
	ld a,(wFeatherLevel)
	cp $02
	jr c,+
	inc c
+
	ld a,(wSwordLevel)
	cp $03
	jr c,+
	inc c
+
	ld a,(wBalladeSoulState)
	bit 1,a
	jr z,+
	inc c
+
	ld e,Interaction.var33
	ld a,c
	ld (de),a
	; Les anneaux
	ld hl,@rings
	ld c,$00
	ld b,$05
-
	ldi a,(hl)
	push hl
	push bc
	ld hl,wRingsObtained
	call checkFlag
	pop bc
	pop hl
	jr z,+
	inc c
+
	dec b
	jr nz,-
	ld e,Interaction.var34
	ld a,c
	ld (de),a
	; Les coffres
	ld hl,progressTrackerChests
	ld c,$00
	ld b,BALLADE_TRACKER_CHESTS
-
	push bc
	ldi a,(hl)
	ld b,(hl)
	inc hl
	push hl
	call getRoomFlags
	pop hl
	pop bc
	and $20
	jr z,+
	inc c
+
	dec b
	jr nz,-
	ld e,Interaction.var35
	ld a,c
	ld (de),a

	; Le pour cent (20 points par sorte, au prorata)
	ld e,Interaction.var30
	ld a,(de)
	ld b,a
	ld c,8
	call @points
	ld e,Interaction.var36
	ld (de),a
	ld a,(wLinkMaxHealth)
	ld b,a
	ld a,(wNumHeartPieces)
	add b
	sub 12
	jr nc,+
	xor a
+
	ld b,a
	ld c,34
	call @points
	call @addPoints
	ld e,Interaction.var33
	ld a,(de)
	ld b,a
	ld c,18
	call @points
	call @addPoints
	ld e,Interaction.var34
	ld a,(de)
	ld b,a
	ld c,5
	call @points
	call @addPoints
	ld e,Interaction.var35
	ld a,(de)
	ld b,a
	ld c,BALLADE_TRACKER_CHESTS
	call @points
	call @addPoints

	; L'écran de la progression (CUTSCENE_BALLADE_PROGRESS, cutscenes/generique.s ; Denis : « l'écran
	; comme les secrets d'Ages ») : les nombres dans wTmpcbb6-cbbc, la case de Link dans wTmpcbbf
	ld e,Interaction.var30
	ld hl,wTmpcbb6
	ld b,7
-
	ld a,(de)
	ldi (hl),a
	inc e
	dec b
	jr nz,-
	ld a,(w1Link.yh)
	and $f0
	ld b,a
	ld a,(w1Link.xh)
	swap a
	and $0f
	or b
	ld (wTmpcbbf),a
	ld a,CUTSCENE_BALLADE_PROGRESS
	ld (wCutsceneTrigger),a
	jp interactionDelete

@second:
@end:
	ret

; a = b * 20 / c (arrondi en dessous)
@points:
	push de
	ld h,$00
	ld l,b
	add hl,hl
	add hl,hl
	ld d,h
	ld e,l
	add hl,hl
	add hl,hl
	add hl,de
	ld b,$00
	ld e,c
	ld d,$00
	xor a
-
	ld a,l
	sub e
	ld l,a
	ld a,h
	sbc d
	ld h,a
	jr c,+
	inc b
	jr -
+
	ld a,b
	pop de
	ret

@addPoints:
	ld e,Interaction.var36
	ld h,a
	ld a,(de)
	add h
	ld (de),a
	ret

; Les objets : la Lanterne, l'épée, le Boomerang, les bombes, les Palmes, les Écailles de Sirène,
; la Canne, le Bracelet, le Grappin-Écho, la Pelle, la Plume, la Clochette d'Aube, le Lance-Graines,
; la sacoche, la boîte à anneaux (plus le Carnet des Rêves : Denis l'a fait enlever)
@items:
	.db TREASURE_HARP, TREASURE_SWORD, TREASURE_BOOMERANG, TREASURE_BOMBS, TREASURE_FLIPPERS
	.db TREASURE_MERMAID_SUIT, TREASURE_CANE_OF_SOMARIA, TREASURE_BRACELET, TREASURE_SWITCH_HOOK
	.db TREASURE_SHOVEL, TREASURE_FEATHER, TREASURE_FLUTE, TREASURE_SHOOTER, TREASURE_SEED_SATCHEL
	.db TREASURE_RING_BOX, $00

; Les anneaux de la Ballade
@rings:
	.db POWER_RING_L1, ARMOR_RING_L1, CHARGE_RING, BALLADE_CAMELEON_RING, BALLADE_EASTER_RING


