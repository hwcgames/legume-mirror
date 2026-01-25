extends RigidBody2D
class_name ChatBalloon

@export var character_root: Node2D
@export var next_balloon: ChatBalloon
@export var force: Vector2 = Vector2(50., 20.)
@export var satisfactory_distance: float = 32
@export var separation: float = 64.
var size: Vector2

func _physics_process(delta: float) -> void:
	size = (get_child(0) as Control).size
	var character_up_position = character_root.global_position.y - separation - size.y / 2
	var balloon_up_position = ((next_balloon.global_position.y - next_balloon.size.y/2  - separation - size.y / 2) if next_balloon != null else character_up_position)
	var goal_position: Vector2 = Vector2(
		next_balloon.global_position.x if next_balloon != null and next_balloon.character_root == character_root else character_root.global_position.x,
		min(balloon_up_position, character_up_position)
	)
	var force_this_tick = global_position.direction_to(goal_position) \
		* force * (clamp(global_position.distance_to(goal_position) / satisfactory_distance, 0, 1))
	apply_central_force(force_this_tick)
