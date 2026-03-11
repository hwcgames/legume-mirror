extends BattleAction
class_name BattleActionHeal

@export var name: String = "Heal"
@export var amount: int = 30
@export var cost: int = 20
@export var message: String = "%s healed %s!"
@export var rfl_message: String = "%s healed!"

func allowed(party_member: PartyMember) -> bool:
	return party_member.sp_component.remaining() >= cost

func plan(battle_planner: BattlePlanner) -> BattleActionPlan:
	var target: PartyMember = await battle_planner.pick_ally()
	if target == null:
		battle_planner.show_toplevel()
		return null
	return HealPlan.new(amount, target, cost, message, rfl_message)

class HealPlan extends BattleActionPlan:
	var amount: int
	var target: Fighter
	var cost: int
	var message: String
	var rfl_message: String
	func _init(amount, target, cost, message, rfl_message):
		self.amount = amount
		self.target = target
		self.cost = cost
		self.message = message
		self.rfl_message = rfl_message
	func go(party_member: PartyMember):
		var battlefield = party_member.battlefield
		var b_lock = await battlefield.lock.shared_lock()
		if !target.alive:
			for ally in battlefield.players:
				if ally.alive:
					target = ally
		if !target.alive:
			print("No living targets!")
			b_lock.call()
			return
		if party_member != target:
			battlefield.println(message % [party_member.human_name, target.human_name])
		else:
			battlefield.println(rfl_message % party_member.human_name)
		var approach = ActorModeApproach.new(party_member, target)
		if target != party_member:
			await party_member.push_mode(approach)
		var animate = ActorModeAnimate.new("friendly_magic")
		await party_member.push_mode(animate)
		party_member.sp -= cost
		target.heal(amount)
		await animate.popped
		approach.finished = true
		b_lock.call()
		if target != party_member:
			await approach.popped
