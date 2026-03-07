extends Node3D
class_name LeaderProxy

@onready var leader = Storyteller.story.FetchVariable("leader")
@onready var pm = PartyMember.find(leader)

func _physics_process(delta: float) -> void:
	var new_leader = Storyteller.story.FetchVariable("leader")
	if new_leader == null:
		return
	if new_leader != leader:
		leader = new_leader
		pm = PartyMember.find(leader)
	if pm == null:
		pm = PartyMember.find(leader)
		return
	global_position = pm.global_position
