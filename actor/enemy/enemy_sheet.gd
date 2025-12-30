extends EnemyFactory
class_name EnemySheet

@export var name: StringName = "Enemy"
@export var hp: int = 10
@export var sp: int = 10
@export var strength: int = 10
@export var magic: int = 10
@export var defense: int = 0
@export var finesse: int = 10

@export var costume: PackedScene = preload("uid://c4r2ey7i7ooq3")

@export var patterns: Array[BulletPattern] = []
@export var planning_priority: int
@export var parleys: Array[ParleyAction] = []

func roll_enemy() -> EnemySheet:
	return self
