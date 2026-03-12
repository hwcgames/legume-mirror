extends RefCounted
class_name Message

var chat_balloon_scene: PackedScene
var dialogue_box_scene: PackedScene

static var last_box: String = "spoken"

var actor: Actor
var instructions: Array[Instruction]
var text_color: Color = Color.WHITE
var bg_color: Color = Color.BLACK
var box: String
var expression: String
const voices_for_box: Dictionary = {
	"spoken": "typed",
	"loudspeaker": "typed",
	"typed": "typed",
	"text": "beepo",
	"bird": "bird",
	"thought": "pling",
	"written": "written"
}

static func from_str(str: String, tags: Array[String]) -> Message:
	var msg = Message.new()
	var split_index = str.find(": ")
	if split_index == -1:
		return null
	var speaker_str = str.substr(0, split_index)
	#var actor = speaker_str
	#var speaker
	#if speaker_str.cont
	#msg.actor = Actor.find(str.substr(0, split_index))
	match Array(speaker_str.split(" as ")):
		[var actor]:
			msg.actor = Actor.find(actor)
			msg.text_color = msg.actor.text_color if msg.actor else msg.text_color
			msg.bg_color = msg.actor.bg_color if msg.actor else msg.bg_color
		[var actor, var speaker]:
			msg.actor = Actor.find(actor)
			var colors = get_colors(speaker)
			msg.text_color = colors[0]
			msg.bg_color = colors[1]
	var line = str.substr(split_index + 2)
	msg.instructions = Instruction.parse(line, msg.actor)
	for tag in tags:
		if tag.begins_with("ty:"):
			last_box = tag.trim_prefix("ty:")
		if tag.begins_with("expr:"):
			msg.expression = tag.trim_prefix("expr:")
			msg.instructions.insert(0, Express.new(msg.expression))
	msg.box = last_box
	if msg.box in voices_for_box:
		msg.instructions.insert(0, ChangeVoice.new(voices_for_box[msg.box]))
	return msg

static func get_colors(name: String) -> Array[Color]:
	var as_pm: CharacterSheet = load("res://database/party_members/%s.tres" % name)
	var as_actor: ActorSheet = load("res://database/actors/%s.tres" % name)
	var as_enemy: EnemyFactory = load("res://database/enemy/%s.tres" % name)
	if as_pm:
		return [as_pm.text_color, as_pm.bg_color]
	if as_actor:
		return [as_actor.text_color, as_actor.bg_color]
	if as_enemy:
		var enemy = as_enemy.roll_enemy()
		return [enemy.text_color, enemy.bg_color]
	return [Color.WHITE, Color.BLACK]

@abstract class Instruction extends RefCounted:
	static func parse(str: String, me: Actor) -> Array[Instruction]:
		var first_percent = str.find("%")
		if first_percent == -1:
			return [TextLeaf.new(str)]
		var rest: Array[Instruction]
		if first_percent != 0:
			rest = parse(str.substr(first_percent), me)
			rest.push_front(TextLeaf.new(str.substr(0, first_percent)))
			return rest
		str = str.trim_prefix("%")
		var second_percent = str.find("%")
		rest.append_array(parse(str.substr(second_percent + 1), me))
		str = str.substr(0, second_percent)
		print(str.split(":"))
		match Array(str.split(":")):
			["expr", var expr]:
				rest.push_front(Express.new(expr, me))
			["expr", var actor, var expr]:
				rest.push_front(Express.new(expr, Actor.find(actor)))
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
			["playername"]:
				rest.push_front(TextLeaf.new("Player"))
				
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
	var actor: Actor
	var mine: bool = false
	var expr: String
	func _init(expr: String, actor: Actor = null):
		self.expr = expr
		self.actor = actor
	func prepare_label(label: Typewriter):
		pass
	func execute(label: Typewriter):
		if not actor:
			if expr == "none":
				label.face.hide()
			elif label.face.sprite_frames.has_animation(expr):
				label.face.animation = expr
				label.face.show()
			else:
				print("Missing expr %s" % expr)
				label.face.hide()
		if actor:
			actor.costume.play("expr_%s" % expr)

class Act extends Instruction:
	var actor: Actor
	var act: String
	func _init(act: String, actor: Actor = null):
		self.act = act
		self.actor = actor
	func prepare_label(label: Typewriter):
		pass
	func execute(label: Typewriter):
		actor.costume.play(act)

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
