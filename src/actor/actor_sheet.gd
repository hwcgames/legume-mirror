extends Resource
class_name ActorSheet

@export var name: StringName = "Actor"
@export var description: String = "Whozemawhatsit"
@export var costume: PackedScene = preload("uid://c4r2ey7i7ooq3")
@export var bg_color: Color = Color.WHITE
@export var text_color: Color = Color.WHITE
@export var default_voice: Voice = preload("uid://coudm8kl2h00x")
@export var default_interval: float = 0.03
@export var id: String
@export var tags: Array[String] = []
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

func get_rules() -> Array[BattleRule]:
	var rules: Array[BattleRule] = rules.duplicate()
	if is_instance_valid(party_component):
		for equip in party_component.equips:
			rules.append_array(equip.rules)
	rules.sort_custom(func(a: BattleRule, b: BattleRule): return a.priority() < b.priority())
	return rules

func add_rule(rule: BattleRule) -> bool:
	for existing in rules:
		if existing.get_script() == rule.get_script():
			existing.merge(rule)
			return false
	rules.push_back(rule)
	return true

func remove_rule(rule: BattleRule) -> bool:
	var idx = rules.find(rule)
	if idx == -1:
		return false
	rules.remove_at(idx)
	rule.removed.emit()
	changed.emit()
	return true

func compute_attrs() -> CombatAttributes:
	var attrs = self.attrs.duplicate()
	for rule in get_rules():
		if not rule.compute_attrs(null, attrs):
			return attrs
	return attrs

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

static func find(name: String) -> ActorSheet:
	var saver = Saver.find()
	if is_instance_valid(saver) and name in saver.current_save.character_sheets:
		return saver.current_save.character_sheets[name]
	var actor_registry: Registry = preload("uid://1j20voyhehyl")
	if !actor_registry.has(name):
		return null
	var actor: ActorSheet = actor_registry.load_entry(name)
	if is_instance_valid(saver) and actor.saved:
		saver.current_save.character_sheets[name] = actor
	return actor
