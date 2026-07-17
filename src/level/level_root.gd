extends Node3D
class_name LevelRoot

const roomset_registry: Registry = preload("uid://b25ftc6s3pror")
const room_registry: Registry = preload("uid://qyg5tv6sg4pu")

func setup(level: Level, room_name: String):
	%Treadmill.rooms.clear()
	var used = []
	var entrance: RoomInfo = null
	if !is_instance_valid(level):
		printerr("No level!")
		queue_free()
		return
	for id in level.roomset:
		var roomset: RoomSet = roomset_registry.load_entry(id)
		for room_id in roomset.rooms:
			if room_id not in used:
				used.push_back(room_id)
				var room_info: RoomInfo = room_registry.load_entry(room_id)
				if room_id == level.entrances[room_name] or (room_id == level.entrances[room_name] and !is_instance_valid(entrance)):
					entrance = room_info
				%Treadmill.rooms.push_back(room_info)
	if !is_instance_valid(entrance):
		if room_name != "default":
			printerr("Unknown entrance, trying again with 'default'...")
			setup(level, "default")
			return
		else:
			printerr("Unknown entrance! No fallback! Giving up!")
			queue_free()
			return
	%Treadmill.spawn_initial_room(entrance)
	pass

func _ready():
	add_to_group("story_listener")

func wants_line(line: String, tags: Array[String]) -> bool:
	return do_line(line, tags) is Callable
func take_line(line: String, tags: Array[String]):
	do_line(line, tags).call()
func do_line(line: String, tags: Array[String]):
	match Array(line.split(" ", false)):
		["/", "level", "end"]:
			return func(): queue_free()
	return null
