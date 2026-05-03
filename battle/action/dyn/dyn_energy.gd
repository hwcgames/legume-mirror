extends DynActionStep
class_name StepEnergy

@export var cost: int = 10
@export var soft: bool = false

func check(them: Actor) -> bool:
	if soft:
		return them.sheet.party_component.sp.remaining() >= cost
	return true

func plan(them: Actor, planner: BattlePlanner, registers: Dictionary) -> bool:
	return false

func before(them: Actor, battlefield: Battlefield, registers: Dictionary) -> bool:
	them.sheet.party_component.sp.sp -= cost
	return false

func after(them: Actor, battlefield: Battlefield, registers: Dictionary):
	pass
