extends Node
class_name Saver

var parent_save: SaveFile = load("uid://07q2yjh6h41t")
var current_save: SaveFile:
	get:
		if current_save == null:
			current_save = parent_save.copy()
			current_save.parent_save_idx = parent_save.index
		return current_save

var queue_save: SaveFile

const path_template = "user://saves/%08d.save.tres"

signal pre_save(file: SaveFile)

static var me: Saver
static func find() -> Saver:
	return me

func save_participants() -> Array[Node]:
	return get_tree().get_nodes_in_group("save_participants")

func _ready():
	me = self
	add_to_group("story_listener")
	if is_instance_valid(queue_save):
		await get_tree().process_frame
		load_save(queue_save)
		queue_save = null
		Storyteller.find().busy = false

func _to_string() -> String:
	return "Saver"

func wants_line(line: String, tags: Array[String]) -> bool:
	return do_line(line, tags) != null
func take_line(line: String, tags: Array[String]):
	do_line(line, tags).call()
func do_line(line: String, tags: Array[String]):
	match Array(line.split(" ", false)):
		["/", "save"]:
			return func():
				save(false)
		["/", "save", "in", "place"]:
			return func():
				save(true)
		["/", "load", "prev"]:
			return func():
				parent_save.load_save(get_tree())
	return null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_load_last_save"):
		parent_save.load_save(get_tree())

func save(in_place: bool = false):
	# Ask everyone to populate the save...
	for participant in save_participants():
		participant.pre_save(current_save)
	current_save.timestamp = Time.get_datetime_string_from_system(true, false)
	#pre_save.emit(current_save)
	# Ensure the existence of the saves directory.
	DirAccess.make_dir_absolute("user://saves")
	# If this is an in-place save, and the parent save is a user save...
	if in_place and parent_save.resource_path.begins_with("user://"):
		# Overwrite the parent save.
		var parent_path = parent_save.resource_path
		current_save.take_over_path(parent_path)
		current_save.resource_path = parent_path
		current_save.index = parent_save.index
		current_save.parent_save_idx = parent_save.parent_save_idx
		ResourceSaver.save(current_save)
		parent_save = current_save
		current_save = null
		return
	# Find the smallest free save index
	var index = current_save.index
	while FileAccess.file_exists(path_template % index):
		index += 1
	current_save.index = index
	current_save.take_over_path(path_template % index)
	ResourceSaver.save(current_save)
	parent_save = current_save
	current_save = null

signal post_load(file: SaveFile)

func load_save(save: SaveFile):
	parent_save = save
	for participant in save_participants():
		participant.post_load(current_save)
	#post_load.emit(save)
