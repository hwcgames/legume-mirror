extends Control
class_name Fade

func fade_out(instant: bool = false):
	await get_tree().process_frame
func fade_in(instant: bool = false):
	await get_tree().process_frame
