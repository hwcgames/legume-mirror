extends Node3D
class_name LevelRoot

func setup(level: Level, room: String):
	%Treadmill.roomset = level.roomset
	%Treadmill.spawn_initial_room(level.entrances[room])
	pass

func _ready():
	add_to_group("story_listener")

func wants_line(line: String, tags: Array[String]) -> bool:
	return do_line(line, tags) is Callable
func take_line(line: String, tags: Array[String]):
	do_line(line, tags).call()
func do_line(line: String, tags: Array[String]):
	match Array(line.split(" ", false)):
		[">>>", "level", "end"]:
			return func(): queue_free()
	return null
