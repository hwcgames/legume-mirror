extends Node
class_name Inventory

@export var items: Array[Item] = [
	#load("res://database/items/pocket-coffee.tres").copy(),
	#load("res://database/items/pocket-coffee.tres").copy(),
	#load("res://database/items/pocket-coffee.tres").copy(),
	#load("res://database/items/re-granola.tres").copy(),
	#load("res://database/items/re-granola.tres").copy(),
	#load("res://database/items/re-granola.tres").copy(),
	#load("res://database/items/ritual-ration.tres").copy(),
	#load("res://database/items/ritual-ration.tres").copy(),
	#load("res://database/items/ritual-ration.tres").copy(),
	#load("res://database/items/crest-of-compression.tres").copy(),
]

func _ready() -> void:
	me = self
	add_to_group("story_listener")
	for item in items:
		print(item.path)
	if is_instance_valid(Saver.find()):
		Saver.find().pre_save.connect(pre_save)
		Saver.find().post_load.connect(post_load)

func pre_save(file: SaveFile):
	file.inventory = []
	for i in items:
		file.inventory.push_back(i.fossilize())

func post_load(file: SaveFile):
	items = []
	for i in file.inventory:
		items.push_back(i.reanimate())

static var me: Inventory
static func find() -> Inventory:
	return me

func equipped_on(item: Item) -> ActorSheet:
	var saver = Saver.find()
	for actor in saver.current_save.character_sheets.values():
		if item in (actor as ActorSheet).party_component.equips:
			return actor
	return null

func item_count(item_name: String) -> int:
	var path = "res://database/items/%s.tres" % item_name
	return len(items.filter(func(i: Item): return i.path == path))
func item_has(item_name: String) -> bool:
	return item_find(item_name) != -1
func item_find(item_name: String) -> int:
	return item_find_nth(item_name, 0)
func item_find_nth(item_name: String, nth: int) -> int:
	var path = "res://database/items/%s.tres" % item_name
	var last_idx = -1
	while last_idx < len(items):
		var idx = items.find_custom(func(i: Item): return i.path == path, last_idx + 1)
		if nth == 0:
			return idx
		if idx == -1:
			return -1
		last_idx = idx
		nth -= 1
	return -1
func item_get_charges(item_idx: int) -> int:
	return items[item_idx].charges
func item_get_register(item_idx: int, register: String) -> Variant:
	return items[item_idx].registers[register]

func _to_string() -> String:
	return "Inventory"
func bind_story(story: InkStory):
	story.BindExternalFunction("item_count", item_count)
	story.BindExternalFunction("item_has", item_has)
	story.BindExternalFunction("item_find", item_find)
	story.BindExternalFunction("item_find_nth", item_find_nth)
	story.BindExternalFunction("item_get_charges", item_get_charges)
	story.BindExternalFunction("item_get_register", item_get_register)
func wants_line(line: String, tags: Array[String]) -> bool:
	return do_line(line, tags) is Callable
func take_line(line: String, tags: Array[String]):
	await do_line(line, tags).call()
func do_line(line: String, _tags: Array[String]):
	var words = Array(line.split(" ", false))
	match words:
		["/", "give", "item", var item_name]:
			var path = "res://database/items/%s.tres" % item_name
			if not FileAccess.file_exists(path):
				return null
			return func():
				var item: Item = load(path).copy()
				items.push_back(item)
		["/", "take", "item", var item_idx]:
			var idx = int(item_idx)
			if idx < 0 or idx >= len(items):
				return null
			return func():
				items.remove_at(idx)
		["/", "set", "item", var item_idx, "charges", var charge_amt]:
			var idx = int(item_idx)
			var charges = int(charge_amt)
			if idx < 0 or idx >= len(items):
				return null
			return func():
				items[idx].charges = charges
		["/", "set", "item", var item_idx, "register", var name, ..]:
			var idx = int(item_idx)
			if idx < 0 or idx >= len(items):
				return null
			if len(words) <= 6:
				return null
			var rest = words.slice(6).reduce(func(a, b): return a + " " + b)
			var expr = Expression.new()
			var error = expr.parse(rest)
			if error != Error.OK:
				return null
			return func():
				items[idx].registers[name] = expr.execute()
		pass
	return null
