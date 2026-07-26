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
	%Location.text = story.EvaluateFunction("location_name", [story.FetchVariable("location")])
	%Button.pressed.connect(load_save)

func load_save():
	save.load_save(get_tree())
