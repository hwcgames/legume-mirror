extends Resource
class_name Item

@export var name: StringName = "Thingamawhatsit"
@export var description: StringName = "I found this in my pocket, once. I'm not sure where it came from."
@export var battle_action: BattleAction
@export var charges: int = 0
@export var tags: Array[String] = []
