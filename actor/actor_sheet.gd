extends Resource
class_name ActorSheet

@export var name: StringName = "Actor"
@export var description: String = "Whozemawhatsit"
@export var costume: PackedScene = preload("uid://c4r2ey7i7ooq3")
@export var bg_color: Color = Color.BLACK
@export var text_color: Color = Color.WHITE
@export var id: String
@export var hp: HealthComponent:
	get:
		if is_instance_valid(hp):
			return hp
		else:
			var h = HealthPool.new()
			h.max_hp = 1
			h.current_hp = 1
			return h
var alive: bool:
	get:
		return hp.alive
@export var attrs: CombatAttributes = CombatAttributes.new()
@export var rules: Array[BattleRule] = []
@export var saved: bool = false

@export var party_component: PartyComponent
@export var enemy_component: EnemyComponent

func copy():
	var out = self.duplicate(false)
	if is_instance_valid(hp):
		out.hp = hp.copy()
	if is_instance_valid(attrs):
		out.attrs = attrs.duplicate()
	if is_instance_valid(party_component):
		out.party_component = party_component.copy()
	if is_instance_valid(enemy_component):
		out.enemy_component = enemy_component.copy()
	for i in range(len(out.rules)):
		out.rules[i] = out.rules[i].copy()
	return out
