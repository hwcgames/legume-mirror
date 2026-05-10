extends DynActionStep
class_name StepStandardDamage

@export var target_register = "target"
@export var skill_register = "skill"
@export var damage_register = "damage"
@export var crit_chance_mul: float = 1.0
@export var crit_mul := 2.0

func check(them: Actor) -> bool:
	return true
func plan(them: Actor, planner: BattlePlanner, registers: Dictionary) -> bool:
	return false

func before(them: Actor, battlefield: Battlefield, registers: Dictionary) -> bool:
	var target: Actor = registers[target_register]
	var skill: int = registers[skill_register]
	if skill >= 120:
		var crit_chance: float = crit_chance_mul * them.computed_attrs.finesse / (target.computed_attrs.finesse * 10)
		if randf() < crit_chance:
			skill *= crit_mul
	var damage = (them.computed_attrs.strength * skill / 20) - (3 * target.computed_attrs.defense)
	if damage > 0:
		if skill >= 250:
			Storyteller.choose_if_available(["%s finesse hits" % them.name, "%s perfect hits" % them.name, "%s hits" % them.name, "party hit"])
			them.battlefield.println("A masterful attack!")
		elif skill >= 150:
			Storyteller.choose_if_available(["%s perfect hits" % them.name, "%s hits" % them.name, "party hit"])
			them.battlefield.println("A precise attack!")
		else:
			Storyteller.choose_if_available(["%s hits" % them.name, "party hit"])
		them.battlefield.println("%s damage!" % [damage])
		target.take_damage(damage)
	registers[damage_register] = damage
	return false

func after(them: Actor, battlefield: Battlefield, registers: Dictionary):
	pass
