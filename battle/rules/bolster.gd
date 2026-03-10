extends BattleRule
class_name Bolster

@export var amount: int = 3

func top(fighter: Fighter) -> bool:
	stacks -= 1
	return true

func compute_attrs(fighter: Fighter, attrs: CombatAttributes) -> bool:
	attrs.defense += amount
	return true
