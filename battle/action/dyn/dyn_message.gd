extends DynActionStep
class_name StepMessage

@export var before_message: String
@export var after_message: String

func check(them: Actor) -> bool:
	return true

func plan(them: Actor, planner: BattlePlanner, registers: Dictionary) -> bool:
	return false

func before(them: Actor, battlefield: Battlefield, registers: Dictionary) -> bool:
	if !before_message.is_empty():
		battlefield.println(before_message.format(registers))
	return false

func after(them: Actor, battlefield: Battlefield, registers: Dictionary):
	if !after_message.is_empty():
		battlefield.println(after_message.format(registers))
