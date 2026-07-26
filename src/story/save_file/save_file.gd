extends Resource
class_name SaveFile

@export var index: int = 0

@export var parent_save_idx: int = 0
@export var timestamp: String

@export_file("*.ink") var story: String
@export var ink_save: String

@export var active_camera: String

@export var party: Array[StringName] = []
@export var character_sheets: Dictionary[StringName, ActorSheet] = {}
@export var inventory: Array[FossilizedItem] = []

@export var treadmill_rooms: Array[String] = []
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

func load_save(tree: SceneTree):
	var main_game: Node = load("uid://h5ppkq5boigl").instantiate()
	var st = main_game.get_node("Storyteller")
	var saver = main_game.get_node("Saver")
	#st.story = preload("uid://del34gulleoth")
	#if not starting_address.text.is_empty():
		#st.story.ChoosePathString(starting_address.text)
	if PlayerManager.get_player_count() == 0:
		PlayerManager.join(-1)
	saver.queue_save = self
	tree.change_scene_to_node(main_game)
