extends Control
class_name BattlePlanner

var party_member: PartyMember
var battlefield: Battlefield:
	get:
		return party_member.battlefield

signal choice(plan: BattleActionPlan)

func choose() -> BattleActionPlan:
	%ToplevelTab.show()
	var plan = await choice
	%IdleTab.show()
	return plan

func show_toplevel():
	%ToplevelTab.show()

signal chosen_target(enemy: Enemy)

func pick_target(predicate: Callable = func(e: Enemy): return e.alive) -> Enemy:
	var prev_tab = %TabContainer.current_tab
	var selector = %TargetMenuParent
	for child in selector.get_children():
		child.free()
	var enemies = battlefield.enemies.filter(predicate)
	var back := Button.new()
	back.text = "back"
	back.pressed.connect(chosen_target.emit.bind(null))
	selector.add_child(back)
	for enemy in enemies:
		var button := Button.new()
		button.text = enemy.name
		button.pressed.connect(chosen_target.emit.bind(enemy))
		selector.add_child(button)
	%TargetSelectTab.show()
	var target = await chosen_target
	if target == null:
		%TabContainer.current_tab = prev_tab
	return target

signal chosen_ally(ally: PartyMember)

func pick_ally(predicate: Callable = func(p: PartyMember): return true) -> PartyMember:
	var prev_tab = %TabContainer.current_tab
	var selector = %TargetMenuParent
	for child in selector.get_children():
		child.free()
	var allies = battlefield.players.filter(predicate)
	var back := Button.new()
	back.text = "back"
	back.pressed.connect(chosen_ally.emit.bind(null))
	selector.add_child(back)
	for ally in allies:
		var button := Button.new()
		button.text = ally.name
		button.pressed.connect(chosen_ally.emit.bind(ally))
		selector.add_child(button)
	%TargetSelectTab.show()
	var ally = await chosen_ally
	if ally == null:
		%TabContainer.current_tab = prev_tab
	return ally

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

signal chosen_item(Item)

func pick_item(predicate = func(i: Item): return i.battle_action != null):
	var i_lock = await battlefield.inventory_lock.exclusive_lock()
	var prev_tab = %TabContainer.current_tab
	var selector = %ItemParent
	for child in selector.get_children():
		child.free()
	var items = Inventory.items.filter(predicate)
	var back := Button.new()
	back.text = "back"
	back.pressed.connect(chosen_item.emit.bind(null))
	selector.add_child(back)
	for item in items:
		var button := Button.new()
		button.text = item.name
		button.pressed.connect(chosen_item.emit.bind(item))
		selector.add_child(button)
	%PocketsTab.show()
	var item = await chosen_item
	if item == null:
		%TabContainer.current_tab = prev_tab
	i_lock.call()
	return item

func pockets():
	var item: Item = await pick_item()
	if item == null:
		choice.emit(null)
		return
	var action = item.battle_action.duplicate()
	action.item = item
	var plan = await action.plan(self)
	choice.emit(plan)
