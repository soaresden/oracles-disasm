dungeonDataTable:
	.dw dungeonData00
	.dw dungeonData01
	.dw dungeonData02
	.dw dungeonData03
	.dw dungeonData04
	.dw dungeonData05
	.dw dungeonData06
	.dw dungeonData07
	.dw dungeonData08
	.dw dungeonData09
	.dw dungeonData0a
	.dw dungeonData0b
	.dw dungeonData0c
	.dw dungeonData0d
	.dw dungeonData0e
	.dw dungeonData0f

; Bytes:
; 0: High byte of flag address.
; 1: Which room wallmasters send you to
; 2: Address of dungeon layout (this gets converted to an index relative to the
;    "dungeonLayoutDataStart" label)
; 3: wDungeonNumFloors
; 4: Base floor number plus 3 (if zero, the first floor is "B3")
;    This only affects how the map names the floor.
; 5: Bitset of floors that are unlocked on the map when you get the compass.
;    Again, this only affects the map.
; 6-7: Unused?

dungeonData00:
	m_DungeonData >wGroup4RoomFlags, $04, dungeon00Layout, $01, $03, $00, $01, $00
dungeonData01:
	; BALLADE: le Phare Éteint, sur un seul étage (tout en hauteur)
	m_DungeonData >wGroup4RoomFlags, $24, dungeon01LayoutPhare, $01, $03, $01, $00, $00
dungeonData02:
	; BALLADE: le Coffre à Jouets (dans le rêve de Lila), sur un seul étage
	m_DungeonData >wGroup4RoomFlags, $39, dungeon02LayoutCoffre, $01, $03, $01, $00, $00
dungeonData03:
	; BALLADE: le Récif Murmurant, sous la Lagune des Serments (B1 sous l'eau, 1F au sec)
	m_DungeonData >wGroup5RoomFlags, $44, dungeon03LayoutRecif, $02, $02, $03, $00, $00
dungeonData04:
	; BALLADE: la Forge Endormie, dans le cratère de Mont-Braise (un seul étage)
	m_DungeonData >wGroup4RoomFlags, $bb, dungeon04LayoutForge, $01, $03, $01, $00, $00
dungeonData05:
	m_DungeonData >wGroup4RoomFlags, $bb, dungeon05Layout, $02, $02, $01, $00, $00
dungeonData06:
	m_DungeonData >wGroup5RoomFlags, $26, dungeon06Layout, $01, $03, $07, $00, $00
dungeonData07:
	m_DungeonData >wGroup5RoomFlags, $56, dungeon07Layout, $03, $03, $00, $00, $00
dungeonData08:
	m_DungeonData >wGroup5RoomFlags, $aa, dungeon08Layout, $04, $00, $00, $00, $00
dungeonData09:
	m_DungeonData >wGroup4RoomFlags, $01, dungeon09Layout, $01, $03, $00, $00, $00
dungeonData0a:
	m_DungeonData >wGroup5RoomFlags, $f4, dungeon0aLayout, $01, $03, $00, $00, $00
dungeonData0b:
	m_DungeonData >wGroup4RoomFlags, $ce, dungeon0bLayout, $02, $02, $00, $00, $00
dungeonData0c:
	m_DungeonData >wGroup5RoomFlags, $44, dungeon0cLayout, $02, $02, $00, $00, $00
dungeonData0d:
	m_DungeonData >wGroup4RoomFlags, $04, dungeon0dLayout, $01, $03, $00, $00, $00
dungeonData0e:
	m_DungeonData >wGroup5RoomFlags, $ce, dungeon0eLayout, $01, $03, $00, $00, $00
dungeonData0f:
	m_DungeonData >wGroup4RoomFlags, $ce, dungeon0fLayout, $01, $03, $00, $00, $00
