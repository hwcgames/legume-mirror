extends BattleRule
class_name Overheat

@export var strength: Curve
@export var defense: Curve
@export var dot: Curve
@export var damage_as_heat: float
@export var sp_gain_mul: float = 0.5

func compute_attrs(fighter: Actor, attrs: CombatAttributes) -> bool:
	var sp = fighter.sheet.party_component.sp as EnergyDebt
	var debt = float(sp.debt) / float(sp.max_debt)
	attrs.strength *= strength.sample(debt)
	attrs.defense *= defense.sample(debt)
	return true

func top(fighter: Actor) -> bool:
	var sp = fighter.sheet.party_component.sp as EnergyDebt
	var debt = float(sp.debt) / float(sp.max_debt)
	fighter.take_damage(dot.sample(debt))
	return true

func take_damage(fighter: Actor, amount: int) -> bool:
	fighter.use_sp(amount * damage_as_heat)
	return true

func get_sp(fighter: Actor, amount: int) -> bool:
	fighter.use_sp(amount * (1. - sp_gain_mul))
	return true
