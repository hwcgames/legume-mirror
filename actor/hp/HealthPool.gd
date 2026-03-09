class_name HealthPool
extends HealthComponent

@export var current_hp: int
@export var max_hp: int

func _get_min() -> int:
	return 0
func _get_max() -> int:
	return max_hp

var max_init: bool = false

func _set_min(health: int):
	pass
func _set_max(health: int):
	max_hp = health
	max_init = true

func _get_health() -> int:
	return current_hp

func _set_health(health: int):
	current_hp = max(health, 0, max_hp if max_init else health)
