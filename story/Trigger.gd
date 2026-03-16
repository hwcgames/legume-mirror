extends RigidBody3D
class_name Trigger

@export var choices: Array[String] = ["north"]
@export var important: bool = true:
	set(new_important):
		important = new_important
@export var wall_only: bool = false

func _ready():
	contact_monitor = true
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	freeze = true
	max_contacts_reported = 32
	body_entered.connect(entered)
	body_exited.connect(exited)
	collision_mask = 3
	collision_layer = 0
	can_sleep = false

var players_colliding: int = 0

func entered(body: Node):
	if not body.is_in_group("party_leader"):
		return
	players_colliding += 1
	if players_colliding == 1:
		var chose = Storyteller.choose_if_available(choices) if not wall_only else Storyteller.choices.any(func(c: InkChoice): return c.GetText() in choices)
		if not chose:
			collision_layer = 3 if important else 0
		else:
			collision_layer = 0

func exited(body: Node):
	if not body.is_in_group("party_leader"):
		return
	players_colliding -= 1
	if players_colliding == 0:
		collision_layer = 0
