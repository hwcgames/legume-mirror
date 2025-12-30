extends Node

var parent_save: SaveFile
var current_save: SaveFile:
	get:
		if current_save == null:
			current_save = parent_save.duplicate(true)
		return current_save

func save(in_place: bool = false):
	DirAccess.make_dir_absolute("user://saves")
	const path_template = "user://saves/%s.save.res"
	if parent_save.resource_path == "":
		while FileAccess.file_exists(path_template % parent_save.index):
			parent_save.index += 1
		parent_save.take_over_path(path_template % parent_save.index)
	if in_place:
		current_save.parent_save = parent_save.parent_save
		current_save.take_over_path(parent_save.resource_path)
	else:
		current_save.parent_save = parent_save
		while FileAccess.file_exists(path_template % current_save.index):
			current_save.index += 1
		current_save.take_over_path(path_template % current_save.index)
	current_save.timestamp = Time.get_datetime_dict_from_system(true)
	parent_save = current_save
	current_save = null
	ResourceSaver.save(parent_save)

func load(save: SaveFile):
	parent_save = save
