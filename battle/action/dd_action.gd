extends BattleAction
class_name DynAction

@export var name: String
@export var description: String
@export var steps: Array[DynActionStep] = []
@export var tags: Array[String] = []

func _tags() -> Array[String]:
	return tags

func allowed(party_member: Actor, source: Object) -> bool:
	return steps.all(func(p: DynActionStep):
		return p.check(source, party_member))

func plan(battle_planner: BattlePlanner, source: Object) -> BattleActionPlan:
	var registers = {}
	var depth: int = 0
	while depth < len(steps):
		var p = steps[depth]
		var cancel = await p.plan(source, battle_planner.party_member, battle_planner, registers)
		if cancel:
			while bool(depth > 0):
				p = steps[depth]
				await p.unplan(source, battle_planner.party_member, battle_planner, registers)
				depth -= 1
			return null
		depth += 1
	return DynActionPlan.new(registers, steps, source)

class DynActionPlan extends BattleActionPlan:
	var registers: Dictionary
	var steps: Array[DynActionStep]
	var source: Object
	func _init(registers, steps, source):
		self.registers = registers
		self.steps = steps
		self.source = source
	
	func go(party_member: Actor):
		registers["me"] = party_member
		var depth: int = 0
		while bool(depth < len(steps)):
			var p = steps[depth]
			var cancel = await p.before(source, party_member, party_member.battlefield, registers)
			if cancel:
				break
			depth += 1
		if bool(depth >= len(steps)):
			depth -= 1
		while bool(depth >= 0):
			var p = steps[depth]
			await p.after(source, party_member, party_member.battlefield, registers)
			depth -= 1
