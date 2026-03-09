extends Fighter
class_name Enemy

@export var enemy_factory: EnemyFactory
@export var patterns: Array[BulletPattern] = []
@export var planning_priority: int
var has_planned: bool = false
var planned_pattern: BulletPattern
@export var state: int = 0
@export var null_telegraph: PackedScene = preload("uid://cdltsqr44pytk")
@export var parleys: Array[ParleyAction] = []
var locks: Locks = Locks.new()

func _ready():
	super._ready()
	%Telegraph.hide()

func _join_battle(_battle: Battlefield):
	home_landmark = battlefield.enemy_landmarks[battlefield.enemies.find(self)]
	global_position = home_landmark.global_position
	global_rotation = home_landmark.global_rotation

func _telegraph():
	if !self.alive:
		return
	var lock = await battlefield.lock.shared_lock()
	await pick_pattern()
	await show_telegraph()
	lock.call()

func _died():
	super._died()
	for child in %TelegraphParent.get_children():
		child.queue_free()
	%Telegraph.hide()

func _enemy_action():
	%Telegraph.hide()
	for child in %TelegraphParent.get_children():
		child.queue_free()
	if !self.alive:
		return
	var lock = await battlefield.lock.shared_lock()
	if planned_pattern != null:
		var board = planned_pattern.create(battlefield, self)
		await get_tree().process_frame
		battlefield.battle_board.add_pattern(board)
		battlefield.players_died.connect(board.done.emit)
		await board.done
	lock.call()

func pick_pattern():
	planned_pattern = null
	has_planned = false
	await get_tree().process_frame
	while battlefield.enemies.any(func(e: Enemy): return e.planning_priority > planning_priority and not e.has_planned):
		await get_tree().process_frame
	has_planned = true
	var enemies = battlefield.enemies.map(func(e: Node): return e.get_path()) as Array[String]
	var already_planned = battlefield.enemies \
		.map(func(e): return e.planned_pattern) \
		.filter(func(p): return p != null) as Array[BulletPattern]
	var must_be_friends = already_planned.filter(func(p): return p.exclusive).map(func(p): return ResourceUID.path_to_uid(p.resource_path)) as Array[String]
	var candidates = patterns.filter(\
		func(p: BulletPattern):
			return \
				(p.enemies.all(func(r): return r in enemies)) and \
				(must_be_friends.all(func(f): return f == ResourceUID.path_to_uid(p.resource_path) or f in p.friends)) and \
				(state in p.states)) as Array[BulletPattern]
	if candidates.is_empty():
		print("No moves!")
		return
	for pattern in already_planned:
		if not pattern.shared:
			continue
		if battlefield.enemies.any(func(e: Enemy): return e.has_planned and pattern in e.patterns and e.planned_pattern != pattern):
			continue
		if candidates.any(func(c): return c.path == pattern.path):
			planned_pattern = pattern
			return
	planned_pattern = candidates[randi_range(0, len(candidates) - 1)]

func show_telegraph():
	for child in %TelegraphParent.get_children():
		child.queue_free()
	var telegraph = planned_pattern.telegraph_scene.instantiate() if planned_pattern != null else null_telegraph.instantiate()
	%TelegraphParent.add_child(telegraph)
	%Telegraph.show()

static func from_enemy_factory(enemy_factory: EnemyFactory) -> Enemy:
	var enemy_sheet: EnemySheet = enemy_factory.roll_enemy()
	var enemy: Enemy = preload("uid://nk8ets08f0mj").instantiate()
	var costume_node: Costume = enemy_sheet.costume.instantiate()
	enemy.costume = costume_node
	enemy.human_name = enemy_sheet.name
	enemy.hp_component = enemy_sheet.hp.duplicate()
	enemy.sp_component = enemy_sheet.sp.duplicate()
	enemy.attrs = enemy_sheet.attrs
	enemy.patterns = enemy_sheet.patterns
	enemy.planning_priority = enemy_sheet.planning_priority
	enemy.parleys = enemy_sheet.parleys
	enemy.enemy_factory = enemy_factory
	return enemy
