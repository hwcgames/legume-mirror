extends ActorMode
class_name ActorModePathfind

var goal_rotation: float
var pathfind_target: Vector3
var speed: float = 10.

func _activate():
	actor.navigation.navigation_finished.connect(func():
		actor.create_tween().tween_property(actor, "global_position", pathfind_target, 0.1)
		await actor.create_tween().tween_property(actor, "global_rotation", Vector3(0., goal_rotation, 0.), 0.1).finished
		self.finished = true)
	_uncovered()
	await actor.get_tree().process_frame
	actor.get_tree().create_timer(3.0 * actor.global_position.distance_to(pathfind_target) / speed).timeout.connect(func():
		if self.finished:
			return
		print("Emergency teleport!")
		actor.global_position = pathfind_target
		finished = true)

func _deactivate():
	finished = true

func _uncovered():
	actor.navigation.target_position = pathfind_target

func _process(delta: float):
	var next_pos = actor.navigation.get_next_path_position()
	var movement = (next_pos - actor.global_position).limit_length(speed * delta)
	if movement.length() > 0.01:
		actor.play("walk")
		actor.global_rotation.y = Vector3.FORWARD.signed_angle_to(movement, Vector3.UP)
	else:
		actor.play("idle")
	actor.velocity += movement / delta
