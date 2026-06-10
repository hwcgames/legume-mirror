extends RefCounted
class_name NMessage

class Region:
	var begin: int
	var end: int
	func _init(b: int, e: int):
		begin = b
		end = e
var text: String = ""
signal new_text(text: String)
var bg_color: Color
var text_color: Color
var voice: Voice:
	set(new_voice):
		voice = new_voice
		voice_stream = AudioStreamRandomizer.new()
		for stream in voice.sounds:
			voice_stream.add_stream(-1, stream)
var voice_stream: AudioStreamRandomizer
var regions: Dictionary[String, Region] = {}
var special: Dictionary[int, Callable] = {}

static func from_str(line: String, tags: Array[String]) -> NMessage:
	if line.begins_with(">>>"):
		return null
	var m = NMessage.new()
	var iof = line.find(": ")
	if iof == -1:
		return null
	#var split = line.split(": ", false, 2)
	var split = [line.substr(0, iof), line.substr(iof + 2)]
	if len(split) < 2:
		return null
	var name = split[0]
	var path = "res://database/actors/%s.tres" % name
	var sheet: ActorSheet = load(path) if FileAccess.file_exists(path) else ActorSheet.new()
	m.bg_color = sheet.bg_color
	m.text_color = sheet.text_color
	m.voice = sheet.default_voice
	line = split[1]
	var cursor = 0
	while cursor < len(line):
		var c = line[cursor]
		if c != "{":
			m.text += c
			cursor += 1
			continue
		if c == "{" and cursor < len(line)-1 and line[cursor+1] == "{":
			m.text += c
			cursor += 2
			continue
		var closing = line.find("}", cursor)
		if cursor == len(line) - 1:
			printerr("ERROR: Opening command bracket isn't allowed at the end of a line: ", line)
			return null
		if closing == -1:
			print_rich("ERROR: Unmatched command bracket: ", line.substr(0, cursor), "[color=red]", line[cursor], "[/color]", line.substr(cursor+1))
			return null
		var command = command_from_str(line.substr(cursor+1, closing-(cursor+1)), tags)
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
				m.regions[r].end = l.visible_characters+1
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
				await Storyteller2.send_line(rest, [])
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
					if Input.is_action_just_pressed("ui_accept"):
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

const silent_chars: String = " !,.?\"\'"
func interval_mul(c: String):
	match c:
		".", "!", "?", "­—": return 15.
		",", ";": return 5.

var waited_this_frame = 0.

func wait(time: float):
	waited_this_frame += time
	if waited_this_frame > 1. / Engine.physics_ticks_per_second:
		await Storyteller2.get_tree().create_timer(time).timeout

func play_on(label: RichTextLabel):
	var last_voice = -999.
	var tick = func():
		timer += 1.0 / Engine.physics_ticks_per_second
	label.get_tree().physics_frame.connect(tick)
	var reset_waited = func():
		waited_this_frame = 0.
	label.get_tree().physics_frame.connect(reset_waited)
	var start_skipping = func():
		if Input.is_action_just_pressed("ui_accept") and label.visible_characters > 2:
			skipping = true
	label.get_tree().physics_frame.connect(start_skipping)
	var update_label_txt = func(txt: String):
		label.text = txt
	new_text.connect(update_label_txt)
	label.text = text
	label.visible_characters = 0
	label.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	var last_color := Color.TRANSPARENT
	while label.visible_characters < len(text):
		var bracket = text[label.visible_characters] == '['
		while bracket:
			bracket &= text[label.visible_characters] != ']'
			if label.visible_characters in special:
				special[label.visible_characters-1].call(self, label)
			label.visible_characters += 1
		if label.visible_characters >= len(text):
			break
		if timer - last_voice > voice.min_delay and text[label.visible_characters] not in silent_chars:
			last_voice = timer
			var player = AudioStreamPlayer.new()
			label.add_child(player)
			player.finished.connect(player.queue_free)
			player.stream = voice_stream
			player.volume_db = voice.volume
			player.play()
		if label.visible_characters in special:
			await special[label.visible_characters].call(self, label)
		if not skipping:
			#await label.get_tree().create_timer(interval).timeout
			await wait(interval)
		label.visible_characters += 1
	label.get_tree().physics_frame.disconnect(tick)
	label.get_tree().physics_frame.disconnect(reset_waited)
	label.get_tree().physics_frame.disconnect(start_skipping)
