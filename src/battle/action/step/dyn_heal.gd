extends DynActionStep
class_name StepHeal

@export var target_register: String = "target"
@export var amount_register: String = "heal_amt"
@export var amount: int = 30

func check(source: Object, them: Actor) -> bool:
	return true

func plan(source: Object, them: Actor, planner: BattlePlanner, registers: Dictionary) -> bool:
	return false

func before(source: Object, them: Actor, battlefield: Battlefield, registers: Dictionary) -> bool:
	var target: Actor = registers[target_register]
	var amt = registers[amount_register] if amount_register in registers else amount
	var old_hp = target.hp
	target.hp_change(HpChange.new(them, target, amt))
	registers[amount_register] = target.hp - old_hp
	return false

func after(source: Object, them: Actor, battlefield: Battlefield, registers: Dictionary):
	pass
