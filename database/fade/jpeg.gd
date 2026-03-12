extends Fade

func fade_out():
	hide()
	var tween = create_tween().tween_property(%JpegEffect, "quality", 92, 1.)
	await get_tree().process_frame
	show()
	await tween.finished
func fade_in():
	await create_tween().tween_property(%JpegEffect, "quality", 100, 1.).finished
