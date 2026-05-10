extends DynActionStep
class_name StepAnimate

@export var animation_name: String
@export var register_name: String = "animation"

func check(them: Actor) -> bool:
	return true

func plan(them: Actor, planner: BattlePlanner, registers: Dictionary) -> bool:
	return false

func before(them: Actor, battlefield: Battlefield, registers: Dictionary) -> bool:
	if register_name in registers and registers[register_name] is ActorModeAnimate and !registers[register_name].finished:
		registers[register_name].finished = true
		await registers[register_name].popped
	registers[register_name] = null
	var mode = ActorModeAnimate.new(animation_name)
	registers[register_name] = mode
	await them.push_mode(mode)
	return false

func after(them: Actor, battlefield: Battlefield, registers: Dictionary):
	if registers[register_name] is ActorModeAnimate and !registers[register_name].finished:
		registers[register_name].finished = true
		await registers[register_name].popped
