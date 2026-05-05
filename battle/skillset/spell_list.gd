extends Skillset
class_name SkillsetSpellList

@export var name: StringName = "Magic"
@export var description: StringName = "Showcase your special talent."
@export var spell_list: Array[BattleAction] = []

func label(party_member: Actor) -> String:
	return name
func tooltip(party_member: Actor) -> String:
	return description

@export var subplanner_scene: PackedScene = preload("uid://bgym47jf3uuxo")

func subplanner(party_member: Actor) -> SubPlanner:
	var subplanner: SpellListPlanner = subplanner_scene.instantiate()
	subplanner.spells = spell_list
	return subplanner
