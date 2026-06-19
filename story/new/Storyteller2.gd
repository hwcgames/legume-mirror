extends Node

var story: InkStory = load("uid://del34gulleoth"):
	set(new_story):
		story = new_story
		bind_functions()

func bind_functions():
	story.BindExternalFunction("in_inky", func(): return false)
	if safety_save != "":
		story.LoadState(safety_save)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bind_functions()
	story.changed.connect(bind_functions)

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
	return false

func message_listeners(message: String, tags: Array[String]) -> Array[Node]:
	return listeners \
		.filter(func(l: Node): return l.has_method("wants_line") and l.wants_line(message, tags))
func choice_choosers(choice: InkChoice) -> Array[Node]:
	return listeners \
		.filter(func(l: Node): return l.has_method("wants_choice") and l.wants_choice(choice))

signal new_choice(choices: Array[InkChoice])
signal chosen(choice: InkChoice)

var safety_save: String = ""

func _process(delta: float) -> void:
	if busy or !is_instance_valid(story):
		return
	if !story.GetCanContinue():
		choices = story.GetCurrentChoices()
		for choice in choices:
			var wanted: bool = listeners.any(func(l: Node):
				return l.has_method("wants_choice") and l.wants_choice(choice))
			if not wanted:
				print("WARNING: Story choice \"%s\" is not wanted by any story listener!" % choice.GetText())
		busy = true
		new_choice.emit(choices)
		return
	while story.GetCanContinue():
		var line = story.Continue()
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
