extends HBoxContainer
class_name PartyUiSlotBar

var slot_name: String:
	set(new_name):
		slot_name = new_name
		update()
var max: int = 1:
	set(new_max):
		max = new_max
		update()
var current_value: int = 0:
	set(new_value):
		current_value = new_value
		update()
var next_value: int = 0:
	set(new_value):
		next_value = new_value
		update()

func update():
	%Label.text = slot_name
	%Bar.custom_maximum_size.x = 4 * max
	%Bar.custom_minimum_size.x = 2 * max
	var high_style: StyleBoxFlat = %High.get_theme_stylebox("fill").duplicate()
	high_style.bg_color = Color.GREEN if next_value > current_value else Color.RED
	%High.add_theme_stylebox_override("fill", high_style)
	%High.max_value = max
	%High.value = max(current_value, next_value)
	%Low.max_value = max
	%Low.value = min(current_value, next_value)
	%Label.modulate = Color.WHITE if next_value >= 0 else Color.ORANGE_RED
