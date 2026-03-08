extends CharacterBody3D
class_name Actor

@export var human_name: StringName = name
@export var costume: Costume:
	set(new_costume):
		if costume != null:
			costume.hide()
			costume.queue_free()
		costume = new_costume
		if not is_ancestor_of(new_costume):
			if new_costume.is_inside_tree():
				new_costume.reparent(self , false)
			else:
				add_child(new_costume)
@export var interactable: Interactable
var head: Marker3D:
	get:
		return costume.head
var head_position: Vector3:
	get:
		return head.global_position

@onready var navigation: NavigationAgent3D = %NavigationAgent3D

var mode_stack: Array[ActorMode] = []

func _ready():
	add_to_group("actor")
	if interactable:
		interactable.choices.insert(0, "%s" % human_name)

var top_mode: ActorMode:
	get:
		var t = mode_stack.get(len(mode_stack) - 1)
		if t == null:
			t = ActorIdle.new()
			t.actor = self
			mode_stack = [t]
		return t

func _physics_process(delta: float):
	velocity = Vector3.ZERO
	var t := top_mode
	if not t.finished and not t.finishing:
		t._process(delta)
	while t.finished:
		if t.finishing:
			break;
		while t.finished and not t.finishing:
			pop_mode()
		t = top_mode
	move_and_slide()

func push_mode(mode: ActorMode) -> ActorMode:
	var old_mode = top_mode
	if old_mode != null:
		await old_mode._covered(mode)
	mode.actor = self
	mode_stack.push_back(mode)
	await mode._activate()
	return mode

func pop_mode() -> ActorMode:
	var mode = top_mode
	if mode.finishing:
		return mode
	mode.finishing = true
	await mode._deactivate()
	mode_stack.pop_back()
	mode.popped.emit()
	await top_mode._uncovered()
	return mode

func play(name: StringName, wait_for_arrival: bool = false, wait_for_completion: bool = false):
	await costume.play(name, wait_for_arrival, wait_for_completion)

static func find(actor_name: StringName) -> Actor:
	for node in Storyteller.get_tree().get_nodes_in_group("actor"):
		if node.name == actor_name:
			return node
	return null

static func from_sheet(sheet: ActorSheet) -> Actor:
	var a: Actor = preload("uid://dsmw0etg767jy").instantiate();
	a.name = sheet.resource_path.trim_prefix("res://database/actors/").trim_suffix(".tres")
	a.human_name = sheet.name
	a.costume = sheet.costume.instantiate()
	return a
