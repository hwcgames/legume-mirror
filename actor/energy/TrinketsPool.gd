extends EnergyPool
class_name TrinketsPool

@export var trinkets_on_field: int = 0:
	set(new_trinkets):
		var amt = new_trinkets - trinkets_on_field
		trinkets_on_field = new_trinkets
		trinkets_changed.emit(amt)

signal trinkets_changed(amount: int)
