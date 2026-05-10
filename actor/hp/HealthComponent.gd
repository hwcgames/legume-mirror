@abstract
extends Resource
class_name HealthComponent

signal took_damage(amount: int)
signal healed(amount: int)
signal died
signal revived

var alive: bool:
	get:
		return hp > min
var hp: int:
	get:
		return _get_health()
	set(health):
		var old_hp = hp
		_set_health(health)
		emit_changed()
		if old_hp <= min and hp > min:
			revived.emit()
		if old_hp > min and hp <= min:
			died.emit()
		if hp != old_hp:
			changed.emit()
		if hp > old_hp:
			healed.emit(hp - old_hp)
		if hp < old_hp:
			took_damage.emit(old_hp - hp)
var max: int:
	get:
		return _get_max()
	set(health):
		_set_max(health)
		emit_changed()
var min: int:
	get:
		return _get_min()
	set(health):
		_set_min(health)
		emit_changed()

var fighter: Actor

func copy() -> HealthComponent:
	return self.duplicate()

@abstract
func _get_health() -> int
@abstract
func _set_health(health: int)
@abstract
func _get_max() -> int
@abstract
func _set_max(health: int)
@abstract
func _get_min() -> int
@abstract
func _set_min(health: int)
