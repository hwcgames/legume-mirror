extends DynActionStep
class_name StepEnergy

@export var cost: int = 10
@export var soft: bool = false

func check(source: Object, them: Actor) -> bool:
	if soft:
		return them.sp_component.remaining() >= cost
	return true

func plan(source: Object, them: Actor, planner: BattlePlanner, registers: Dictionary) -> bool:
	return false

func before(source: Object, them: Actor, battlefield: Battlefield, registers: Dictionary) -> bool:
	them.sp_change(SpChange.new(them, them, cost))
	return false

func after(source: Object, them: Actor, battlefield: Battlefield, registers: Dictionary):
	pass
