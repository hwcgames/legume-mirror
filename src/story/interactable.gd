extends Area3D
class_name Interactable

@export var choices: Array[String] = []
@export var marker: Node
@export var label: Label
var interactable: bool:
	get:
		for choice_name in choices:
			var matching = Storyteller.find().choices.filter(func(c: InkChoice): return c.GetText().begins_with(choice_name))
			var choice = matching.get(0) if not matching.is_empty() else null
			if choice:
				return true
		return false

func _ready():
	collision_layer = 4
	collision_mask = 4
	marker.hide()

func hover():
	var choice: InkChoice
	for choice_name in choices:
		choice = Storyteller.find().choices.filter(func(c: InkChoice): return c.GetText() == choice_name).get(0)
		if choice:
			break
	if !choice:
		return
	if label:
		label.text = choice.GetText()
	marker.show()

func go():
	Storyteller.find().choose(choices)

func blur():
	marker.hide()
