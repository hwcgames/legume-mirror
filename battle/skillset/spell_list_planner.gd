extends SubPlanner
class_name SpellListPlanner

var spells: Array[BattleAction] = []

func show_toplevel():
	return

func _ready():
	for child in get_children():
		child.queue_free()
	var back := Button.new()
	back.text = "back"
	back.pressed.connect(choice.emit.bind(null))
	add_child(back)
	for spell in spells:
		var button := Button.new()
		button.text = spell.name if "name" in spell else spell.get_script().get_global_name()
		button.pressed.connect(func():
			var plan = await spell.plan(self)
			choice.emit(plan))
		add_child(button)

func choose() -> BattleActionPlan:
	return await choice
