extends RichTextLabel
class_name Typewriter

var skipping: int = 0
var typewriter_time: float = 0.02
var voice: Voice = preload("uid://coudm8kl2h00x")
@export var face: AnimatedSprite2D
@export var voice_player: AudioStreamPlayer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		skipping = 2

var skip_count = 0
var waited_this_frame = 0.
var last_delta = 0.

func _process(delta: float) -> void:
	last_delta = delta
	waited_this_frame = 0

func wait(time: float):
	if skipping > 0:
		time = 0.
	waited_this_frame += time
	if waited_this_frame > last_delta:
		await get_tree().create_timer(time).timeout
	#if not skipping:
		#await get_tree().create_timer(time).timeout
	#else:
		#skip_count += 1
		#if skip_count >= 10:
			#await get_tree().physics_frame
			#skip_count = 0

func type_messages(instructions: Array[Message.Instruction]):
	skipping = 0
	for instruction in instructions:
		instruction.prepare_label(self)
	for instruction in instructions:
		await instruction.execute(self)
	if skipping == 1:
		skipping = 0
	await wait(typewriter_time * 50.)
