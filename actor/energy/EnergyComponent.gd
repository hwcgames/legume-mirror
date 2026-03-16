@abstract
extends Resource
class_name EnergyComponent

signal spent(amount: int)
signal restored(amount: int)

var sp: int:
	get:
		return _get_energy()
	set(energy):
		_set_energy(energy)
var min: int:
	get:
		return _get_min()
	set(energy):
		_set_min(energy)
var max: int:
	get:
		return _get_max()
	set(energy):
		_set_max(energy)

var fighter: Fighter

@export var normal_sp: bool = true

@abstract
func _get_min() -> int
@abstract
func _get_max() -> int
@abstract
func _set_min(energy: int)
@abstract
func _set_max(energy: int)

@abstract
func _get_energy() -> int

@abstract
func _set_energy(energy: int)

func remaining() -> int:
	return max(0, sp - min)

func battle_end():
	sp = min
