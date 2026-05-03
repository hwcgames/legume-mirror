extends Resource
class_name ActorSheet

@export var name: StringName = "Actor"
@export var description: String = "Whozemawhatsit"
@export var costume: PackedScene = preload("uid://c4r2ey7i7ooq3")
@export var bg_color: Color = Color.BLACK
@export var text_color: Color = Color.WHITE
@export var id: String
@export var hp: HealthComponent
var alive: bool:
	get:
		return hp.alive
@export var attrs: CombatAttributes = CombatAttributes.new()
@export var rules: Array[BattleRule] = []

@export var party_component: PartyComponent
@export var enemy_component: EnemyComponent

func copy():
	return self.duplicate(true)
