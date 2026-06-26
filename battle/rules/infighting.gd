extends BattleRule
class_name RuleInfighting

func top(fighter: Actor) -> bool:
	stacks -= 1
	return true

func done(fighter: Actor, player_victory: bool) -> bool:
	stacks = 0
	return true

func _added(fighter: Actor):
	fighter.battlefield.println("%s infights for %s turns." % [fighter.name, stacks])

func player_action(fighter: Actor) -> bool:
	activated.emit()
	(func():
		fighter.turns = 1
		var self_lock = await fighter.lock.exclusive_lock()
		if not fighter.alive:
			self_lock.call()
			return true
		var targets = fighter \
			.battlefield \
			.players \
			.filter(func(p): return p.alive)
		if targets.is_empty():
			self_lock.call()
			return false
		var target: Actor = targets[randi_range(0, len(targets) - 1)]
		var target_lock = await target.lock.exclusive_lock() if target != fighter else func(): pass
		#var mode: ActorModeApproach
		#if target != fighter:
			#mode = ActorModeApproach.new(fighter, target)
			#await fighter.push_mode(mode)
		fighter.battlefield.println(("%s struck %s in confusion!" % [fighter.human_name, target.human_name]) \
			if target != fighter \
			else ("%s was injured in their confusion!" % fighter.human_name))
		@warning_ignore("integer_division")
		target.hp_change(
			HpChange.new(
				fighter,
				target,
				-((fighter.computed_attrs.strength * 100 / 20) - (3 * target.computed_attrs.defense))
			)
		)
		await fighter.get_tree().create_timer(1.).timeout
		#if target != fighter:
			#mode.finished = true
			#await mode.popped
		target_lock.call()
		self_lock.call()
		fighter.turns = 0
	).call()
	return false

func icon(fighter: Actor) -> Texture2D:
	var sheet: SpriteFrames = preload("uid://dd807705h8yfd")
	return sheet.get_frame_texture("INFIGHT", 0)

func message(fighter: Actor) -> String:
	return "Can't tell friend from foe for {stacks} round(s).".format(self)
