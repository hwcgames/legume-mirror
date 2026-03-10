extends BattleAction
class_name BattleActionApplyRule

@export var name: String
@export var cost: int = 15
@export var message: String = "%s applied a rule to %s!"
@export var stacks: int = 3
@export var rule: BattleRule
@export var friendly: bool = false

func allowed(party_member: PartyMember) -> bool:
	return party_member.sp_component.remaining() > cost

func plan(battle_planner: BattlePlanner) -> BattleActionPlan:
	var target: Fighter = await battle_planner.pick_ally() if friendly else await battle_planner.pick_target()
	if target == null:
		battle_planner.show_toplevel()
		return null
	return ApplyRulePlan.new(name, cost, message, stacks, rule, friendly, target)

class ApplyRulePlan extends BattleActionPlan:
	var name: String
	var cost: int
	var message: String
	var stacks: int
	var rule: BattleRule
	var friendly: bool
	var target: Fighter
	func _init(name, cost, message, stacks, rule, friendly, target) -> void:
		self.name = name
		self.cost = cost
		self.message = message
		self.stacks = stacks
		self.rule = rule
		self.friendly = friendly
		self.target = target
	func go(party_member: PartyMember):
		var battlefield = party_member.battlefield
		var b_lock = await battlefield.lock.shared_lock()
		var t_lock = await target.locks.exclusive_lock() if not friendly else func(): return
		if !target.alive:
			for enemy in battlefield.enemies:
				if enemy.alive:
					target = enemy
		if !target.alive:
			print("No living targets!")
			b_lock.call()
			t_lock.call()
			return
		battlefield.println(message % [party_member.human_name, target.human_name])
		var approach = ActorModeApproach.new(party_member, target)
		await party_member.push_mode(approach)
		var animate = ActorModeAnimate.new("friendly_magic")
		await party_member.push_mode(animate)
		party_member.sp -= cost
		target.add_rule(rule.duplicate())
		await animate.popped
		approach.finished = true
		b_lock.call()
		t_lock.call()
		await approach.popped
