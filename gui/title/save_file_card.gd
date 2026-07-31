extends Control
class_name SaveFileCard

@export var save: SaveFile
@export var story: InkStory
@export var location: String
#@export var day: String

func _ready() -> void:
	%Date.text = " {index}: {weekday}. {month}-{day}: ".format({
		"index": save.index,
		"weekday": ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"][story.FetchVariable("weekday")],
		"month": story.FetchVariable("month"),
		"day": story.FetchVariable("day"),
	})
	var name: String = story.EvaluateFunction("location_name", [story.FetchVariable("location")])
	if name.begins_with("tok!"):
		name = name.trim_prefix("tok!")
		var font_registry: Registry = preload("uid://dujnuubfyldyg")
		name.insert(0, "[font=\"%s\"]" % font_registry.get_uid("linja-pona"))
		name += "[/font]"
	%Location.text = name
	%Button.pressed.connect(load_save)

func load_save():
	save.load_save(get_tree())
