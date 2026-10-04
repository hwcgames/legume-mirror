extends SubViewportContainer

@export var camera_host: PhantomCameraHost

var tween: Tween
var active: bool = false

func _ready() -> void:
	size_flags_stretch_ratio = 0.
	hide()

func _process(delta: float) -> void:
	var new_active = is_instance_valid(camera_host.get_active_pcam()) and (camera_host.get_active_pcam() as PhantomCamera3D).priority > 0
	if new_active != active:
		set_active(new_active)

func set_active(new_active: bool):
	active = new_active
	if is_instance_valid(tween):
		tween.kill()
	tween = create_tween()
	tween.tween_callback(func():
		if active:
			show())
	tween.tween_property(self, "size_flags_stretch_ratio", 1.0 if active else 0., 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_callback(func():
		if !active:
			hide())
	tween.play()
