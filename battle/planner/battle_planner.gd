@abstract
extends Control
class_name BattlePlanner

signal choice(plan: BattleActionPlan)

var party_member: PartyMember
var battlefield: Battlefield:
	get:
		return party_member.battlefield

var choosing: bool = false

@abstract func choose() -> BattleActionPlan
@abstract func show_toplevel()
@abstract func pick_target(predicate: Callable = func(e: Enemy): return e.alive) -> Enemy
@abstract func pick_ally(predicate: Callable = func(p: PartyMember): return true) -> PartyMember
@abstract func pick_item(predicate = func(i: Item): return i.battle_action != null) -> Item
