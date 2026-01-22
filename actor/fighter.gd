extends Actor
class_name Fighter

var alive: bool:
	get:
		return hp > 0
signal died
signal revived
@export var max_hp: int
@export var hp: int
@export var max_sp: int
@export var sp: int
@export var strength: int
@export var magic: int
@export var defense: int
@export var finesse: int

var home_landmark: Marker3D

func take_damage(amount: int):
	var was_alive = alive
	hp -= amount
	if was_alive and not alive:
		died.emit()
		_died()

func _died():
	if costume != null:
		costume.play("dead")

func heal(amount: int):
	var was_dead = not alive
	hp += amount
	if hp > max_hp:
		hp = max_hp
	if was_dead and alive:
		revived.emit()
		_revived()

func _revived():
	if costume != null:
		costume.play("idle")

func get_sp(amount: int):
	sp += amount
	if sp > max_sp:
		sp = max_sp

var battlefield: Battlefield

signal joined_battle(Battlefield)

func join_battle(battle: Battlefield):
	battlefield = battle
	battle.begin.connect(begin)
	battle.top.connect(top)
	battle.telegraph.connect(telegraph)
	battle.player_action.connect(player_action)
	battle.enemy_action.connect(enemy_action)
	var battle_idle = ActorIdle.new()
	battle.done.connect(done)
	battle.done.connect(func(_w): battle_idle.finished = true)
	push_mode(battle_idle)
	_join_battle(battle)
	joined_battle.emit(battlefield)

func _join_battle(_battle: Battlefield):
	pass

func begin():
	_begin()

func top():
	_top()

func telegraph():
	_telegraph()

func player_action():
	_player_action()

func enemy_action():
	_enemy_action()

func done(player_victory: bool):
	_done(player_victory)

func _begin():
	pass

func _top():
	pass

func _telegraph():
	pass

func _player_action():
	pass

func _enemy_action():
	pass

func _done(_player_victory: bool):
	pass
