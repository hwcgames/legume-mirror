extends Node
class_name SaveFileLister

signal no_saves
signal done

var in_progress: int = 0:
	set(new_v):
		in_progress = new_v
		if in_progress == 0:
			done.emit()

func _ready():
	DirAccess.make_dir_absolute("user://saves")
	var dir := DirAccess.open("user://saves")
	dir.list_dir_begin()
	var fname = dir.get_next()
	while fname != "":
		load_save("user://saves/%s" % fname)
		fname = dir.get_next()
	if in_progress == 0:
		no_saves.emit()

var saves: Dictionary[int, SaveFile] = {}
var stories: Dictionary[int, InkStory] = {}
var day_indices: Dictionary[int, int] = {}
signal new_save(index: int)
var save_card_scene: PackedScene = preload("uid://dxkxskrppsecg")

func load_save(path: String):
	in_progress += 1
	var error = ResourceLoader.load_threaded_request(path, "SaveFile")
	match error:
		Error.OK:
			pass
		Error.ERR_FILE_MISSING_DEPENDENCIES:
			load_error(path, "A mysterious asset reference.")
			return
		var e:
			load_error(path, "File access error %s." % e)
			return
	while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
	match ResourceLoader.load_threaded_get_status(path):
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			load_error(path, "This is a bread box. (Appears to be corrupted.)")
			return
		ResourceLoader.THREAD_LOAD_FAILED:
			load_error(path, "...Something, clearly. (An unknown error condition.)")
			return
	var s = ResourceLoader.load_threaded_get(path)
	if s is not SaveFile:
		load_error(path, "Why are you buying {0} at the SaveFile store? (I understand it, but it looks like a {0} instead of a SaveFile.)".format([s.get_script().get_global_name()]))
		return
	var save: SaveFile = s
	saves[save.index] = save
	error = ResourceLoader.load_threaded_request(save.story)
	match error:
		Error.OK:
			pass
		var e:
			load_error(path, "File access error %s." % e)
			return
	while ResourceLoader.load_threaded_get_status(save.story) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
	match ResourceLoader.load_threaded_get_status(path):
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			load_error(path, "This is written in crayon. (This save file's story appears to be corrupted.)")
			return
		ResourceLoader.THREAD_LOAD_FAILED:
			load_error(path, "...Something, clearly. (An unknown error condition when loading the story.)")
			return
	s = ResourceLoader.load_threaded_get(save.story)
	if s is not InkStory:
		load_error(path, "Why are you buying {0} at the InkStory store? (I understand the story this refers to, but it looks like a {0} instead of an InkStory.)".format([s.get_script().get_global_name()]))
		return
	var story: InkStory = s
	story.LoadState(save.ink_save)
	stories[save.index] = story
	var year: int = story.FetchVariable("year")
	var month: int = story.FetchVariable("month")
	var day: int = story.FetchVariable("day")
	var week: int = story.FetchVariable("week")
	var day_idx: int = year * 366 + month * 32 + day
	day_indices[save.index] = day_idx
	#var title: String = story.EvaluateFunction("___title")
	var location: String = story.EvaluateFunction("___location_name")
	var date_string: String = story.EvaluateFunction("name_day", year, month, day, week)

@export var error_parent: Control

func load_error(path: String, message: String):
	in_progress -= 1
	var label = Label.new()
	label.add_theme_color_override("font_color", Color.ORANGE_RED)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = "Loading {0} failed because: {1}".format([path, message])
	printerr(label.text)
	error_parent.add_child(label)
	pass
