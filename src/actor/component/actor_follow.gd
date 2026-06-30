extends ActorComponent
class_name ActorFollow

var target: Actor
var speed: float = 10.
var distance: float
var history: Array[Vector3]
func _activate():
	history = [target.global_position]
func _active(delta: float):
	if history.is_empty() or history[-1].distance_to(target.global_position) > 0.1:
		history.push_back(target.global_position)
	if actor.global_position.distance_to(target.global_position) < distance:
		return
	var speed_this_frame = speed * delta
	while (not history.is_empty()) and actor.global_position.distance_to(history[0]) < speed_this_frame:
		history.pop_front()
	if not history.is_empty():
		actor.velocity = actor.global_position.direction_to(history[0]) * speed
	actor.get_node("%Component/Idle")._active(delta)
