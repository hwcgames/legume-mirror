@abstract
extends Resource
class_name Encounterable

@export var weight: float = 1.

@abstract func roll_encounter() -> Encounter
