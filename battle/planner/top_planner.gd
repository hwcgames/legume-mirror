extends BattlePlanner
class_name TopPlanner

class BattleActionFinish extends BattleActionPlan:
	func go(_party_member: Actor):
		return

func choose() -> BattleActionPlan:
	populate_skillset_button()
	%ToplevelTab.show()
	choosing = true
	var plan = await choice
	choosing = false
	%IdleTab.show()
	return plan

func populate_skillset_button():
	for child in %SkillsetParent.get_children():
		child.queue_free()
	var button := party_member.sheet.party_component.skillset.button(party_member)
	button.pressed.connect(skillset)
	%SkillsetParent.add_child(button)

func show_toplevel():
	%ToplevelTab.show()
	%BasicAttackButton.grab_focus()

signal chosen_target(enemy: Actor)

func pick_target(predicate: Callable = func(e: Actor): return e.alive) -> Actor:
	var prev_tab = %TabContainer.current_tab
	var selector = %TargetMenuParent
	for child in selector.get_children():
		child.free()
	var enemies = battlefield.valid_enemies.filter(predicate)
	var back := Button.new()
	back.text = "back"
	back.pressed.connect(chosen_target.emit.bind(null))
	selector.add_child(back)
	back.grab_focus()
	var enemy_buttons: Array[Button] = []
	for enemy in enemies:
		var button := Button.new()
		enemy_buttons.push_back(button)
		button.text = enemy.human_name
		button.tooltip_text = enemy.sheet.description
		button.pressed.connect(chosen_target.emit.bind(enemy))
		selector.add_child(button)
	%TargetSelectTab.show()
	enemy_buttons[0].grab_focus()
	var target = await chosen_target
	if target == null:
		%TabContainer.current_tab = prev_tab
	return target

signal chosen_ally(ally: Actor)

func pick_ally(predicate: Callable = func(p: Actor): return true) -> Actor:
	var prev_tab = %TabContainer.current_tab
	var selector = %TargetMenuParent
	for child in selector.get_children():
		child.free()
	var allies = battlefield.players.filter(predicate)
	var back := Button.new()
	back.text = "back"
	back.pressed.connect(chosen_ally.emit.bind(null))
	selector.add_child(back)
	back.grab_focus()
	var ally_buttons: Array[Button] = []
	for ally in allies:
		var button := Button.new()
		ally_buttons.push_back(button)
		button.text = ally.human_name
		button.pressed.connect(chosen_ally.emit.bind(ally))
		selector.add_child(button)
	%TargetSelectTab.show()
	if !ally_buttons.is_empty():
		ally_buttons[0].grab_focus()
	var ally = await chosen_ally
	if ally == null:
		%TabContainer.current_tab = prev_tab
	return ally

signal chosen_actor(target: Actor)

func pick_actor(predicate: Callable = func(a: Actor): return true) -> Actor:
	var prev_tab = %TabContainer.current_tab
	var selector = %TargetMenuParent
	for child in selector.get_children():
		child.free()
	var allies = battlefield.players.filter(predicate)
	var enemies = battlefield.enemies.filter(predicate)
	var back := Button.new()
	back.text = "back"
	back.pressed.connect(chosen_actor.emit.bind(null))
	selector.add_child(back)
	back.grab_focus()
	var actor_buttons: Array[Button] = []
	for ally in allies:
		var button := Button.new()
		actor_buttons.push_back(button)
		button.text = ally.human_name
		button.pressed.connect(chosen_actor.emit.bind(ally))
		selector.add_child(button)
	for enemy in enemies:
		var button := Button.new()
		actor_buttons.push_back(button)
		button.text = enemy.human_name
		button.pressed.connect(chosen_actor.emit.bind(enemy))
		selector.add_child(button)
	%TargetSelectTab.show()
	if !actor_buttons.is_empty():
		actor_buttons[0].grab_focus()
	var enemy = await chosen_actor
	if enemy == null:
		%TabContainer.current_tab = prev_tab
	return enemy

func _ready():
	%IdleTab.show()
	%Name.text = party_member.human_name
	%Name.add_theme_color_override("font_color", party_member.text_color)
	%ColorBg.modulate = party_member.sheet.bg_color
	%HPBar.min_value = party_member.sheet.hp.min
	%HPBar.max_value = party_member.sheet.hp.max
	%HPBar.value = party_member.sheet.hp.hp
	%SPBar.min_value = party_member.sheet.party_component.sp.min
	%SPBar.max_value = party_member.sheet.party_component.sp.max
	%SPBar.value = party_member.sheet.party_component.sp.sp
	%BasicAttackButton.grab_focus()
	%TabContainer.tab_changed.connect(func(idx):
		if idx == %ToplevelTab.get_index():
			%BasicAttackButton.grab_focus())
	party_member.new_rule.connect(new_rule)
	for rule in party_member.sheet.rules:
		new_rule(rule)
	battlefield.top.connect(sort_rules)

