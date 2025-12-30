extends Resource
class_name SaveFile

@export var index: int = 0

@export var parent_save: SaveFile
@export var timestamp: Dictionary

@export var party: Array[StringName] = []
@export var character_sheets: Dictionary[StringName, CharacterSheet] = {}

@export var flags: Dictionary[StringName, bool] = {}
@export var counters: Dictionary[StringName, int] = {}

@export var treadmill_rooms: Array[RoomInfo] = []
@export var treadmill_allowed_themes: Array[StringName] = []
@export var map_state: MapState
