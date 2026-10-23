; Each number corresponds to TX_03XX (see text.txt).
; BALLADE: les salles de l'île de la Brume (lignes 7 à a, colonnes 9 à c) utilisent $36 (Île de la
; Brume), $37 (Port-Veille) et $38 (Cap du Phare) ; textes dans story/textes.yaml.
; If bit 7 is set, that indicates special behaviour; see the "mapGetRoomText" function.
presentMapTextIndices:
	.db $02 $02 $02 $02 $03 $03 $03 $03 $04 $04 $04 $04 $04 $0a
	.db $02 $02 $02 $02 $03 $03 $03 $03 $04 $04 $04 $04 $04 $0a
	.db $02 $02 $02 $02 $03 $03 $03 $03 $04 $04 $04 $04 $04 $0a
	.db $02 $02 $02 $02 $03 $03 $03 $03 $04 $04 $04 $04 $04 $0a
	.db $05 $05 $05 $05 $05 $06 $06 $06 $06 $0a $0a $0a $0a $0a
	.db $05 $05 $05 $05 $05 $06 $06 $06 $06 $0a $0a $09 $09 $0a
	.db $05 $05 $05 $05 $05 $06 $06 $06 $06 $0a $0a $09 $09 $0a
	.db $05 $05 $05 $05 $05 $06 $06 $06 $06 $36 $38 $38 $36 $0a
	.db $0a $0a $0a $0a $0a $0a $0a $0a $0a $36 $36 $36 $36 $0a
	.db $0a $0a $0a $0a $0a $0a $0a $0a $0a $37 $37 $37 $37 $0a
	.db $07 $07 $07 $07 $07 $0a $0a $0a $0a $36 $36 $37 $36 $0a
	.db $07 $07 $07 $07 $07 $0a $0a $0a $08 $08 $08 $0a $0a $0a
	.db $07 $07 $07 $07 $07 $0a $0a $0a $08 $08 $08 $0a $0a $0a
	.db $07 $07 $07 $07 $07 $0a $0a $0a $08 $08 $08 $0a $0a $0a

pastMapTextIndices:
	.db $02 $02 $02 $02 $03 $03 $03 $03 $04 $04 $04 $04 $04 $0a
	.db $02 $02 $02 $02 $03 $03 $03 $03 $04 $04 $04 $04 $04 $0a
	.db $02 $02 $02 $02 $03 $03 $03 $03 $04 $04 $04 $04 $04 $0a
	.db $02 $02 $02 $02 $03 $03 $03 $03 $04 $04 $04 $04 $04 $0a
	.db $05 $05 $05 $05 $05 $06 $06 $06 $06 $0a $0a $0a $0a $0a
	.db $05 $05 $05 $05 $05 $06 $06 $06 $06 $0a $0a $09 $09 $0a
	.db $05 $05 $05 $05 $05 $06 $06 $06 $06 $0a $0a $09 $09 $0a
	.db $05 $05 $05 $05 $05 $06 $06 $06 $06 $36 $38 $38 $36 $0a
	.db $0a $0a $0a $0a $0a $0a $0a $0a $0a $36 $36 $36 $36 $0a
	.db $0a $0a $0a $0a $0a $0a $0a $0a $0a $37 $37 $37 $37 $0a
	.db $07 $07 $07 $07 $07 $0a $0a $0a $0a $36 $36 $37 $36 $0a
	.db $07 $07 $07 $07 $07 $0a $0a $0a $08 $08 $08 $0a $0a $0a
	.db $07 $07 $07 $07 $07 $0a $0a $0a $08 $08 $08 $0a $0a $0a
	.db $07 $07 $07 $07 $07 $0a $0a $0a $08 $08 $08 $0a $0a $0a



; This is the list of popups that appear when hovering the cursor over a tile.
;
; b0: room index
; b1: popup behaviour. Each digit represents a different popup; screens with only one
;     popup use the same digit twice. (see the "mapMenu_LoadPopupData" function)
presentMinimapPopups: ; BALLADE: pas les petites images d'Ages sur notre carte
	.db $ff

pastMinimapPopups:
	.db $ff
