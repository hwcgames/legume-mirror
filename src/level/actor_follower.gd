extends Node3D
class_name ActorProxy

@export var actors: Array[StringName] = []

func _process(delta: float) -> void:
	var a: Actor
	for actor in actors:
		a = Actor.find(actor)
		if a:
			break
	if a == null:
		return
	global_position = a.global_position
