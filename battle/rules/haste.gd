extends BattleRule
class_name Haste

@export var amount: int = 1

func _added(fighter: Fighter):
	return player_action(fighter)

func top(fighter: Fighter) -> bool:
	stacks -= 1
	return true

func done(fighter: Fighter, player_victory: bool) -> bool:
	stacks = 0
	return true

func player_action(fighter: Fighter) -> bool:
	if fighter is not PartyMember:
		return true
	(fighter as PartyMember).turns += amount
	return true

func enemy_action(fighter: Fighter) -> bool:
	if fighter is not Enemy:
		return true
	var e: Enemy = fighter as Enemy
	for _action in range(amount):
		if e.planned_pattern != null:
			var board = e.planned_pattern.create(e.battlefield, e)
			#await get_tree().process_frame
			for rule in e.rules:
				if not rule.setup_battle_board(e, board):
					break
			e.battlefield.battle_board.add_pattern(board)
			e.battlefield.players_died.connect(board.done.emit)
		#(fighter as Enemy).pick_pattern()
	return true
