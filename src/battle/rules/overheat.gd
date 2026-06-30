extends BattleRule
class_name Overheat

@export var strength: Curve
@export var defense: Curve
@export var dot: Curve
@export var damage_as_heat: float
#@export var sp_gain_mul: float = 0.5

func compute_attrs(fighter: Actor, attrs: CombatAttributes) -> bool:
	var sp = fighter.sheet.party_component.sp as EnergyDebt
	var debt = float(sp.debt) / float(sp.max_debt)
	attrs.strength *= strength.sample(debt)
	attrs.defense *= defense.sample(debt)
	return true

func top(fighter: Actor) -> bool:
	var sp = fighter.sheet.party_component.sp as EnergyDebt
	var debt = float(sp.debt) / float(sp.max_debt)
	var damage = dot.sample(debt)
	if damage > 0:
		activated.emit()
		fighter.hp_change(HpChange.new(fighter, fighter, damage))
	return true

func hp_change(fighter: Actor, instance: HpChange) -> bool:
	if instance.amount >= 0:
		return true
	activated.emit()
	fighter.sp_change(SpChange.new(fighter, fighter, instance.amount * damage_as_heat))
	return true

func icon(fighter: Actor) -> Texture2D:
	var sheet: SpriteFrames = preload("uid://dd807705h8yfd")
	return sheet.get_frame_texture("OVERHEAT", 0)

func message(fighter: Actor) -> String:
	var sp = fighter.sheet.party_component.sp as EnergyDebt
	var debt = float(sp.debt) / float(sp.max_debt)
	return "Energy is governed by \"heat\":
- Strength adjusted by {str_mul}x (to {strength})
- Defense adjusted by {def_mul}x (to {defense})
- Damage over time (currently {dot}/round)".format({
	"str_mul": "%.02f" % strength.sample(debt),
	"def_mul": "%.02f" % defense.sample(debt),
	"dot": "%.02f" % dot.sample(debt),
}).format(fighter.computed_attrs)
