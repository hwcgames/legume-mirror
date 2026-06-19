extends Node
class_name DungeonMap

@export var enabled: bool = true
@export var allow_progress: bool = false:
	set(new_allow_progress):
		allow_progress = new_allow_progress
		if allow_progress:
			match state:
				STATE.HALLWAY_TO_JUNCTION:
					state = STATE.WAIT_FOR_JUNCTION
				STATE.HALLWAY_TO_ROOM:
					state = STATE.WAIT_FOR_ROOM
@export var treadmill: Treadmill
@export var start_junction: RoomInfo

enum STATE {
	GENERATE,
	HALLWAY_TO_JUNCTION,
	WAIT_FOR_JUNCTION,
	JUNCTION,
	HALLWAY_TO_ROOM,
	WAIT_FOR_ROOM,
	ROOM,
}

var state = STATE.GENERATE

var current_position: Vector2i
var choice: int = 0
var current_room: Room

var width: int = 7
var height: int = 14
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

func to_room_info_type(room_type: ROOM_TYPE) -> RoomInfo.ROOM_TYPE:
	match room_type:
		ROOM_TYPE.MONSTER:
			return RoomInfo.ROOM_TYPE.MONSTER
		ROOM_TYPE.ITEM:
			return RoomInfo.ROOM_TYPE.ITEM
		ROOM_TYPE.EVENT:
			return RoomInfo.ROOM_TYPE.EVENT
		ROOM_TYPE.SAFE:
			return RoomInfo.ROOM_TYPE.SAFE
		ROOM_TYPE.BOSS:
			return RoomInfo.ROOM_TYPE.BOSS
		ROOM_TYPE.SHOP:
			return RoomInfo.ROOM_TYPE.SHOP
	return RoomInfo.ROOM_TYPE.UNKNOWN

func name_room(room: ROOM_TYPE):
	match room:
		ROOM_TYPE.EMPTY:
			return "empty"
		ROOM_TYPE.MONSTER:
			return "monster"
		ROOM_TYPE.ITEM:
			return "item"
		ROOM_TYPE.EVENT:
			return "event"
		ROOM_TYPE.SAFE:
			return "safe"
		ROOM_TYPE.BOSS:
			return "boss"
		ROOM_TYPE.SHOP:
			return "shop"

func reset():
	map = {}
	current_position = Vector2i(floor(width/2), 0)
	state = STATE.GENERATE

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
			p = p2

func roll_room(p: Vector2i) -> ROOM_TYPE:
	if p.y == 0:
		return ROOM_TYPE.MONSTER
	if p.y == 1:
		return ROOM_TYPE.SAFE
	if p.y == 8:
		return ROOM_TYPE.ITEM
	#if p.y == height - 1:
		#return ROOM_TYPE.BOSS
	if p.y == height - 1:
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
		banned_types.append_array([
			ROOM_TYPE.BOSS,
			#ROOM_TYPE.SAFE
		])
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

signal map_generated

func generate_map():
	reset()
	var center: int = floor(width / 2)
	for y in range(height):
		for x in range(width):
			if abs(x-center) >= height - y or abs(x-center) >= (y+1):
				continue
			map[Vector2i(x, y)] = MapRoom.new()
	for n in range(path_amt):
		#var x: int = randi_range(0, width-1)
		#while n == 1 and not map[Vector2i(x, 1)].outgoing.is_empty():
			#x = randi_range(0, width-1)
		make_path(Vector2i(floor(width / 2), 0))
	for y in range(height):
		for x in range(width):
			if Vector2i(x, y) not in map:
				continue
			if (y == 0 and map[Vector2i(x,y)].outgoing.is_empty()) \
			or (y > 0 and map[Vector2i(x, y)].incoming.is_empty()):
				map.erase(Vector2i(x, y))
	for y in range(height):
		for x in range(width):
			if Vector2i(x, y) not in map:
				continue
			map[Vector2i(x, y)].room_type = roll_room(Vector2i(x, y))
	state = STATE.HALLWAY_TO_ROOM
	map_generated.emit()
	return map

func _ready():
	#map_generated.connect(func():
		#state = STATE.JUNCTION
		#current_room = treadmill.spawn_initial_room(start_junction)
		#current_room.tree_exited.connect(junction_unloaded),
		#CONNECT_ONE_SHOT)
	#generate_map()
	treadmill.wants_room_for.connect(fill_handler)
	Saver.pre_save.connect(pre_save)
	Saver.post_load.connect(post_load)
	if is_instance_valid(loading_save):
		load_after_reload(loading_save)

func pre_save(file: SaveFile):
	file.map_state = MapState.new()
	file.map_state.current_position = current_position
	file.map_state.height = height
	file.map_state.width = width
	file.map_state.map = map.duplicate()
	file.treadmill_roomset = treadmill.roomset
	file.treadmill_allowed_themes = treadmill.allowed_themes

static var loading_save: SaveFile = null
static var loading_handle: Callable = func(): pass

func post_load(save: SaveFile):
	loading_handle = await Storyteller2.lock.shared_lock()
	loading_save = save
	var tree = get_tree()
	tree.reload_current_scene()
func load_after_reload(save: SaveFile):
	loading_save = null
	var tree = get_tree()
	var map: DungeonMap = tree.current_scene.get_node("%DungeonMap")
	var treadmill = map.treadmill
	treadmill.allowed_themes = save.treadmill_allowed_themes
	treadmill.roomset = save.treadmill_roomset
	map.map = save.map_state.map
	map.height = save.map_state.height
	map.width = save.map_state.width
	map.current_position = save.map_state.current_position
	if map.map.is_empty():
		state = STATE.GENERATE
		loading_handle.call()
		return
	state = STATE.ROOM
	var candidates = treadmill.rooms.filter(func(r: RoomInfo):
		var room_type = r.room_type
		var wanted = to_room_info_type(map.map[map.current_position].room_type)
		return room_type == wanted \
			and r.theme in treadmill.allowed_themes)
	var choice = candidates[randi_range(0, len(candidates) - 1)]
	var new_room = treadmill.spawn_initial_room(choice)
	new_room.tree_exited.connect(room_unloaded)
	loading_handle.call()

