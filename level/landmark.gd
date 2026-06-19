extends Marker3D
class_name Landmark

@onready var _name = name

func _init() -> void:
	add_to_group("landmark", true)

static func find(name: String) -> Landmark:
	var found = []
	for landmark in Storyteller2.get_tree().get_nodes_in_group("landmark"):
		if landmark.name == name:
			found.push_back(landmark)
	var leader = Storyteller2.leader
	if leader:
		found.sort_custom(func(a, b):
			return a.global_position.distance_to(leader.global_position) < b.global_position.distance_to(leader.global_position))
	return found[0] if not found.is_empty() else null
