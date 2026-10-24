; ==================================================================================================
; ENEMY_LINK_MIMIC
;
; Shares code with ENEMY_ARM_MIMIC.
; ==================================================================================================
enemyCode64:
	jr z,@normalStatus
	sub ENEMYSTATUS_NO_HEALTH
	ret c
	jp z,enemyDie
	dec a
	jp nz,ecom_updateKnockback
	ret

@normalStatus:
	ld e,Enemy.state
	ld a,(de)
	rst_jumpTable
	.dw @state_uninitialized
	.dw armMimic_state_stub
	.dw armMimic_state_stub
	.dw armMimic_state_switchHook
	.dw armMimic_state_stub
	.dw ecom_blownByGaleSeedState
	.dw armMimic_state_stub
	.dw armMimic_state_stub
	.dw linkMimic_state8


@state_uninitialized:
	ld a,PALH_82
	call loadPaletteHeader
	call armMimic_uninitialized
	jp objectSetVisible83


linkMimic_state8:
	ld a,(wDisabledObjects)
	or a
	ret nz
.ifdef ROM_AGES
	; BALLADE: Dark Link (la Tour Sans-Nuit, 2F) : plus un reflet des gestes de Link, un vrai duel
	; (Denis). Il réfléchit ailleurs (code/ages/balladeDarkLink.s : la banque des ennemis est
	; pleine) ; ici, il bouge (bit 0 de var34) et s'anime (bit 1) ; var35 = 1 s'il a buté.
	callab balladeDarkLink.think
	ld e,Enemy.var34
	ld a,(de)
	rrca
	ret nc
	push af
	call ecom_applyVelocityForTopDownEnemyNoHoles
	ld e,Enemy.var35
	ld a,$00
	jr nz,+
	inc a
+
	ld (de),a
	pop af
	rrca
	ret nc
	jp enemyAnimate
.else
	jr armMimic_state8
.endif
