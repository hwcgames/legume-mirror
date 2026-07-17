extends VBoxContainer
class_name PartyUiCharacterPane

var state: PartyUiState:
	set(new_state):
		state = new_state
		state.changed.connect(update)
		update()

func update():
	var sheet: ActorSheet = state.selected_actor
	%Name.text = sheet.name
	var party: PartyComponent = sheet.party_component
	while %SlotBars.get_child_count() > len(party.visible_slots):
		get_child(0).queue_free()
	for idx in range(len(party.visible_slots)):
		var slot = party.visible_slots[idx]
		var child: PartyUiSlotBar = %SlotBars.get_child(idx) if idx < %SlotBars.get_child_count()\
			else null
		if !is_instance_valid(child):
			child = preload("uid://bu1w5iemvd3fo").instantiate()
			%SlotBars.add_child(child)
		child.slot_name = PartyComponent.equip_names[slot]
		child.max = party.equip_slots[slot]
		var capacity: int = party.capacity()[slot]
		child.current_value = capacity
		var hover_item: Item = state.hover_item
		if state.tab in [PartyUiState.TAB.WEAPON, PartyUiState.TAB.ARMOR]\
			and is_instance_valid(hover_item)\
			and slot in hover_item.equip_sizes:
			var after: int = capacity - hover_item.equip_sizes[slot] if state.action == PartyUiState.ACTION.EQUIP\
				else capacity + hover_item.equip_sizes[slot]
			child.next_value = after
		else:
			child.next_value = capacity
