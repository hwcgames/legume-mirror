extends DynActionStep
class_name StepStandardDamage

@export var target_register = "target"
@export var skill_register = "skill"
@export var default_skill = 0
@export var damage_register = "damage"
@export var crit_chance_mul: float = 1.0
@export var crit_mul := 2.0
@export var our_skill = "strength"
@export var their_skill = "defense"
@export var our_crit = "finesse"
@export var their_crit = "finesse"
@export_flags(
	"ENERGY",
	"MATTER",
	"CONCORD",
	"DISCORD",
	"FORCE",
	"TECH",
	"POINT",
	"WIDE") var alignment: int = 0

func check(source: Object, me: Actor) -> bool:
	return true
func plan(source: Object, me: Actor, planner: BattlePlanner, registers: Dictionary) -> bool:
	return false

func before(source: Object, me: Actor, battlefield: Battlefield, registers: Dictionary) -> bool:
	var target: Actor = registers[target_register]
	var skill: int = registers[skill_register] if skill_register in registers else default_skill
	var critical = false
	if skill >= 120:
		var crit_chance: float = crit_chance_mul * me.computed_attrs[our_crit] / (target.computed_attrs[their_crit] * 10)
		if randf() < crit_chance:
			skill *= crit_mul
			critical = true
	var damage = HpChange.new(
		me,
		target,
		-((me.computed_attrs[our_skill] * skill / 20) - (3 * target.computed_attrs[their_skill])),
		0,
		critical
	)
	damage.registers["skill"] = skill
	if damage.amount > 0:
		if skill >= 250:
			Storyteller.find().choose(["%s finesse hits" % me.name, "%s perfect hits" % me.name, "%s hits" % me.name, "party hit"])
			me.battlefield.println("A masterful attack!")
		elif skill >= 150:
			Storyteller.find().choose(["%s perfect hits" % me.name, "%s hits" % me.name, "party hit"])
			me.battlefield.println("A precise attack!")
		else:
			Storyteller.find().choose(["%s hits" % me.name, "party hit"])
		me.battlefield.println("%s damage!" % [damage])
		target.hp_change(damage)
	registers[damage_register] = -damage.amount
	return false

func after(source: Object, me: Actor, battlefield: Battlefield, registers: Dictionary):
	pass
