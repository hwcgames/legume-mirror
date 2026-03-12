extends BattleRule
class_name Haste

@export var amount: int = 1

func _added(fighter: Fighter):
	return player_action(fighter)

func top(fighter: Fighter) -> bool:
	stacks -= 1
	return true

func player_action(fighter: Fighter) -> bool:
	(fighter as PartyMember).turns += amount
	return true
