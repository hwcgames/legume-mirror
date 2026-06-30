extends BattleComponent
class_name PartyComponent

@export var sp: EnergyComponent

@export_file_path("*.tscn") var skill_challenge_scene = "uid://bbpp48kcropih"
@export_file_path("*.tscn") var battle_planner_scene = "uid://d21yudvneounm"
@export var basic_attack: BattleAction = BattleActionBasicAttack.new()
@export var skillset: Skillset = SkillsetUnskilled.new()
@export var equip_slots: Dictionary[String, int] = {
	"armor": 10,
	"head": 2,
	"torso": 2,
	"hands": 2,
	"legs": 2,
	"feet": 1,
}
@export var equips: Array[Item] = []
@export var tags: Array[String] = []

func capacity() -> Dictionary[String, int]:
	var cap = equip_slots.duplicate()
	for equip in equips:
		for slot in equip.equip_sizes.keys():
			cap -= equip.equip_sizes[slot] if slot in equip.equip_sizes else 0
	return cap

const equip_names: Dictionary[String, String] = {
	"armor": "ARMOR",
	"head": "HAT'S",
	"torso": "TORSO",
	"hands": "HANDS",
	"legs": "LEGS",
	"feet": "FEET"
}

func copy() -> PartyComponent:
	var new = self.duplicate()
	new.sp = sp.duplicate()
	new.skillset = self.skillset.duplicate()
	return new

func _join_battle(actor: Actor, _battle: Battlefield):
	if actor.battle_planner != null:
		actor.battle_planner.queue_free()
	actor.battle_planner = load(battle_planner_scene).instantiate()
	actor.battle_planner.party_member = actor
	actor.battlefield.player_zone.add_child(actor.battle_planner)
	#var b_lock = await actor.battlefield.lock.shared_lock()
	actor.home_landmark = actor.battlefield.player_landmarks[actor.battlefield.players.find(actor) % len(actor.battlefield.player_landmarks)]
	#await create_tween() \
		#.tween_property(self, "global_position", home_landmark.global_position, 0.75).finished
	#await actor.create_tween().tween_property(actor, "global_rotation", actor.home_landmark.global_rotation, 0.25).finished
	#b_lock.call()

func _begin(actor: Actor):
	pass

func _top(actor: Actor):
	pass

func _telegraph(actor: Actor):
	pass

func _player_action(actor: Actor):
	#if not actor.alive:
		#return
	actor.turns = 1
	while is_instance_valid(actor.battlefield) and actor.battlefield.phase == Battlefield.PHASE.PLAYER_ACTION:
		if actor.turns == 0 or !actor.alive:
			await actor.get_tree().process_frame
			continue
		while !InputLocks.lock(actor.player).is_clear():
			await InputLocks.lock(actor.player).wait_for_clear()
		var p_lock = await InputLocks.lock(actor.player).shared_lock()
		print(InputLocks.lock(actor.player).is_clear())
		var action: BattleActionPlan = null
		while action == null and actor.turns > 0 and actor.alive:
			action = await actor.battle_planner.choose()
			await actor.get_tree().process_frame
		if actor.turns <= 0 or not actor.alive:
			p_lock.call_deferred()
			continue
		var cancel = false
		for rule in actor.sheet.rules:
			if not rule.player_plan(actor, action):
				cancel = true
				break
		if cancel or !actor.alive or actor.turns <= 0:
			p_lock.call_deferred()
			continue
		actor.turns -= 1
		var coroutine = Promise.new(func(resolve, _reject):
			await action.go(actor)
			resolve.call())
		p_lock.call_deferred()
		await coroutine.resolved

func _enemy_action(actor: Actor):
	if not actor.alive:
		return
	await actor.get_tree().process_frame
	var soul_index = actor.battlefield.battle_board.souls.find_custom(func(s: Soul): return s.device_index == actor.device_index)
	if soul_index == -1:
		var soul: Soul = preload("uid://r8iv2h12xgwc").instantiate()
		soul.device_index = actor.device_index
		actor.battlefield.battle_board.add_soul(soul)
		soul_index = len(actor.battlefield.battle_board.souls) - 1
	var soul: Soul = actor.battlefield.battle_board.souls[soul_index]
	soul.players.push_back(actor)
	for rule in actor.sheet.rules:
		if not rule.soul(actor, soul):
			break

func _done(actor: Actor, _player_victory: bool):
	pass
