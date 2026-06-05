extends ActorComponent
class_name ActorPathing
var speed: float = 10.
var target: Vector3
var rotation: float
func _activate():
	actor.navigation.target_position = target
	var old_target = target
	actor.navigation.navigation_finished.connect(func():
		if active && target == old_target:
			actor.mode_done()
			if is_finite(rotation):
				await get_tree().process_frame
				actor.goal_rotation = rotation
				actor.velocity = Vector3.ZERO)
func _active(delta: float):
	var next_pos = actor.navigation.get_next_path_position()
	actor.velocity = (next_pos - actor.global_position).normalized() * speed
	actor.get_node("%Component/Idle")._active(delta)
