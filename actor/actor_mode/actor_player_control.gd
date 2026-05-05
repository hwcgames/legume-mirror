extends ActorMode
class_name ActorPlayerControl

var last_camera_rotation: float


func _process(delta: float):
	var camera = actor.get_viewport().get_camera_3d()
	var input_rotation = camera.global_rotation.y
	var active_pcam = PhantomCameraManager.get_phantom_camera_hosts()[0].get_active_pcam()
	if active_pcam.has_meta("move_align"):
		input_rotation = (active_pcam.get_node(active_pcam.get_meta("move_align"))).global_rotation.y
	var input = MultiplayerInput.get_vector(PlayerManager.get_player_device(actor.player), "left", "right", "down", "up")
	if input.length() < 0.1 or abs(angle_difference(input_rotation, last_camera_rotation)) < 0.5:
		last_camera_rotation = input_rotation
	var forward = Vector3.FORWARD.rotated(Vector3.UP, last_camera_rotation)
	var right = Vector3.RIGHT.rotated(Vector3.UP, last_camera_rotation)
	if actor.player not in PlayerManager.player_data:
		return
	var movement = (forward * input.y + right * input.x) * 10.
	if movement.length() > 0.1:
		actor.play("walk")
		actor.global_rotation.y = Vector3.FORWARD.signed_angle_to(movement, Vector3.UP)
	else:
		actor.play("idle")
	actor.velocity += movement
	super._process(delta)
