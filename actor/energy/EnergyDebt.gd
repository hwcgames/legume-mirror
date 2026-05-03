extends EnergyComponent
class_name EnergyDebt

@export var max_debt: int = 100
@export var debt: int = 0:
	set(debt):
		self.debt = debt
		emit_changed()

func _get_max() -> int:
	return 0
func _get_min() -> int:
	return -max_debt
func _set_max(energy: int):
	return
func _set_min(energy: int):
	max_debt = -energy
func _get_energy() -> int:
	return -debt
func _set_energy(energy: int):
	debt = clamp(-energy, 0, max_debt)

func battle_end():
	debt = 0
