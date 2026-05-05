@abstract
extends Resource
class_name BattleComponent

@abstract
func _begin(actor: Actor)

@abstract
func _top(actor: Actor)

@abstract
func _telegraph(actor: Actor)

@abstract
func _player_action(actor: Actor)

@abstract
func _enemy_action(actor: Actor)

@abstract
func _done(actor: Actor, _player_victory: bool)
