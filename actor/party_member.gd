extends Fighter
class_name PartyMember

@export var character_sheet: CharacterSheet

## How many turns this actor has left.
## Usually 0 or 1, but not always.
var turns: int = 0
var lock: Locks = Locks.new()
var party_order_key: int = 0
@export var player: int = 0
var device_index:
	get:
		return PlayerManager.get_player_device(player)
@export var skill_challenge_scene: PackedScene = preload("uid://bbpp48kcropih")
@export var battle_planner_scene: PackedScene = preload("uid://d21yudvneounm")
var skill_challenge: SkillChallenge
var battle_planner: BattlePlanner

@export var basic_attack: BattleAction = BattleActionBasicAttack.new()
@export var skillset: Skillset = SkillsetUnskilled.new()

func _ready():
	super._ready()
	add_to_group("party_member")

func _join_battle(_battle: Battlefield):
	if battle_planner != null:
		battle_planner.queue_free()
	battle_planner = battle_planner_scene.instantiate()
	battle_planner.party_member = self
	battlefield.player_zone.add_child(battle_planner)
	var b_lock = await battlefield.lock.shared_lock()
	home_landmark = battlefield.player_landmarks[battlefield.players.find(self )]
	#await create_tween() \
		#.tween_property(self, "global_position", home_landmark.global_position, 0.75).finished
	await (await push_mode(ActorModeMoveTo.new(self, home_landmark.global_position))).popped
	await create_tween().tween_property(self, "global_rotation", home_landmark.global_rotation, 0.25).finished
	b_lock.call()

func _player_action():
	if not alive:
		return
	turns = 1
	while battlefield.phase == Battlefield.PHASE.PLAYER_ACTION:
		if turns == 0:
			await get_tree().process_frame
			continue
		await InputLocks.lock(player).wait_for_clear()
		var p_lock = await InputLocks.lock(player).shared_lock()
		var action: BattleActionPlan = null
		while action == null:
			action = await battle_planner.choose()
			await get_tree().process_frame
		for rule in rules:
			if not rule.player_plan(self, action):
				return
		turns -= 1
		var self_lock = await lock.exclusive_lock()
		var coroutine = Promise.new(func(resolve, _reject):
			await action.go(self )
			resolve.call())
		self_lock.call()
		p_lock.call_deferred()
		await coroutine.resolved

#func _basic_attack(_p: PartyMember, target: Enemy):
	#var p_lock = await InputLocks.lock(player).shared_lock()
	#var b_lock = await battlefield.locks.shared_lock()
	#var e_lock = await target.locks.exclusive_lock()
	#
	#await get_tree().create_timer(1.).timeout
	#
	#if !target.alive:
		#for enemy in battlefield.enemies:
			#if enemy.alive:
				#target = enemy
	#if !target.alive:
		#print("No living targets!")
		#p_lock.call()
		#b_lock.call()
		#e_lock.call()
		#return
	#battlefield.println("%s attacks %s!" % [self.name, target.name])
	#var orig_pos = global_position
	#await get_tree().create_tween().tween_property(self, "global_position", target.global_position + Vector3.LEFT * 2, 0.75).finished
	#var skill = await skill_challenge.skill_challenge(randi_range(20,40))
	#var damage = (self.strength*skill/20)-(3*target.defense)
	#if damage > 0:
		#battlefield.println("%s damage!" % [damage])
		#target.take_damage(damage)
	#else:
		#battlefield.println("Swing and a miss...")
	#var tw = get_tree().create_tween().tween_property(self, "global_position", orig_pos, 0.75)
	#await get_tree().create_timer(0.5).timeout
	#p_lock.call()
	#b_lock.call()
	#e_lock.call()
	#await tw.finished

func _enemy_action():
	if not alive:
		return
	await get_tree().process_frame
	var soul_index = battlefield.battle_board.souls.find_custom(func(s: Soul): return s.device_index == device_index)
	if soul_index == -1:
		var soul: Soul = preload("uid://r8iv2h12xgwc").instantiate()
		soul.device_index = device_index
		battlefield.battle_board.add_soul(soul)
		soul_index = len(battlefield.battle_board.souls) - 1
	var soul: Soul = battlefield.battle_board.souls[soul_index]
	soul.players.push_back(self)
	for rule in rules:
		if not rule.soul(self, soul):
			break

func setup_challenge(scene: PackedScene = skill_challenge_scene) -> SkillChallenge:
	skill_challenge = scene.instantiate()
	skill_challenge.party_member = self
	%SkillChallengeParent.add_child(skill_challenge)
	return skill_challenge

static func from_character_sheet(character_sheet: CharacterSheet) -> PartyMember:
	var pm: PartyMember = preload("uid://b0hnypxq8ieth").instantiate()
	pm.name = character_sheet.id
	var costume_node: Costume = character_sheet.costume.instantiate()
	pm.costume = costume_node
	pm.human_name = character_sheet.name
	pm.hp_component = character_sheet.hp
	pm.sp_component = character_sheet.sp
	pm.fighter_rules = character_sheet.rules.duplicate(true)
	pm.attrs = character_sheet.attrs
	pm.basic_attack = character_sheet.basic_attack
	pm.skillset = character_sheet.skillset
	pm.skill_challenge_scene = load(character_sheet.skill_challenge_scene)
	pm.battle_planner_scene = load(character_sheet.battle_planner_scene)
	pm.character_sheet = character_sheet
	pm.text_color = character_sheet.text_color
	pm.bg_color = character_sheet.bg_color
	return pm
