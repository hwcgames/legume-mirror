extends SkillChallenge

@export var frame_count: int = 30

func start():
	var cursor: ColorRect = %Cursor
	cursor.modulate = Color.TRANSPARENT
	get_tree().create_tween().tween_property(cursor, "modulate", Color.WHITE, 0.5)
	cursor.anchor_left = 1.
	cursor.anchor_right = 1.
	show()
	var off = frame_count
	while off >= -2:
		off -= 1
		cursor.anchor_left = float(off) / frame_count
		cursor.anchor_right = float(off) / frame_count
		for i in range(2):
			await get_tree().physics_frame
		if MultiplayerInput.is_action_pressed(party_member.device_index, "ui_accept"):
			break
	get_tree().create_timer(0.5).timeout.connect(queue_free)
	if off < -2:
		(func():
			var further = off
			while true:
				further -= 1
				cursor.anchor_left = float(further) / frame_count
				cursor.anchor_right = float(further) / frame_count
				for i in range(2):
					await get_tree().physics_frame
			).call()
		get_tree().create_tween().tween_property(cursor, "modulate", Color.TRANSPARENT, 0.5)
		result.emit(0)
	match off:
		0: result.emit(150)
		1 or -1: result.emit(120)
		2 or -2: result.emit(110)
		_: result.emit(100-(off*2))
