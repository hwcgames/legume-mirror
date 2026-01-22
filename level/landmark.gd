extends Marker3D
class_name Landmark

func _ready() -> void:
	add_to_group("landmark", true)

static func find(name: String) -> Landmark:
	var found = Storyteller.get_tree().get_nodes_in_group("landmark").filter(func(l: Landmark): return l.name == name)
	return found[0] if not found.is_empty() else null
