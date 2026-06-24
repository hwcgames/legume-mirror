extends Resource
class_name Item

@export var name: StringName = "Thingamawhatsit"
@export var description: StringName = "I found this in my pocket, once. I'm not sure where it came from."
### The battle action for this item, if it's usable in combat.
@export var battle_action: BattleAction
@export var charges: int = 0
@export var tags: Array[String] = []

@export var equip_sizes: Dictionary[String, int] = {}
@export var rules: Array[BattleRule]

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
