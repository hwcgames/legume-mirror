extends RigidBody2D
class_name ChatBalloon

var character_root: Marker3D
var actor: Actor
var next_balloon: ChatBalloon
@export var force: Vector2 = Vector2(50., 20.)
@export var satisfactory_distance: float = 16.
@export var separation: float = 64.
@export var lifetime: float = 30.
@export var max_width: float = 256.
var elapsed: float = 0.
var expired: bool:
	get:
		return elapsed > lifetime
var size: Vector2:
	get:
		return %PanelContainer.size
var text: String:
	get:
		return %Label.text
	set(text):
		%Label.text = text

var last_root_position: Vector2 = Vector2.INF
func root_screen_position():
	if character_root != null:
		last_root_position = get_viewport().get_camera_3d().unproject_position(character_root.global_position)
	if last_root_position == Vector2.INF:
		return get_viewport_rect().size * Vector2(0.5, 1.)
	return last_root_position

func _ready():
	global_position = root_screen_position() + Vector2.UP * separation * 0.75
	%Label.resized.connect(_on_label_resized)
	_on_label_resized()

func _on_label_resized():
	if %Label.size.x > max_width:
		%Label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		%Label.custom_minimum_size = Vector2(max_width, 0.)

func _physics_process(delta: float) -> void:
	elapsed += delta
	(%CollisionShape2D.shape as RectangleShape2D).size = size
	var root_position = root_screen_position()
	var character_up_position = root_position.y - separation - size.y / 2
	var balloon_up_position = ((next_balloon.global_position.y - next_balloon.size.y/2  - separation - size.y / 2) if next_balloon != null else character_up_position)
	var goal_position: Vector2 = Vector2(
		next_balloon.global_position.x if next_balloon != null and next_balloon.character_root == character_root else root_position.x,
		min(balloon_up_position, character_up_position)
	)
	var force_this_tick = global_position.direction_to(goal_position) \
		* force * (clamp(global_position.distance_to(goal_position) / satisfactory_distance, 0, 1))
	apply_central_force(force_this_tick)

func play_message(message: Message):
	actor = message.actor
	if actor:
		character_root = actor.head
	if message.expression != null and actor:
		actor.play("expr_%s" % message.expression)
	await %Label.type_messages(message.instructions)
