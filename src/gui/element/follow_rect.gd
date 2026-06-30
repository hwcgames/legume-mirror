extends Control
class_name FollowRect

@export var targets: Array[Control] = []

var current_follow: Control
var tween: Tween
func _process(delta: float) -> void:
	self.top_level = true
	if not (is_instance_valid(current_follow) and current_follow.is_visible_in_tree()):
		var idx = targets.find(func(f: Control): return is_instance_valid(f) and f.is_visible_in_tree())
		if idx == -1:
			return
		current_follow = targets[idx]
		if is_instance_valid(tween):
			tween.kill()
		tween = create_tween()
		tween.tween_property(self, "global_position", current_follow.global_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "size", current_follow.size, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	if is_instance_valid(tween) and tween.is_running():
		return
	global_position = current_follow.global_position
	size = current_follow.size
