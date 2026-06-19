extends DynActionStep
class_name StepApplyRule

@export var target_register: String = "target"
@export var message: String
@export var rfl_message: String
@export var rules: Array[BattleRule]
@export var self_rules: Array[BattleRule]

func check(source: Object, them: Actor) -> bool:
	return true

func plan(source: Object, them: Actor, planner: BattlePlanner, registers: Dictionary) -> bool:
	return false

func before(source: Object, them: Actor, battlefield: Battlefield, registers: Dictionary) -> bool:
	var registers_clone = registers.duplicate()
	registers_clone["me"] = them
	if target_register in registers:
		var target = registers[target_register]
		for rule in rules:
			target.add_rule(rule.duplicate())
		battlefield.println((message if target != them else rfl_message).format(registers_clone))
	else:
		battlefield.println(message.format(registers_clone))
	for rule in self_rules:
		them.add_rule(rule.duplicate())
	return false

func after(source: Object, them: Actor, battlefield: Battlefield, registers: Dictionary):
	pass
