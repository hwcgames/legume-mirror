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
var locks: Locks = Locks.new()

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
	await locks.wait_for_clear()
	while true:
		println("[center]- Top of the round! -[/center]")
		phase = PHASE.TOP
		top.emit()
		await locks.wait_for_clear()
		if enemies.all(func(e): return !e.alive):
			println("[center]- Enemy defeat! -[/center]")
			break
		if players.all(func(p): return !p.alive):
			println("[center]- Player defeat! -[/center]")
			break
		println("Telegraph phase!")
		phase = PHASE.TELEGRAPH
		telegraph.emit()
		await locks.wait_for_clear()
		println("Player action!")
		phase = PHASE.PLAYER_ACTION
		player_action.emit()
		while players.any(func(p: PartyMember): return p.turns > 0):
			await get_tree().process_frame
			await locks.wait_for_clear()
		println("Enemy action!")
		battle_board = battle_board_scene.instantiate()
		add_child(battle_board)
		await battle_board.appear()
		phase = PHASE.ENEMY_ACTION
		enemy_action.emit()
		await get_tree().process_frame
		await locks.wait_for_clear()
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
