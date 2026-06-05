extends BattleRule
class_name MagicStrength

@export var decay: bool = false
@export var effect_mul: float = 0.5

func top(fighter: Actor) -> bool:
	if decay:
		stacks -= 1
	return true

func compute_attrs(fighter: Actor, attrs: CombatAttributes) -> bool:
	attrs.strength += attrs.magic * effect_mul
	return true

func message(fighter: Actor) -> String:
	if decay:
		return "Strength increased by {effect_mul}*Magic ({magic} Magic, to {strength} Strength) for {stacks} round(s).".format(self ).format(fighter.computed_attrs)
	else:
		return "Strength increased by {effect_mul}*Magic ({magic} Magic, to {strength} Strength) by a mysterious power.".format(self ).format(fighter.computed_attrs)
