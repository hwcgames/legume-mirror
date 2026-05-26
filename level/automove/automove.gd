@abstract
extends Marker3D
class_name Automove

@export var next_automove: Automove
@export var next_seam: RoomSeam
@export var next_seam_key: StringName

@abstract func apply_to_actor(actor: Actor)

func _ready():
	add_to_group("automove")

static func find(actor: Actor, automove_name: StringName) -> Automove:
	var candidates: Array[Automove] = []
	for node in Storyteller.get_tree().get_nodes_in_group("automove"):
		if node.name == automove_name:
			candidates.push_back(node)
	if candidates.is_empty():
		return null
	candidates.sort_custom(func(a, b):
		return actor.global_position.distance_to(a.global_position) < actor.global_position.distance_to(b.global_position))
	return candidates[0]
