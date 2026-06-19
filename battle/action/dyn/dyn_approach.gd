extends DynActionStep
class_name StepApproach

@export var target_register_name: String = "target"
@export var mode_register_name: String = "approach"
@export var distance: float =3.

func check(source: Object, them: Actor) -> bool:
	return true

func plan(source: Object, them: Actor, planner: BattlePlanner, registers: Dictionary) -> bool:
	return false

func before(source: Object, us: Actor, battlefield: Battlefield, registers: Dictionary) -> bool:
	#var mode = ActorModeApproach.new(them, registers[target_register_name])
	#registers[mode_register_name] = mode
	#await them.push_mode(mode)
	var them: Actor = registers[target_register_name]
	if us == them:
		return false
	await us.snap_to_position(
		them.global_position + them.global_basis * Vector3.FORWARD * distance,
		them.global_rotation.y + PI
	)
	return false

func after(source: Object, us: Actor, battlefield: Battlefield, registers: Dictionary):
	await us.snap_to_landmark(us.home_landmark)
