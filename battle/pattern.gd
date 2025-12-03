extends Resource
class_name BulletPattern

## Enemies that must be present for this bullet pattern to be a candidate
@export_file("enemies/*.tres") var enemies: Array[String] = []

## If a pattern is shared, all enemies carrying the pattern will choose it when it appears.
@export var shared: bool = false

## The enemy must be in one of these states to pick this pattern
@export var states: Array[int] = [0]

## An exclusive pattern can only coexist with patterns that explicitly list it as a friend.
@export var exclusive: bool = false
@export_file("battle/pattern/*.tres") var friends: Array[String] = []

## Bullet pattern scene that should appear
@export var pattern_scene: PackedScene

## Telegraph scene that should appear
@export var telegraph_scene: PackedScene = preload("res://battle/telegraph/null_telegraph.tscn")

func create(battlefield: Battlefield) -> Control:
	var pattern = pattern_scene.instantiate()
	pattern.battlefield = battlefield
	return pattern
