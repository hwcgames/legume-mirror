extends ActorMode
class_name ActorModePathfind

var do_rotate: bool = false
var goal_rotation: float = INF
var pathfind_target: Vector3
var speed: float = 10.

var dont_teleport = false

func _activate():
	var e_teleport_timer = actor.get_tree().create_timer(3.0 * actor.global_position.distance_to(pathfind_target) / speed)
	actor.navigation.navigation_finished.connect(func():
		#e_teleport_timer.timeout.disconnect()
		finished = true
		dont_teleport = true
		actor.play("idle")
		#actor.global_position = pathfind_target
		if do_rotate:
			actor.global_rotation.y = goal_rotation)
	_uncovered()
	await actor.get_tree().process_frame
	e_teleport_timer.timeout.connect(func():
		if dont_teleport or finished:
			return
		print("Emergency teleport!")
		actor.global_position = pathfind_target
		if do_rotate:
			actor.global_rotation.y = goal_rotation
		actor.play("idle")
		finished = true)

func _deactivate():
	finished = true
	dont_teleport = true

func _covered(by: ActorMode):
	dont_teleport = true

func _uncovered():
	actor.navigation.target_position = pathfind_target

func _process(delta: float):
	super._process(delta)
	var next_pos = actor.navigation.get_next_path_position()
	if finished:
		return
	var movement = (next_pos - actor.global_position).normalized() * speed * delta
	if movement.length() > 0.05:
		actor.play("walk")
		actor.global_rotation.y = Vector3.FORWARD.signed_angle_to(next_pos - actor.global_position, Vector3.UP)
	else:
		actor.play("idle")
		finished = true
	actor.velocity += movement / delta
