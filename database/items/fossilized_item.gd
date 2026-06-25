extends Resource
class_name FossilizedItem

@export_file_path(".tres") var item: String
@export var charges: int = 0
@export var registers: Dictionary = {}

func reanimate() -> Item:
	var new: Item = load(item)
	new = new.copy()
	new.charges = charges
	new.registers = registers.duplicate()
	return new
