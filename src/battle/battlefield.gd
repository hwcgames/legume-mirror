extends Node3D
class_name Battlefield

@export var battle_board_scene: PackedScene = preload("uid://cmeywylnup3e1")
var battle_board: BattleBoard
@export var player_landmarks: Array[Marker3D]
@export var enemy_landmarks: Array[Marker3D]
@export var players: Array[Actor]
@export var enemies: Array[Actor]
var valid_enemies: Array[Actor]:
	get:
		return enemies.filter(func(e): return is_instance_valid(e))
@export var camera_priority_offset: int = 5
@export var camera: PhantomCamera3D
@export var song: PackedScene
@onready var hud: CanvasLayer = %HUD
@onready var log_zone: Control = hud.get_node("%LogZone")
@onready var player_zone: Control = hud.get_node("%PlayerZone")
var lock: Locks = Locks.new()
var inventory_lock: Locks = Locks.new()
var parley_lock: Locks = Locks.new()

@export var rules: Array[BattleRule] = []

var right_direction: Vector3:
	get:
		return self.global_position.direction_to(%Right.global_position)

signal begin
signal top
signal telegraph
signal player_action
signal enemy_action
signal done(bool)
signal players_died

enum PHASE {
	IDLE,
	SETUP,
	TOP,
	TELEGRAPH,
	PLAYER_ACTION,
	ENEMY_ACTION,
	DONE
}

var phase := PHASE.IDLE

static func find() -> Battlefield:
	return Storyteller.find().get_tree().get_nodes_in_group("battlefield").get(0)

func _ready() -> void:
	hud.hide()
	add_to_group("battlefield")
	add_to_group("story_listener")


func wants_line(line: String, tags: Array[String]) -> bool:
	return do_line(line, tags) is Callable
func take_line(line: String, tags: Array[String]):
	await do_line(line, tags).call()
func do_line(line: String, tags: Array[String]):
	match Array(line.split(" ", false)):
		["/", var actor_name, "joins", "battle"]:
			return func():
				var actor = Actor.find(actor_name)
				if is_instance_valid(actor.sheet.party_component):
					players.push_back(actor)
				elif is_instance_valid(actor.sheet.enemy_component):
					enemies.push_back(actor)
				else:
					printerr("Tried to add actor %s to the battle, but I don't know where to place them.")
		["/", var actor_name, "joins", "battle", "as", "player"]:
			return func():
				var actor = Actor.find(actor_name)
				assert(is_instance_valid(actor), "Actor should exist")
				players.push_back(actor)
		["/", var actor_name, "joins", "battle", "as", "enemy"]:
			return func():
				var actor = Actor.find(actor_name)
				assert(is_instance_valid(actor), "Actor should exist")
				enemies.push_back(actor)
		["/", "battle!"]:
			return func():
				battle()
		["/", "battle", "lock"]:
			return func():
				await lock.exclusive_lock()
		["/", "battle", "unlock"]:
			return func():
				assert(lock.exclusive_locked)
				lock.exclusive_locked = false
				lock.exclusive_free.emit()


func _process(delta: float) -> void:
	if phase == PHASE.ENEMY_ACTION and not players.any(func(p: Actor): return p.alive):
		players_died.emit()

func battle():
	phase = PHASE.SETUP
	for player in players:
		player.join_battle(self)
	for enemy in enemies:
		enemy.join_battle(self, true)
	if camera != null:
		camera.priority += camera_priority_offset
	begin.emit()
	hud.show()
	println("[center]- Battle!!! -[/center]")
	var prev_song: Song
	#if song != null:
		#prev_song = MusicMan.start(song.instantiate())
		#if prev_song != null:
			#prev_song.cancel_free()
	await lock.wait_for_clear()
	while true:
		println("[center]- Top of the round! -[/center]")
		if players.all(func(p: Actor): return !p.alive):
			println("[center]- Player defeat! -[/center]")
			Storyteller.find().choose(["battle lost", "battle end"], true)
			break
		hud.hide()
		if Storyteller.find().choose(["battle top"], true):
			await get_tree().process_frame
			await get_tree().process_frame
		await lock.wait_for_clear()
		hud.show()
		phase = PHASE.TOP
		top.emit()
		await lock.wait_for_clear()
		println("Telegraph phase!")
		if Storyteller.find().choose(["battle telegraph"], true):
			await get_tree().process_frame
			await get_tree().process_frame
		var t_lock = await lock.exclusive_lock()
		phase = PHASE.TELEGRAPH
		telegraph.emit()
		await assign_patterns()
		t_lock.call()
		await lock.wait_for_clear()
		println("Player action!")
		await get_tree().process_frame
		if Storyteller.find().choose(["battle player action"], true):
			await get_tree().process_frame
			await get_tree().process_frame
		await lock.wait_for_clear()
		phase = PHASE.PLAYER_ACTION
		player_action.emit()
		while players.any(func(p: Actor): return p.turns > 0):
			await get_tree().process_frame
			await lock.wait_for_clear()
		println("Enemy action!")
		await get_tree().process_frame
		if valid_enemies.all(func(e): return !e.sheet.enemy_component.active or !e.alive):
			println("[center]- Enemy defeat! -[/center]")
			Storyteller.find().choose(["battle won", "battle end"], true)
			break
		if Storyteller.find().choose(["battle enemy action"], true):
			await get_tree().process_frame
			await get_tree().process_frame
		await lock.wait_for_clear()
		battle_board = battle_board_scene.instantiate()
		add_child(battle_board)
		await battle_board.appear()
		phase = PHASE.ENEMY_ACTION
		enemy_action.emit()
		await get_tree().process_frame
		await lock.wait_for_clear()
		await battle_board.done()
		battle_board.queue_free()
		battle_board = null
	phase = PHASE.DONE
	done.emit(enemies.all(func(e): return e.sheet.enemy_component.active and !e.alive))
	#Chatterbox.clear()
	hud.hide()
	if camera != null:
		camera.priority -= camera_priority_offset
	if song != null:
		MusicMan.stop()
	if prev_song != null:
		MusicMan.start(prev_song)
	phase = PHASE.IDLE

