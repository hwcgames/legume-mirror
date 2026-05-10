extends Node

var parent_save: SaveFile = preload("uid://07q2yjh6h41t")
var current_save: SaveFile:
	get:
		if current_save == null:
			current_save = parent_save.copy()
			current_save.parent_save_idx = parent_save.index
		return current_save

const path_template = "user://saves/%08d.save.tres"

signal pre_save(file: SaveFile)

func save(in_place: bool = false):
	# Ask everyone to populate the save...
	pre_save.emit(current_save)
	# Ensure the existence of the saves directory.
	DirAccess.make_dir_absolute("user://saves")
	# If this is an in-place save, and the parent save is a user save...
	if in_place and parent_save.resource_path.begins_with("user://"):
		# Overwrite the parent save.
		current_save.take_over_path(parent_save.resource_path)
		current_save.index = parent_save.index
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

func load(save: SaveFile):
	parent_save = save
	post_load.emit(save)
