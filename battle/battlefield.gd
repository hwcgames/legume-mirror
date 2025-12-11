extends Node
class_name Battlefield

@export var stage: Node3D
@export var battle_board_scene: PackedScene = preload("uid://cmeywylnup3e1")
var battle_board: BattleBoard
@export var landmarks: Array[Marker3D]
@export var players: Array[PartyMember]
@export var enemies: Array[Enemy]
@onready var log_box: RichTextLabel = %BattleText
@onready var player_zone: Control = %PlayerZone

var shared_locks: int = 0
var exclusive_locked: bool = false

signal shared_free
signal exclusive_free

func shared_lock():
	while exclusive_locked:
		await exclusive_free
	shared_locks += 1;
	return func():
		if shared_locks == 0:
			printerr("Shared lock double-freed!")
			return
		shared_locks -= 1
		if shared_locks == 0:
			shared_free.emit()

func exclusive_lock():
	await wait_for_clear()
	exclusive_locked = true
	return func():
		if !exclusive_locked:
			printerr("Exclusive lock double-freed!")
			return
		exclusive_locked = false
		exclusive_free.emit()

func wait_for_clear():
	await get_tree().process_frame
	while shared_locks > 0 or exclusive_locked:
		while shared_locks > 0:
			await shared_free
		while exclusive_locked:
			await exclusive_free

signal begin
signal top
signal telegraph
signal player_action
signal enemy_action
signal done(bool)

enum PHASE {
	SETUP,
	TOP,
	TELEGRAPH,
	PLAYER_ACTION,
	ENEMY_ACTION,
	DONE
}

var phase := PHASE.SETUP

func _ready() -> void:
	%BattleHUD.hide()

func battle():
	for player in players:
		player.join_battle(self)
	for enemy in enemies:
		enemy.join_battle(self)
	begin.emit()
	log_box.text = ""
	%BattleHUD.show()
	println("[center]- Battle!!! -[/center]")
	await wait_for_clear()
	while true:
		println("[center]- Top of the round! -[/center]")
		phase = PHASE.TOP
		top.emit()
		await wait_for_clear()
		if enemies.all(func(e): return !e.alive):
			println("[center]- Enemy defeat! -[/center]")
			break
		if players.all(func(p): return !p.alive):
			println("[center]- Player defeat! -[/center]")
			break
		println("Telegraph phase!")
		phase = PHASE.TELEGRAPH
		telegraph.emit()
		await wait_for_clear()
		println("Player action!")
		phase = PHASE.PLAYER_ACTION
		player_action.emit()
		while players.any(func(p: PartyMember): return p.turns > 0):
			await wait_for_clear()
		println("Enemy action!")
		battle_board = battle_board_scene.instantiate()
		add_child(battle_board)
		await battle_board.appear()
		phase = PHASE.ENEMY_ACTION
		enemy_action.emit()
		await get_tree().process_frame
		await wait_for_clear()
		await battle_board.done()
		battle_board.queue_free()
		battle_board = null
	phase = PHASE.DONE
	done.emit(enemies.all(func(e): return !e.alive))
	%BattleHUD.hide()

func println(text: String):
	print_rich(text)
	if !log_box.text.is_empty():
		log_box.text += "\n"
	log_box.text += text
