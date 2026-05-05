extends BattleRule
class_name Haste

@export var amount: int = 1

func _added(fighter: Actor):
	return player_action(fighter)

func top(fighter: Actor) -> bool:
	stacks -= 1
	return true

func done(fighter: Actor, player_victory: bool) -> bool:
	stacks = 0
	return true

func player_action(fighter: Actor) -> bool:
	if !is_instance_valid(fighter.sheet.party_component):
		return true
	fighter.turns += amount
	return true

func enemy_action(fighter: Actor) -> bool:
	if !is_instance_valid(fighter.sheet.enemy_component):
		return true
	for _action in range(amount):
		if fighter.planned_pattern != null:
			var board = fighter.planned_pattern.create(fighter.battlefield, fighter)
			#await get_tree().process_frame
			for rule in fighter.rules:
				if not rule.setup_battle_board(fighter, board):
					break
			fighter.battlefield.battle_board.add_pattern(board)
			fighter.battlefield.players_died.connect(board.done.emit)
		#(fighter as Enemy).pick_pattern()
	return true
