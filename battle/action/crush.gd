extends BattleAction
class_name BattleActionCrush

@export var name = "Crush"
@export var description = "Break the enemy's defenses"
@export var cost: int = 10

func allowed(party_member: Actor, source: Object) -> bool:
	return party_member.sp_component.remaining() > cost

func plan(planner: BattlePlanner, source: Object) -> BattleActionPlan:
	var target = await planner.pick_target()
	if target == null:
		planner.show_toplevel()
		return null
	var plan = CrushPlan.new()
	plan.target = target
	plan.cost = cost
	return plan

class CrushPlan extends BattleActionPlan:
	var target: Actor
	var cost: int
	func go(party_member: Actor):
		var battlefield = party_member.battlefield
		var b_lock = await battlefield.lock.shared_lock()
		var e_lock = await target.lock.exclusive_lock()
		#await get_tree().create_timer(1.).timeout
		if !target.alive:
			for enemy in battlefield.valid_enemies:
				if enemy.alive:
					target = enemy
		if !target.alive:
			print("No living targets!")
			b_lock.call()
			e_lock.call()
			return
		battlefield.println("%s wallops %s!" % [party_member.human_name, target.human_name])
		#await party_member.get_tree().create_tween().tween_property(party_member, "global_position", target.global_position - target.right_direction * 2, 0.75).finished
		#var approach = ActorModeApproach.new(party_member, target)
		#await party_member.push_mode(approach)
		#var animate = ActorModeAnimate.new("attack")
		#await party_member.push_mode(animate)
		#var challenge: SkillChallenge = party_member.setup_challenge()
		#challenge.frame_count = randi_range(20,40)
		#challenge.start()
		var skill = 100
		#if skill >= 120:
			#var crit_chance: float = party_member.computed_attrs.finesse * 10 / target.computed_attrs.finesse
			#if randf() < crit_chance:
				#skill *= 4
		var damage = (party_member.computed_attrs.strength * skill / 20) - (2 * target.computed_attrs.defense)
		#animate.finished = true
		party_member.sp -= cost
		if damage > 0:
			Storyteller.choose_if_available(["%s crushes" % party_member.name, "%s hits" % party_member.name, "party hit"])
			battlefield.println("%s damage!" % [damage])
			Chatterbox.simple_message(target, "%s!" % [damage])
			target.take_damage(damage)
			#var sub_animate = ActorModeAnimate.new("attack_hit")
			#await party_member.push_mode(sub_animate)
			var crush := Crush.new()
			crush.stacks = 3
			target.add_rule(crush)
		else:
			Storyteller.choose_if_available(["%s misses" % party_member.name, "party misses"])
			battlefield.println("Swing and a miss...")
		#await animate.popped
		#approach.finished = true
		await party_member.get_tree().create_timer(0.5).timeout
		b_lock.call()
		e_lock.call()
		#await approach.popped
