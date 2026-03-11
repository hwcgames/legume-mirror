extends EnemyFactory
class_name EnemySheet

@export var name: StringName = "Enemy"
@export var hp: HealthComponent
@export var sp: EnergyComponent
@export var attrs: CombatAttributes = CombatAttributes.new()
@export var rules: Array[BattleRule] = []
@export var bg_color: Color = Color.BLACK
@export var text_color: Color = Color.WHITE

@export var costume: PackedScene = preload("uid://c4r2ey7i7ooq3")

@export var patterns: Array[BulletPattern] = []
@export var planning_priority: int
@export var parleys: Array[ParleyAction] = []

func roll_enemy() -> EnemySheet:
	return self
