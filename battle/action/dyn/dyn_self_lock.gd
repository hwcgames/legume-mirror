extends DynActionStep
class_name StepSelfLock

@export var exclusive: bool = true
@export var register_name: StringName = "self_lock"

func check(them: Actor) -> bool:
	return true

func plan(them: Actor, planner: BattlePlanner, registers: Dictionary) -> bool:
	return false

func before(them: Actor, battlefield: Battlefield, registers: Dictionary) -> bool:
	registers[register_name] = await them.lock.exclusive_lock() if exclusive else await them.lock.shared_lock()
	return false

func after(them: Actor, battlefield: Battlefield, registers: Dictionary):
	(registers[register_name] as Callable).call()
