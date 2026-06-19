extends CanvasLayer


func _on_line_edit_text_changed(new_text: String) -> void:
	var listeners = Storyteller2.message_listeners(new_text, [])
	for child in %WantedBy.get_children():
		child.queue_free()
	for listener in listeners:
		var l = Label.new()
		l.text = str(listener)
		%WantedBy.add_child(l)
	if listeners.is_empty():
		var l = Label.new()
		l.text = "...Nobody. (This command won't do anything.)"
		%WantedBy.add_child(l)
	pass # Replace with function body.


func _on_line_edit_text_submitted(new_text: String) -> void:
	Storyteller2.send_line(new_text, [])
	for child in %WantedBy.get_children():
		child.queue_free()
	%CmdLine.hide()
	pass # Replace with function body.

func _ready() -> void:
	%CmdLine.hide()
	Storyteller2.new_choice.connect(new_choices)
	Storyteller2.chosen.connect(func(_c):
		for child in %ChoiceButtons.get_children():
			child.queue_free())

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cmdline"):
		if not %CmdLine.visible:
			%CmdLine.show()
			%LineEdit.grab_focus()
			%LineEdit.text = ""
		else:
			%CmdLine.hide()

func _on_line_edit_focus_exited() -> void:
	pass # Replace with function body.

func new_choices(choices: Array[InkChoice]):
	for child in %ChoiceButtons.get_children():
		child.queue_free()
	for index in range(len(choices)):
		var choice = choices[index]
		var b = Button.new()
		b.text = choice.GetText()
		b.pressed.connect(func():
			Storyteller2.choose([choice.GetText()]))
