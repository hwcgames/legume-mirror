extends Button

@export var starting_address: LineEdit

func _pressed() -> void:
	var main_game: Node = preload("uid://h5ppkq5boigl").instantiate()
	var st: Storyteller = main_game.get_node("Storyteller")
	st.story = preload("uid://0rfm1f33w0pv")
	st.story.ResetState()
	if not starting_address.text.is_empty():
		st.story.ChoosePathString(starting_address.text)
	var tree := get_tree()
	if PlayerManager.get_player_count() == 0:
		PlayerManager.join(-1)
	tree.change_scene_to_node(main_game)
	st.busy = false
