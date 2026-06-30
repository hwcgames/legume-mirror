extends ActorComponent
class_name ActorCargo

var carrier: Actor
var colliders
func _activate():
	colliders = actor.get_children()\
		.filter(func(c): return c is CollisionShape3D and not c.disabled)\
		.map(func(c): return c as CollisionShape3D)
	for c in colliders:
		c.disabled = true
	actor.hide()
	await actor.new_mode # Our own new_mode
func _deactivate():
	for c in colliders:
		c.disabled = false
	actor.show()
func _active(delta: float):
	actor.global_transform = carrier.global_transform
