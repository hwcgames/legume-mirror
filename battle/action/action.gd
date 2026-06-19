@abstract
extends Resource
class_name BattleAction

## If this action is run from an item, it will be referenced here.
#var item: Item

func allowed(party_member: Actor, source: Object) -> bool:
	return true

func plan(battle_planner: BattlePlanner, source: Object) -> BattleActionPlan:
	await battle_planner.get_tree().process_frame
	return null

func copy():
	return self
