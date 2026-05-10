extends BattleAction
class_name DynAction

@export var steps: Array[DynActionStep] = []

func allowed(party_member: Actor) -> bool:
	return steps.all(func(p: DynActionStep):
		return p.check(party_member))

func plan(battle_planner: BattlePlanner) -> BattleActionPlan:
	var registers = {}
	for p in steps:
		var cancel = await p.plan(battle_planner.party_member, battle_planner, registers)
		if cancel:
			return null
	return DynActionPlan.new(registers, steps)

class DynActionPlan extends BattleActionPlan:
	var registers: Dictionary
	var steps: Array[DynActionStep]
	func _init(registers, steps):
		self.registers = registers
		self.steps = steps
	
	func go(party_member: Actor):
		var depth: int = 0
		while depth < len(steps):
			var p = steps[depth]
			var cancel = await p.before(party_member, party_member.battlefield, registers)
			if cancel:
				break
			depth += 1
		if depth >= len(steps):
			depth -= 1
		while depth >= 0:
			var p = steps[depth]
			await p.after(party_member, party_member.battlefield, registers)
			depth -= 1
