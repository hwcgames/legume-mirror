extends Encounterable
class_name EncounterTable

@export var encounters: Array[Encounterable] = []

func roll_encounter() -> Encounter:
	var total_weight = 0.
	for encounter in encounters:
		total_weight += encounter.weight
	var roll = randf_range(0, total_weight)
	for encounter in encounters:
		roll -= encounter.weight
		if roll <= 0:
			return encounter.roll_encounter()
	return null
