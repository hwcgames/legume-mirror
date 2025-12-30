extends Resource
class_name CharacterSheet

@export var name: StringName = "Player"
@export var hp: int = 10
@export var sp: int = 10
@export var strength: int = 10
@export var magic: int = 10
@export var defense: int = 0
@export var finesse: int = 10

@export var costume: PackedScene = preload("uid://c4r2ey7i7ooq3")
@export var skill_challenge_scene: PackedScene = preload("uid://bbpp48kcropih")
@export var battle_planner_scene: PackedScene = preload("uid://d21yudvneounm")
@export var basic_attack: BattleAction = BattleActionBasicAttack.new()
@export var skillset: Skillset = SkillsetUnskilled.new()
