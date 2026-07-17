extends RefCounted
class_name NMessage

class Region:
	var begin: int
	var end: int
	func _init(b: int, e: int):
		begin = b
		end = e
var sheet: ActorSheet
var text: String = ""
signal new_text(text: String)
var bg_color: Color
var text_color: Color
var voice: Voice
var tags: Array[String] = []
var regions: Dictionary[String, Region] = {}
var special: Dictionary[int, Callable] = {}

static var last_character: String = ""
static var last_voice: Voice

static func from_str(line: String, tags: Array[String]) -> NMessage:
	if line.begins_with("/"):
		return null
	var m = NMessage.new()
	m.tags = tags
	var iof = -1
	if line.begins_with("> "):
		iof = 0
	elif line.begins_with("("):
		pass
	else:
		iof = line.find(": ")
		if iof == -1:
			return null
	#var split = line.split(": ", false, 2)
	var split = [line.substr(0, iof), line.substr(iof + 2 if iof != -1 else 0)]
	if len(split) < 2:
		return null
	var name = split[0]
	var path = "res://database/actors/%s.tres" % name
	var enemy_path = "res://database/enemy/static/%s.tres" % name
	m.sheet = load(path) if FileAccess.file_exists(path) else load(enemy_path) if FileAccess.file_exists(enemy_path) else ActorSheet.new()
	if m.sheet.name == "Actor":
		m.sheet.name = name
	m.bg_color = m.sheet.bg_color
	m.text_color = m.sheet.text_color
	m.voice = m.sheet.default_voice
	m.interval = m.sheet.default_interval
	if name != last_character:
		last_voice = null
		last_character = name
	if line.begins_with("("):
		m.sheet.name = "Narrator"
		m.voice = null
	if line.begins_with(">"):
		m.sheet.name = "Thought"
		m.voice = load("res://database/voices/pling.tres")
	if is_instance_valid(last_voice):
		m.voice = last_voice
	for tag in tags:
		if tag.begins_with("v:"):
			last_voice = load("res://database/voices/%s.tres" % tag.trim_prefix("v:"))
			m.voice = last_voice
			break
	last_voice = m.voice
	line = split[1]
	var cursor = 0
	while cursor < len(line):
		var c = line[cursor]
		if c != "{":
			m.text += c
			cursor += 1
			continue
		if c == "{" and cursor < len(line) - 1 and line[cursor + 1] == "{":
			m.text += c
			cursor += 2
			continue
		var closing = line.find("}", cursor)
		if cursor == len(line) - 1:
			printerr("ERROR: Opening command bracket isn't allowed at the end of a line: ", line)
			return null
		if closing == -1:
			print_rich("ERROR: Unmatched command bracket: ", line.substr(0, cursor), "[color=red]", line[cursor], "[/color]", line.substr(cursor + 1))
			return null
		var command = command_from_str(line.substr(cursor + 1, closing - (cursor + 1)), tags)
		var others = (func(m, l): m.special[cursor].call(m, l)) if cursor in m.special else func(m, l): pass
		m.special[cursor] = func(m, l):
			await others.call(m, l)
			await command.call(m, l)
		cursor = closing + 1
	return m

static func command_from_str(cmd: String, tags: Array[String]) -> Callable:
	var words = Array(cmd.split(" ", false))
	match words:
		["region", var r]:
			return func(m: NMessage, l: RichTextLabel):
				m.regions[r] = Region.new(l.visible_characters, l.visible_characters)
		["/region", var r]:
			return func(m: NMessage, l: RichTextLabel):
				m.regions[r].end = l.visible_characters + 1
		["swap", var r, ..]:
			var rest = Array(words.slice(2)).reduce(func(a, b): return "{0} {1}".format([a, b]))
			return func(m: NMessage, l: RichTextLabel):
				m.splice(rest, m.regions[r])
		["interval", var i]:
			var interval = float(i)
			return func(m: NMessage, l: RichTextLabel):
				m.interval = interval
		["cmd", ..]:
			var rest = Array(words.slice(1)).reduce(func(a, b): return "{0} {1}".format([a, b]))
			return func(m: NMessage, l: RichTextLabel):
				await Storyteller.find().send_line(rest, [])
		["voice", var v]:
			var path = "res://database/voices/%s.tres" % v
			if FileAccess.file_exists(path):
				var new_voice = load(path)
				return func(m: NMessage, l: RichTextLabel):
					m.voice = new_voice
			printerr("ERROR: Tried to change to a nonexistent voice")
		#["color", var a]:
			#return func(m: NMessage, l: RichTextLabel):
				#var path = "res://database/actors/%s.tres" % a
				#if FileAccess.file_exists(path):
					#var sheet: ActorSheet = load(path)
					#m.text_color = sheet.text_color
					#m.voice = sheet.default_voice
		["wait", var t]:
			var time_ := float(t)
			return func(m: NMessage, l: RichTextLabel):
				if m.skipping:
					return
				var time = time_
				while time > 0.:
					await l.get_tree().physics_frame
					time -= 1.0 / Engine.physics_ticks_per_second
					if Input.is_action_just_pressed("ui_accept") or Input.is_action_pressed("menu"):
						time = 0.
	print(cmd)
	return func(message: NMessage, label: RichTextLabel): print(cmd)

