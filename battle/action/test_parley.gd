extends ParleyAction
class_name ParleyActionTest

func label() -> String:
	match enemy.state:
		0:
			return "Pick one"
		1, 2:
			return "No, the other one"
		_:
			return "???"

func allowed(party_member: PartyMember) -> bool:
	return true

func display(party_member: PartyMember) -> bool:
	return true

func plan(battle_planner: BattlePlanner) -> ActionPlanParleyTest:
	var plan = ActionPlanParleyTest.new()
	plan.target = enemy
	return plan

class ActionPlanParleyTest extends BattleActionPlan:
	var target: Enemy
	func go(party_member: PartyMember):
		var battlefield = party_member.battlefield
		var b_lock = await battlefield.lock.shared_lock()
		var e_lock = await target.locks.exclusive_lock()
		#await get_tree().create_timer(1.).timeout
		if !target.alive:
			for enemy in battlefield.enemies:
				if enemy.alive:
					target = enemy
		if !target.alive:
			print("No living targets!")
			b_lock.call()
			e_lock.call()
			return
		battlefield.println("%s advises %s..." % [party_member.human_name, target.human_name])
		var approach = ActorModeApproach.new(party_member, target)
		await party_member.push_mode(approach)
		var animate = ActorModeAnimate.new("attack_magic")
		await party_member.push_mode(animate)
		match target.state:
			0:
				battlefield.println("\"Make up your mind!\"")
				Chatterbox.simple_message(party_member, "Make up your mind!")
				target.state = randi_range(1, 2)
			1:
				Chatterbox.simple_message(party_member, "Change it up!")
				target.state = 2
			2:
				Chatterbox.simple_message(party_member, "Change it up!")
				target.state = 1
		await target.pick_pattern()
		await target.show_telegraph()
		await animate.popped
		approach.finished = true
		await party_member.get_tree().create_timer(0.5).timeout
		b_lock.call()
		e_lock.call()
		await approach.popped
