extends Actor
class_name Fighter

var alive: bool:
	get:
		return hp_component.alive
signal died
signal revived
# @export var max_hp: int
# @export var hp: int
@export var hp_component: HealthComponent:
	set(hp):
		hp_component = hp
		hp.fighter = self
		hp.died.connect(self.died.emit)
		hp.revived.connect(self.revived.emit)
		hp.died.connect(self._died)
		hp.revived.connect(self._revived)
var hp: int:
	get:
		return hp_component.hp
	set(hp):
		if hp_component:
			hp_component.hp = hp
# @export var max_sp: int
# @export var sp: int
@export var sp_component: EnergyComponent:
	set(sp):
		sp_component = sp
		sp.fighter = self
var sp: int:
	get:
		return sp_component.sp
	set(sp):
		if sp_component:
			sp_component.sp = sp
@export var attrs: CombatAttributes = CombatAttributes.new()
@export var fighter_rules: Array[BattleRule] = [] 
var rules: Array[BattleRule]:
	get:
		var rules: Array[BattleRule] = []
		rules.append_array(fighter_rules)
		if battlefield:
			rules.append_array(battlefield.rules)
		rules.append_array(Storyteller.rules)
		return rules
var computed_attrs: CombatAttributes:
	get:
		var attrs = self.attrs.duplicate()
		for rule in rules:
			if not rule.compute_attrs(self, attrs):
				return attrs
		return attrs

var home_landmark: Marker3D

func take_damage(amount: int):
	for rule in rules:
		if not rule.take_damage(self, amount):
			return
	hp -= amount

func _died():
	for rule in rules:
		if not rule._died(self):
			return
	if costume != null:
		costume.play("dead")

func heal(amount: int):
	for rule in rules:
		if not rule.heal(self, amount):
			return
	hp += amount

func _revived():
	for rule in rules:
		if not rule._revived(self):
			return
	if costume != null:
		costume.play("idle")

func get_sp(amount: int):
	for rule in rules:
		if not rule.get_sp(self, amount):
			return
	sp += amount

func use_sp(amount: int):
	for rule in rules:
		if not rule.use_sp(self, amount):
			return
	sp -= amount

var battlefield: Battlefield

signal joined_battle(Battlefield)

func join_battle(battle: Battlefield):
	battlefield = battle
	battle.begin.connect(begin)
	battle.top.connect(top)
	battle.telegraph.connect(telegraph)
	battle.player_action.connect(player_action)
	battle.enemy_action.connect(enemy_action)
	var battle_idle = ActorIdle.new()
	battle.done.connect(done)
	battle.done.connect(func(_w): battle_idle.finished = true)
	push_mode(battle_idle)
	_join_battle(battle)
	joined_battle.emit(battlefield)
	for rule in rules:
		if not rule.join_battle(self):
			break

func add_rule(rule: BattleRule) -> bool:
	for existing in fighter_rules:
		if existing.get_script() == rule.get_script():
			existing.merge(rule)
			return false
	fighter_rules.push_back(rule)
	rule._added(self)
	return true

func _join_battle(_battle: Battlefield):
	pass

func begin():
	for rule in rules:
		if not rule.begin(self):
			break
	_begin()

func top():
	rules = rules.filter(func(r: BattleRule):
		var keep = r.stacks > 0
		if not keep:
			r._removed(self)
		return keep)
	for rule in rules:
		if not rule.top(self):
			break
	_top()

func telegraph():
	for rule in rules:
		if not rule.telegraph(self):
			break
	_telegraph()

func player_action():
	for rule in rules:
		if not rule.player_action(self):
			break
	_player_action()

func enemy_action():
	for rule in rules:
		if not rule.enemy_action(self):
			break
	_enemy_action()

func done(player_victory: bool):
	for rule in rules:
		if not rule.done(self, player_victory):
			break
	_done(player_victory)

func _begin():
	pass

func _top():
	pass

func _telegraph():
	pass

func _player_action():
	pass

func _enemy_action():
	pass

func _done(_player_victory: bool):
	pass
