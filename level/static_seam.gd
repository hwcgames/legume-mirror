@tool
extends RoomSeam
class_name StaticSeam

@export var target_name: StringName:
	set(name):
		target_name = name
		update_configuration_warnings()
@export var target_room: RoomInfo:
	set(room):
		target_room = room
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var out = PackedStringArray()
	if not self.unique_name_in_owner:
		out.push_back("Seams should have a scene-unique name")
	if not target_room is RoomInfo:
		out.push_back("The room must be set")
	if target_name == null or target_name == "":
		out.push_back("The target door name must be set")
	var room_scene = load(target_room.room_path)
	if not room_scene is PackedScene:
		out.push_back("The target room info's room path must point to a scene")
		return out
	var room = (room_scene as PackedScene).instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	var seam = room.get_node("%%%s" % target_name)
	if seam == null:
		out.push_back("Room must have a seam named %s" % target_name)
		return out
	if not seam is RoomSeam:
		out.push_back("Room must have a seam named %s" % target_name)
		return out
	if seam is StaticSeam and seam.target_room.room_path != ResourceUID.path_to_uid(self.owner.scene_file_path):
		out.push_back("Partner room's seam must point to this room" % target_name)
	if seam is StaticSeam and seam.target_name != name:
		out.push_back("Partner room's seam must point to this seam" % target_name)
	return out
