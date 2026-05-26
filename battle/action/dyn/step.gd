@abstract
extends Resource
class_name DynActionStep

@abstract func check(them: Actor) -> bool
@abstract func plan(them: Actor, planner: BattlePlanner, registers: Dictionary) -> bool
func unplan(them: Actor, planner: BattlePlanner, registers: Dictionary):
	@warning_ignore("redundant_await")
	await true
	pass
@abstract func before(them: Actor, battlefield: Battlefield, registers: Dictionary) -> bool
@abstract func after(them: Actor, battlefield: Battlefield, registers: Dictionary)
