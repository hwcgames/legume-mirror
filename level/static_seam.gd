@tool
extends RoomSeam
class_name StaticSeam

@export var target_name: StringName:
	set(name):
		target_name = name
		update_configuration_warnings()
@export_file() var target_room: String:
	set(room):
		target_room = room
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var out = PackedStringArray()
	if not self.unique_name_in_owner:
		out.push_back("Seams should have a scene-unique name")
	if target_room == "" or target_room == null:
		out.push_back("The room must be set")
	if target_name == null:
		out.push_back("The target door name must be set")
	var room_scene = load(target_room)
	if not room_scene is PackedScene:
		out.push_back("The target room must be a scene")
		return out
	var room = (room_scene as PackedScene).instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	var seam = room.get_node("%%%s" % target_name)
	if seam == null:
		out.push_back("Room must have a seam named %s" % target_name)
		return out
	if not seam is RoomSeam:
		out.push_back("Room must have a seam named %s" % target_name)
		return out
	var dirty = false
	if seam is StaticSeam and seam.target_room != ResourceUID.path_to_uid(self.owner.scene_file_path):
		print("Updating partner target room")
		seam.target_room = ResourceUID.path_to_uid(self.owner.scene_file_path)
		dirty = true
	if seam is StaticSeam and seam.target_name != name:
		print("Updating partner target node")
		seam.target_name = name
		dirty = true
	if dirty:
		print("Saving partner scene")
		room_scene.pack(room as Node3D)
		ResourceSaver.save(room_scene)
		EditorInterface.get_resource_filesystem().reimport_files([room.scene_file_path])
		EditorInterface.reload_scene_from_path(room.scene_file_path)
	print("Seam %s looks OK" % name)
	return out
