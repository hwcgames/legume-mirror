extends RichTextLabel
class_name Typewriter

var skipping: bool = false
var typewriter_time: float = 0.02
var voice: Voice = preload("uid://coudm8kl2h00x")
@export var voice_player: AudioStreamPlayer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		skipping = true

var skip_count = 0

func wait(time: float):
	if not skipping:
		await get_tree().create_timer(time).timeout
	else:
		skip_count += 1
		if skip_count >= 10:
			await get_tree().physics_frame
			skip_count = 0

func type_messages(instructions: Array[Message.Instruction]):
	skipping = false
	for instruction in instructions:
		instruction.prepare_label(self)
	for instruction in instructions:
		await instruction.execute(self)
	await wait(typewriter_time * 50.)
