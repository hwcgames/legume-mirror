extends BattleRule
class_name Enfeeble

@export var amount: int = 3

func top(fighter: Fighter) -> bool:
	stacks -= 1
	return true

func compute_attrs(fighter: Fighter, attrs: CombatAttributes) -> bool:
	attrs.strength -= amount
	return true
