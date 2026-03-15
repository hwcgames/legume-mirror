extends BattleRule
class_name MagicStrength

@export var decay: bool = false
@export var effect_mul: float = 0.5

func top(fighter: Fighter) -> bool:
	if decay:
		stacks -= 1
	return true

func compute_attrs(fighter: Fighter, attrs: CombatAttributes) -> bool:
	attrs.strength += attrs.magic * effect_mul
	return true
