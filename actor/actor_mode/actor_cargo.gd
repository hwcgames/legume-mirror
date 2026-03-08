extends ActorMode
class_name ActorModeCargo

var carrier: Actor

func _init(carrier: Actor):
	self.carrier = carrier

var enabled_colliders: Array = []
func _activate():
	enabled_colliders = actor.get_children()\
		.filter(func(c): return c is CollisionShape3D and not c.disabled)\
		.map(func(c): return c as CollisionShape3D)
	for c in enabled_colliders:
		c.disabled = true
	actor.hide()

func _deactivate():
	for c in enabled_colliders:
		c.disabled = false
	actor.show()

func _process(delta: float):
	actor.global_position = carrier.global_position
	pass # will never process

func _covered(by: ActorMode):
	_deactivate()

func _uncovered():
	_activate()
