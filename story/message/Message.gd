extends RefCounted
class_name Message

var chat_balloon_scene: PackedScene
var dialogue_box_scene: PackedScene

static var last_box: String = "spoken"

var actor: Actor
var instructions: Array[Instruction]
var box: String
var expression: String

static func from_str(str: String, tags: Array[String]) -> Message:
	var msg = Message.new()
	var split_index = str.find(": ")
	if split_index == -1:
		return null
	msg.actor = Actor.find(str.substr(0, split_index))
	var line = str.substr(split_index + 2)
	msg.instructions = Instruction.parse(line)
	for tag in tags:
		if tag.begins_with("box:"):
			last_box = tag.trim_prefix("box:")
		if tag.begins_with("expr:"):
			msg.expression = tag.trim_prefix("expr:")
	msg.box = last_box
	return msg

@abstract class Instruction extends RefCounted:
	static func parse(str: String) -> Array[Instruction]:
		var first_percent = str.find("%")
		if first_percent == -1:
			return [TextLeaf.new(str)]
		var rest: Array[Instruction]
		if first_percent != 0:
			rest = parse(str.substr(first_percent))
			rest.push_front(TextLeaf.new(str.substr(0, first_percent)))
		str = str.trim_prefix("%")
		var second_percent = str.find("%")
		rest = parse(str.substr(second_percent + 1))
		str = str.substr(0, second_percent)
		match str.split(":"):
			["e", var expr]:
				rest.push_front(Express.new(expr))
			["e", var expr, var actor]:
				rest.push_front(Express.new(expr, actor))
			["a", var act]:
				rest.push_front(Act.new(act))
			["a", var act, var actor]:
				rest.push_front(Act.new(act, actor))
			["p", var length]:
				rest.push_front(Pause.new(float(length)))
			["i"]:
				rest.push_front(Instant.new())
			["tw"]:
				rest.push_front(StartTypewriter.new())
			_:
				printerr("Malformed inline command '%s'" % str)
		return rest
	
	@abstract func prepare_label(label: Typewriter)
	@abstract func execute(label: Typewriter)

class TextLeaf extends Instruction:
	var text: String
	func _init(text: String):
		self.text = text
	var start: int
	var end: int
	func prepare_label(label: Typewriter):
		start = len(label.text)
		end = start + len(text)
		label.text += text
	func execute(label: Typewriter):
		label.visible_characters = start
		while label.visible_characters < end:
			label.visible_characters += 1
			var wait_mul: float = 1.
			match label.text[label.visible_characters - 1]:
				".", "!", "?", "­—": wait_mul = 5.
				",", ";": wait_mul = 3.
			await label.wait(label.typewriter_time)

class Express extends Instruction:
	var actor: String
	var expr: String
	func _init(expr: String, actor = null):
		self.expr = expr
		self.actor = actor
	func prepare_label(label: Typewriter):
		pass
	func execute(label: Typewriter):
		Actor.find(actor).costume.play("expr_%s" % expr)

class Act extends Instruction:
	var actor: String
	var act: String
	func _init(act: String, actor = null):
		self.act = act
		self.actor = actor
	func prepare_label(label: Typewriter):
		pass
	func execute(label: Typewriter):
		Actor.find(actor).costume.play(act)

class Pause extends Instruction:
	var length: float
	func _init(length: float):
		self.length = length
	func prepare_label(label: Typewriter):
		pass
	func execute(label: Typewriter):
		await label.wait(length)

class Instant extends Instruction:
	func prepare_label(label: Typewriter):
		pass
	func execute(label: Typewriter):
		label.skipping = true
class StartTypewriter extends Instruction:
	func prepare_label(label: Typewriter):
		pass
	func execute(label: Typewriter):
		label.skipping = false
