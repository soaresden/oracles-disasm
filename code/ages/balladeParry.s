; ==================================================================================================
; BALLADE: le contre parfait (idée de Denis, comme l'Issen d'Onimusha). Si Link sort l'épée juste
; avant qu'un ennemi le touche (moins de BALLADE_PARRY_WINDOW images : swordParent.s note le moment
; dans wcde3, et wcde3+1 = 1), le coup ne le touche pas : un grand son, l'écran tremble, Link passe
; de l'autre coté de l'ennemi (si la case est libre), et l'ennemi meurt d'un coup ; un boss ou un
; mini-boss perd seulement BALLADE_PARRY_BOSS_DAMAGE points de vie (sans mourir de ce coup).
;
; Appelé par collisionEffects.s à la place des dégâts (d = l'ennemi ; on garde d).
; ==================================================================================================
counter:
	xor a
	ld (wcde3+1),a

	; L'ennemi : mort d'un coup, sauf les boss et mini-boss d'Ages (identifiants $70 et plus, et
	; Ramrock / ses mains)
	ld h,d
	ld l,Enemy.id
	ld a,(hl)
	ld l,Enemy.health
	cp $70
	jr nc,@boss
	cp ENEMY_RAMROCK_ARMS
	jr z,@boss
	cp ENEMY_RAMROCK
	jr z,@boss
	ld (hl),$00
	jr @link
@boss:
	ld a,(hl)
	sub BALLADE_PARRY_BOSS_DAMAGE
	jr nc,+
	xor a
+
	jr nz,+
	inc a
+
	ld (hl),a

@link:
	; Link : invincible un moment
	ld hl,w1Link.invincibilityCounter
	ld (hl),60

	; Link passe de l'autre coté de l'ennemi : ennemi + (ennemi - Link), si c'est dans la salle et
	; que la case est libre
	ld h,d
	ld l,Enemy.yh
	ld a,(hl)
	ld b,a
	ld a,(w1Link.yh)
	cpl
	inc a
	add b           ; ennemi - Link
	add b           ; ennemi + (ennemi - Link)
	cp $10
	jr c,@effects
	cp $a0
	jr nc,@effects
	ld b,a
	ld l,Enemy.xh
	ld a,(hl)
	ld c,a
	ld a,(w1Link.xh)
	cpl
	inc a
	add c
	add c
	cp $10
	jr c,@effects
	cp $e0
	jr nc,@effects
	ld c,a
	push bc
	call getTileCollisionsAtPosition
	pop bc
	jr nz,@effects
	ld hl,w1Link.yh
	ld (hl),b
	ld l,<w1Link.xh
	ld (hl),c

@effects:
	ld a,SND_BIG_EXPLOSION
	call playSound
	ld a,$10
	call setScreenShakeCounter
	; une étincelle sur l'ennemi
	call getFreeInteractionSlot
	ret nz
	ld (hl),INTERAC_KILLENEMYPUFF
	ld l,Interaction.yh
	ld e,Enemy.yh
	ld a,(de)
	ld (hl),a
	ld l,Interaction.xh
	ld e,Enemy.xh
	ld a,(de)
	ld (hl),a
	ret
