extends Control
class_name Fade

func fade_out():
	await get_tree().process_frame
func fade_in():
	await get_tree().process_frame
