extends DynActionStep
class_name StepApproach

@export var target_register_name: String = "target"
@export var mode_register_name: String = "approach"

func check(them: Actor) -> bool:
	return true

func plan(them: Actor, planner: BattlePlanner, registers: Dictionary) -> bool:
	return false

func before(them: Actor, battlefield: Battlefield, registers: Dictionary) -> bool:
	var mode = ActorModeApproach.new(them, Actor.find(registers[target_register_name]))
	registers[mode_register_name] = mode
	await them.push_mode(mode)
	return false

func after(them: Actor, battlefield: Battlefield, registers: Dictionary):
	(registers[mode_register_name] as ActorMode).finished = true
