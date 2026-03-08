extends RefCounted
class_name Message

var chat_balloon_scene: PackedScene
var dialogue_box_scene: PackedScene

static var last_box: String = "spoken"

var actor: Actor
var instructions: Array[Instruction]
var box: String
var expression: String
const voices_for_box: Dictionary = {
	"spoken": "typed",
	"loudspeaker": "typed",
	"thought": "pling",
	"written": "written"
}

static func from_str(str: String, tags: Array[String]) -> Message:
	var msg = Message.new()
	var split_index = str.find(": ")
	if split_index == -1:
		return null
	msg.actor = Actor.find(str.substr(0, split_index))
	var line = str.substr(split_index + 2)
	msg.instructions = Instruction.parse(line)
	for tag in tags:
		if tag.begins_with("ty:"):
			last_box = tag.trim_prefix("ty:")
		if tag.begins_with("expr:"):
			msg.expression = tag.trim_prefix("expr:")
	msg.box = last_box
	if msg.box in voices_for_box:
		msg.instructions.insert(0, ChangeVoice.new(voices_for_box[msg.box]))
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
			return rest
		str = str.trim_prefix("%")
		var second_percent = str.find("%")
		rest.append_array(parse(str.substr(second_percent + 1)))
		str = str.substr(0, second_percent)
		print(str.split(":"))
		match Array(str.split(":")):
			["expr", var expr]:
				rest.push_front(Express.new(expr))
			["expr", var expr, var actor]:
				rest.push_front(Express.new(expr, actor))
			["act", var act]:
				rest.push_front(Act.new(act))
			["act", var act, var actor]:
				rest.push_front(Act.new(act, actor))
			["p", var length]:
				rest.push_front(Pause.new(float(length)))
			["i"]:
				rest.push_front(Instant.new())
			["tw"]:
				rest.push_front(StartTypewriter.new())
			["v", var voice]:
				rest.push_front(ChangeVoice.new(voice))
			["char", var name]:
				rest.push_front(TextLeaf.new(Saver.current_save.get_character_sheet(name).name))
			_:
				printerr("Malformed inline command '%s'" % str)
		return rest
	
	@abstract func prepare_label(label: Typewriter)
	@abstract func execute(label: Typewriter)


class TextLeaf extends Instruction:
	var last_voice: float = -999.
	var time: float = 0.
	var text: String
	func _init(text: String):
		self.text = text
		Storyteller.get_tree().physics_frame.connect(func():
			self.time += 1.0 / Engine.physics_ticks_per_second)
	var start: int
	var end: int
	var idx = 0
	func prepare_label(label: Typewriter):
		start = label.get_parsed_text().length()
		label.text += text
		end = label.get_parsed_text().length()
	func execute(label: Typewriter):
		label.visible_characters = start
		var in_tag = false
		while label.visible_characters < end:
			#var current_char = text[idx]
			#idx += 1
			#if current_char == '[':
				#in_tag = true
				#continue
			#if current_char == ']':
				#in_tag = false
				#continue
			#if in_tag:
				#continue
			var current_char = label.get_parsed_text()[label.visible_characters]
			label.visible_characters += 1
			if label.voice and \
				idx < len(text) and \
				current_char not in ' !,.?"\'' and \
				label.voice_player and \
				(self.time - last_voice) > label.voice.min_delay:
					last_voice = self.time
					label.voice_player.play()
			var wait_mul: float = 1.
			match current_char:
				".", "!", "?", "­—": wait_mul = 15.
				",", ";": wait_mul = 5.
			await label.wait(label.typewriter_time * wait_mul)

class Express extends Instruction:
	var actor: String
	var expr: String
	func _init(expr: String, actor = ""):
		self.expr = expr
		self.actor = actor
	func prepare_label(label: Typewriter):
		pass
	func execute(label: Typewriter):
		var actor = Actor.find(actor)
		if actor:
			actor.costume.play("expr_%s" % expr)

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

class ChangeVoice extends Instruction:
	var voice: Voice
	func _init(voice: String):
		self.voice = load("res://database/voices/%s.tres" % voice)
	func prepare_label(label: Typewriter):
		pass
	func execute(label: Typewriter):
		if !voice:
			return
		label.voice = self.voice
		var stream := AudioStreamRandomizer.new()
		for sound in self.voice.sounds:
			stream.add_stream(-1, sound)
		label.voice_player.stream = stream
		label.voice_player.max_polyphony = voice.polyphony
