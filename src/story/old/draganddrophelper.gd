extends Control

var dragged: bool = false

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index != MouseButton.MOUSE_BUTTON_LEFT:
			return
		dragged = event.pressed
	if event is InputEventMouseMotion and dragged:
		global_position = event.global_position
