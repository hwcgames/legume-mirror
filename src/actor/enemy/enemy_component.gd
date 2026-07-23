extends BattleComponent
class_name EnemyComponent

@export var active: bool = true

@export var patterns: Array[BulletPattern] = []
@export var planning_priority: int
@export var parleys: Array[BattleAction] = []

func copy() -> EnemyComponent:
	var out: EnemyComponent = duplicate()
	out.patterns = []
	for pattern in patterns:
		out.patterns.push_back(pattern.copy())
	out.parleys = []
	for parley in parleys:
		out.parleys.push_back(parley.copy())
	return out

func _join_battle(enemy: Actor, battlefield: Battlefield):
	enemy.home_landmark = enemy.battlefield.enemy_landmarks[enemy.battlefield.enemies.find(enemy) % len(enemy.battlefield.enemy_landmarks)]


func _telegraph(actor: Actor):
	if !actor.alive:
		return
	#await pick_pattern()
	var lock = await actor.battlefield.lock.shared_lock()
	for rule in actor.sheet.rules:
		if not rule.pick_pattern(actor):
			return
	await actor.show_telegraph()
	lock.release()

func _died(actor: Actor):
	for child in actor.get_node("%TelegraphParent").get_children():
		child.queue_free()
	actor.get_node("%Telegraph").hide()

func _done(actor: Actor, player_victory: bool):
	if not active:
		actor.queue_free()

func _enemy_action(actor: Actor):
	actor.get_node("%Telegraph").hide()
	for child in actor.get_node("%TelegraphParent").get_children():
		child.queue_free()
	if !actor.alive:
		return
	var lock = await actor.battlefield.lock.shared_lock()
	if actor.planned_pattern != null:
		var board = actor.planned_pattern.create(actor.battlefield, actor)
		await actor.get_tree().process_frame
		for rule in actor.sheet.rules:
			if not rule.setup_battle_board(actor, board):
				await board.done
				lock.release()
				return
		actor.battlefield.battle_board.add_pattern(board)
		actor.battlefield.players_died.connect(board.done.emit)
		await board.done
	lock.release()

func _begin(actor: Actor):
	pass

func _top(actor: Actor):
	pass

func _player_action(actor: Actor):
	pass
