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

func spawn() -> Enemy:
	var enemy: Enemy = preload("uid://nk8ets08f0mj").instantiate()
	var costume_node: Costume = costume.instantiate()
	enemy.costume = costume_node
	enemy.human_name = name
	enemy.max_hp = hp
	enemy.hp = hp
	enemy.max_sp = sp
	enemy.sp = sp
	enemy.strength = strength
	enemy.magic = magic
	enemy.defense = defense
	enemy.finesse = finesse
	enemy.patterns = patterns
	enemy.planning_priority = planning_priority
	enemy.parleys = parleys
	return enemy
