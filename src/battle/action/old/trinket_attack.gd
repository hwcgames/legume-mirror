extends BattleAction
class_name BattleActionTrinketAttack

@export var trinkets_amount: float = 0.5

func plan(planner: BattlePlanner, source: Object) -> BattleActionPlan:
	var target = await planner.pick_target()
	if target == null:
		planner.show_toplevel()
		return null
	var plan = BasicAttackPlan.new()
	plan.target = target
	plan.trinkets_amount = trinkets_amount
	return plan

class BasicAttackPlan extends BattleActionPlan:
	var target: Actor
	var trinkets_amount: float = 0.5
	func go(party_member: Actor):
		var battlefield = party_member.battlefield
		var p_lock = await InputLocks.lock(party_member.player).shared_lock()
		var b_lock = await battlefield.lock.shared_lock()
		var e_lock = await target.lock.exclusive_lock()
		#await get_tree().create_timer(1.).timeout
		if !target.alive:
			for enemy in battlefield.valid_enemies:
				if enemy.alive:
					target = enemy
		if !target.alive:
			print("No living targets!")
			p_lock.release()
			b_lock.release()
			e_lock.release()
			return
		battlefield.println("%s attacks %s!" % [party_member.human_name, target.human_name])
		#await party_member.get_tree().create_tween().tween_property(party_member, "global_position", target.global_position - target.right_direction * 2, 0.75).finished
		var approach = ActorModeApproach.new(party_member, target)
		await party_member.push_mode(approach)
		var animate = ActorModeAnimate.new("attack", false)
		await party_member.push_mode(animate)
		var challenge: SkillChallenge = party_member.setup_challenge()
		challenge.frame_count = randi_range(20, 40)
		challenge.start()
		var skill = await challenge.result
		if skill >= 120:
			var crit_chance: float = party_member.computed_attrs.finesse / (target.computed_attrs.finesse * 10)
			if randf() < crit_chance:
				skill *= 2
		var damage = (party_member.computed_attrs.strength * skill / 20) - (3 * target.computed_attrs.defense)
		animate.finished = true
		if damage > 0:
			if skill >= 250:
				Storyteller.choose_if_available(["%s finesse hits" % party_member.name, "%s perfect hits" % party_member.name, "%s hits" % party_member.name, "party hit"])
				battlefield.println("A masterful attack!")
			elif skill >= 150:
				Storyteller.choose_if_available(["%s perfect hits" % party_member.name, "%s hits" % party_member.name, "party hit"])
				battlefield.println("A precise attack!")
			else:
				Storyteller.choose_if_available(["%s hits" % party_member.name, "party hit"])
			battlefield.println("%s damage!" % [damage])
			Chatterbox.simple_message(target, "%s!" % [damage])
			target.hp_change(HpChange.new(party_member, target, damage))
			(party_member.sp_component as TrinketsPool).trinkets_on_field += damage * trinkets_amount
			var sub_animate = ActorModeAnimate.new("attack_hit", false)
			await party_member.push_mode(sub_animate)
		else:
			Storyteller.choose_if_available(["%s misses" % party_member.name, "party misses"])
			battlefield.println("Swing and a miss...")
		await animate.popped
		approach.finished = true
		await party_member.get_tree().create_timer(0.5).timeout
		p_lock.release()
		b_lock.release()
		e_lock.release()
		await approach.popped
