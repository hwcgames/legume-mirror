extends Fade

func fade_out():
	await create_tween().tween_property(self, "modulate", Color.WHITE, 1.).finished
func fade_in():
	await create_tween().tween_property(self, "modulate", Color.TRANSPARENT, 1.).finished
