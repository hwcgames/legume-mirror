extends ActorComponent
class_name ActorGlide
var target: Callable
var speed: float
var rotation: float = INF
var afterimage_duration: float = 0.
var afterimage_interval: float = 0.
var afterimage_count: int = 0
var timer: Timer = Timer.new()
func _ready() -> void:
	add_child(timer)
	timer.timeout.connect(func():
		if not active:
			return
		print("Glide took too long. Emergency teleport!")
		actor.global_position = target.call()
		actor.goal_rotation = rotation
		actor.mode_done())
func _activate():
	var movement_time = actor.global_position.distance_to(target.call()) / speed
	if afterimage_count > 0:
		afterimage_interval = movement_time / afterimage_count
	timer.start(movement_time * 2)
	actor.skip_physics = true
	pass
	#t.tween_property(actor, "global_position", target, glide_time)
	#t.play()
	#await t.finished
	#if active:
		#actor.mode_done()

var afterimage_ticker = 0.

func _active(delta: float):
	if afterimage_count > 0:
		afterimage_ticker -= delta
		if afterimage_ticker <= 0:
			actor.afterimage_stationary(afterimage_duration)
	var target_pos: Vector3 = target.call()
	var movement := (target_pos - actor.global_position).limit_length(speed / Engine.physics_ticks_per_second)
	if abs(movement.y) < 0.01:
		actor.global_position.y = target_pos.y
		movement.y = 0
	if abs(movement.x) < 0.01:
		actor.global_position.x = target_pos.x
		movement.x = 0
	actor.global_position += movement
	#actor.get_node("%Component/Idle")._active(delta)
	if movement.length() > 1.:
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
func _deactivate():
	actor.skip_physics = false
	timer.stop()
