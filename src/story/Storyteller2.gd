extends Node
class_name Storyteller

var story: InkStory = load("uid://del34gulleoth"):
	set(new_story):
		story = new_story
		bind_functions()

func bind_functions():
	story.BindExternalFunction("in_inky", func(): return false)
	if safety_save != "":
		story.LoadState(safety_save)
	if not is_inside_tree():
		await tree_entered
	await get_tree().process_frame
	for listener in listeners:
		if listener.has_method("bind_story"):
			listener.bind_story(story)

static var me: Storyteller

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	me = self
	story.changed.connect(bind_functions)
	add_to_group("story_listener")
	var spec_timer = Timer.new()
	#spec_timer.timeout.connect(func():
		#spec_timer.start(2)
		#runahead())
	if is_instance_valid(Saver.find()):
		Saver.find().pre_save.connect(pre_save)
		Saver.find().post_load.connect(post_load)

func pre_save(file: SaveFile):
	file.story = ResourceUID.path_to_uid(story.resource_path)
	file.ink_save = JSON.parse_string(story.SaveState())

func post_load(file: SaveFile):
	var save = JSON.stringify(file.ink_save)
	safety_save = save
	story = load(file.story)
	story.LoadState(save)

static func find() -> Storyteller:
	return me

var listeners: Array[Node]:
	get:
		return get_tree().get_nodes_in_group("story_listener")

var barriers: Dictionary[String, Locks] = {}

func wait_barriers(names: Array[String]):
	names.sort()
	var out = []
	for name in names:
		if name not in barriers:
			continue
		out.push_back(await barriers[name].exclusive_lock())
	for lock in out:
		lock.call()

func take_barriers(names: Array[String]) -> Callable:
	names.sort()
	var out = []
	for name in names:
		if name not in barriers:
			barriers[name] = Locks.new()
		out.push_back(await barriers[name].shared_lock())
	return func():
		for lock in out:
			lock.call()

var busy: bool = true
var choices: Array[InkChoice] = []
var leader: Actor:
	get:
		return Actor.find(story.FetchVariable("leader"))
var party_stack: Array[Actor] = []

var choice_queue: Array[StringName] = []

func choose(names: Array[String], persistent: bool = false, dry: bool = false) -> bool:
	if persistent:
		printerr("TODO reimplement persistent choices")
	choices = story.GetCurrentChoices()
	for name in names:
		for index in range(len(choices)):
			var choice: InkChoice = choices[index]
			if choice.GetText().begins_with(name):
				if not dry:
					story.ChooseChoiceIndex(index)
					if busy:
						busy = false
				return true
	if persistent:
		choice_queue.append_array(names)
	return false

func message_listeners(message: String, tags: Array[String]) -> Array[Node]:
	return listeners \
		.filter(func(l: Node): return l.has_method("wants_line") and l.wants_line(message, tags))
func choice_choosers(choice: InkChoice) -> Array[Node]:
	return listeners \
		.filter(func(l: Node): return l.has_method("wants_choice") and l.wants_choice(choice))

func wants_line(message: String, tags: Array[String]) -> bool:
	match message.split(" ", false):
		["/", "divert", var address]:
			return true
	return false
func take_line(message: String, tags: Array[String]):
	match message.split(" ", false):
		["/", "divert", var address]:
			story.ChoosePathString(address)

signal new_choice(choices: Array[InkChoice])
signal chosen(choice: InkChoice)

var safety_save: String = ""

func runahead():
	if !story.GetCanContinue():
		return []
	var save: String = story.SaveState()
	var counter: int = 0
	while story.GetCanContinue() and counter < 10:
		counter += 1
		var line = story.Continue()
		var tags: Array[String] = story.GetCurrentTags()
		advise_line(line, tags)
	story.LoadState(save)

func _process(delta: float) -> void:
	if busy or !is_instance_valid(story):
		return
	if !story.GetCanContinue():
		choices = story.GetCurrentChoices()
		while !choice_queue.is_empty():
			var choice = choice_queue.pop_front()
			if choose([choice], false):
				return
		for choice in choices:
			var wanted: bool = listeners.any(func(l: Node):
				return l.has_method("wants_choice") and l.wants_choice(choice))
			if not wanted:
				print("WARNING: Story choice \"%s\" is not wanted by any story listener!" % choice.GetText())
		busy = true
		new_choice.emit(choices)
		return
	while story.GetCanContinue():
		story.SwitchToDefaultFlow()
		var line = story.Continue().strip_edges()
		safety_save = story.SaveState()
		var tags: Array[String] = story.GetCurrentTags()
		await send_line(line, tags)
