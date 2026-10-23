m_section_free chestData NAMESPACE chestData

; m_ChestData macro takes 3 parameters:
;   1: Y/X position of chest (byte); an opened chest tile will be placed here when the room is
;      loaded, if ROOMFLAG_ITEM has been set in that room.
;   2: Low byte of room index
;   3: Treasure object to get from the chest (see "data/{game}/treasureObjectData.s")

chestDataGroupTable:
	.dw chestGroup0Data
	.dw chestGroup1Data
	.dw chestGroup2Data
	.dw chestGroup3Data
	.dw chestGroup4Data
	.dw chestGroup5Data
	.dw chestGroup6Data
	.dw chestGroup7Data

chestGroup0Data:
	;m_ChestData $49, $51, TREASURE_OBJECT_RUPEES_04 ; BALLADE: l'île des Échos (1:40-74)
	m_ChestData $51, $49, TREASURE_OBJECT_RUPEES_04
	m_ChestData $36, $84, TREASURE_OBJECT_RUPEES_05
	m_ChestData $35, $91, TREASURE_OBJECT_RING_21
	m_ChestData $25, $d4, TREASURE_OBJECT_RING_23
	m_ChestData $25, $d5, TREASURE_OBJECT_RING_25
	;m_ChestData $12, $63, TREASURE_OBJECT_GASHA_SEED_01 ; BALLADE: l'île des Échos (1:40-74)
	.db $ff

