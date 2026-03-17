extends BattleAction
class_name BattleActionApplyRule

@export var name: String
@export var description: String
@export var cost: int = 15
@export var message: String = "%s applied a rule to %s!"
@export var rfl_message: String = "%s applied a rule to themselves!"
@export var rules: Array[BattleRule]
@export var friendly: bool = false
@export var alive: bool = true

func allowed(party_member: PartyMember) -> bool:
	return party_member.sp_component.remaining() > cost

func plan(battle_planner: BattlePlanner) -> BattleActionPlan:
	var target: Fighter = await battle_planner.pick_ally(func(p): return p.alive == alive)\
		if friendly else \
		await battle_planner.pick_target(func(e): return e.alive == alive)
	if target == null:
		battle_planner.show_toplevel()
		return null
	return ApplyRulePlan.new(name, cost, message, rfl_message, rules, friendly, target)

class ApplyRulePlan extends BattleActionPlan:
	var name: String
	var cost: int
	var message: String
	var rfl_message: String
	var rules: Array[BattleRule]
	var friendly: bool
	var target: Fighter
	func _init(name, cost, message, rfl_message, rules, friendly, target) -> void:
		self.name = name
		self.cost = cost
		self.message = message
		self.rfl_message = rfl_message
		self.rules = rules
		self.friendly = friendly
		self.target = target
	func go(party_member: PartyMember):
		var battlefield = party_member.battlefield
		var b_lock = await battlefield.lock.shared_lock()
		var t_lock = await target.locks.exclusive_lock() if target is Enemy else func(): return
		if !target.alive:
			for t in battlefield.players if friendly else battlefield.valid_enemies:
				if t.alive:
					target = t
		if !target.alive:
			print("No living targets!")
			b_lock.call()
			t_lock.call()
			return
		if party_member != target:
			battlefield.println(message % [party_member.human_name, target.human_name])
		else:
			battlefield.println(rfl_message % party_member.human_name)
		var approach = ActorModeApproach.new(party_member, target)
		if target != party_member:
			await party_member.push_mode(approach)
		var animate = ActorModeAnimate.new("friendly_magic" if friendly else "hostile_magic")
		await party_member.push_mode(animate)
		party_member.sp -= cost
		for rule in rules:
			target.add_rule(rule.duplicate())
		await animate.popped
		approach.finished = true
		b_lock.call()
		t_lock.call()
		if target != party_member:
			await approach.popped
