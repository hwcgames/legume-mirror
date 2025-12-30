extends Resource
class_name MapRoom

@export var incoming: Array[Vector2i] = []
@export var outgoing: Array[Vector2i] = []
@export var room_type: DungeonMap.ROOM_TYPE = DungeonMap.ROOM_TYPE.EMPTY
