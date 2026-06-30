extends ActorSheet
class_name EnemySheet

@export var sp: EnergyComponent
@export var active: bool = true

@export var patterns: Array[BulletPattern] = []
@export var planning_priority: int
@export var parleys: Array[ParleyAction] = []

func roll_enemy() -> EnemySheet:
	return self

func _join_battle(enemy: Actor, battlefield: Battlefield):
	enemy.home_landmark = battlefield.enemy_landmarks[battlefield.enemies.find(enemy)]
	enemy.global_position = enemy.home_landmark.global_position
	enemy.global_rotation = enemy.home_landmark.global_rotation
