extends Node2D
class_name Soul

@export var speed: float = 196.
@export var janky_diagonals: bool = false
@export var border_margin: float = 8.
var players: Array[PartyMember] = []
var device_index: int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	move(delta)
	clip_to_world()
	if !grazers.is_empty():
		graze_state.travel("near")
	else:
		graze_state.travel("idle")
	pass

func move(delta: float):
	var command = MultiplayerInput.get_vector(device_index, "ui_left", "ui_right", "ui_up", "ui_down")
	if command.length() > 1. and not janky_diagonals:
		command = command.normalized()
	var movement = command * speed * delta
	position += movement

func clip_to_world():
	var battle_world: Control = get_parent();
	var world_rect = battle_world.get_rect().grow(-border_margin)
	world_rect.position -= battle_world.position
	position = position.clamp(world_rect.position, world_rect.position + world_rect.size)

@onready var graze_state: AnimationNodeStateMachinePlayback = %GrazeAnimator.get("parameters/playback")

var grazers: Array[Node] = []
var already_grazed: Array[Node] = []

func _on_graze(area: Node) -> void:
	if not area.has_method("_on_graze_player"):
		if area.get_parent() != null:
			_on_graze(area.get_parent())
		return
	if area in already_grazed:
		return
	already_grazed.push_back(area)
	grazers.push_back(area)

func _on_graze_exited(area: Node) -> void:
	if not area.has_method("_on_graze_player"):
		if area.get_parent() != null:
			_on_graze_exited(area.get_parent())
		return
	if not area in grazers:
		return
	grazers.remove_at(grazers.find(area))
	graze_state.start("tick")
	area._on_graze_player(self)

func _on_hurt(area: Node) -> void:
	if not area.has_method("_on_hurt_player"):
		if area.get_parent() != null:
			_on_hurt(area.get_parent())
		return
	if area in grazers:
		grazers.remove_at(grazers.find(area))
	area._on_hurt_player(self)
