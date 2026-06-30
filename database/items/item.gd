extends Resource
class_name Item

@export var name: StringName = "Thingamawhatsit"
@export var description: StringName = "I found this in my pocket, once. I'm not sure where it came from."
### The battle action for this item, if it's usable in combat.
@export var battle_action: BattleAction
@export var charges: int = 0
@export var registers: Dictionary = {}
@export var tags: Array[String] = []

@export var equip_sizes: Dictionary[String, int] = {}
@export var rules: Array[BattleRule]
### The skill actions this item provides when equipped.
@export var equip_actions: Array[BattleAction]
var path: String = ""
@export var require_actor_tags: Array[String]

enum CanEquip {
	YES,
	NOT_EQUIPMENT,
	MISSING_SLOT,
	SMALL_SLOT,
}
func can_equip(party: PartyComponent) -> CanEquip:
	if equip_sizes.is_empty():
		return CanEquip.NOT_EQUIPMENT
	for slot in equip_sizes.keys():
		if slot not in party.equip_slots:
			return CanEquip.MISSING_SLOT
		var capacity: int = party.equip_slots[slot]
		capacity -= equip_sizes[slot]
		for equip in party.equips:
			capacity -= equip.equip_sizes[slot] if slot in equip.equip_sizes else 0
		if capacity < 0:
			return CanEquip.SMALL_SLOT
	return CanEquip.YES

func capacity_after_equip(party: PartyComponent) -> Dictionary[String, int]:
	var out = {}
	for slot in equip_sizes.keys():
		if slot not in party.equip_slots:
			return {}
		var capacity: int = party.equip_slots[slot]
		capacity -= equip_sizes[slot]
		for equip in party.equips:
			capacity -= equip.equip_sizes[slot] if slot in equip.equip_sizes else 0
		out[slot] = capacity
	return out

func copy() -> Item:
	var new = self.duplicate()
	new.path = self.resource_path
	return new

func fossilize() -> FossilizedItem:
	var item = FossilizedItem.new()
	item.charges = charges
	item.registers = registers.duplicate()
	item.item = path
	return item
