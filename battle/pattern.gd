extends Resource
class_name BulletPattern

## Enemies that must be present for this bullet pattern to be a candidate
@export_file("*.tres") var enemies: Array[String] = []

## If a pattern is shared, all enemies carrying the pattern will choose it when it appears.
@export var shared: bool = false

## The enemy must be in one of these states to pick this pattern
@export var states: Array[int] = [0]

## The probability multiplier of this pattern.
@export var weight = 1.

enum PATTERN_CATEGORY {
	## Composable with support patterns.
	SOLO,
	## Composable with team and support patterns.
	TEAM,
	## Composable with itself and support patterns.
	## Only affects the board once.
	JOINT,
	## Composable with any other pattern.
	SUPPORT
}
## Which type of pattern is this?
@export var category: PATTERN_CATEGORY = PATTERN_CATEGORY.TEAM

### An exclusive pattern can only coexist with patterns that explicitly list it as a friend.
#@export var exclusive: bool = false
#@export_file("*.tres") var friends: Array[String] = []

## Bullet pattern scene that should appear
@export var pattern_scene: PackedScene

## Telegraph scene that should appear
@export var telegraph_scene: PackedScene = preload("res://battle/telegraph/null_telegraph.tscn")

func create(battlefield: Battlefield, enemy: Actor) -> Control:
	var pattern: BulletPatternLayer = pattern_scene.instantiate()
	pattern.battlefield = battlefield
	pattern.enemy = enemy
	return pattern

func copy() -> BulletPattern:
	return self.duplicate()
