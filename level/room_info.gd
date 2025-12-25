@tool
extends Resource
class_name RoomInfo

@export_tool_button("Repopulate")
var repopulate_action = repopulate

enum ROOM_TYPE {
	UNKNOWN,
	HALLWAY,
	DEAD_END,
	JUNCTION,
	MONSTER,
	ITEM,
	EVENT,
	SAFE,
	BOSS,
	SHOP
}

@export var weight: float = 1.0
@export var autoplace: bool = true
@export var room_type: ROOM_TYPE = ROOM_TYPE.UNKNOWN
@export var theme: StringName = "default"
@export var room_scene: PackedScene
@export var static_seams: Array[String] = []
@export var proc_seams: Array[String] = []
@export var seam_backtrack: Dictionary[String, bool] = {}
@export var seam_profiles: Dictionary[String, String] = {}
@export var seam_target_rooms: Dictionary[String, String] = {}
@export var seam_target_name: Dictionary[String, String] = {}

func repopulate():
	static_seams = []
	proc_seams = []
	seam_backtrack = {}
	seam_profiles = {}
	seam_target_rooms = {}
	seam_target_name = {}
	var room: Node3D = room_scene.instantiate()
	walk(room)

func walk(node: Node):
	if node is StaticSeam:
		print(node)
		static_seams.push_back(node.name)
		seam_target_rooms.set(node.name, node.target_room)
		seam_target_name.set(node.name, node.target_name)
	elif node is ProceduralSeam:
		print(node)
		proc_seams.push_back(node.name)
		seam_profiles.set(node.name, node.profile)
		seam_backtrack.set(node.name, node.backtrack)
	else:
		for child in node.get_children():
			walk(child)
