class_name EnergyPool
extends EnergyComponent

@export var current_sp: int = max_sp:
	set(sp):
		current_sp = sp
		emit_changed()
@export var max_sp: int:
	set(sp):
		max_sp = sp
		emit_changed()

func _get_min() -> int:
	return 0
func _get_max() -> int:
	return max_sp

func _set_min(energy: int):
	pass
func _set_max(energy: int):
	max_sp = energy

func _get_energy() -> int:
	return current_sp

func _set_energy(energy: int):
	var old_sp = current_sp
	energy = clamp(energy, 0, max_sp)
	current_sp = energy
	if current_sp != old_sp:
		changed.emit()
	if current_sp > old_sp:
		restored.emit(current_sp - old_sp)
	if current_sp < old_sp:
		spent.emit(old_sp - current_sp)
