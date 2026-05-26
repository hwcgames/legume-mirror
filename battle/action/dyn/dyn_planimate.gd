extends DynActionStep
class_name StepPlanimate

@export var animation_name: String
@export var register_name: String = "planimation"

func check(them: Actor) -> bool:
	return true

func plan(them: Actor, planner: BattlePlanner, registers: Dictionary) -> bool:
	registers[register_name] = them.costume.player.current_animation
	them.costume.play(animation_name)
	#if registers[register_name] is ActorModeAnimate and !registers[register_name].finished:
		#registers[register_name].finished = true
		#await registers[register_name].popped
	#registers[register_name] = null
	#if animation_name != '':
		#var mode = ActorModeAnimate.new(animation_name)
		#registers[register_name] = mode
		#await them.push_mode(mode)
	return false

func unplan(them: Actor, planner: BattlePlanner, registers: Dictionary):
	them.costume.play(registers[animation_name])

func before(them: Actor, battlefield: Battlefield, registers: Dictionary) -> bool:
	return false

func after(them: Actor, battlefield: Battlefield, registers: Dictionary):
	pass
