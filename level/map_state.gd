extends Resource
class_name MapState

@export var current_position: Vector2i
@export var width: int
@export var height: int
@export var map: Dictionary[Vector2i, MapRoom]
