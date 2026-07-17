extends CenterContainer
class_name PartyUiStatsGrid

var state: PartyUiState:
	set(new_state):
		state = new_state
		state.changed.connect(update)
		update()

func update():
	if !is_instance_valid(state.selected_actor):
		%STR.text = "???"
		%DEF.text = "???"
		%MAG.text = "???"
		%FIN.text = "???"
		return
	var stats = state.selected_actor.compute_attrs()
	var spec_stats = stats.duplicate()
	if is_instance_valid(state.hover_item):
		var spec_actor: ActorSheet = state.selected_actor.copy()
		match state.action:
			PartyUiState.ACTION.EQUIP:
				spec_actor.party_component.equips.push_back(state.hover_item)
			PartyUiState.ACTION.UNEQUIP:
				var idx = spec_actor.party_component.equips.find(state.hover_item)
				if idx != -1:
					spec_actor.party_component.equips.remove_at(idx)
		spec_stats = spec_actor.compute_attrs()
	for pair in [
		["strength", %STR],
		["defense", %DEF],
		["magic", %MAG],
		["finesse", %FIN],
	]:
		var attr = stats[pair[0]]
		var spec_attr = spec_stats[pair[0]]
		if attr == spec_attr:
			pair[1].text = str(attr)
		else:
			pair[1].text = "%s→%s" % [str(attr), str(spec_attr)]
