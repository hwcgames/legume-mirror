extends CanvasLayer
class_name BattlePlanner

@onready var party_member: PartyMember = get_parent()
var battlefield: Battlefield:
	get:
		return party_member.battlefield

signal _choice(Callable)

func choose() -> Callable:
	%ToplevelTab.show()
	show()
	var choice = await _choice
	hide()
	return choice

signal _chose_target(Enemy)

func pick_target() -> Enemy:
	var prev_tab = %TabContainer.current_tab
	var selector = %EnemyMenuParent
	for child in selector.get_children():
		child.free()
	var enemies = battlefield.enemies.filter(func(e: Enemy): return e.alive)
	var back := Button.new()
	back.text = "back"
	back.pressed.connect(func(): _chose_target.emit(null))
	selector.add_child(back)
	for enemy in enemies:
		var button := Button.new()
		button.text = enemy.name
		button.pressed.connect(func(): _chose_target.emit(enemy))
		selector.add_child(button)
	%TargetSelectTab.show()
	var target = await _chose_target
	if target == null:
		%TabContainer.current_tab = prev_tab
	return target

func _ready():
	hide()
