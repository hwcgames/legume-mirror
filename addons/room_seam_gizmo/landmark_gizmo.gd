@tool
extends EditorNode3DGizmoPlugin

func _get_gizmo_name() -> String:
	return "Landmark"

func _has_gizmo(for_node_3d: Node3D) -> bool:
	return for_node_3d is Landmark

func _init():
	create_material("main", Color(1, 0, 0, 0.5))

func _redraw(gizmo: EditorNode3DGizmo) -> void:
	gizmo.clear()
	var landmark: Marker3D = gizmo.get_node_3d()
	gizmo.add_mesh(preload("uid://cgrpyx8nfv4qy"), get_material("main", gizmo))
