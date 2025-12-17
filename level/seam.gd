@abstract
extends Marker3D
class_name RoomSeam

## When this seam exists at runtime, its partner will be referenced here.
var partner: RoomSeam = null
## When this seam exists at runtime, it will be "locked" when someone is trying to load its partner
var loading_lock: Locks = Locks.new()