func junction_unloaded():
	current_position += Vector2i(choice, 1)
	Storyteller2.choose([
		"dungeon choice %s" % choice,
		"dungeon towards %s" % name_room(map[current_position].room_type),
		"dungeon towards room"
	], true)
	state = STATE.WAIT_FOR_ROOM if allow_progress else STATE.HALLWAY_TO_ROOM

func room_unloaded():
	if current_position.y == height - 1:
		Storyteller2.choose(["dungeon done"], true)
		reset()
		return
	Storyteller2.choose(["dungeon towards junction"], true)
	state = STATE.WAIT_FOR_JUNCTION if allow_progress else STATE.HALLWAY_TO_JUNCTION

func fill_handler(seam: ProceduralSeam):
	if not enabled:
		return
	if seam.backtrack:
		return
	var room := seam.room
	match state:
		STATE.WAIT_FOR_JUNCTION:
			if room.room_info.room_type != RoomInfo.ROOM_TYPE.HALLWAY:
				seam.wants_room_type = RoomInfo.ROOM_TYPE.DEAD_END
			seam.wants_room_type = RoomInfo.ROOM_TYPE.JUNCTION
			match choice:
				-1:
					seam.wants_partner_name = "RightIn"
				0:
					seam.wants_partner_name = "MiddleIn"
				1:
					seam.wants_partner_name = "LeftIn"
			var new_room = await treadmill.fill_seam(seam, false)
			state = STATE.JUNCTION
			current_room = new_room
			var lock = await new_room.keep_loaded_lock.shared_lock()
			new_room.tree_exited.connect(junction_unloaded)
			new_room.player_entered.connect(func(_p):
				Storyteller2.choose([
					"dungeon entered junction"
				], true)
				lock.call(), CONNECT_ONE_SHOT)
		STATE.JUNCTION:
			if room.room_info.room_type == RoomInfo.ROOM_TYPE.HALLWAY:
				seam.wants_room_type = RoomInfo.ROOM_TYPE.HALLWAY
			if room.room_info.room_type != RoomInfo.ROOM_TYPE.JUNCTION:
				return
			var offset: Vector2i
			var choice_index: int
			match seam.name:
				"LeftOut":
					offset = Vector2i(-1, 1)
				"MiddleOut":
					offset = Vector2i(0, 1)
				"RightOut":
					offset = Vector2i(1, 1)
				_: return
			if are_connected(current_position, current_position + offset):
				seam.wants_room_type = RoomInfo.ROOM_TYPE.HALLWAY
			else:
				seam.wants_room_type = RoomInfo.ROOM_TYPE.DEAD_END
			var new_room = await treadmill.fill_seam(seam, false)
			new_room.player_entered.connect(func(_p):
				choice = offset.x)
		STATE.HALLWAY_TO_JUNCTION, STATE.HALLWAY_TO_ROOM:
			if room.room_info.room_type != RoomInfo.ROOM_TYPE.HALLWAY:
				seam.wants_room_type = RoomInfo.ROOM_TYPE.DEAD_END
			else:
				seam.wants_room_type = RoomInfo.ROOM_TYPE.HALLWAY
		STATE.WAIT_FOR_ROOM:
			if room.room_info.room_type != RoomInfo.ROOM_TYPE.HALLWAY:
				seam.wants_room_type = RoomInfo.ROOM_TYPE.DEAD_END
			match map[current_position].room_type:
				ROOM_TYPE.EMPTY:
					state = STATE.WAIT_FOR_ROOM
					return
				ROOM_TYPE.MONSTER:
					seam.wants_room_type = RoomInfo.ROOM_TYPE.MONSTER
				ROOM_TYPE.ITEM:
					seam.wants_room_type = RoomInfo.ROOM_TYPE.ITEM
				ROOM_TYPE.EVENT:
					seam.wants_room_type = RoomInfo.ROOM_TYPE.EVENT
				ROOM_TYPE.SAFE:
					seam.wants_room_type = RoomInfo.ROOM_TYPE.SAFE
				ROOM_TYPE.BOSS:
					seam.wants_room_type = RoomInfo.ROOM_TYPE.BOSS
				ROOM_TYPE.SHOP:
					seam.wants_room_type = RoomInfo.ROOM_TYPE.SHOP
			if not treadmill.rooms.any(func(r: RoomInfo): return r.room_type == seam.wants_room_type):
				printerr("Can't find any rooms that match the type requested by the map, moving on to a junction.")
				seam.wants_room_type = RoomInfo.ROOM_TYPE.HALLWAY
				Storyteller2.choose([
					"dungeon entered %s" % name_room(map[current_position].room_type),
					"dungeon entered room"
				], true)
				room_unloaded()
				return
			var new_room = await treadmill.fill_seam(seam, false)
			state = STATE.ROOM
			current_room = new_room
			Storyteller2.choose([
				"dungeon built %s" % name_room(map[current_position].room_type),
				"dungeon built room"
			], true)
			new_room.player_entered.connect(func(_p):
				Storyteller2.choose([
					"dungeon entered %s" % name_room(map[current_position].room_type),
					"dungeon entered room"
				], true),
				ConnectFlags.CONNECT_ONE_SHOT)
			new_room.tree_exited.connect(room_unloaded)
		STATE.ROOM:
			seam.wants_room_type = RoomInfo.ROOM_TYPE.HALLWAY
