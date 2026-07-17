extends Fade

func fade_out(instant: bool = false):
	hide()
	var tween = create_tween().tween_property(%JpegEffect, "quality", 92, 1. if not instant else 0)
	await get_tree().process_frame
	show()
	if not instant:
		await tween.finished
func fade_in(instant: bool = false):
	var tween = create_tween().tween_property(%JpegEffect, "quality", 100, 1. if not instant else 0)
	if not instant:
		await tween.finished
