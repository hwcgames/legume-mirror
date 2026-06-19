extends Control
class_name Picker

func new_choice(choices: Array[InkChoice]):
	var buttons = {
		"up": %Up,
		"down": %Down,
		"left": %Left,
		"right": %Right,
	}
	var b_choices = {}
	for choice in choices:
		for tag in choice.GetTags():
			if tag.begins_with("c:"):
				b_choices[(tag as String).trim_prefix("c:")] = choice
	for key in buttons.keys():
		var button: Button = buttons[key]
		if key not in b_choices:
			button.hide()
			continue
		var choice: InkChoice = b_choices[key]
		button.text = choice.GetText()
		button.pressed.connect(func():
			Storyteller2.choose([choice.GetText()])
			queue_free())
