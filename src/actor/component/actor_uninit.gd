extends ActorComponent
class_name ActorUninit

func _activate():
	actor.hide()
	actor.set_physics_process(false)
	actor.set_process(false)

func _active(delta: float):
	return

func _deactivate():
	actor.show()
	actor.set_physics_process(true)
	actor.set_process(true)
