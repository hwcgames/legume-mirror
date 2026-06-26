extends ActorComponent
class_name ActorIdle
func _active(delta: float):
	if Vector2(actor.velocity.x, actor.velocity.z).length() > 0.05:
		actor.goal_rotation = Vector3.FORWARD.signed_angle_to(actor.velocity, Vector3.UP)
	actor.global_rotation.y = move_toward(
		actor.global_rotation.y,
		lerp_angle(actor.global_rotation.y, actor.goal_rotation, 1.),
		4. * PI * delta
	)
	if actor.is_on_floor() or !actor.gravity:
		return
	actor.velocity += Vector3.DOWN * 5.
