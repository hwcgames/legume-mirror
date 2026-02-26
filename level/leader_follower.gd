extends Node3D

func _process(delta: float) -> void:
	var leader = Storyteller.story.FetchVariable("leader")
	if leader == null:
		return
	var pm = PartyMember.find(leader)
	if pm == null:
		return
	global_position = pm.global_position
