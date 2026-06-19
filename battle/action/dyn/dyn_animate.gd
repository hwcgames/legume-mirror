extends DynActionStep
class_name StepAnimate

@export var animation_name: String
@export var after_animation_name: String

func check(source: Object, them: Actor) -> bool:
	return true

func plan(source: Object, them: Actor, planner: BattlePlanner, registers: Dictionary) -> bool:
	return false

func before(source: Object, them: Actor, battlefield: Battlefield, registers: Dictionary) -> bool:
	#if register_name in registers and registers[register_name] is ActorModeAnimate and !registers[register_name].finished:
		#registers[register_name].finished = true
		#await registers[register_name].popped
	#registers[register_name] = null
	#var mode = ActorModeAnimate.new(animation_name)
	#registers[register_name] = mode
	#await them.push_mode(mode)
	if animation_name != "":
		them.costume.play(animation_name)
	return false

func after(source: Object, them: Actor, battlefield: Battlefield, registers: Dictionary):
	#if registers[register_name] is ActorModeAnimate and !registers[register_name].finished:
		#registers[register_name].finished = true
		#await registers[register_name].popped
	if after_animation_name != "":
		them.costume.play(after_animation_name)