func new_rule(rule: BattleRule):
	var indicator: Control = rule.make_marker(party_member)
	if !is_instance_valid(indicator):
		return
	print(indicator)
	%StatusContainer.add_child(indicator)
	rule.removed.connect(func():
		print("Removed")
		if is_instance_valid(indicator):
			indicator.queue_free())
	sort_rules()

func sort_rules():
	var children = %StatusContainer.get_children()
	children.sort_custom(func(l, r): return l.amount < r.amount)
	for child in children:
		%StatusContainer.move_child(child, -1)

var hp: int = 0
var sp: int = 0

func _process(delta: float) -> void:
	update_bars()
	if choosing and not battlefield.enemies.any(func(e: Actor): return e.sheet.enemy_component.active and e.alive):
		choice.emit(BattleActionFinish.new())

func update_bars():
	%HPBar.min_value = party_member.sheet.hp.min
	%HPBar.max_value = party_member.sheet.hp.max
	%SPBar.min_value = party_member.sheet.party_component.sp.min
	%SPBar.max_value = party_member.sheet.party_component.sp.max
	if party_member.sheet.hp.hp != hp:
		hp = party_member.sheet.hp.hp
		create_tween().tween_property(%HPBar, "value", party_member.sheet.hp.hp, 0.5)
	if party_member.sheet.party_component.sp.sp != sp:
		sp = party_member.sheet.party_component.sp.sp
		create_tween().tween_property(%SPBar, "value", party_member.sheet.party_component.sp.sp, 0.5)

signal chosen_item(Item)

func pick_item(predicate = func(i: Item): return i.battle_action != null) -> Item:
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
	back.grab_focus()
	var item_buttons: Array[Button] = []
	for item in items:
		var button := Button.new()
		item_buttons.push_back(button)
		button.text = item.name
		button.tooltip_text = item.description.format({
			"me": party_member,
			"item": item,
			"charges": item.charges
		})
		button.pressed.connect(chosen_item.emit.bind(item))
		if not (item as Item).battle_action.allowed(party_member, item):
			button.disabled = true
		selector.add_child(button)
	%PocketsTab.show()
	if !item_buttons.is_empty():
		item_buttons[0].grab_focus()
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
	if "item" in action:
		action.item = item
	var plan = await action.plan(self, item)
	#if plan != null:
		#Inventory.items.remove_at(Inventory.items.find(item))
	choice.emit(plan)

signal chosen_parley(parley: ParleyAction)

func pick_parley(enemy: Actor, predicate = func(i: BattleAction): return true):
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
	back.grab_focus()
	var parleys = enemy.sheet.enemy_component.parleys.filter(predicate) \
		.map(func(p):
			var parley = p.duplicate()
			parley.enemy = enemy
			return parley) \
		.filter(func(p: ParleyAction): return p.display(party_member))
	var parley_buttons: Array[Button] = []
	for parley in parleys:
		var button := Button.new()
		parley_buttons.push_back(button)
		button.text = parley.label()
		button.tooltip_text = parley.description()
		button.pressed.connect(chosen_parley.emit.bind(parley))
		button.disabled = not parley.allowed(party_member)
		selector.add_child(button)
	%ParleyTab.show()
	if !parley_buttons.is_empty():
		parley_buttons[0].grab_focus()
	var parley = await chosen_parley
	if parley == null:
		%TabContainer.current_tab = prev_tab
	p_lock.call()
	return parley

func parley():
	var enemy: Actor = await pick_target()
	if enemy == null:
		choice.emit(null)
		return
	var parley_action: ParleyAction = await pick_parley(enemy)
	if parley_action == null:
		choice.emit(null)
		return
	var plan = await parley_action.plan(self, enemy.sheet.enemy_component)
	choice.emit(plan)

func skillset():
	var skillset_planner = party_member.sheet.party_component.skillset.subplanner(party_member)
	skillset_planner.battle_planner = self
	skillset_planner.party_member = party_member
	for child in %SkillsetTab.get_children():
		child.queue_free()
	%SkillsetTab.add_child(skillset_planner)
	%SkillsetTab.show()
	var plan = await skillset_planner.choose()
	choice.emit(plan)

func _propagate_input_event(event: InputEvent) -> bool:
	var player_no = party_member.player
	var player_idx = PlayerManager.get_player_device(player_no)
	return (player_idx == -1 and
			(event is InputEventMouse or event is InputEventKey))\
		or event.device == player_idx
