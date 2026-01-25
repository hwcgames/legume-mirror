extends CanvasLayer
class_name BattleBoard

@onready var bg := %BattleBackground
@onready var world := %BattleWorld
@onready var field: Battlefield = get_parent()
var souls: Array[Node2D] = []

func appear():
	show()

signal cancel_now

func done():
	hide()

func add_pattern(pattern: Control):
	world.add_child(pattern)
	pass

func add_soul(soul: Node2D):
	souls.push_back(soul)
	%BattleWorld.add_child(soul)
	soul.global_position = %SoulHome.global_position
