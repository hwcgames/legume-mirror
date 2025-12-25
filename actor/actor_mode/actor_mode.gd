@abstract
extends RefCounted
class_name ActorMode

var actor: Actor
var finished: bool = false
var finishing: bool = false

signal popped

func _activate():
	pass

func _deactivate():
	pass

func _covered():
	pass

func _uncovered():
	pass

func _process(delta: float):
	_gravity(delta)
	pass

var fall_speed: float = 0.

func _gravity(delta: float):
	if actor.is_on_floor():
		fall_speed = 0.
		return
	fall_speed += 9.8 * delta
	fall_speed = min(fall_speed, 10.)
	actor.velocity += Vector3.DOWN * fall_speed
