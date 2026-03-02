extends Area3D

@export var camera: PhantomCamera3D
@export var priority_offset: int = 1

var players_inside: int = 0

func _ready() -> void:
	body_entered.connect(func(other: PhysicsBody3D):
		if Storyteller.leader == other:
			camera.priority += priority_offset)
	body_exited.connect(func(other: PhysicsBody3D):
		if Storyteller.leader == other:
			camera.priority -= priority_offset)
