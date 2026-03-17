extends BattleRule
class_name RuleInfighting

func top(fighter: Fighter) -> bool:
	stacks -= 1
	return true

func done(fighter: Fighter, player_victory: bool) -> bool:
	stacks = 0
	return true

func _added(fighter: Fighter):
	fighter.battlefield.println("%s infights for %s turns." % [fighter.name, stacks])

func player_action(fighter: Fighter) -> bool:
	(func():
		fighter.turns = 1
		var self_lock = await fighter.lock.exclusive_lock()
		if not fighter.alive:
			self_lock.call()
			return true
		var targets = fighter\
			.battlefield\
			.players\
			.filter(func(p): return p.alive)
		if targets.is_empty():
			self_lock.call()
			return false
		var target: PartyMember = targets[randi_range(0, len(targets) - 1)]
		var target_lock = await target.lock.exclusive_lock() if target != fighter else func(): pass
		var mode: ActorModeApproach
		if target != fighter:
			mode = ActorModeApproach.new(fighter, target)
			await fighter.push_mode(mode)
		fighter.battlefield.println(("%s struck %s in confusion!" % [fighter.human_name, target.human_name])\
			if target != fighter\
			else ("%s was injured in their confusion!" % fighter.human_name))
		@warning_ignore("integer_division")
		target.take_damage((fighter.computed_attrs.strength*100/20)-(3*target.computed_attrs.defense))
		await fighter.get_tree().create_timer(1.).timeout
		if target != fighter:
			mode.finished = true
			await mode.popped
		target_lock.call()
		self_lock.call()
		fighter.turns = 0
	).call()
	return false
