extends Fighter
class_name PartyMember

## How many turns this actor has left.
## Usually 0 or 1, but not always.
var turns: int = 0
var lock: Locks = Locks.new()
@export var player: int = 0
var device_index:
	get:
		return PlayerManager.get_player_device(player)
var battle_planner: BattlePlanner
@export var skill_challenge_scene: PackedScene = preload("uid://bbpp48kcropih")
@export var battle_planner_scene: PackedScene = preload("uid://d21yudvneounm")
@onready var skill_challenge: SkillChallenge
@export var basic_attack: BattleAction

func _join_battle(_battle: Battlefield):
	if battle_planner != null:
		battle_planner.queue_free()
	battle_planner = battle_planner_scene.instantiate()
	battle_planner.party_member = self
	battlefield.player_zone.add_child(battle_planner)

func _player_action():
	if not alive:
		return
	turns = 1
	while turns > 0 and battlefield.phase == Battlefield.PHASE.PLAYER_ACTION:
		await InputLocks.lock(player).wait_for_clear()
		var p_lock = await InputLocks.lock(player).shared_lock()
		var action: BattleActionPlan
		while action == null:
			action = await battle_planner.choose()
			await get_tree().process_frame
		turns -= 1
		var self_lock = await lock.exclusive_lock()
		var coroutine = Promise.new(func(resolve, reject):
			await action.go(self)
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
		soul_index = len(battlefield.battle_board.souls)-1
	var soul: Soul = battlefield.battle_board.souls[soul_index]
	soul.players.push_back(self)

func setup_challenge(scene: PackedScene = skill_challenge_scene) -> SkillChallenge:
	skill_challenge = scene.instantiate()
	skill_challenge.party_member = self
	%SkillChallengeParent.add_child(skill_challenge)
	return skill_challenge
