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

const level_registry: Registry = preload("uid://dt4eemr0431fl")

func wants_line(line: String, tags: Array[String]) -> bool:
	return do_line(line, tags) is Callable
func take_line(line: String, tags: Array[String]):
	do_line(line, tags).call()
func do_line(line: String, tags: Array[String]):
	match Array(line.split(" ", false)):
		["/", "level", var name, var room]:
			var level_r: Level = level_registry.load_entry(name) # load("res://database/level/%s.tres" % name)
			if !is_instance_valid(level_r):
				printerr("Level \"%s\" missing." % name)
				return null
			return func():
				if OS.is_debug_build():
					print("Saving during level change for story live-reload...")
					Saver.find().save(true)
					Saver.find().parent_save.ink_save = Storyteller.find().safety_save
					ResourceSaver.save(Saver.find().parent_save)
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
		["/", "level", var name, var room]:
			ResourceLoader.load_threaded_request("res://database/level/%s.tres" % name)
			ResourceLoader.load_threaded_request("res://database/room/%s.tres" % room)

func load_level(name: String, room_name: String):
	if is_instance_valid(level):
		level.queue_free()
	var level_r: Level = level_registry.load_entry(name)#load("res://database/level/%s.tres" % name)
	level = preload("uid://c0mpdcfx8tg2i").instantiate()
	%LevelParent.add_child(level)
	for actor in get_tree().get_nodes_in_group("actor"):
		actor.queue_free()
	level.setup(level_r, room_name)
	pass
