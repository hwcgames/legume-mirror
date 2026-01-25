extends Line2D

@export var top_balloon: ChatBalloon

func _process(delta: float) -> void:
	global_position = Vector2.ZERO
	var _top_balloon = top_balloon
	var new_points := PackedVector2Array()
	while true:
		new_points.push_back(_top_balloon.global_position)
		if _top_balloon.next_balloon != null:
			_top_balloon = _top_balloon.next_balloon
		else:
			new_points.push_back(_top_balloon.character_root.global_position)
			break
	points = new_points
