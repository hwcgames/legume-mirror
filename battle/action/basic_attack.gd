extends BattleAction
class_name BattleActionBasicAttack

@export var name: String = "Basic Attack"
@export var description: String = "Basic Attack"
@export var damage_mul = 1.0
@export var crit_chance_mul = 1.0
@export var crit_mul = 2.0

func plan(planner: BattlePlanner, source: Object) -> BattleActionPlan:
	var target = await planner.pick_target()
	if target == null:
		planner.show_toplevel()
		return null
	var plan = BasicAttackPlan.new()
	plan.target = target
	plan.crit_chance_mul = crit_chance_mul
	plan.crit_mul = crit_mul
	return plan

class BasicAttackPlan extends BattleActionPlan:
	var target: Actor
	var crit_chance_mul = 1.0
	var crit_mul = 2.0
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
			p_lock.call()
			b_lock.call()
			e_lock.call()
			return
		battlefield.println("%s attacks %s!" % [party_member.human_name, target.human_name])
		#await party_member.get_tree().create_tween().tween_property(party_member, "global_position", target.global_position - target.right_direction * 2, 0.75).finished
		var challenge: SkillChallenge = party_member.setup_challenge()
		challenge.frame_count = randi_range(20, 40)
		challenge.start()
		var skill = await challenge.result
		if skill >= 120:
			var crit_chance: float = crit_chance_mul * party_member.computed_attrs.finesse / (target.computed_attrs.finesse * 10)
			if randf() < crit_chance:
				skill *= crit_mul
		var damage = (party_member.computed_attrs.strength * skill / 20) - (3 * target.computed_attrs.defense)
		if damage > 0:
			if skill >= 250:
				Storyteller2.choose(["%s finesse hits" % party_member.name, "%s perfect hits" % party_member.name, "%s hits" % party_member.name, "party hit"])
				battlefield.println("A masterful attack!")
			elif skill >= 150:
				Storyteller2.choose(["%s perfect hits" % party_member.name, "%s hits" % party_member.name, "party hit"])
				battlefield.println("A precise attack!")
			else:
				Storyteller2.choose(["%s hits" % party_member.name, "party hit"])
			battlefield.println("%s damage!" % [damage])
			#Chatterbox.simple_message(target, "%s!" % [damage])
			target.take_damage(damage)
		else:
			Storyteller2.choose(["%s misses" % party_member.name, "party misses"])
			battlefield.println("Swing and a miss...")
		await party_member.get_tree().create_timer(0.5).timeout
		p_lock.call()
		b_lock.call()
		e_lock.call()
