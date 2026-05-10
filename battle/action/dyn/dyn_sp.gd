extends DynActionStep
class_name StepSP

@export var damage_register_name: String = "damage"
@export var sp_amount: float = 0.2

func check(them: Actor) -> bool:
	return true

func plan(them: Actor, planner: BattlePlanner, registers: Dictionary) -> bool:
	return false

func before(them: Actor, battlefield: Battlefield, registers: Dictionary) -> bool:
	return false

func after(them: Actor, battlefield: Battlefield, registers: Dictionary):
	var damage = registers[damage_register_name]
	them.get_sp(damage * sp_amount)
