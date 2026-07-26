extends ActorComponent
class_name ActorPathing
var base_speed: float = 10.
var speed_mul: float = 1.
var speed:
	get:
		return base_speed * speed_mul
var target: Vector3
var rotation: float
var timer: Timer = Timer.new()
func _ready() -> void:
	add_child(timer)
	timer.timeout.connect(func():
		if not active:
			return
		print("Pathing took too long. Emergency teleport!")
		actor.global_position = target
		actor.goal_rotation = rotation
		actor.mode_done())
	await get_tree().process_frame
	actor.navigation.path_changed.connect(func():
		var time = actor.navigation.get_path_length() / speed
		timer.stop()
		timer.start(time))
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
	#last_movement = Vector3.ZERO
var last_movement: Vector3
func _active(delta: float):
	actor.navigation.get_next_path_position()
	var old_pos = actor.global_position
	actor.velocity = Vector3.ZERO
	var idx := actor.navigation.get_current_navigation_path_index()
	var path := actor.navigation.get_current_navigation_path()
	#if idx + 1 < len(path):
	var speed_this_frame = speed * delta
	if not path.is_empty():
		while speed_this_frame > 0.01:
			var prev_speed = speed_this_frame
			var next_pos := path[idx]
			#while actor.global_position.distance_to(next_pos) < 0.1 and idx+1 < len(path):
				#idx += 1
				#next_pos = path[idx]
			var wants_move := next_pos - actor.global_position
			actor.velocity += wants_move
			var movement = wants_move.limit_length(speed_this_frame) if idx < len(path) - 1 \
			else wants_move.normalized() * speed_this_frame
			speed_this_frame -= movement.length()
			actor.global_position += movement
			if prev_speed - speed_this_frame < 0.01:
				break
		#print(speed_this_frame)
		last_movement += actor.global_position - old_pos
		last_movement /= 2.
	else:
		actor.global_position += last_movement
		speed_this_frame = 0.
	#elif not path.is_empty():
		#var next_pos := path[idx]
		#var wants_move := next_pos - actor.global_position
		#var movement = wants_move.normalized() * speed * delta
		#actor.global_position += movement
	var g = actor.gravity
	actor.gravity = false
	actor.get_node("%Component/Idle")._active(1./Engine.physics_ticks_per_second)
	actor.gravity = g
	actor.velocity = Vector3.ZERO
func _deactivate():
	#print(last_movement)
	#actor.global_position += last_movement#.normalized() * speed * 1./Engine.physics_ticks_per_second
	timer.stop()
