extends DynActionStep
class_name StepMessage

@export var target_register: String = "target"
@export var before_message: String
@export var after_message: String
@export var before_message_rfl: String
@export var after_message_rfl: String

func check(source: Object, them: Actor) -> bool:
	return true

func plan(source: Object, them: Actor, planner: BattlePlanner, registers: Dictionary) -> bool:
	return false

func before(source: Object, them: Actor, battlefield: Battlefield, registers: Dictionary) -> bool:
	var is_self = target_register in registers and registers[target_register] == them
	var message = (before_message_rfl if is_self else before_message)
	if !message.is_empty():
		battlefield.println(message.format(registers))
	return false

func after(source: Object, them: Actor, battlefield: Battlefield, registers: Dictionary):
	var is_self = target_register in registers and registers[target_register] == them
	var message = (after_message_rfl if is_self else after_message)
	if !message.is_empty():
		battlefield.println(message.format(registers))
