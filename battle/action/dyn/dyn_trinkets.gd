extends DynActionStep
class_name StepTrinkets

@export var damage_register_name: String = "damage"
@export var trinkets_amount: float = 1.0

func check(them: Actor) -> bool:
	return true

func plan(them: Actor, planner: BattlePlanner, registers: Dictionary) -> bool:
	return false

func before(them: Actor, battlefield: Battlefield, registers: Dictionary) -> bool:
	return false

func after(them: Actor, battlefield: Battlefield, registers: Dictionary):
	var damage = registers[damage_register_name]
	for rule in them.sheet.rules:
		print(rule)
		print(rule is TrinketsRule)
		if rule is TrinketsRule:
			rule.activated.emit()
	(them.sheet.party_component.sp as TrinketsPool).trinkets_on_field += damage * trinkets_amount
	print((them.sheet.party_component.sp as TrinketsPool).trinkets_on_field)
