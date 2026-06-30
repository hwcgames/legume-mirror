@abstract
extends BattlePlanner
class_name SubPlanner

signal planned(plan: BattleActionPlan)

var battle_planner: BattlePlanner

func pick_actor(predicate: Callable = func(a: Actor): return true) -> Actor:
	return await battle_planner.pick_actor(predicate)

func pick_target(predicate: Callable = func(e: Actor): return e.alive) -> Actor:
	return await battle_planner.pick_target(predicate)

func pick_ally(predicate: Callable = func(p: Actor): return true) -> Actor:
	return await battle_planner.pick_ally(predicate)

func pick_item(predicate = func(i: Item): return i.battle_action != null) -> Item:
	return await battle_planner.pick_item(predicate)
