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

func _process(_delta: float):
	pass
