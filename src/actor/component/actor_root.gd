extends ActorComponent
class_name ActorRooted

var root: Node3D

func _active(delta: float):
	actor.global_transform = root.global_transform
