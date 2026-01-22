extends ActorMode
class_name ActorModeFollow

var follow_target: Actor
var follow_distance: float

var distance_to_target: float:
	get:
		return actor.global_position.distance_to(follow_target.global_position)

func _init(follow_target: Actor, follow_distance: float):
	self.follow_target = follow_target
	self.follow_distance = follow_distance

var follow_history: Array[Vector3]
var follow_history_length: float:
	get:
		var length = 0
		var pos = actor.global_position
		for new_pos in follow_history:
			length += pos.distance_to(new_pos)
			pos = new_pos
		return length

func _process(delta: float):
	if (not follow_history.is_empty()) and follow_target.global_position.distance_to(follow_history[0]) > 3.0:
		follow_history.clear()
	if follow_history.is_empty() or follow_target.global_position.distance_to(follow_history[0]) > 0.5:
		follow_history.push_back(follow_target.global_position)
	if follow_history_length < follow_distance:
		actor.play("idle")
		return
	actor.play("walk")
	var speed = 11. * delta
	var movement: Vector3 = Vector3.ZERO
	while (not follow_history.is_empty()) and follow_history[0].distance_to(actor.global_position) < 0.1:
		follow_history.pop_front()
	while speed > 0.1 and (not follow_history.is_empty()) and follow_history_length > follow_distance:
		var next_leg = follow_history[0] - actor.global_position
		if next_leg.length() > speed:
			next_leg = next_leg.normalized() * speed
		else:
			follow_history.pop_front()
		speed -= next_leg.length()
		movement += next_leg
	if movement.length() > 0.1:
		actor.play("walk")
		actor.global_rotation.y = Vector3.FORWARD.signed_angle_to(movement, Vector3.UP)
	else:
		actor.play("idle")
	actor.velocity += movement / delta

func _covered():
	follow_history.clear()
