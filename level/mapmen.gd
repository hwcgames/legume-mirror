extends Node
class_name DungeonMap

@export var treadmill: Treadmill

var width: int = 7
var height: int = 20
var path_amt: int = 6

var map: Dictionary[Vector2i, MapRoom] = {}

enum ROOM_TYPE {
	EMPTY,
	MONSTER,
	ITEM,
	EVENT,
	SAFE,
	BOSS,
	SHOP
}

class MapRoom extends RefCounted:
	var incoming: Array[Vector2i] = []
	var outgoing: Array[Vector2i] = []
	var room_type: ROOM_TYPE = ROOM_TYPE.EMPTY

func reset():
	map = {}

func are_connected(from: Vector2i, to: Vector2i):
	if from not in map or to not in map:
		return false
	return to in map[from].outgoing

func connect_rooms(from: Vector2i, to: Vector2i):
	if not to in map:
		return false
	if from == to:
		return true
	if are_connected(from, to):
		return true
	if from.x != to.x and are_connected(Vector2i(to.x, from.y), Vector2i(from.x, to.y)):
		return false
	if not to in map[from].outgoing:
		map[from].outgoing.push_back(to)
	if not from in map[to].incoming:
		map[to].incoming.push_back(from)
	return true

func make_path(p: Vector2i = Vector2i(randi_range(0, width), 0)):
	while p.y < height - 1:
		if not p in map:
			return
		var offset: int = randi_range(-1, 1)
		var p2 = p + Vector2i(offset, 1)
		if connect_rooms(p, p2):
			await get_tree().process_frame
			p = p2

func roll_room(p: Vector2i) -> ROOM_TYPE:
	if p.y == 0:
		return ROOM_TYPE.MONSTER
	if p.y == 8:
		return ROOM_TYPE.ITEM
	if p.y == height - 1:
		return ROOM_TYPE.BOSS
	if p.y == height - 2:
		return ROOM_TYPE.SAFE
	var banned_types: Array[ROOM_TYPE] = []
	for previous in map[p].incoming:
		if map[previous].room_type in [ROOM_TYPE.BOSS, ROOM_TYPE.SHOP, ROOM_TYPE.SAFE]:
			banned_types.push_back(map[previous].room_type)
		for neighbor in map[previous].outgoing:
			banned_types.push_back(map[neighbor].room_type)
	if p.y >= height - 4:
		banned_types.push_back(ROOM_TYPE.SAFE)
	if p.y < 6:
		banned_types.append_array([ROOM_TYPE.BOSS, ROOM_TYPE.SAFE])
	for i in range(100):
		var roll = randf()
		var wants = ROOM_TYPE.EMPTY
		if roll < 0.45:
			wants = ROOM_TYPE.MONSTER
		elif roll < 0.45+0.22:
			wants = ROOM_TYPE.EVENT
		elif roll < 0.45+0.22+0.16:
			wants = ROOM_TYPE.BOSS
		elif roll < 0.45+0.22+0.16+0.12:
			wants = ROOM_TYPE.SAFE
		else:
			wants = ROOM_TYPE.SHOP
		if wants not in banned_types:
			return wants
	return ROOM_TYPE.MONSTER

func generate_map():
	reset()
	var center: int = floor(width / 2)
	for y in range(height):
		for x in range(width):
			if abs(x-center) >= height - y or abs(x-center) >= (y+1):
				continue
			await get_tree().process_frame
			map[Vector2i(x, y)] = MapRoom.new()
	for n in range(path_amt):
		await get_tree().create_timer(.1).timeout
		#var x: int = randi_range(0, width-1)
		#while n == 1 and not map[Vector2i(x, 1)].outgoing.is_empty():
			#x = randi_range(0, width-1)
		await make_path(Vector2i(floor(width / 2), 0))
	for y in range(height):
		for x in range(width):
			if Vector2i(x, y) not in map:
				continue
			await get_tree().process_frame
			if (y == 0 and map[Vector2i(x,y)].outgoing.is_empty()) \
			or (y > 0 and map[Vector2i(x, y)].incoming.is_empty()):
				map.erase(Vector2i(x, y))
	for y in range(height):
		for x in range(width):
			if Vector2i(x, y) not in map:
				continue
			await get_tree().process_frame
			map[Vector2i(x, y)].room_type = roll_room(Vector2i(x, y))
	return map

func _ready():
	generate_map()
	print(map)
