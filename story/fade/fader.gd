extends CanvasLayer

var current_fade: Fade

func fade_out(to_fade: String):
	if is_instance_valid(current_fade):
		fade_in()
	var fade_scn: PackedScene = load("res://database/fade/%s.tscn" % to_fade)
	var fade: Fade = fade_scn.instantiate()
	add_child(fade)
	current_fade = fade
	await fade.fade_out()

func fade_in():
	var fade = current_fade
	if not fade:
		return
	current_fade = null
	await fade.fade_in()
	fade.queue_free()
