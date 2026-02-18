extends RichTextLabel
class_name Typewriter

var skipping: bool = false
var typewriter_time: float = 0.02

func wait(time: float):
	if not skipping:
		await get_tree().create_timer(time).timeout
	else:
		await get_tree().physics_frame

func type_messages(instructions: Array[Message.Instruction]):
	for instruction in instructions:
		instruction.prepare_label(self)
	for instruction in instructions:
		await instruction.execute(self)
