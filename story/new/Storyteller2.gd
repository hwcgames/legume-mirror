extends Node

var story: InkStory

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

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

var busy: bool = false

func choose(name: String, dry: bool = false) -> bool:
	var choices = story.GetCurrentChoices()
	for index in range(len(choices)):
		var choice: InkChoice = choices[index]
		if choice.GetText().begins_with(name):
			if not dry:
				story.ChooseChoiceIndex(index)
				if busy:
					busy = false
			return true
	return false

func _process(delta: float) -> void:
	if busy:
		return
	if !story.GetCanContinue():
		for choice in story.GetCurrentChoices():
			var wanted: bool = listeners.any(func(l: Node):
				return l.has_method("wants_choice") and l.wants_choice(choice))
			if not wanted:
				print("WARNING: Story choice \"%s\" is not wanted by any story listener!" % choice.GetText())
		busy = true
		return
	while story.GetCanContinue():
		busy = true
		var line = story.Continue()
		var tags: Array[String] = story.GetCurrentTags()
		
		var wants_barriers: Array[String] = []
		if not "!w:main" in tags:
			wants_barriers.push_back("main")
		var blocks_barriers: Array[String] = []
		if not "!b:main" in tags:
			blocks_barriers.push_back("main")
		var safety_time: float = 15
		for tag in tags:
			if tag.begins_with("w:"):
				wants_barriers.push_back(tag.trim_prefix("w:"))
			if tag.begins_with("b:"):
				blocks_barriers.push_back(tag.trim_prefix("b:"))
			if tag.begins_with("safety:"):
				safety_time = float(tag.trim_prefix("safety:"))
		await wait_barriers(wants_barriers)
		var blocking = await take_barriers(blocks_barriers)
		
		(func():
			var lock = Locks.new()
			get_tree().create_timer(safety_time, false).timeout.connect(func():
				if lock.shared_locks > 0:
					lock.shared_locks = 0
					lock.shared_free.emit())
			var wanted: bool = false
			for listener in listeners:
				if listener.has_method("wants_line") and listener.wants_line(line, tags):
					wanted = true
					var handle = await lock.shared_lock()
					(func():
						await listener.take_line(line, tags)
						handle.call()
					).call()
			if !wanted:
				print("WARNING: The line \"%s\" with tags %s isn't wanted by any story listener!" % [line, tags])
			await lock.shared_free
			blocking.call()
		).call()
		busy = false
