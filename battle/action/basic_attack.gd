extends BattleAction
class_name BattleActionBasicAttack

func plan(planner: BattlePlanner) -> BattleActionPlan:
	var target = await planner.pick_target()
	if target == null:
		planner.show_toplevel()
		return null
	var plan = BasicAttackPlan.new()
	plan.target = target
	return plan

class BasicAttackPlan extends BattleActionPlan:
	var target: Enemy
	func go(party_member: PartyMember):
		var battlefield = party_member.battlefield
		var p_lock = await InputLocks.lock(party_member.player).shared_lock()
		var b_lock = await battlefield.lock.shared_lock()
		var e_lock = await target.locks.exclusive_lock()
		#await get_tree().create_timer(1.).timeout
		if !target.alive:
			for enemy in battlefield.enemies:
				if enemy.alive:
					target = enemy
		if !target.alive:
			print("No living targets!")
			p_lock.call()
			b_lock.call()
			e_lock.call()
			return
		battlefield.println("%s attacks %s!" % [party_member.human_name, target.human_name])
		#await party_member.get_tree().create_tween().tween_property(party_member, "global_position", target.global_position - target.right_direction * 2, 0.75).finished
		var approach = ActorModeApproach.new(party_member, target)
		await party_member.push_mode(approach)
		var animate = ActorModeAnimate.new("attack", false)
		await party_member.push_mode(animate)
		var challenge: SkillChallenge = party_member.setup_challenge()
		challenge.frame_count = randi_range(20,40)
		challenge.start()
		var skill = await challenge.result
		var damage = (party_member.strength*skill/20)-(3*target.defense)
		animate.finished = true
		if damage > 0:
			Storyteller.choose_if_available(["%s hits" % party_member.name, "party hit"])
			battlefield.println("%s damage!" % [damage])
			Chatterbox.simple_message(target, "%s!" % [damage])
			target.take_damage(damage)
			var sub_animate = ActorModeAnimate.new("attack_hit", false)
			await party_member.push_mode(sub_animate)
		else:
			Storyteller.choose_if_available(["%s misses" % party_member.name, "party misses"])
			battlefield.println("Swing and a miss...")
		await animate.popped
		approach.finished = true
		await party_member.get_tree().create_timer(0.5).timeout
		p_lock.call()
		b_lock.call()
		e_lock.call()
		await approach.popped
