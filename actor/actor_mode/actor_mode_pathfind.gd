extends ActorMode
class_name ActorModePathfind

var pathfind_target: Vector3
var speed: float = 10.

func _activate():
	actor.navigation.navigation_finished.connect(func(): self.finished = true)
	_uncovered()
	actor.get_tree().create_timer(3.0 * actor.navigation.get_path_length() / speed).timeout.connect(func():
		if finished:
			return
		print("Emergency teleport!")
		actor.global_position = pathfind_target
		finished = true)

func _uncovered():
	actor.navigation.target_position = pathfind_target

func _process(delta: float):
	var next_pos = actor.navigation.get_next_path_position()
	var movement = (next_pos - actor.global_position).normalized() * speed * delta
	if movement.length() > 0.1:
		actor.play("walk")
		actor.global_rotation.y = Vector3.FORWARD.signed_angle_to(movement, Vector3.UP)
	else:
		actor.play("idle")
	actor.velocity += movement / delta
