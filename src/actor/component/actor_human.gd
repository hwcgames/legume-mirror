extends ActorComponent
class_name ActorHuman

var last_camera_rotation: float

func _active(delta: float):
	if actor.captured:
		actor.active_component = actor.get_node("%Component/Idle")
		return
	if actor.player not in PlayerManager.player_data:
		return
	var camera = get_viewport().get_camera_3d()
	var input_rotation = camera.global_rotation.y if is_instance_valid(camera) else 0
	var active_pcam = PhantomCameraManager.get_phantom_camera_hosts()[0].get_active_pcam() if !PhantomCameraManager.get_phantom_camera_hosts().is_empty() else null
	if is_instance_valid(active_pcam) and active_pcam.has_meta("move_align"):
		input_rotation = (active_pcam.get_node(active_pcam.get_meta("move_align"))).global_rotation.y
	var input = MultiplayerInput.get_vector(PlayerManager.get_player_device(actor.player), "left", "right", "down", "up")
	if input.length() < 0.1 or abs(angle_difference(input_rotation, last_camera_rotation)) < 0.5:
		last_camera_rotation = input_rotation
	var forward = Vector3.FORWARD.rotated(Vector3.UP, last_camera_rotation)
	var right = Vector3.RIGHT.rotated(Vector3.UP, last_camera_rotation)
	var movement = (forward * input.y + right * input.x) * 10.
	actor.velocity += movement
	actor.get_node("%Component/Idle")._active(delta)
