@abstract
extends Marker3D
class_name RoomSeam

@export var loading_distance: int = 1
@export var automoves: Dictionary[String, Automove] = {}
## When this is false, the treadmill won't try to fill this seam, and it won't
## carry loadedness.
@export var enabled: bool = true:
	set(new_enabled):
		enabled = new_enabled
		room.update_loading()
		if is_instance_valid(partner):
			partner.room.update_loading()

## When this seam exists at runtime, its partner will be referenced here.
var partner: RoomSeam = null
## When this seam exists at runtime, it will be "locked" when someone is trying to load its partner
var loading_lock: Locks = Locks.new()
var room: Room:
	get:
		return find_room()

func find_room():
	var n := get_parent()
	while not n is Room:
		n = n.get_parent()
		if n == null:
			return null
	return n
