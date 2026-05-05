extends Control
class_name BulletPatternLayer

var battlefield: Battlefield
@export var duration: float = 10.0
@export var enemy: Actor

signal done

func _process(delta: float) -> void:
	duration -= delta
	if duration <= 0:
		done.emit()

func random_position(distance_from_soul = 64., distance_from_edge = 24.) -> Vector2:
	while true:
		var position = Vector2(
			randf_range(distance_from_edge, size.x - distance_from_edge),
			randf_range(distance_from_edge, size.y - distance_from_edge),
		)
		if battlefield.battle_board.souls.any(func(soul): return soul.position.distance_to(position) < distance_from_soul):
			continue
		return position
	return Vector2.ZERO

func angle_to_soul(from_position: Vector2, variance = 10.) -> float:
	if battlefield.battle_board == null:
		return 0.
	var soul: Soul = battlefield.battle_board.souls[0]
	return from_position.angle_to_point(soul.position)

func spawn_bullet_at(node_path: NodePath, bullet_scene: PackedScene):
	var node = get_node(node_path)
	var bullet: Bullet = bullet_scene.instantiate()
	add_child(bullet)
	bullet.layer = self
	bullet.enemy = enemy
	bullet.global_position = node.global_position
	bullet.global_rotation = node.global_rotation
	# bullet._bullet_ready()
