extends CanvasLayer
class_name Bubble

func safety_time() -> float:
	return INF

#func wants_line(line: String, tags: Array[String]) -> bool:
	#var is_dialogue = NMessage.from_str(line, tags) != null
	#var is_queue_choice = line.begins_with("/ choice ")
	#var is_clear = line == "/ clear"
	#var is_hide = line == "/ done"
	#var wanted = is_dialogue or is_queue_choice or is_clear or is_hide
	#return wanted
#
#func take_line(line: String, tags: Array[String]):
	#var dialogue = NMessage.from_str(line, tags)
	#var is_queue_choice = line.begins_with("/ choice ")
	#var is_clear = line == "/ clear"
	#var is_hide = line == "/ done"
	#if dialogue != null:
		#await message(NMessage.from_str(line, tags))
	#elif is_queue_choice:
		#choice_msg = line.trim_prefix("/ choice ")
	#elif is_clear:
		#for child in %ContentsZone.get_children():
			#child.queue_free()
	#elif is_hide:
		#hide()

func wants_line(line: String, tags: Array[String]) -> bool:
	return do_line(line, tags) is Callable
func take_line(line: String, tags: Array[String]):
	await do_line(line, tags).call()
func do_line(line: String, tags: Array[String]):
	var dialogue = NMessage.from_str(line, tags)
	if is_instance_valid(dialogue):
		return func():
			await message(dialogue)
	var words = line.split(" ", false)
	match Array(words):
		["/", "choice", ..]:
			return func():
				choice_msg = Array(words.slice(2)).reduce(func(a, b): return a + " " + b)
		["/", "clear"]:
			if not visible:
				return null
			return func():
				for child in %ContentsZone.get_children():
					child.queue_free()
		["/", "dialogue"]:
			return func():
				for child in %ContentsZone.get_children():
					child.queue_free()
				show()
		["/", "done"]:
			if not visible:
				return null
			return func():
				for child in %ContentsZone.get_children():
					child.queue_free()
				hide()
	return null

func _to_string() -> String:
	return "Main Dialogue Bubble"

func wants_choice(choice: InkChoice) -> bool:
	return choice.GetTags().any(func(t: String): return t in ["c:up", "c:down", "c:left", "c:right"])

var choice_msg: String
static var me: Bubble
static func find() -> Bubble:
	return me

func _ready() -> void:
	%Sprite.play("idle")
	Storyteller.find().new_choice.connect(new_choice)
	Storyteller.find().chosen.connect(chosen)
	#Storyteller.find().new_line.connect(func(line: String, tags: Array[String]):
		#if not wants_line(line, tags):
			#hide())
	%Continue.hide()
	me = self
	visible = false

var last_character: String

func message(m: NMessage):
	show()
	%Sprite.play("typing")
	if m.sheet.name != last_character or "clear" in m.tags:
		last_character = m.sheet.name
		for child in %ContentsZone.get_children():
			child.queue_free()
	%Sprite.modulate = m.bg_color
	var txt: RichTextLabel = preload("uid://bwjbuoo6krawa").instantiate()
	%ContentsZone.add_child(txt)
	txt.text = m.text
	txt.visible_characters = 0
	await get_tree().process_frame
	%ScrollContainer.scroll_vertical += 10000
	%Box.custom_minimum_size = %ContentsZone.get_children().map(func(c: Control): return c.size).max() + Vector2(0, 32)
	await m.play_on(txt)
	%Sprite.play("idle")
	var wait = -1
	for tag in m.tags:
		if tag.begins_with("w:"):
			wait = float(tag.trim_prefix("w:"))
			break
	if wait == -1:
		%Continue.show()
		%Continue.grab_focus()
		await %Continue.pressed
		%Continue.hide()
	else:
		await get_tree().create_timer(wait).timeout
	#hide()

var picker: Picker

func new_choice(choices: Array[InkChoice]):
	if choices.is_empty():
		return
	if not (is_instance_valid(choice_msg) and not choice_msg.is_empty()):
		return
	show()
	if is_instance_valid(picker):
		picker.queue_free()
	picker = preload("uid://c2mfjwaf7yy16").instantiate()
	for child in %ContentsZone.get_children():
		child.queue_free()
	%Sprite.modulate = Color.WHITE
	%ContentsZone.add_child(picker)
	picker.new_choice(choices)
	pass

func chosen():
	if is_instance_valid(picker):
		picker.queue_free()
	hide()
	pass
