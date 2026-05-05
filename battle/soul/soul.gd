extends Node2D
class_name Soul

@export var speed: float = 196.
@export var janky_diagonals: bool = false
@export var border_margin: float = 8.
@export var invuln_time: float = 3.
var players: Array[Actor] = []
var device_index: int = -1
var invuln: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	move(delta)
	clip_to_world()
	if invuln:
		graze_state.travel("invuln")
	elif !grazers.is_empty():
		graze_state.travel("near")
	else:
		graze_state.travel("idle")
	pass

func move(delta: float):
	var command = MultiplayerInput.get_vector(device_index, "left", "right", "up", "down")
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
	#if area in already_grazed:
		#return
	if not area.should_graze:
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
	if not area.should_graze:
		return
	grazers.remove_at(grazers.find(area))
	graze_state.start("tick")
	if invuln:
		return
	area._on_graze_player(self )

func _on_hurt(area: Node) -> void:
	if invuln:
		return
	if not area.has_method("_on_hurt_player"):
		if area.get_parent() != null:
			_on_hurt(area.get_parent())
		return
	if area in grazers:
		grazers.remove_at(grazers.find(area))
	area._on_hurt_player(self )
	if area.should_invuln:
		invuln = true
		await get_tree().create_timer(invuln_time).timeout
		invuln = false
		%GrazeShape.disabled = true
		%HurtShape.disabled = true
		await get_tree().physics_frame
		%GrazeShape.disabled = false
		%HurtShape.disabled = false
