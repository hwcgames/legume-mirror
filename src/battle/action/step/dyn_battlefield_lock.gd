extends DynActionStep
class_name StepFieldLock

@export var exclusive: bool = false
@export var register_name: StringName = "field_lock"

func check(source: Object, them: Actor) -> bool:
	return true

func plan(source: Object, them: Actor, planner: BattlePlanner, registers: Dictionary) -> bool:
	return false

func before(source: Object, them: Actor, battlefield: Battlefield, registers: Dictionary) -> bool:
	if exclusive:
		registers[register_name] = await battlefield.lock.exclusive_lock()
	else:
		registers[register_name] = await battlefield.lock.shared_lock()
	return false

func after(source: Object, them: Actor, battlefield: Battlefield, registers: Dictionary):
	(registers[register_name] as Callable).call()
