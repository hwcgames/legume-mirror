@abstract
extends Resource
class_name DynActionStep

@abstract func check(source: Object, them: Actor) -> bool
@abstract func plan(source: Object, them: Actor, planner: BattlePlanner, registers: Dictionary) -> bool
func unplan(source: Object, them: Actor, planner: BattlePlanner, registers: Dictionary):
	@warning_ignore("redundant_await")
	await true
	pass
@abstract func before(source: Object, them: Actor, battlefield: Battlefield, registers: Dictionary) -> bool
@abstract func after(source: Object, them: Actor, battlefield: Battlefield, registers: Dictionary)
