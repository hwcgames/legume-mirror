@abstract
extends BattlePlanner
class_name SubPlanner

signal planned(plan: BattleActionPlan)

var battle_planner: BattlePlanner

func pick_target(predicate: Callable = func(e: Enemy): return e.alive) -> Enemy:
	return await battle_planner.pick_target(predicate)

func pick_ally(predicate: Callable = func(p: PartyMember): return true) -> PartyMember:
	return await battle_planner.pick_ally(predicate)

func pick_item(predicate = func(i: Item): return i.battle_action != null) -> Item:
	return await battle_planner.pick_item(predicate)
