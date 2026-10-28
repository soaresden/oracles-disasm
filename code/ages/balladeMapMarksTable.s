; Généré par tools/make_map_marks.py (ne pas modifier à la main) : les marques de l'après-jeu
; sur la carte (code/ages/balladeMapMarks.s). Une marque : la sorte (0 quart de cœur, 1 anneau,
; 2 coffre), la case, le nombre de choses ; puis chaque chose : l'octet qui dit si elle est prise
; (.dw), son masque (.db). La marque s'affiche si l'une d'elles reste à prendre.
mapMarks:
	.db $00, $12, 1
	.dw wBoughtShopItems2
	.db $40 ; la boutique de Pépin
	.db $00, $17, 1
	.dw wGroup5RoomFlags+$d2
	.db $20 ; la Fosse de Bulle, à 3 m
	.db $00, $20, 1
	.dw wGroup1RoomFlags+$20
	.db $20 ; Tic et Tac (les cinq cachettes)
	.db $00, $62, 1
	.dw wGroup0RoomFlags+$62
	.db $20 ; la grand-mère de Noé (le Songe)
	.db $00, $74, 1
	.dw wGroup1RoomFlags+$74
	.db $40 ; la carte au trésor
	.db $00, $89, 1
	.dw wGroup1RoomFlags+$89
	.db $40 ; enterré au milieu du motif
	.db $00, $ac, 3
	.dw wGroup1RoomFlags+$ac
	.db $80 ; le Creuse-Rubis, en Difficile
	.dw wGroup5RoomFlags+$ea
	.db $80 ; le Mamono, en Dur sans être blessé
	.dw wGroup5RoomFlags+$ee
	.db $80 ; le 2e Labyrinthe des Lynels
	.db $00, $b3, 1
	.dw wGroup1RoomFlags+$b3
	.db $02 ; la chanteuse du Grand Sommeil
	.db $01, $20, 1
	.dw wRingsObtained+(ARMOR_RING_L1>>3)
	.db 1<<(ARMOR_RING_L1&7) ; Tic et Tac
	.db $01, $5c, 1
	.dw wRingsObtained+(BALLADE_EASTER_RING>>3)
	.db 1<<(BALLADE_EASTER_RING&7) ; Marine, sur son île
	.db $01, $ac, 3
	.dw wRingsObtained+(POWER_RING_L1>>3)
	.db 1<<(POWER_RING_L1&7) ; le 1er Labyrinthe des Lynels
	.dw wRingsObtained+(CHARGE_RING>>3)
	.db 1<<(CHARGE_RING&7) ; le Mamono
	.dw wRingsObtained+(BALLADE_CAMELEON_RING>>3)
	.db 1<<(BALLADE_CAMELEON_RING&7) ; le Creuse-Rubis
	.db $02, $0a, 6
	.dw wGroup4RoomFlags+$b1
	.db $20 ; le coffre de 4:b1
	.dw wGroup4RoomFlags+$b2
	.db $20 ; le coffre de 4:b2
	.dw wGroup4RoomFlags+$b0
	.db $20 ; le coffre de 4:b0
	.dw wGroup4RoomFlags+$af
	.db $20 ; le coffre de 4:af
	.dw wGroup4RoomFlags+$ae
	.db $20 ; le coffre de 4:ae
	.dw wGroup4RoomFlags+$b9
	.db $20 ; le coffre de 4:b9
	.db $02, $13, 1
	.dw wGroup1RoomFlags+$13
	.db $20 ; le coffre de 1:13
	.db $02, $17, 3
	.dw wGroup5RoomFlags+$d1
	.db $20 ; le coffre de 5:d1
	.dw wGroup5RoomFlags+$d2
	.db $20 ; le coffre de 5:d2
	.dw wGroup5RoomFlags+$d3
	.db $20 ; le coffre de 5:d3
	.db $02, $21, 5
	.dw wGroup4RoomFlags+$31
	.db $20 ; le coffre de 4:31
	.dw wGroup4RoomFlags+$34
	.db $20 ; le coffre de 4:34
	.dw wGroup4RoomFlags+$3a
	.db $20 ; le coffre de 4:3a
	.dw wGroup4RoomFlags+$3b
	.db $20 ; le coffre de 4:3b
	.dw wGroup4RoomFlags+$2c
	.db $20 ; le coffre de 4:2c
	.db $02, $27, 1
	.dw wGroup5RoomFlags+$b1
	.db $20 ; le coffre de 5:b1
	.db $02, $28, 1
	.dw wGroup5RoomFlags+$b2
	.db $20 ; le coffre de 5:b2
	.db $02, $32, 1
	.dw wGroup5RoomFlags+$b0
	.db $20 ; le coffre de 5:b0
	.db $02, $36, 5
	.dw wGroup5RoomFlags+$3a
	.db $20 ; le coffre de 5:3a
	.dw wGroup5RoomFlags+$40
	.db $20 ; le coffre de 5:40
	.dw wGroup5RoomFlags+$3d
	.db $20 ; le coffre de 5:3d
	.dw wGroup5RoomFlags+$37
	.db $20 ; le coffre de 5:37
	.dw wGroup5RoomFlags+$39
	.db $20 ; le coffre de 5:39
	.db $02, $42, 9
	.dw wGroup5RoomFlags+$92
	.db $20 ; le coffre de 5:92
	.dw wGroup5RoomFlags+$93
	.db $20 ; le coffre de 5:93
	.dw wGroup5RoomFlags+$8b
	.db $20 ; le coffre de 5:8b
	.dw wGroup5RoomFlags+$8e
	.db $20 ; le coffre de 5:8e
	.dw wGroup5RoomFlags+$8d
	.db $20 ; le coffre de 5:8d
	.dw wGroup5RoomFlags+$80
	.db $20 ; le coffre de 5:80
	.dw wGroup5RoomFlags+$7c
	.db $20 ; le coffre de 5:7c
	.dw wGroup5RoomFlags+$89
	.db $20 ; le coffre de 5:89
	.dw wGroup5RoomFlags+$7f
	.db $20 ; le coffre de 5:7f
	.db $02, $48, 7
	.dw wGroup4RoomFlags+$3f
	.db $20 ; le coffre de 4:3f
	.dw wGroup4RoomFlags+$42
	.db $20 ; le coffre de 4:42
	.dw wGroup4RoomFlags+$43
	.db $20 ; le coffre de 4:43
	.dw wGroup4RoomFlags+$46
	.db $20 ; le coffre de 4:46
	.dw wGroup4RoomFlags+$4d
	.db $20 ; le coffre de 4:4d
	.dw wGroup4RoomFlags+$47
	.db $20 ; le coffre de 4:47
	.dw wGroup4RoomFlags+$49
	.db $20 ; le coffre de 4:49
	.db $02, $60, 2
	.dw wGroup4RoomFlags+$d3
	.db $20 ; le coffre de 4:d3
	.dw wGroup4RoomFlags+$d6
	.db $20 ; le coffre de 4:d6
	.db $02, $7b, 8
	.dw wGroup4RoomFlags+$1e
	.db $20 ; le coffre de 4:1e
	.dw wGroup4RoomFlags+$1f
	.db $20 ; le coffre de 4:1f
	.dw wGroup4RoomFlags+$15
	.db $20 ; le coffre de 4:15
	.dw wGroup4RoomFlags+$1d
	.db $20 ; le coffre de 4:1d
	.dw wGroup4RoomFlags+$1c
	.db $20 ; le coffre de 4:1c
	.dw wGroup4RoomFlags+$17
	.db $20 ; le coffre de 4:17
	.dw wGroup4RoomFlags+$19
	.db $20 ; le coffre de 4:19
	.dw wGroup4RoomFlags+$1a
	.db $20 ; le coffre de 4:1a
	.db $02, $b2, 6
	.dw wGroup4RoomFlags+$5b
	.db $20 ; le coffre de 4:5b
	.dw wGroup4RoomFlags+$5c
	.db $20 ; le coffre de 4:5c
	.dw wGroup4RoomFlags+$5a
	.db $20 ; le coffre de 4:5a
	.dw wGroup4RoomFlags+$60
	.db $20 ; le coffre de 4:60
	.dw wGroup4RoomFlags+$61
	.db $20 ; le coffre de 4:61
	.dw wGroup4RoomFlags+$5f
	.db $20 ; le coffre de 4:5f
	.db $02, $c1, 2
	.dw wGroup0RoomFlags+$c1
	.db $20 ; le coffre de 0:c1
	.dw wGroup1RoomFlags+$c1
	.db $20 ; le coffre de 1:c1
	.db $ff
