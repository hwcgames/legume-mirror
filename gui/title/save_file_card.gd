extends Control
class_name SaveFileCard

@export var save: SaveFile
@export var story: InkStory
@export var location: String
#@export var day: String

func _ready() -> void:
	%Date.text = " {weekday}. {month}-{day}: ".format({
		"weekday": ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"][story.FetchVariable("weekday")],
		"month": story.FetchVariable("month"),
		"day": story.FetchVariable("day"),
	})
	%Location.text = story.EvaluateFunction("location_name", [story.FetchVariable("location")])
	%Button.pressed.connect(load_save)

func load_save():
	var main_game: Node = preload("uid://h5ppkq5boigl").instantiate()
	var st: Storyteller = main_game.get_node("Storyteller")
	var saver: Saver = main_game.get_node("Saver")
	#st.story = preload("uid://del34gulleoth")
	#if not starting_address.text.is_empty():
		#st.story.ChoosePathString(starting_address.text)
	var tree := get_tree()
	if PlayerManager.get_player_count() == 0:
		PlayerManager.join(-1)
	saver.queue_save = save
	tree.change_scene_to_node(main_game)
