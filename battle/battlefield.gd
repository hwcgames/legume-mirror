extends Node3D
class_name Battlefield

@export var battle_board_scene: PackedScene = preload("uid://cmeywylnup3e1")
var battle_board: BattleBoard
@export var player_landmarks: Array[Marker3D]
@export var enemy_landmarks: Array[Marker3D]
@export var players: Array[PartyMember]
@export var enemies: Array[Enemy]
@export var camera_priority_offset: int = 5
@export var camera: PhantomCamera3D
@export var song: PackedScene
@onready var log_zone: Control = %LogZone
@onready var player_zone: Control = %PlayerZone
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
	return Storyteller.get_tree().get_nodes_in_group("battlefield").get(0)

func _ready() -> void:
	%BattleHUD.hide()
	add_to_group("battlefield")

func _process(delta: float) -> void:
	if phase == PHASE.ENEMY_ACTION and not players.any(func(p: PartyMember): return p.alive):
		players_died.emit()

func battle():
	phase = PHASE.SETUP
	for player in players:
		player.join_battle(self)
	for enemy in enemies:
		enemy.join_battle(self)
	if camera != null:
		camera.priority += camera_priority_offset
	begin.emit()
	%BattleHUD.show()
	println("[center]- Battle!!! -[/center]")
	var prev_song: Song
	#if song != null:
		#prev_song = MusicMan.start(song.instantiate())
		#if prev_song != null:
			#prev_song.cancel_free()
	await lock.wait_for_clear()
	while true:
		println("[center]- Top of the round! -[/center]")
		if players.all(func(p): return !p.alive):
			println("[center]- Player defeat! -[/center]")
			Storyteller.choose_if_available(["battle lost", "battle end"])
			break
		%BattleHUD.hide()
		if Storyteller.choose_if_available(["battle top"]):
			await get_tree().process_frame
			await get_tree().process_frame
		await lock.wait_for_clear()
		%BattleHUD.show()
		phase = PHASE.TOP
		top.emit()
		await lock.wait_for_clear()
		println("Telegraph phase!")
		if Storyteller.choose_if_available(["battle telegraph"]):
			await get_tree().process_frame
			await get_tree().process_frame
		await lock.wait_for_clear()
		phase = PHASE.TELEGRAPH
		telegraph.emit()
		await lock.wait_for_clear()
		println("Player action!")
		if Storyteller.choose_if_available(["battle player action"]):
			await get_tree().process_frame
			await get_tree().process_frame
		await lock.wait_for_clear()
		phase = PHASE.PLAYER_ACTION
		player_action.emit()
		while players.any(func(p: PartyMember): return p.turns > 0):
			await get_tree().process_frame
			await lock.wait_for_clear()
		println("Enemy action!")
		if enemies.all(func(e): return !e.alive):
			println("[center]- Enemy defeat! -[/center]")
			Storyteller.choose_if_available(["battle won", "battle end"])
			break
		if Storyteller.choose_if_available(["battle enemy action"]):
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
	done.emit(enemies.all(func(e): return !e.alive))
	Chatterbox.clear()
	%BattleHUD.hide()
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
