@tool
extends EditorNode3DGizmoPlugin

func _get_gizmo_name() -> String:
	return "RoomSeam"

func _has_gizmo(for_node_3d: Node3D) -> bool:
	return for_node_3d is RoomSeam

func _init():
	create_material("main", Color(1, 1, 1, 0.25))

func _redraw(gizmo: EditorNode3DGizmo) -> void:
	gizmo.clear()
	var room_seam: RoomSeam = gizmo.get_node_3d()
	gizmo.add_mesh(preload("uid://cg3k844prskc"), get_material("main", gizmo))
