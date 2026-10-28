; ==================================================================================================
; BALLADE: après la fin, sur la carte (Select), ce qui reste à trouver clignote (Denis : « comme on a
; fait pour la ROM combined, les quarts de cœur, les anneaux aussi ; et les coffres manquants ») :
; des étincelles rouges (les quarts de cœur), un anneau, un petit coffre (les coffres ; ceux d'un
; donjon sur son entrée). La table vient de tools/make_map_marks.py. Appelé par bank2.s (la
; carte du dehors), comme les marques de la ROM combined (code/crossworldMapMarkers.s).
; ==================================================================================================
.include "code/ages/balladeMapMarksTable.s"

draw:
	ld a,GLOBALFLAG_BALLADE_FIN
	call checkGlobalFlag
	ret z
	ld a,(wFrameCounter)
	and $10
	ret z
	ld hl,mapMarks
@next:
	ldi a,(hl)
	cp $ff
	ret z
	ld b,a			; la sorte
	ldi a,(hl)
	ld c,a			; la case
	ldi a,(hl)
	ld e,a			; le nombre de choses
	ld d,$00		; (1 : l'une reste à prendre)
@item:
	push de
	ldi a,(hl)
	ld e,a
	ldi a,(hl)
	ld d,a
	ld a,(de)
	and (hl)
	inc hl
	pop de
	jr nz,+
	ld d,$01
+
	dec e
	jr nz,@item
	ld a,d
	or a
	jr z,@next
	push hl
	ld a,b
	add a
	add a
	add b			; (5 octets par dessin)
	ld hl,@sprites
	rst_addAToHl
	; la case -> la position à l'écran (comme mapMenu_drawSpriteAtRoomIndex, bank2.s)
	ldde OVERWORLD_MAP_START_Y*8, OVERWORLD_MAP_START_X*8
	ld a,c
	and $f0
	srl a
	add d
	ld b,a
	ld a,c
	and $0f
	add a
	add a
	add a
	add e
	ld c,a
	call addSpritesToOam_withOffset
	pop hl
	jr @next

; Un sprite chacun, parmi ceux de l'écran de la carte (il n'y a pas de cœur) : les étincelles en
; rouge (les quarts de cœur, en haut à gauche de la case), l'anneau (à droite), le petit coffre (en
; bas)
@sprites:
	.db $01, $0a, $06, $4a, $05
	.db $01, $0a, $0a, $1c, $07
	.db $01, $0e, $08, $40, $07
