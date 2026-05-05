extends Resource
class_name SaveFile

@export var index: int = 0

@export var parent_save: SaveFile
@export var timestamp: Dictionary

@export var party: Array[StringName] = []
@export var character_sheets: Dictionary[StringName, ActorSheet] = {}

@export var flags: Dictionary[StringName, bool] = {}
@export var counters: Dictionary[StringName, int] = {}

@export var treadmill_rooms: Array[RoomInfo] = []
@export var treadmill_allowed_themes: Array[StringName] = []
@export var map_state: MapState

func get_character_sheet(name: String) -> ActorSheet:
	if name in character_sheets:
		return character_sheets[name]
	var sheet: ActorSheet = load("res://database/actors/%s.tres" % name)
	return sheet

func copy() -> SaveFile:
	var new = self.duplicate()
	for name in new.character_sheets.keys():
		new.character_sheets[name] = character_sheets[name].copy()
	return new
