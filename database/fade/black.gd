extends Fade

func fade_out(instant: bool = false):
	self.modulate = Color.TRANSPARENT
	await create_tween().tween_property(self, "modulate", Color.WHITE, 1. if not instant else 0.).finished
func fade_in(instant: bool = false):
	await create_tween().tween_property(self, "modulate", Color.TRANSPARENT, 1. if not instant else 0.).finished
