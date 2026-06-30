extends DynActionStep
class_name StepWait

@export var before_wait: float = 0.
@export var after_wait: float = 0.

func check(source: Object, them: Actor) -> bool:
	return true

func plan(source: Object, them: Actor, planner: BattlePlanner, registers: Dictionary) -> bool:
	return false

func before(source: Object, them: Actor, battlefield: Battlefield, registers: Dictionary) -> bool:
	await them.get_tree().create_timer(before_wait).timeout
	return false

func after(source: Object, them: Actor, battlefield: Battlefield, registers: Dictionary):
	await them.get_tree().create_timer(after_wait).timeout
