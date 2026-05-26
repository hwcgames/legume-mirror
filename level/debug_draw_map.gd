extends Node2D
class_name DebugDrawMap

@export var map: DungeonMap
@export var cell_size: Vector2 = Vector2(24, -24)

func _draw() -> void:
	for point in map.map.keys():
		if not point in map.map:
			continue
		var room = map.map[point]
		var origin = Vector2(0, -cell_size.y * map.height)
		for point2 in room.outgoing:
			draw_line(origin + cell_size * Vector2(point), origin + cell_size * Vector2(point2), Color.BLACK, 2.)
		var color: Color
		match room.room_type:
			DungeonMap.ROOM_TYPE.EMPTY: color = Color.WHITE
			DungeonMap.ROOM_TYPE.MONSTER: color = Color.PINK
			DungeonMap.ROOM_TYPE.ITEM: color = Color.PURPLE
			DungeonMap.ROOM_TYPE.EVENT: color = Color.BLUE
			DungeonMap.ROOM_TYPE.SAFE: color = Color.GREEN
			DungeonMap.ROOM_TYPE.BOSS: color = Color.RED
			DungeonMap.ROOM_TYPE.SHOP: color = Color.YELLOW
		draw_circle(origin + cell_size * Vector2(point), 4 if map.current_position == point else 2, color, true)

func _process(delta: float) -> void:
	queue_redraw()
