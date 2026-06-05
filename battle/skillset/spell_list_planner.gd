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
		button.tooltip_text = spell.description if "description" in spell else "Its effect is a mystery."
		button.pressed.connect(func():
			var plan = await spell.plan(self)
			choice.emit(plan))
		button.disabled = not spell.allowed(party_member)
		add_child(button)
	(get_child(1 if get_child_count() > 1 else 0) as Control).grab_focus()

func choose() -> BattleActionPlan:
	return await choice
