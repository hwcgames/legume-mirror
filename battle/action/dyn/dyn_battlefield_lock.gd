extends DynActionStep
class_name StepFieldLock

@export var exclusive: bool = false
@export var register_name: StringName = "field_lock"

func check(them: Actor) -> bool:
	return true

func plan(them: Actor, planner: BattlePlanner, registers: Dictionary) -> bool:
	return false

func before(them: Actor, battlefield: Battlefield, registers: Dictionary) -> bool:
	registers[register_name] = await battlefield.lock.exclusive_lock() if exclusive else await them.lock.shared_lock()
	return false

func after(them: Actor, battlefield: Battlefield, registers: Dictionary):
	(registers[register_name] as Callable).call()
