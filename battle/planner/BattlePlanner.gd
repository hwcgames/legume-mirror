extends Control
class_name BattlePlanner

var party_member: PartyMember
var battlefield: Battlefield:
	get:
		return party_member.battlefield

signal _choice(Callable)

func choose() -> Callable:
	%ToplevelTab.show()
	var choice = await _choice
	%IdleTab.show()
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
	%IdleTab.show()
	%HPBar.value = float(hp) / float(party_member.max_hp)
	%SPBar.value = float(sp) / float(party_member.max_sp)

@onready var hp: int = party_member.hp
@onready var sp: int = party_member.sp

func _process(delta: float) -> void:
	update_bars()

func update_bars():
	if party_member.hp != hp:
		hp = party_member.hp
		create_tween().tween_property(%HPBar, "value", float(hp) / float(party_member.max_hp), 0.5)
	if party_member.sp != sp:
		sp = party_member.sp
		create_tween().tween_property(%SPBar, "value", float(sp) / float(party_member.max_sp), 0.5)