chestGroup1Data:
	m_ChestData $43, $6d, TREASURE_OBJECT_RING_27
	m_ChestData $11, $c1, TREASURE_OBJECT_RUPEES_03 ; BALLADE: le lac de glace (1:c1) : des rubis (20) (il était dans la liste du groupe 2 : le coffre ne s'ouvrait pas)
	m_ChestData $36, $13, TREASURE_OBJECT_RUPEES_05 ; BALLADE: le château de sable de Hameau-Grelot (1:13) : on y passe par le Songe (le pont-levis)
	.db $ff

chestGroup2Data:
	m_ChestData $14, $f7, TREASURE_OBJECT_RING_11
	m_ChestData $16, $f7, TREASURE_OBJECT_GASHA_SEED_01
	m_ChestData $45, $be, TREASURE_OBJECT_RING_17
	m_ChestData $22, $fc, TREASURE_OBJECT_RUPEES_06
	m_ChestData $15, $ce, TREASURE_OBJECT_GASHA_SEED_01
	m_ChestData $34, $ec, TREASURE_OBJECT_RING_19
	m_ChestData $34, $f4, TREASURE_OBJECT_RING_19
	m_ChestData $18, $4f, TREASURE_OBJECT_RING_22
	m_ChestData $14, $c0, TREASURE_OBJECT_GASHA_SEED_01
	.db $ff

chestGroup3Data:
	m_ChestData $24, $0e, TREASURE_OBJECT_RING_26
	m_ChestData $18, $1f, TREASURE_OBJECT_RUPEES_06
	m_ChestData $35, $e8, TREASURE_OBJECT_NONE_00
	m_ChestData $35, $ff, TREASURE_OBJECT_NONE_00
	m_ChestData $18, $f9, TREASURE_OBJECT_RING_20
	m_ChestData $34, $fd, TREASURE_OBJECT_HEART_PIECE_01
	.db $ff

chestGroup4Data:
	; BALLADE: la Spirale Céleste (story/salles/spirale.txt)
	m_ChestData $47, $3f, TREASURE_OBJECT_SMALL_KEY_03  ; l'îlot (le Grappin-Écho) : la petite clé 1
	m_ChestData $5a, $42, TREASURE_OBJECT_MAP_02        ; le carrelage bleu : la carte
	m_ChestData $85, $43, TREASURE_OBJECT_COMPASS_02    ; les chauves-souris battues : la boussole
	m_ChestData $15, $46, TREASURE_OBJECT_SMALL_KEY_03  ; le Grappin-Écho puis un saut : la petite clé 2
	m_ChestData $8b, $4d, TREASURE_OBJECT_BOSS_KEY_03   ; l'îlot (le pont du cristal de 4c) : la clé du boss
	m_ChestData $57, $50, TREASURE_OBJECT_FEATHER_03    ; le cœur de la spirale : la Cape de Roc
	; BALLADE: le Palais Givré (story/salles/palais.txt)
	m_ChestData $87, $5b, TREASURE_OBJECT_SMALL_KEY_03  ; les deux torches allumées en biais : la petite clé 1
	m_ChestData $72, $5c, TREASURE_OBJECT_MAP_02        ; le champ de glace : la carte
	m_ChestData $37, $5a, TREASURE_OBJECT_FLUTE_03      ; le Chevalier Gelé battu : la Clochette d'Aube
	m_ChestData $87, $60, TREASURE_OBJECT_SMALL_KEY_03  ; le cristal frappé en biais : la petite clé 2
	m_ChestData $67, $61, TREASURE_OBJECT_COMPASS_02    ; l'îlot (le Grappin-Écho) : la boussole
	m_ChestData $53, $5f, TREASURE_OBJECT_BOSS_KEY_03   ; les deux torches entourées de trous : la clé du boss
	; BALLADE: la Forge Endormie (story/salles/forge.txt)
	m_ChestData $57, $b1, TREASURE_OBJECT_CANE_OF_SOMARIA_00 ; les Copies battues : la Canne des Songes
	m_ChestData $5b, $b2, TREASURE_OBJECT_MAP_02        ; la carte
	m_ChestData $22, $b0, TREASURE_OBJECT_SMALL_KEY_03  ; un bloc de la Canne sur le bouton : la petite clé 2
	m_ChestData $27, $af, TREASURE_OBJECT_RUPEES_02     ; des rubis (10)
	m_ChestData $77, $ae, TREASURE_OBJECT_BOSS_KEY_03   ; les deux boutons : la clé du boss
	m_ChestData $53, $b9, TREASURE_OBJECT_COMPASS_02    ; la boussole
	; BALLADE: le Coffre à Jouets (story/salles/coffre.txt)
	m_ChestData $57, $31, TREASURE_OBJECT_BOOMERANG_04  ; le Boomerang-Toupie (quand les soldats sont battus)
	m_ChestData $2c, $34, TREASURE_OBJECT_SMALL_KEY_03  ; le grelot : la petite clé 2
	m_ChestData $57, $3a, TREASURE_OBJECT_COMPASS_02    ; la boussole
	m_ChestData $57, $3b, TREASURE_OBJECT_MAP_02        ; la carte
	m_ChestData $57, $2c, TREASURE_OBJECT_BOSS_KEY_03   ; le Soldat de Plomb : la clé du boss
	; BALLADE: le Phare Éteint (story/salles/phare.txt ; un coffre par salle, le premier compte)
	m_ChestData $57, $1e, TREASURE_OBJECT_SMALL_KEY_03   ; les Zols (quand ils sont battus)
	m_ChestData $8c, $1f, TREASURE_OBJECT_RUPEES_02      ; la statue sur le bouton : 10 rubis
	m_ChestData $57, $15, TREASURE_OBJECT_HARP_02        ; la Lanterne des Songes
	m_ChestData $2c, $1d, TREASURE_OBJECT_RUPEES_03      ; derrière le mur qui brûle : 20 rubis
	m_ChestData $53, $1c, TREASURE_OBJECT_SMALL_KEY_03   ; la douve
	m_ChestData $57, $17, TREASURE_OBJECT_SMALL_KEY_03   ; la tour, 3 torches
	m_ChestData $5a, $19, TREASURE_OBJECT_BOSS_KEY_03    ; le balcon ouest
	m_ChestData $1c, $1a, TREASURE_OBJECT_RUPEES_04      ; le balcon est : 30 rubis
	; BALLADE: le Terrier des Serpents (story/salles/terrier.txt)
	m_ChestData $2c, $d3, TREASURE_OBJECT_SMALL_KEY_03   ; la statue sur le bouton : la petite clé
	m_ChestData $8d, $d6, TREASURE_OBJECT_RUPEES_03      ; l'antichambre : 20 rubis
	m_ChestData $57, $08, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $17, $16, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $53, $1d, TREASURE_OBJECT_COMPASS_02
	m_ChestData $73, $1f, TREASURE_OBJECT_RING_04
	m_ChestData $16, $23, TREASURE_OBJECT_BOSS_KEY_03
	m_ChestData $12, $25, TREASURE_OBJECT_MAP_02
	m_ChestData $57, $30, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $58, $3e, TREASURE_OBJECT_BOSS_KEY_03
	m_ChestData $87, $40, TREASURE_OBJECT_MAP_02
	m_ChestData $59, $41, TREASURE_OBJECT_GASHA_SEED_01
	m_ChestData $1d, $45, TREASURE_OBJECT_COMPASS_02
	m_ChestData $57, $48, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $8c, $4e, TREASURE_OBJECT_RUPEES_03
	m_ChestData $28, $50, TREASURE_OBJECT_BOSS_KEY_03
	m_ChestData $4c, $55, TREASURE_OBJECT_GASHA_SEED_01
	m_ChestData $69, $56, TREASURE_OBJECT_COMPASS_02
	m_ChestData $59, $58, TREASURE_OBJECT_SHOOTER_00
	m_ChestData $27, $5c, TREASURE_OBJECT_RUPEES_04
	m_ChestData $57, $60, TREASURE_OBJECT_GASHA_SEED_01
	m_ChestData $58, $65, TREASURE_OBJECT_MAP_02
	m_ChestData $67, $6f, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $54, $74, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $39, $7a, TREASURE_OBJECT_BOSS_KEY_03
	m_ChestData $65, $87, TREASURE_OBJECT_SWITCH_HOOK_00
	m_ChestData $41, $8b, TREASURE_OBJECT_COMPASS_02
	m_ChestData $57, $8f, TREASURE_OBJECT_MAP_02
	m_ChestData $84, $90, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $62, $92, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $19, $99, TREASURE_OBJECT_RUPEES_05
	m_ChestData $54, $9b, TREASURE_OBJECT_BOSS_KEY_03
	m_ChestData $47, $9e, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $57, $9f, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $57, $a3, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $53, $a5, TREASURE_OBJECT_CANE_OF_SOMARIA_00
	m_ChestData $8b, $ad, TREASURE_OBJECT_COMPASS_02
	m_ChestData $57, $ba, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $57, $bc, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $17, $be, TREASURE_OBJECT_MAP_02
	m_ChestData $47, $c1, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $27, $c3, TREASURE_OBJECT_GASHA_SEED_01
	m_ChestData $47, $c4, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $27, $c5, TREASURE_OBJECT_RING_1f
	m_ChestData $47, $c6, TREASURE_OBJECT_GASHA_SEED_01
	m_ChestData $8b, $c7, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $47, $c8, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $8c, $c9, TREASURE_OBJECT_GASHA_SEED_01
	m_ChestData $3b, $ca, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $47, $cb, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $66, $cc, TREASURE_OBJECT_RUPEES_08
	m_ChestData $57, $cf, TREASURE_OBJECT_SMALL_KEY_03
	.db $ff

chestGroup5Data:
	; BALLADE: la Cathédrale des Échos (story/salles/cathedrale.txt)
	m_ChestData $53, $92, TREASURE_OBJECT_MAP_02        ; le bas-côté sud-ouest : la carte
	m_ChestData $57, $93, TREASURE_OBJECT_COMPASS_02    ; les Stalfos battus : la boussole
	m_ChestData $37, $8b, TREASURE_OBJECT_SMALL_KEY_03  ; la sacristie : la petite clé 1
	m_ChestData $37, $8e, TREASURE_OBJECT_RUPEES_03     ; le reliquaire : des rubis (20)
	m_ChestData $12, $8d, TREASURE_OBJECT_SWITCH_HOOK_00 ; la nef : le Grappin-Écho
	m_ChestData $54, $80, TREASURE_OBJECT_SMALL_KEY_03  ; le bout ouest : la petite clé 2
	m_ChestData $37, $7c, TREASURE_OBJECT_RUPEES_02     ; la tribune ouest : des rubis (10)
	m_ChestData $5a, $89, TREASURE_OBJECT_BOSS_KEY_03   ; le bout est : la clé du chœur
	m_ChestData $37, $7f, TREASURE_OBJECT_RUPEES_02     ; la tribune est : des rubis (10)
	m_ChestData $1c, $b0, TREASURE_OBJECT_TRADEITEM_0c ; BALLADE: la grotte de la Boîte : Sire Bouchon, le jouet de Lila
	m_ChestData $17, $b1, TREASURE_OBJECT_RUPEES_03 ; BALLADE: la grotte des amoureux : des rubis (20)
	m_ChestData $1b, $b2, TREASURE_OBJECT_RUPEES_03 ; BALLADE: la mine abandonnée (Mont-Braise) : des rubis (20)
	; BALLADE: la Fosse de Bulle (story/salles/fosse.txt)
	m_ChestData $81, $d1, TREASURE_OBJECT_RUPEES_03      ; profondeur 2 : des rubis (20)
	m_ChestData $11, $d2, TREASURE_OBJECT_HEART_PIECE_01 ; profondeur 3 : un quart de cœur
	m_ChestData $4d, $d3, TREASURE_OBJECT_RUPEES_05      ; profondeur 4 : beaucoup de rubis (50)
	; BALLADE: le Récif Murmurant (story/salles/recif.txt)
	m_ChestData $53, $3a, TREASURE_OBJECT_COMPASS_02    ; la boussole
	m_ChestData $2b, $40, TREASURE_OBJECT_MAP_02        ; la carte
	m_ChestData $5b, $3d, TREASURE_OBJECT_SMALL_KEY_03  ; la petite clé 2
	m_ChestData $57, $37, TREASURE_OBJECT_MERMAID_SUIT_00 ; Vire battu : les Écailles de Sirène
	m_ChestData $8b, $39, TREASURE_OBJECT_BOSS_KEY_03   ; les coquillages-échos : la clé du boss
	m_ChestData $17, $13, TREASURE_OBJECT_MERMAID_SUIT_00
	m_ChestData $25, $14, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $53, $1b, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $17, $1c, TREASURE_OBJECT_BOSS_KEY_03
	m_ChestData $13, $1d, TREASURE_OBJECT_MAP_02
	m_ChestData $13, $1f, TREASURE_OBJECT_RUPEES_02
	m_ChestData $67, $21, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $3d, $25, TREASURE_OBJECT_COMPASS_02
	m_ChestData $57, $2c, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $24, $2e, TREASURE_OBJECT_RUPEES_04
	m_ChestData $57, $31, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $55, $3c, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $53, $3f, TREASURE_OBJECT_COMPASS_02
	m_ChestData $52, $41, TREASURE_OBJECT_MAP_02
	m_ChestData $57, $45, TREASURE_OBJECT_GASHA_SEED_01
	m_ChestData $31, $4c, TREASURE_OBJECT_RING_28
	m_ChestData $18, $4d, TREASURE_OBJECT_GASHA_SEED_01
	m_ChestData $12, $4e, TREASURE_OBJECT_SWITCH_HOOK_01
	m_ChestData $28, $53, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $47, $54, TREASURE_OBJECT_COMPASS_02
	m_ChestData $56, $5f, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $57, $64, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $42, $65, TREASURE_OBJECT_MAP_02
	m_ChestData $27, $6a, TREASURE_OBJECT_GASHA_SEED_01
	m_ChestData $57, $6c, TREASURE_OBJECT_BOSS_KEY_03
	m_ChestData $6c, $72, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $57, $50, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $12, $79, TREASURE_OBJECT_BOSS_KEY_03
	m_ChestData $16, $7b, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $27, $7c, TREASURE_OBJECT_SLATE_00
	m_ChestData $27, $7e, TREASURE_OBJECT_SLATE_00
	m_ChestData $1b, $85, TREASURE_OBJECT_MAP_02
	m_ChestData $27, $92, TREASURE_OBJECT_SLATE_00
	m_ChestData $25, $94, TREASURE_OBJECT_SLATE_00
	m_ChestData $16, $97, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $2c, $9f, TREASURE_OBJECT_GASHA_SEED_01
	m_ChestData $1d, $a3, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $1a, $a4, TREASURE_OBJECT_COMPASS_02
	m_ChestData $6d, $a7, TREASURE_OBJECT_SMALL_KEY_03
	m_ChestData $37, $a6, TREASURE_OBJECT_BRACELET_02
	m_ChestData $27, $91, TREASURE_OBJECT_GASHA_SEED_01
	m_ChestData $15, $b5, TREASURE_OBJECT_RUPEES_04
	m_ChestData $74, $bd, TREASURE_OBJECT_RING_16
	m_ChestData $47, $b9, TREASURE_OBJECT_RUPEES_05
	m_ChestData $15, $ee, TREASURE_OBJECT_GASHA_SEED_01
	m_ChestData $15, $dd, TREASURE_OBJECT_BOMBS_00
	m_ChestData $81, $c0, TREASURE_OBJECT_RUPEES_04
	m_ChestData $24, $c0, TREASURE_OBJECT_RUPEES_04
	m_ChestData $83, $e1, TREASURE_OBJECT_RUPEES_05
	m_ChestData $22, $e0, TREASURE_OBJECT_GASHA_SEED_01
	m_ChestData $47, $b3, TREASURE_OBJECT_GASHA_SEED_01
	m_ChestData $57, $cb, TREASURE_OBJECT_RING_1c
	m_ChestData $43, $c7, TREASURE_OBJECT_RING_1a
	m_ChestData $12, $ca, TREASURE_OBJECT_GASHA_SEED_01
	m_ChestData $22, $b8, TREASURE_OBJECT_RING_19
	m_ChestData $14, $ac, TREASURE_OBJECT_RUPEES_08
	m_ChestData $12, $f7, TREASURE_OBJECT_RING_1b
	.db $ff

chestGroup6Data:
	.db $ff

chestGroup7Data:
	.db $ff

.ends