signal new_line(line: String, tags: Array[String])
func send_line(line: String, tags: Array[String]):
	var was_busy = busy
	busy = true
	var wants_barriers: Array[String] = []
	if not "!W:main" in tags:
		wants_barriers.push_back("main")
	var blocks_barriers: Array[String] = []
	if not "!b:main" in tags:
		blocks_barriers.push_back("main")
	var wanted_by: Array[Node] = message_listeners(line, tags)
	var safety_time: float = wanted_by.map(func(l: Node): return l.safety_time() if l.has_method("safety_time") else 15.).max() if !wanted_by.is_empty() else 0.
	if safety_time == null:
		return 0.
	for tag in tags:
		if tag.begins_with("W:"):
			wants_barriers.push_back(tag.trim_prefix("W:"))
		if tag.begins_with("b:"):
			blocks_barriers.push_back(tag.trim_prefix("b:"))
		if tag.begins_with("safety:"):
			safety_time = float(tag.trim_prefix("safety:"))
	var blocking: Callable
	if "main" in wants_barriers:
		await wait_barriers(wants_barriers)
		blocking = await take_barriers(blocks_barriers)
	
	(func():
		if "main" not in wants_barriers:
			await wait_barriers(wants_barriers)
			blocking = await take_barriers(blocks_barriers)
		var lock = Locks.new()
		if safety_time < 100.:
			get_tree().create_timer(safety_time, false).timeout.connect(func():
				if lock.shared_locks > 0:
					lock.shared_locks = 0
					lock.shared_free.emit())
		wanted_by = message_listeners(line, tags)
		if wanted_by.is_empty():
			print("WARNING: The line \"%s\" with tags %s isn't wanted by any story listener!" % [line, tags])
		for listener in wanted_by:
			var handle = await lock.shared_lock()
			(func():
				await listener.take_line(line, tags)
				handle.call()
			).call()
		new_line.emit(line, tags)
		if lock.shared_locks > 0:
			await lock.shared_free
		blocking.call()
	).call()
	if not was_busy:
		busy = false

func advise_line(line: String, tags: Array[String]):
	var wanted_by: Array[Node] = message_listeners(line, tags)
	for wanter in wanted_by:
		if !wanter.has_method("notice_line"):
			continue
		wanter.notice_line(line, tags)

static func ordinal(num: int) -> String:
	var suffix: String
	if floor(num / 10) == 1:
		suffix = "th"
	else:
		match num % 10:
			1: suffix = "st"
			2: suffix = "nd"
			3: suffix = "rd"
			_: suffix = "th"
	return str(num) + suffix
static func name_day(year: int, month: int, day: int, weekday: int) -> String:
	var year_name: String
	match year:
		0: year_name = "20XX"
		1: year_name = "20XY"
		2: year_name = "20XZ"
		_: year_name = str(year)
	var month_name: String
	match month:
		1: month_name = "January"
		2: month_name = "February"
		3: month_name = "March"
		4: month_name = "April"
		5: month_name = "May"
		6: month_name = "June"
		7: month_name = "July"
		8: month_name = "August"
		9: month_name = "September"
		10: month_name = "October"
		11: month_name = "November"
		12: month_name = "December"
	var weekday_name: String
	match weekday:
		1: weekday_name = "Monday"
		2: weekday_name = "Tuesday"
		3: weekday_name = "Wednesday"
		4: weekday_name = "Thursday"
		5: weekday_name = "Friday"
		6: weekday_name = "Saturday"
		7: weekday_name = "Sunday"
	var ordinal = ordinal(day)
	return weekday_name + ", " + month_name + " " + ordinal + ", " + year_name
const location_names: Dictionary[String, String] = {
	"map": "A bird's-eye view.",
	"school_front": "Before a learned one.",
	"apartment": "Yours."
}
const location_fallback: String = "A place outside place."
static func name_location(location: String) -> String:
	if location in location_names:
		return location_names[location]
	return location_fallback
