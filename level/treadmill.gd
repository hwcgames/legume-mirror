extends Marker3D
class_name Treadmill

#@export var load_range: float = 24.
var existing_rooms: Array[Room] = []
@export var allowed_themes: Array[StringName] = ["default"]
@export var rooms: Array[RoomInfo] = []:
	get:
		return rooms.filter(func(r: RoomInfo): return r.theme in allowed_themes)

func fill_seam(seam: RoomSeam, allow_handlers: bool = true) -> Room:
	var room: Room
	if seam is ProceduralSeam:
		room = await auto_fill_proc_seam(seam, allow_handlers)
	elif seam is StaticSeam:
		var index = rooms.find_custom(func(r: RoomInfo): return r.room_path == seam.target_room.room_path)
		if index == -1:
			printerr("Can't find room candidate for seam %s" % seam)
		var room_info = rooms[index]
		room = await fill_seam_with(seam, room_info)
	resolve_partners()
	if room != null and room.battlefield != null:
		if room.encounter == null:
			printerr("Room %s is missing an encounter" % room.name)
		var encounter = room.encounter.roll_encounter()
		encounter.apply_to_battlefield(room.battlefield)
	return room

func fill_seam_with(seam: RoomSeam, room_info: RoomInfo) -> Room:
	var lock = await seam.loading_lock.exclusive_lock()
	var room: Room = room_info.room_scene.instantiate()
	room.room_info = room_info
	room.position = Vector3(1000, 0, 0)
	add_child(room)
	var partner: RoomSeam
	if seam is ProceduralSeam:
		var candidates = room.find_proc_seam(seam.profile)
		if candidates.any(func(n: Node): return n.name == seam.wants_partner_name):
			candidates = candidates.filter(func(n: Node): return n.name == seam.wants_partner_name)
		elif candidates.any(func(s: ProceduralSeam): return s.backtrack != seam.backtrack):
			candidates = candidates.filter(func(s: ProceduralSeam): return s.backtrack != seam.backtrack)
		partner = candidates[randi_range(0, len(candidates)-1)]
	elif seam is StaticSeam:
		var path = "%%%s" % seam.target_name
		partner = room.get_node(path)
	existing_rooms.push_back(room)
	seam.partner = partner
	partner.partner = seam
	room.top_level = true
	room.global_rotation.y += seam.global_rotation.y - partner.global_rotation.y + PI
	room.global_position += seam.global_position - partner.global_position
	resolve_partners()
	lock.call()
	return room

func resolve_partners():
	var seams_without_partners: Array[RoomSeam] = []
	for room in existing_rooms:
		for seam in room.find_seams():
			if seam.partner == null:
				seams_without_partners.push_back(seam)
	for left_index in range(len(seams_without_partners)):
		var left = seams_without_partners[left_index]
		for right_index in range(left_index+1, len(seams_without_partners)):
			var right = seams_without_partners[right_index]
			if right.partner != null:
				continue
			if left is ProceduralSeam and right is ProceduralSeam:
				if left.global_position == right.global_position:
					left.partner = right
					right.partner = left
					left.room.update_loading()
					right.room.update_loading()
			if left is StaticSeam and right is StaticSeam:
				var names_match = left.target_name == right.name and right.target_name == left.name
				var scenes_match = ResourceUID.uid_to_path(left.target_room.room_path) == right.owner.scene_file_path \
					and ResourceUID.uid_to_path(right.target_room.room_path) == left.owner.scene_file_path
				if names_match and scenes_match:
					left.partner = right
					right.partner = left
					left.room.update_loading()
					right.room.update_loading()
					if left.global_position.distance_to(right.global_position) > 0.01:
						printerr("Static seams %s and %s match, but they aren't in the same position; maybe the scenes have mismatching layouts?" % [left, right])

signal wants_room_for(seam: ProceduralSeam)
func auto_fill_proc_seam(seam: ProceduralSeam, allow_handlers: bool = true) -> Room:
	# Give others a chance to fill the seam or impose restrictions
	if allow_handlers:
		wants_room_for.emit(seam)
	if seam.partner != null or seam.loading_lock.exclusive_locked:
		# Someone else filled this seam
		return
	var choice: RoomInfo = find_room_for(seam)
	if choice == null:
		printerr("Couldn't find a room, giving up")
		return
	return await fill_seam_with(seam, choice)

func spawn_initial_room(room_info: RoomInfo) -> Node3D:
	var room: Node3D = room_info.room_scene.instantiate()
	room.room_info = room_info
	room.top_level = true
	existing_rooms.push_back(room)
	add_child(room)
	return room

func find_room_for(seam: ProceduralSeam) -> RoomInfo:
	var candidates: Array[RoomInfo] = rooms.filter(func(r: RoomInfo):
		if seam.wants_partner_name != "" and seam.wants_partner_name not in r.proc_seams:
			return false
		for name in r.proc_seams:
			if r.seam_profiles[name] == seam.profile:
				return true
		return false)
	if seam.wants_room_type != RoomInfo.ROOM_TYPE.UNKNOWN and candidates.any(func(c: RoomInfo): return c.room_type == seam.wants_room_type):
		candidates = candidates.filter(func(c: RoomInfo): return c.room_type == seam.wants_room_type)
	elif seam.backtrack and candidates.any(func(c: RoomInfo): return c.room_type == RoomInfo.ROOM_TYPE.DEAD_END):
		candidates = candidates.filter(func(c: RoomInfo): return c.room_type == RoomInfo.ROOM_TYPE.DEAD_END)
	var total = 0.
	for candidate in candidates:
		total += candidate.weight
	var choice = randf_range(0., total)
	for candidate in candidates:
		choice -= candidate.weight
		if choice <= 0:
			return candidate
	return null
#
#func find_proc_seam(in_node: Node, by_profile: String) -> Array[ProceduralSeam]:
	#if in_node is ProceduralSeam and in_node.profile == by_profile:
		#return [in_node]
	#var out: Array[ProceduralSeam] = []
	#for child in in_node.get_children():
		#var r = find_proc_seam(child, by_profile)
		#out.append_array(r)
	#return out
#
#func find_seams(in_node: Node) -> Array[RoomSeam]:
	#if in_node is RoomSeam:
		#return [in_node]
	#var out: Array[RoomSeam] = []
	#for child in in_node.get_children():
		#var r = find_seams(child)
		#out.append_array(r)
	#return out

func _process(delta: float) -> void:
	var did_anything = true
	while did_anything:
		did_anything = false
		var rooms_to_cull: Array[Room] = existing_rooms.filter(func(room: Room):
			return room.loadedness == 0)
		rooms_to_cull.sort_custom(func(a,b):
			return a.global_position.distance_to(self.global_position) > b.global_position.distance_to(self.global_position))
		var seams_to_fill: Array[RoomSeam] = []
		resolve_partners()
		for room in existing_rooms:
			if room.loadedness <= 1:
				continue
			for seam in room.find_seams():
				if seam.partner == null and not seam.loading_lock.exclusive_locked:
					seams_to_fill.push_back(seam)
		for room in rooms_to_cull:
			room.update_loading()
			if room.loadedness > 0:
				continue
			if len(existing_rooms) == 1:
				# Don't delete the last room
				break
			did_anything = true
			existing_rooms.remove_at(existing_rooms.find(room))
			room.queue_free()
		for seam in seams_to_fill:
			did_anything = true
			resolve_partners()
			(func():
				var room = await fill_seam(seam)
				if room != null:
					room.update_loading()).call()
