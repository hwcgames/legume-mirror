extends Marker3D
class_name Landmark

@onready var _name = name

func _init() -> void:
	add_to_group("landmark", true)

static func find(name: String) -> Landmark:
	var predicate = func(_l: Landmark): return true
	var mg := MainGame.find()
	if is_instance_valid(mg):
		match mg.mode:
			MainGame.MODE.LEVEL:
				predicate = func(l: Landmark):
					return mg.level.is_ancestor_of(l)
			MainGame.MODE.BATTLE:
				predicate = func(l: Landmark):
					return mg.battle.is_ancestor_of(l)
	var found = []
	for landmark in Storyteller.find().get_tree().get_nodes_in_group("landmark"):
		if not predicate.call(landmark):
			continue
		if landmark.name == name:
			found.push_back(landmark)
	var leader = Storyteller.find().leader
	if leader:
		found.sort_custom(func(a, b):
			return a.global_position.distance_to(leader.global_position) < b.global_position.distance_to(leader.global_position))
	return found[0] if not found.is_empty() else null
