;;
; ITEM_SWORD_BEAM
itemCode27:
	ld e,Item.state
	ld a,(de)
	rst_jumpTable

	.dw @state0
	.dw @state1

@state0:
	ld hl,@initialOffsetsTable
	call applyOffsetTableHL
	call itemLoadAttributesAndGraphics
	call itemIncState

	ld l,Item.speed
	ld (hl),SPEED_300

	; Calculate angle
	ld l,Item.direction
	ldi a,(hl)
	ld c,a
	swap a
	rrca
	ld (hl),a

	ld a,c
	call itemSetAnimation
	call objectSetVisible81

	ld a,SND_SWORDBEAM
	jp playSound

@initialOffsetsTable:
	.db $f5 $fc $00 ; DIR_UP
	.db $00 $0c $00 ; DIR_RIGHT
	.db $0a $03 $00 ; DIR_DOWN
	.db $00 $f3 $00 ; DIR_LEFT

@state1:
	call itemUpdateDamageToApply
.ifdef ROM_AGES
	jr nz,@hitObject
.else
	jr nz,@collision
.endif

	; No collision with an object?

	call objectApplySpeed
	call objectCheckTileCollision_allowHoles
	jr nc,@noCollision

	call itemCheckCanPassSolidTile
	jr nz,@collision

@noCollision:
	; Flip palette every 4 frames
	ld a,(wFrameCounter)
	and $03
	jr nz,+
	ld h,d
	ld l,Item.oamFlagsBackup
	ld a,(hl)
	xor $01
	ldi (hl),a
	ldi (hl),a
+
	call objectCheckWithinScreenBoundary
	ret c
	jp itemDelete

.ifdef ROM_AGES
@hitObject:
	; BALLADE: le Bracelet des Âmes : un ennemi touché rend un quart de cœur à Link
	ld a,(wBalladeSoulState)
	bit 1,a
	jr z,@collision
	ld hl,wLinkHealth
	ldi a,(hl)
	cp (hl)
	jr nc,@collision
	dec l
	inc (hl)
.endif

@collision:
	ldbc INTERAC_CLINK, $81
	call objectCreateInteraction
	jp itemDelete
