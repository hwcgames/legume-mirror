extends Node
class_name MainGame

enum MODE {
	NONE,
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
	add_to_group("story_listener")

var mode: MODE:
	get:
		if is_instance_valid(battle):
			return MODE.BATTLE
		if is_instance_valid(level):
			return MODE.LEVEL
		return MODE.NONE
var level: LevelRoot
var battle: BattleWorld

func wants_line(line: String, tags: Array[String]) -> bool:
	return do_line(line, tags) is Callable
func take_line(line: String, tags: Array[String]):
	do_line(line, tags).call()
func do_line(line: String, tags: Array[String]):
	match Array(line.split(" ", false)):
		["/", "level", var name, var room]:
			var level_r = load("res://database/level/%s.tres" % name)
			if !(is_instance_valid(level_r) and level_r is Level):
				printerr("WARNING: Invalid level.")
				return null
			if room not in (level_r as Level).entrances:
				printerr("WARNING: Invalid room.")
				return null
			return func():
				load_level(name, room)
		["/", "battle", "setup", var environment_name]:
			return func():
				if is_instance_valid(battle):
					printerr("WARNING: Battle already active!")
					return null
				var env_path = "res://database/battlefield/%s.tscn" % environment_name
				var environment = load(env_path).instantiate()
				battle = preload("uid://cyxdvd335kc1p").instantiate()
				%BattleWorldParent.add_child(battle)
				battle.setup(environment)
	return null
func notice_line(line: String, tags: Array[String]):
	match line.split(" ", false):
		["/", "level", var name, "room", var room]:
			ResourceLoader.load_threaded_request("res://database/level/%s.tres" % name)
			ResourceLoader.load_threaded_request("res://database/room/%s.tres" % room)

func load_level(name: String, room_name: String):
	if is_instance_valid(level):
		level.queue_free()
	var level_r: Level = load("res://database/level/%s.tres" % name)
	level = preload("uid://c0mpdcfx8tg2i").instantiate()
	%LevelParent.add_child(level)
	for actor in get_tree().get_nodes_in_group("actor"):
		actor.queue_free()
	level.setup(level_r, room_name)
	pass
