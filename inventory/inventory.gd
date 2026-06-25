extends Node
class_name Inventory

@export var items: Array[Item] = [
	load("res://database/items/pocket-coffee.tres").copy(),
	load("res://database/items/pocket-coffee.tres").copy(),
	load("res://database/items/pocket-coffee.tres").copy(),
	load("res://database/items/re-granola.tres").copy(),
	load("res://database/items/re-granola.tres").copy(),
	load("res://database/items/re-granola.tres").copy(),
	load("res://database/items/ritual-ration.tres").copy(),
	load("res://database/items/ritual-ration.tres").copy(),
	load("res://database/items/ritual-ration.tres").copy(),
	load("res://database/items/crest-of-compression.tres").copy(),
]

static var me: Inventory

func _ready() -> void:
	me = self
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

static func find() -> Inventory:
	return me
