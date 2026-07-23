extends BattleAction
class_name BattleActionResurrect

@export var name: String = "Resurrect"
@export var description: String = "Bring an ally from the brink of death."
@export var amount: float = 0.5
@export var cost: int = 50
@export var message: String = "%s brought %s back to life!"
@export var rfl_message: String = "%s???"

func allowed(party_member: Actor, source: Object) -> bool:
	return party_member.sp_component.remaining() >= cost

func plan(battle_planner: BattlePlanner, source: Object) -> BattleActionPlan:
	var target: Actor = await battle_planner.pick_ally(func(p): return not p.alive)
	if target == null:
		battle_planner.show_toplevel()
		return null
	return ResurrectPlan.new(amount, target, cost, message, rfl_message)

class ResurrectPlan extends BattleActionPlan:
	var amount: float
	var target: Actor
	var cost: int
	var message: String
	var rfl_message: String
	func _init(amount, target, cost, message, rfl_message):
		self.amount = amount
		self.target = target
		self.cost = cost
		self.message = message
		self.rfl_message = rfl_message
	func go(party_member: Actor):
		var battlefield = party_member.battlefield
		var b_lock = await battlefield.lock.shared_lock()
		if target.alive:
			for ally in battlefield.players:
				if not ally.alive:
					target = ally
		if target.alive:
			print("No dead targets!")
			b_lock.release()
			return
		battlefield.println(message % [party_member.human_name, target.human_name])
		#var approach = ActorModeApproach.new(party_member, target)
		#var animate = ActorModeAnimate.new("friendly_magic")
		#await party_member.push_mode(animate)
		party_member.sp -= cost
		target.hp_change(HpChange.new(party_member, target, (party_member.hp_component.max - party_member.hp_component.min) * amount))
		target.turns = 0
		#await animate.popped
		#approach.finished = true
		b_lock.release()
		#await approach.popped
