extends BattleAction
class_name BattleActionExtraTurn

@export var amt: int = 1

func plan(planner: BattlePlanner) -> BattleActionPlan:
	var ally = await planner.pick_ally()
	if ally == null:
		planner.show_toplevel()
		return null
	var plan = ExtraTurnPlan.new()
	plan.ally = ally
	plan.amt = amt
	plan.item = item
	return plan

class ExtraTurnPlan extends BattleActionPlan:
	var ally: PartyMember
	var amt: int
	var item: Item
	func go(party_member: PartyMember):
		var battlefield = party_member.battlefield
		var t_lock = await ally.lock.exclusive_lock()
		var b_lock = await battlefield.lock.shared_lock()
		if not ally.alive:
			for p in battlefield.players:
				if p.alive:
					ally = p
		if not ally.alive:
			print("No living targets!")
			b_lock.call()
			t_lock.call()
			return
		if item != null:
			Inventory.items.remove_at(Inventory.items.find(self))
		var orig_pos = party_member.global_position
		await party_member.create_tween().tween_property(party_member, "global_position", ally.global_position + Vector3.RIGHT * 2, 0.75).finished
		battlefield.println("%s gives %s a boost!" % [party_member.name, ally.name])
		ally.turns += amt
		await party_member.get_tree().create_timer(1.).timeout
		var tw = party_member.get_tree().create_tween().tween_property(party_member, "global_position", orig_pos, 0.75)
		await party_member.get_tree().create_timer(0.5).timeout
		b_lock.call()
		t_lock.call()
		await tw.finished
