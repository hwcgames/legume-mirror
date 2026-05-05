extends BattleAction
class_name BattleActionFancyAttack

@export var name = "Tricky Attack"
@export var description = "Carefully pierce an enemy's defenses."
@export var cost: int = 10

func allowed(party_member: Actor) -> bool:
	return party_member.sp_component.remaining() > cost

func plan(planner: BattlePlanner) -> BattleActionPlan:
	var target = await planner.pick_target()
	if target == null:
		planner.show_toplevel()
		return null
	var plan = FancyAttackPlan.new()
	plan.target = target
	plan.cost = cost
	return plan

class FancyAttackPlan extends BattleActionPlan:
	var target: Actor
	var cost: int
	func go(party_member: Actor):
		var battlefield = party_member.battlefield
		var p_lock = await InputLocks.lock(party_member.player).shared_lock()
		var b_lock = await battlefield.lock.shared_lock()
		var e_lock = await target.locks.exclusive_lock()
		#await get_tree().create_timer(1.).timeout
		if !target.alive:
			for enemy in battlefield.valid_enemies:
				if enemy.alive:
					target = enemy
		if !target.alive:
			print("No living targets!")
			p_lock.call()
			b_lock.call()
			e_lock.call()
			return
		battlefield.println("%s strikes %s with tricky technique!" % [party_member.human_name, target.human_name])
		#await party_member.get_tree().create_tween().tween_property(party_member, "global_position", target.global_position - target.right_direction * 2, 0.75).finished
		var approach = ActorModeApproach.new(party_member, target)
		await party_member.push_mode(approach)
		var animate = ActorModeAnimate.new("attack", false)
		await party_member.push_mode(animate)
		var challenge: SkillChallenge = party_member.setup_challenge()
		challenge.frame_count = randi_range(20,40)
		challenge.start()
		var skill = await challenge.result
		#if skill >= 120:
			#var crit_chance: float = party_member.computed_attrs.finesse * 10 / target.computed_attrs.finesse
			#if randf() < crit_chance:
				#skill *= 4
		var damage = (party_member.computed_attrs.finesse*skill/20)-(3*target.computed_attrs.finesse)
		animate.finished = true
		if damage > 0:
			if skill >= 250:
				Storyteller.choose_if_available(["%s finesse hits" % party_member.name, "%s perfect hits" % party_member.name, "%s hits" % party_member.name, "party hit"])
			elif skill >= 150:
				Storyteller.choose_if_available(["%s perfect hits" % party_member.name, "%s hits" % party_member.name, "party hit"])
			else:
				Storyteller.choose_if_available(["%s hits" % party_member.name, "party hit"])
			battlefield.println("%s damage!" % [damage])
			Chatterbox.simple_message(target, "%s!" % [damage])
			target.take_damage(damage)
			var sub_animate = ActorModeAnimate.new("attack_hit", false)
			await party_member.push_mode(sub_animate)
		else:
			Storyteller.choose_if_available(["%s misses" % party_member.name, "party misses"])
			battlefield.println("Swing and a miss...")
		party_member.sp -= cost
		await animate.popped
		approach.finished = true
		await party_member.get_tree().create_timer(0.5).timeout
		p_lock.call()
		b_lock.call()
		e_lock.call()
		await approach.popped