func splice(new_content: String, region: Region):
	var before_len = region.end - region.begin
	var change_in_len = len(new_content) - before_len
	text.erase(region.begin, before_len)
	text.insert(region.begin, new_content)
	var end = region.end
	var fix_index = (func(i: int):
		if i < end:
			return i
		return i + change_in_len)
	for r in regions.values():
		r.begin = fix_index.call(r.begin)
		r.end = fix_index.call(r.end)
	var new_special = {}
	for i in special.keys():
		new_special[fix_index.call(i)] = special[i]
	special = new_special
	new_text.emit(text)

var interval = 0.03
var skipping = false
var timer: float = 0.

func interval_mul(c: String):
	match c:
		".", "!", "?", "­—": return 15.
		",", ";": return 5.

var waited_this_frame = 0.

func wait(time: float):
	waited_this_frame += time
	if waited_this_frame > 1. / Engine.physics_ticks_per_second:
		await Storyteller.find().get_tree().create_timer(time).timeout

func play_on(label: RichTextLabel):
	var last_voice = -999.
	var tick = func():
		timer += 1.0 / Engine.physics_ticks_per_second
	label.get_tree().physics_frame.connect(tick)
	var reset_waited = func():
		waited_this_frame = 0.
	label.get_tree().physics_frame.connect(reset_waited)
	var start_skipping = func():
		if (Input.is_action_just_pressed("ui_accept") or Input.is_action_pressed("menu")) and label.visible_characters > 2:
			skipping = true
	label.get_tree().physics_frame.connect(start_skipping)
	var update_label_txt = func(txt: String):
		label.text = txt
	new_text.connect(update_label_txt)
	label.text = text
	label.visible_characters = 0
	label.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	var last_color := Color.TRANSPARENT
	var player = AudioStreamPlayer.new()
	label.add_child(player)
	player.stream = AudioStreamPolyphonic.new()
	player.play()
	var playback: AudioStreamPlaybackPolyphonic = player.get_stream_playback()
	var cursor = 0
	while cursor < len(text):
		var bracket = text[cursor] == '['
		while bracket:
			bracket = bracket && text[cursor] != ']'
			if cursor in special:
				special[cursor - 1].call(self, label)
			cursor += 1
		if cursor >= len(text):
			break
		var c = text[cursor]
		var parsed = label.get_parsed_text()
		var voice_c = parsed[label.visible_characters] if label.visible_characters < len(parsed) else ' '
		var voice_s: AudioStream = voice.stream_for(voice_c) if is_instance_valid(voice) else null
		if is_instance_valid(voice) and timer - last_voice > voice.min_delay and is_instance_valid(voice_s) and label.visible_characters < len(parsed) - 1:
			last_voice = timer
			player.max_polyphony = voice.polyphony
			playback.play_stream(voice_s, 0, voice.volume)
			#if player.stream != voice_stream:
				#player.stream = voice_stream
		if label.visible_characters in special:
			await special[label.visible_characters].call(self, label)
		label.visible_characters += 1
		cursor += 1
		if (not skipping):
			#await label.get_tree().create_timer(interval).timeout
			var mul = 1.
			match voice_c:
				'.', '!', '?': mul = 15.
				',', ';', ':': mul = 10.
				' ': mul = 0.
			await wait(interval * mul)
	label.get_tree().physics_frame.disconnect(tick)
	label.get_tree().physics_frame.disconnect(reset_waited)
	label.get_tree().physics_frame.disconnect(start_skipping)
