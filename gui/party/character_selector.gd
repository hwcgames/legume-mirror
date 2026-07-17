extends HBoxContainer
class_name PartyMenuCharacterSelector

var state: PartyUiState:
	set(new_state):
		state = new_state
		state.changed.connect(update)
		update()

func update():
	var character_button = preload("uid://b08awxoknn3ag")
	for idx in range(len(state.party)):
		var sheet = state.party[idx]
		var child: PartyUiCharacterButton = get_child(idx) if idx < get_child_count() else null
		if !is_instance_valid(child):
			child = character_button.instantiate()
			child.pressed.connect(func(sheet: ActorSheet): state.selected_actor = sheet)
			add_child(child)
		child.sheet = sheet
