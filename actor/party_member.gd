extends Fighter
class_name PartyMember

## How many turns this actor has left.
## Usually 0 or 1, but not always.
var turns: int = 0

var battle_planner: BattlePlanner
@export var battle_planner_scene: PackedScene = preload("uid://d21yudvneounm")
@onready var skill_challenge: SkillChallenge = $SkillChallenge

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
		var action = await battle_planner.choose()
		await action.call(self)
		turns -= 1

func basic_attack(_p: PartyMember, target: Enemy):
	var lock = await battlefield.exclusive_lock()
	if !target.alive:
		for enemy in battlefield.enemies:
			if enemy.alive:
				target = enemy
	if !target.alive:
		print("No living targets!")
		lock.call()
		return
	battlefield.println("%s attacks %s!" % [self.name, target.name])
	var orig_pos = global_position
	await get_tree().create_tween().tween_property(self, "global_position", target.global_position + Vector3.LEFT * 2, 0.75).finished
	var skill = await skill_challenge.skill_challenge(randi_range(20,40))
	var damage = (self.strength*skill/20)-(3*target.defense)
	if damage > 0:
		battlefield.println("%s damage!" % [damage])
		target.take_damage(damage)
	else:
		battlefield.println("Swing and a miss...")
	var tw = get_tree().create_tween().tween_property(self, "global_position", orig_pos, 0.75)
	await get_tree().create_timer(0.5).timeout
	lock.call()
	await tw.finished

func _enemy_action():
	await get_tree().process_frame
	if battlefield.battle_board.souls.is_empty():
		battlefield.battle_board.add_soul(preload("uid://r8iv2h12xgwc").instantiate())
	battlefield.battle_board.souls[0].players.push_back(self)
