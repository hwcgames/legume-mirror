extends Node
class_name Inventory

@export var items: Array[Item] = [
	load("res://database/items/pocket-coffee.tres").duplicate(),
	load("res://database/items/pocket-coffee.tres").duplicate(),
	load("res://database/items/pocket-coffee.tres").duplicate(),
	load("res://database/items/re-granola.tres").duplicate(),
	load("res://database/items/re-granola.tres").duplicate(),
	load("res://database/items/re-granola.tres").duplicate(),
	load("res://database/items/ritual-ration.tres").duplicate(),
	load("res://database/items/ritual-ration.tres").duplicate(),
	load("res://database/items/ritual-ration.tres").duplicate(),
	load("res://database/items/crest-of-compression.tres").duplicate(),
]

static var me: Inventory

func _ready() -> void:
	me = self

static func find() -> Inventory:
	return me
