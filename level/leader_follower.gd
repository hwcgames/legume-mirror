extends Node3D
class_name LeaderProxy

@onready var leader = Storyteller2.story.FetchVariable("leader")
@onready var pm = Actor.find(leader)

func _physics_process(delta: float) -> void:
	var new_leader = Storyteller2.story.FetchVariable("leader")
	if new_leader == null:
		return
	if new_leader != leader:
		leader = new_leader
		pm = Actor.find(leader)
	if pm == null:
		pm = Actor.find(leader)
		return
	global_position = pm.global_position
