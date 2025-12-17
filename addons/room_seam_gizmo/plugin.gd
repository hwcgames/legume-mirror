@tool
extends EditorPlugin

const RoomSeamGizmoPlugin = preload("res://addons/room_seam_gizmo/gizmo.gd")
var room_seam_plugin = RoomSeamGizmoPlugin.new()

func _enter_tree():
	add_node_3d_gizmo_plugin(room_seam_plugin)

func _exit_tree():
	remove_node_3d_gizmo_plugin(room_seam_plugin)
