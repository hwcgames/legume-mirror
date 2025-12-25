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
@onready var log_box: RichTextLabel = %BattleText
@onready var player_zone: Control = %PlayerZone
var lock: Locks = Locks.new()
var inventory_lock: Locks = Locks.new()
var parley_lock: Locks = Locks.new()

var right_direction: Vector3:
	get:
		return self.global_position.direction_to(%Right.global_position)

signal begin
signal top
signal telegraph
signal player_action
signal enemy_action
signal done(bool)

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

func _ready() -> void:
	%BattleHUD.hide()

func battle():
	phase = PHASE.SETUP
	for player in players:
		player.join_battle(self)
	for enemy in enemies:
		enemy.join_battle(self)
	if camera != null:
		camera.priority += camera_priority_offset
	begin.emit()
	log_box.text = ""
	%BattleHUD.show()
	println("[center]- Battle!!! -[/center]")
	await lock.wait_for_clear()
	while true:
		println("[center]- Top of the round! -[/center]")
		if players.all(func(p): return !p.alive):
			println("[center]- Player defeat! -[/center]")
			break
		phase = PHASE.TOP
		top.emit()
		await lock.wait_for_clear()
		println("Telegraph phase!")
		phase = PHASE.TELEGRAPH
		telegraph.emit()
		await lock.wait_for_clear()
		println("Player action!")
		phase = PHASE.PLAYER_ACTION
		player_action.emit()
		while players.any(func(p: PartyMember): return p.turns > 0):
			await get_tree().process_frame
			await lock.wait_for_clear()
		println("Enemy action!")
		if enemies.all(func(e): return !e.alive):
			println("[center]- Enemy defeat! -[/center]")
			break
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
	%BattleHUD.hide()
	if camera != null:
		camera.priority -= camera_priority_offset
	phase = PHASE.IDLE

func println(text: String):
	print_rich(text)
	if !log_box.text.is_empty():
		log_box.text += "\n"
	log_box.text += text
