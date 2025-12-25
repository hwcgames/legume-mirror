extends ActorMode
class_name ActorModeApproach

var target: Actor
var return_pos: Vector3
var relative_pos: Vector3
var return_rotation: Vector3
var goal: Vector3:
	get:
		return target.global_position + relative_pos.rotated(Vector3.UP, target.global_rotation.y)

var approach_time: float
var retreat_time: float

func _init(actor: Actor,
	target: Actor,
	relative_pos: Vector3 = Vector3.FORWARD * 2,
	return_pos: Vector3 = actor.home_landmark.global_position if actor is Fighter else actor.global_position,
	return_rotation: Vector3 = actor.home_landmark.global_rotation if actor is Fighter else actor.global_rotation,
	approach_time: float = 0.5,
	retreat_time: float = approach_time) -> void:
	self.target = target
	self.relative_pos = relative_pos
	self.return_pos = return_pos
	self.return_rotation = return_rotation
	self.approach_time = approach_time
	self.retreat_time = retreat_time

func _activate():
	await actor.play("walk", true)
	var target_angle_change = (target.global_rotation.y - PI) - actor.global_rotation.y
	while target_angle_change < -PI:
		target_angle_change += 2*PI
	while target_angle_change > PI:
		target_angle_change -= 2*PI
	actor.create_tween().tween_property(actor, "global_rotation", actor.global_rotation + Vector3(0, target_angle_change, 0), approach_time)
	await actor.create_tween().tween_property(actor, "global_position", goal, approach_time).finished
	await actor.play("idle", true)

func _uncovered():
	if actor.global_position != goal:
		actor.play("walk")
		await _activate()

func _deactivate():
	await actor.play("walk", true)
	actor.create_tween().tween_property(actor, "global_rotation", return_rotation, approach_time)
	await actor.create_tween().tween_property(actor, "global_position", return_pos, retreat_time).finished
	await actor.play("idle", true)
