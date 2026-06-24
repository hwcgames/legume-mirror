extends Node
class_name MainGame

enum MODE {
	IDLE,
	LEVEL,
	BATTLE,
}

func _to_string() -> String:
	return "Game Master"

static var me: MainGame
static func find() -> MainGame:
	return me

func _ready() -> void:
	me = self

var level: Node
var battle: Node

func wants_line(line: String, tags: Array[String]) -> bool:
	return is_instance_valid(do_line(line, tags))
func take_line(line: String, tags: Array[String]):
	do_line(line, tags).call()
func do_line(line: String, tags: Array[String]):
	match line.split(" ", false):
		[">>>", "level", var name, "room", var room]:
			if !ResourceLoader.exists("res://database/level/%s.tres" % name, "Level"):
				printerr("WARNING: Invalid level.")
				return null
			if !ResourceLoader.exists("res://database/room/%s.tres" % room, "Room"):
				printerr("WARNING: Invalid room.")
				return null
			return func():
				load_level(name, room)
	return null
func notice_line(line: String, tags: Array[String]):
	match line.split(" ", false):
		[">>>", "level", var name, "room", var room]:
			ResourceLoader.load_threaded_request("res://database/level/%s.tres" % name)
			ResourceLoader.load_threaded_request("res://database/room/%s.tres" % room)

func load_level(name: String, room_name: String):
	var level: Level = load("res://database/level/%s.tres" % name)
	var room: RoomInfo = load("res://database/rooms/%s.tres" % room_name)
	assert(room in level.roomset.rooms)
	pass
