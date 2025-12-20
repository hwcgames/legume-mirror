extends ActorMode
class_name ActorModeMoveTo

var goal: Vector3

var approach_time: float

func _init(actor: Actor,
	goal: Vector3,
	approach_time: float = 0.5) -> void:
	self.actor = actor
	self.goal = goal
	self.approach_time = approach_time

func _activate():
	actor.create_tween().tween_property(actor, "global_rotation", Vector3(0, Vector3.FORWARD.signed_angle_to(goal - actor.global_position, Vector3.UP), 0), 0.25)
	await actor.create_tween().tween_property(actor, "global_position", goal, approach_time).finished
	finished = true
