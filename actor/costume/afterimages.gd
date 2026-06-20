extends Node3D
class_name Afterimager

@export var target: Node3D

func create_afterimage(material_filter: Callable = func(material: BaseMaterial3D): pass, sprite_filter: Callable = func(sprite: Sprite3D): pass) -> Node3D:
	var afterimage = target.duplicate()
	var visualinstances = walk_for_vi(afterimage)
	for vi in visualinstances:
		if vi is GeometryInstance3D and is_instance_valid(vi.material_override):
			vi.material_override = vi.material_override.duplicate()
			material_filter.call(vi.material_override)
		if vi is MeshInstance3D:
			for idx in range(vi.mesh.get_surface_count()):
				var material = vi.get_active_material(idx).duplicate() if is_instance_valid(vi.get_active_material(idx)) else StandardMaterial3D.new()
				material_filter.call(material)
				vi.set_surface_override_material(idx, material)
		if vi is SpriteBase3D:
			sprite_filter.call(vi)
	add_child(afterimage)
	afterimage.top_level = true
	afterimage.global_transform = target.global_transform
	afterimage.process_mode = Node.PROCESS_MODE_DISABLED
	return afterimage
	pass

func walk_for_vi(node: Node) -> Array[VisualInstance3D]:
	if node == self or (node is Node3D and node.top_level):
		return []
	var out: Array[VisualInstance3D] = []
	if node is VisualInstance3D:
		out.push_back(node)
	for child in node.get_children():
		out.append_array(walk_for_vi(child))
	return out
