extends Node3D
class_name Hidable

func _ready() -> void:
	add_to_group("hidable")

static func find(name: String) -> Hidable:
	var found = Storyteller2.get_tree().get_nodes_in_group("hidable").filter(func(l: Hidable): return l.name == name)
	var leader = Storyteller2.leader
	if leader:
		found.sort_custom(func(a, b):
			return a.global_position.distance_to(leader.global_position) < b.global_position.distance_to(leader.global_position))
	return found[0] if not found.is_empty() else null
