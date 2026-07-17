extends Node
class_name CanvasLayerFollowsParent

@onready var layer: CanvasLayer = get_parent()
@onready var target: Node3D = get_parent().get_parent()

func _process(_d):
	var camera = target.get_viewport().get_camera_3d()
	if !is_instance_valid(camera):
		return
	if camera.is_position_behind(target.global_position):
		layer.offset = Vector2(1000000, 0)
		return
	var position = camera.unproject_position(target.global_position)
	layer.offset = position
