@tool
extends EditorPlugin

const RoomSeamGizmoPlugin = preload("res://addons/room_seam_gizmo/room_seam_gizmo.gd")
const LandmarkGizmoPlugin = preload("res://addons/room_seam_gizmo/landmark_gizmo.gd")
var room_seam_plugin = RoomSeamGizmoPlugin.new()
var landmark_plugin = LandmarkGizmoPlugin.new()

func _enter_tree():
	add_node_3d_gizmo_plugin(room_seam_plugin)
	add_node_3d_gizmo_plugin(landmark_plugin)

func _exit_tree():
	remove_node_3d_gizmo_plugin(room_seam_plugin)
	remove_node_3d_gizmo_plugin(landmark_plugin)
