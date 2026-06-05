extends ActorComponent
class_name ActorGlide
var target: Callable
var speed: float
var rotation: float = INF
func _activate():
	pass
	#t.tween_property(actor, "global_position", target, glide_time)
	#t.play()
	#await t.finished
	#if active:
		#actor.mode_done()
func _active(delta: float):
	var target_pos: Vector3 = target.call()
	var movement = (target_pos - actor.global_position).limit_length(speed * delta)
	actor.global_position += movement
	#actor.get_node("%Component/Idle")._active(delta)
	actor.goal_rotation = Vector3.FORWARD.signed_angle_to(movement, Vector3.UP)
	actor.global_rotation.y = move_toward(
		actor.global_rotation.y,
		lerp_angle(actor.global_rotation.y, actor.goal_rotation, 1.),
		4. * PI * delta
	)
	if actor.global_position.distance_to(target_pos) < 0.05:
		if is_finite(rotation):
			actor.goal_rotation = rotation
		actor.mode_done()
	pass