func println(text: String):
	print_rich(text)
	#if !log_box.text.is_empty():
		#log_box.text += "\n"
	#log_box.text += text
	var label := RichTextLabel.new()
	label.modulate = Color.WHITE
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.fit_content = true
	label.bbcode_enabled = true
	log_zone.add_child(label)
	log_zone.move_child(label, 0)
	await get_tree().create_timer(5.).timeout
	await label.create_tween().tween_property(label, "modulate", Color.TRANSPARENT, 1.).finished
	label.queue_free()

func assign_patterns():
	if phase == PHASE.TELEGRAPH:
		for enemy in enemies:
			enemy.planned_pattern = null
	var base_plan: Dictionary[Actor, BulletPattern] = {}
	for enemy in enemies:
		if enemy.planned_pattern:
			base_plan[enemy] = enemy.planned_pattern
	var candidates: Array = []
	var tries = 0
	var total_weight = 0.
	while len(candidates) < 100 and tries < 1000:
		tries += 1
		if tries % 50 == 0:
			await get_tree().process_frame
		# Build a random pattern
		var plan: Dictionary[Actor, BulletPattern] = base_plan.duplicate()
		for enemy in enemies:
			if !enemy.alive:
				plan.erase(enemy)
				continue
			if enemy in plan:
				continue
			var candidate_patterns = enemy.sheet.enemy_component.patterns.filter(func(p: BulletPattern): return enemy.state in p.states)
			if candidate_patterns.is_empty():
				continue
			plan[enemy] = candidate_patterns.get(randi_range(0, len(candidate_patterns) - 1))
		if candidates.any(func(p): return p[0] == plan):
			continue
		# Check that this pattern is valid
		var solo: bool = false
		var team: bool = false
		var joint: BulletPattern = null
		var support_only: bool = true
		var valid = true
		for pattern in (plan.values() as Array[BulletPattern]):
			if pattern == null:
				continue
			if pattern.category == BulletPattern.PATTERN_CATEGORY.SOLO:
				if solo or team or joint:
					valid = false
					break
				solo = true
				support_only = false
			if pattern.category == BulletPattern.PATTERN_CATEGORY.TEAM:
				if solo or joint:
					valid = false
					break
				team = true
				support_only = false
			if pattern.category == BulletPattern.PATTERN_CATEGORY.JOINT:
				if solo or team or (joint and joint.get_script().resource_path != pattern.get_script().resource_path):
					valid = false
					break
				joint = pattern
				support_only = false
		if not valid:
			continue
		# Determine the probability of this plan.
		var weight: float = 1.
		for enemy in (plan.keys() as Array[Actor]):
			var pattern = plan[enemy]
			var total = enemy.sheet.enemy_component.patterns \
				.filter(func(p: BulletPattern): return enemy.state in p.states) \
				.map(func(p: BulletPattern): return p.weight) \
				.reduce(func(a, b): return a * b) + 0.01
			var chance = (pattern.weight if pattern else 0.01) * enemy.sheet.enemy_component.planning_priority / total
			weight *= chance
		if plan.values().all(func(v): return v == null):
			weight = 0.
		if support_only:
			weight /= 10.
		if weight == 0. and total_weight > 0.:
			continue
		total_weight += weight
		candidates.push_back([plan, weight])
	if candidates.is_empty():
		printerr("Can't find a legal plan!")
		return
	if total_weight > 0:
		candidates = candidates.filter(func(c): return c[1] > 0)
	var choice = randf_range(0., total_weight - 0.01)
	var plan: Dictionary[Actor, BulletPattern]
	for candidate in candidates:
		choice -= candidate[1]
		if choice <= 0:
			plan = candidate[0]
			break
	for enemy in (plan.keys() as Array[Actor]):
		if enemy in base_plan:
			continue
		enemy.planned_pattern = plan[enemy]
		enemy.show_telegraph()
