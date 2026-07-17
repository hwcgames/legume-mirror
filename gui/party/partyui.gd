extends Control
class_name PartyUi

var state: PartyUiState:
	set(new_state):
		state = new_state
		state.changed.connect(update)
		for tgt in [%CharacterPane, %CharacterSelector, %StatsGrid, %TargetPane, %ItemsPane]:
			tgt.state = state
		update()

func update():
	pass
