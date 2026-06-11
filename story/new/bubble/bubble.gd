extends CenterContainer
class_name NDialogueBubble

func wants_line(line: String, tags: Array[String]) -> bool:
	return RMessage.from_str(line, tags) != null
func take_line(line: String, tags: Array[String]):
	await message(NMessage.from_str(line, tags))

func _ready() -> void:
	%Sprite.play("idle")

func message(m: NMessage):
	%Sprite.play("typing")
	for child in %ContentsZone.get_children():
		child.queue_free()
	%Sprite.modulate = m.bg_color
	var txt: RichTextLabel = preload("uid://bwjbuoo6krawa").instantiate()
	%ContentsZone.add_child(txt)
	await m.play_on(txt)
	%Sprite.play("idle")
