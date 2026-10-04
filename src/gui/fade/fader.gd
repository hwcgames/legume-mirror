extends CanvasLayer

var current_fade: Fade

func _ready():
	add_to_group("story_listener")


func wants_line(line: String, tags: Array[String]) -> bool:
	return do_line(line, tags) is Callable
func take_line(line: String, tags: Array[String]):
	await do_line(line, tags).call()
func do_line(line: String, _tags: Array[String]):
	var words = Array(line.split(" ", false))
	match words:
		["/", "fade", "in"]:
			return func():
				await fade_in()
		["/", "cut", "in"]:
			return func():
				await fade_in(true)
		["/", "fade", var fade]:
			return func():
				await fade_out(fade)
		["/", "cut", var fade]:
			return func():
				await fade_out(fade, true)
	return null

func fade_out(to_fade: String, instant: bool = false):
	if is_instance_valid(current_fade):
		current_fade.queue_free()
	var fade_scn: PackedScene = load("res://database/fade/%s.tscn" % to_fade)
	if !is_instance_valid(fade_scn):
		printerr("ERROR: Bad fade %s" % to_fade)
		return
	var fade: Fade = fade_scn.instantiate()
	add_child(fade)
	current_fade = fade
	await fade.fade_out(instant)

func fade_in(instant: bool = false):
	var fade = current_fade
	if not is_instance_valid(fade):
		return
	current_fade = null
	await fade.fade_in(instant)
	fade.queue_free()
