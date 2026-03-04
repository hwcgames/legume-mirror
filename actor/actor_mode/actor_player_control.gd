extends ActorMode
class_name ActorPlayerControl

var last_camera_rotation: float

func _process(delta: float):
	var camera = actor.get_viewport().get_camera_3d()
	var input = MultiplayerInput.get_vector(PlayerManager.get_player_device(actor.player if actor is PartyMember else 0), "ui_left", "ui_right", "ui_down", "ui_up")
	if input.length() < 0.1 or abs(angle_difference(camera.global_rotation.y, last_camera_rotation)) < 0.5:
		last_camera_rotation = camera.global_rotation.y
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
