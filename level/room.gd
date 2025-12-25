extends Area3D
class_name Room

var room_info: RoomInfo
@export var battlefield: Battlefield
@export var encounter: Encounterable
@export var camera: PhantomCamera3D
@export var camera_priority_offset: int = 5

@export var loading_range: int = 3
## If this lock has shared references, this room is treated as a loading root.
var keep_loaded_lock: Locks = Locks.new()
var loadedness: int = 0

var players_inside: int = 0
signal player_entered(player: PartyMember)
signal player_exited(player: PartyMember)

func _ready():
	keep_loaded_lock.shared_take.connect(update_loading)
	keep_loaded_lock.shared_free.connect(update_loading)
	body_entered.connect(_body_entered)
	body_exited.connect(_body_exited)
	if battlefield != null:
		player_entered.connect(func(_p):
			battlefield.players.clear()
			for player in get_tree().get_nodes_in_group("party_member"):
				battlefield.players.push_back(player)
			battlefield.battle(),
		ConnectFlags.CONNECT_ONE_SHOT)

func _body_entered(body: PhysicsBody3D):
	if body.is_in_group("loading_root"):
		keep_loaded_lock.shared_locks += 1
		update_loading()
	if body is PartyMember:
		player_entered.emit(body)
		if players_inside == 0 and camera != null:
			camera.priority += camera_priority_offset
		players_inside += 1
func _body_exited(body: PhysicsBody3D):
	if body.is_in_group("loading_root"):
		keep_loaded_lock.shared_locks = max(keep_loaded_lock.shared_locks-1, 0)
		update_loading()
	if body is PartyMember:
		player_exited.emit(body)
		players_inside -= 1
		if players_inside == 0 and camera != null:
			camera.priority -= camera_priority_offset

func update_loading():
	var old_loadedness = loadedness
	var seams: Array[RoomSeam] = find_seams()
	if keep_loaded_lock.shared_locks > 0:
		loadedness = loading_range
	else:
		var most_loaded_neighbor = 0
		for seam in seams:
			if seam.partner == null:
				continue
			most_loaded_neighbor = max(most_loaded_neighbor, seam.partner.room.loadedness - seam.partner.loading_distance)
		loadedness = max(most_loaded_neighbor, 0)
	if loadedness != old_loadedness:
		for seam in seams:
			if seam.partner == null:
				continue
			seam.partner.room.update_loading()

func find_proc_seam(by_profile: String, in_node: Node = self) -> Array[ProceduralSeam]:
	if in_node is ProceduralSeam and in_node.profile == by_profile:
		return [in_node]
	var out: Array[ProceduralSeam] = []
	for child in in_node.get_children():
		var r = find_proc_seam(by_profile, child)
		out.append_array(r)
	return out

func find_seams(in_node: Node = self) -> Array[RoomSeam]:
	if in_node is RoomSeam:
		return [in_node]
	var out: Array[RoomSeam] = []
	for child in in_node.get_children():
		var r = find_seams(child)
		out.append_array(r)
	return out

func find_leaves(out: Array[ProceduralSeam] = [], in_node: Node = self):
	if in_node is ProceduralSeam:
		if in_node.partner == null:
			out.push_back(in_node)
		else:
			find_leaves(out, in_node.partner.room)
	for child in get_children():
		find_leaves(out, child)
	return out
