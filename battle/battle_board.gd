extends CanvasLayer
class_name BattleBoard

@onready var bg := %BattleBackground
@onready var world := %BattleWorld
@onready var field: Battlefield = get_parent()

func appear():
	show()

func done():
	hide()

func add_pattern(pattern: Control):
	world.add_child(pattern)
	pass
