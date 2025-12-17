extends Control
class_name BattlePlanner

var party_member: PartyMember
var battlefield: Battlefield:
	get:
		return party_member.battlefield

signal choice(plan: BattleActionPlan)

class BattleActionFinish extends BattleActionPlan:
	func go(party_member: PartyMember):
		return

var choosing: bool = false

func choose() -> BattleActionPlan:
	%ToplevelTab.show()
	choosing = true
	var plan = await choice
	choosing = false
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
	if choosing and not battlefield.enemies.any(func(e: Enemy): return e.alive):
		choice.emit(BattleActionFinish.new())

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

signal chosen_parley(parley: ParleyAction)

func pick_parley(enemy: Enemy, predicate = func(i: ParleyAction): return true):
	var p_lock = await battlefield.parley_lock.exclusive_lock()
	var prev_tab = %TabContainer.current_tab
	var selector = %ParleyParent
	for child in selector.get_children():
		child.free()
	var items = Inventory.items.filter(predicate)
	var back := Button.new()
	back.text = "back"
	back.pressed.connect(chosen_parley.emit.bind(null))
	selector.add_child(back)
	var parleys = enemy.parleys.filter(predicate)\
		.map(func(p): 
			var parley = p.duplicate()
			parley.enemy = enemy
			return parley)\
		.filter(func(p: ParleyAction): return p.display(party_member))
	for parley in parleys:
		var button := Button.new()
		button.text = parley.label()
		button.pressed.connect(chosen_parley.emit.bind(parley))
		button.disabled = not parley.allowed(party_member)
		selector.add_child(button)
	%ParleyTab.show()
	var parley = await chosen_parley
	if parley == null:
		%TabContainer.current_tab = prev_tab
	p_lock.call()
	return parley

func parley():
	var enemy: Enemy = await pick_target()
	if enemy == null:
		choice.emit(null)
		return
	var parley_action: ParleyAction = await pick_parley(enemy)
	if parley_action == null:
		choice.emit(null)
		return
	var plan = await parley_action.plan(self)
	choice.emit(plan)
