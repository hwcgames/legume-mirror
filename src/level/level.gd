extends Resource
class_name Level

## The initial roomset to use when loading this level
@export var roomset: RoomSet

## The initial room to spawn in this level
@export var entrances: Dictionary[StringName, RoomInfo]
