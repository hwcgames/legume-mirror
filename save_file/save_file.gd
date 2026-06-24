extends Resource
class_name SaveFile

@export var index: int = 0

@export var parent_save_idx: int = 0
@export var timestamp: Dictionary

@export_file_path("*.ink") var story: String
@export var ink_save: String

@export var active_camera: String

@export var party: Array[StringName] = []
@export var character_sheets: Dictionary[StringName, ActorSheet] = {}

@export var treadmill_roomset: RoomSet
@export var treadmill_allowed_themes: Array[StringName] = []
@export var map_state: MapState

func get_character_sheet(name: String) -> ActorSheet:
	if name in character_sheets:
		return character_sheets[name]
	var sheet: ActorSheet = load("res://database/actors/%s.tres" % name)
	if sheet.saved:
		sheet = sheet.copy()
		character_sheets[name] = sheet
	return sheet

func copy() -> SaveFile:
	var new = self.duplicate()
	for name in new.character_sheets.keys():
		new.character_sheets[name] = character_sheets[name].copy()
	return new
