extends DynActionStep
class_name StepResurrect

@export var target_register: String = "target"
@export var health_fraction: float = 0.5
@export var turns: int = 0

func check(source: Object, them: Actor) -> bool:
	return true

func plan(source: Object, them: Actor, planner: BattlePlanner, registers: Dictionary) -> bool:
	return false

func before(source: Object, them: Actor, battlefield: Battlefield, registers: Dictionary) -> bool:
	var target: Actor = registers[target_register]
	target.hp = lerp(target.hp_component.min, target.hp_component.max, health_fraction)
	target.turns = turns
	return false

func after(source: Object, them: Actor, battlefield: Battlefield, registers: Dictionary):
	pass
