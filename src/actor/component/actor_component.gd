@abstract
extends Node
class_name ActorComponent

var actor: Actor:
	get:
		return get_node("../..")
var active: bool = false:
	get:
		return _is_active()
	set(new_active):
		if new_active == _is_active():
			return
		active = new_active
		if active:
			actor.active_component = self
		else:
			actor.mode_done()
func _is_active():
	return actor.active_component == self

func _deactivate():
	return
func _activate():
	return
func _reset_velocity() -> bool:
	return true

func _active(delta: float):
	actor.mode_done() # If a component that doesn't know how to be active activates somehow, abdicate.

func wants_line(line: String, tags: Array[String]):
	return false
func take_line(line: String, tags: Array[String]):
	pass
func wants_choice(choice: InkChoice):
	return false
func take_choice(choice: InkChoice):
	pass
