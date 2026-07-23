extends DynActionStep
class_name StepInputLock

@export var register_name: StringName = "input_lock"

func check(source: Object, them: Actor) -> bool:
	return true

func plan(source: Object, them: Actor, planner: BattlePlanner, registers: Dictionary) -> bool:
	return false

func before(source: Object, them: Actor, battlefield: Battlefield, registers: Dictionary) -> bool:
	registers[register_name] = await InputLocks.lock(them.player).shared_lock()
	return false

func after(source: Object, them: Actor, battlefield: Battlefield, registers: Dictionary):
	(registers[register_name] as Locks.LockHandle).release()
