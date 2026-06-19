extends DynActionStep
class_name StepCharges

@export var charges: int = 1
@export var destroy: bool = true
@export var replace: Item = null
@export var soft: bool = true

func check(source: Object, them: Actor) -> bool:
	if not (source is Item):
		return true
	var item: = source as Item
	if (not soft) and item.charges < charges:
		return false
	return true

func plan(source: Object, them: Actor, planner: BattlePlanner, registers: Dictionary) -> bool:
	return false

func before(source: Object, them: Actor, battlefield: Battlefield, registers: Dictionary) -> bool:
	if not (source is Item):
		return true
	var item: = source as Item
	item.charges = max(item.charges - charges, 0)
	return false

func after(source: Object, them: Actor, battlefield: Battlefield, registers: Dictionary):
	if not (source is Item):
		return true
	var item: = source as Item
	if item.charges == 0 and destroy:
		if is_instance_valid(replace):
			Inventory.items[Inventory.items.find(item)] = replace.duplicate()
		else:
			Inventory.items.remove_at(Inventory.items.find(item))
