extends BattleAction
class_name BattleActionExtraTurn

@export var amt: int = 1

func plan(planner: BattlePlanner, source: Object) -> BattleActionPlan:
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
			Inventory.find().items.remove_at(Inventory.find().items.find(self))
		var approach = ActorModeApproach.new(party_member, ally)
		await party_member.push_mode(approach)
		var animate = ActorModeAnimate.new("friendly_magic")
		await party_member.push_mode(animate)
		battlefield.println("%s gives %s a boost!" % [party_member.human_name, ally.human_name])
		Chatterbox.simple_message(party_member, "Don't give up now!")
		ally.turns += amt
		await animate.popped
		#await party_member.get_tree().create_timer(1.).timeout
		approach.finished = true
		b_lock.call()
		t_lock.call()
		await approach.popped
