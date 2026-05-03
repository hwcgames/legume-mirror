extends DynActionStep
class_name StepTarget

enum LOCK_TYPE {
	NONE,
	SHARED,
	EXCLUSIVE
}

@export var predicates: Array[ActorPredicate] = []
@export var lock_type: LOCK_TYPE = LOCK_TYPE.NONE
@export var register_name: StringName = "target"
@export var lock_register_name: StringName = "target_lock"

func check(them: Actor) -> bool:
	return true

func plan(them: Actor, planner: BattlePlanner, registers: Dictionary) -> bool:
	var target = await planner.pick_actor(func(a: Actor):
		predicates.all(func(p: ActorPredicate): return p.test(a, planner.battlefield)))
	if target == null:
		return true
	return false

func lock_for(target: Actor) -> Callable:
	match lock_type:
		LOCK_TYPE.SHARED:
			return await target.lock.shared_lock()
		LOCK_TYPE.EXCLUSIVE:
			return await target.lock.exclusive_lock()
	return func(): pass

func before(them: Actor, battlefield: Battlefield, registers: Dictionary) -> bool:
	var target: Actor = registers[register_name]
	var lock = await lock_for(target)
	# Do we have a lock for an acceptable target?
	while !predicates.all(func(p): p.test(target)):
		var other_targets = (battlefield.players as Array[Actor]) + (battlefield.enemies as Array[Actor]).filter(func(a: Actor):
			predicates.all(func(p: ActorPredicate): return p.test(a, battlefield)))
		if other_targets.is_empty():
			battlefield.println("No valid targets!")
			return true
		target = other_targets[0]
		lock.call()
		lock = await lock_for(target)
	# Now we definitely have a lock on an acceptable target.
	# Save it for later...
	registers[register_name] = target
	registers[lock_register_name] = lock
	return false

func after(them: Actor, battlefield: Battlefield, registers: Dictionary):
	(registers[lock_register_name] as Callable).call()
	pass
