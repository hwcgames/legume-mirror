extends BattleRule
class_name MagicStrength

func compute_attrs(fighter: Fighter, attrs: CombatAttributes) -> bool:
	attrs.strength += attrs.magic / 2
	return true
