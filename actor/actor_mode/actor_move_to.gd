extends ActorMode
class_name ActorModeMoveTo

var target: Node3D
var goal: Vector3
var _goal: Vector3:
	get:
		return target.global_position if target else goal

var approach_time: float
var speed: float

func _init(actor: Actor,
	goal: Variant,
	speed: float = 10.) -> void:
	self.actor = actor
	if goal is Vector3:
		self.goal = goal
	elif goal is Node3D:
		self.target = goal
	else:
		printerr("Goal should be a vector3 or a node3D")
	#self.approach_time = approach_time
	self.speed = speed
	actor.get_tree().create_timer(3.0 * actor.global_position.distance_to(_goal) / speed).timeout.connect(func():
		if finished:
			return
		print("Emergency teleport!")
		actor.global_position = _goal
		finished = true)

signal done
func _process(delta: float):
	if actor.global_position.distance_to(_goal) < 0.4:
		actor.play("idle")
		finished = true
		if target is Landmark:
			actor.global_rotation = target.global_rotation
		done.emit()
	actor.global_position += actor.global_position.direction_to(_goal) * speed * delta

func _uncovered():
	self.speed = actor.global_position.distance_to(_goal) / approach_time

func _activate():
	await actor.play("walk", true)
	actor.global_rotation = Vector3(0, Vector3.FORWARD.signed_angle_to(_goal - actor.global_position, Vector3.UP), 0)
	await done
	#actor.global_rotation.y = Vector3.FORWARD.signed_angle_to(_goal - actor.global_position, Vector3.UP)
