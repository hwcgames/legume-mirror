extends RigidBody2D
class_name ChoiceBalloon

@export var anchor: ChatBalloon
@export var force: Vector2 = Vector2(50., 20.)
@export var satisfactory_distance: float
@export var separation: float

var size: Vector2:
	get:
		return %PanelContainer.size

signal chose(index: int)

func _ready():
	#if anchor == null:
		#global_position = get_viewport_rect().get_center()
		#return
	var parent_position: Vector2 = anchor.global_position if anchor else (get_viewport_rect().size * Vector2(0.5, 1.0))
	var anchor_size = anchor.size.y if anchor else 0.
	global_position = parent_position + Vector2(0., separation) * (size.y/2) * (anchor_size/2)

func choose(choices: Array[InkChoice]):
	for child in %ChoiceParent.get_children():
		child.queue_free()
	for index in range(len(choices)):
		var choice = choices[index]
		var button = Button.new()
		button.text = choice.GetText()
		button.pressed.connect(func():
			chose.emit(choice.GetIndex()))
		%ChoiceParent.add_child(button)
	return await chose

func _physics_process(delta: float) -> void:
	if anchor == null:
		global_position = get_viewport_rect().get_center()
		return
	(%CollisionShape2D.shape as RectangleShape2D).size = size
	var parent_position: Vector2 = anchor.global_position
	var goal_position = parent_position + Vector2(0., separation) * (size.y/2) * (anchor.size.y/2)
	var force_this_tick = global_position.direction_to(goal_position) \
		* force * (clamp(global_position.distance_to(goal_position) / satisfactory_distance, 0, 1))
	apply_central_force(force_this_tick)
