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
	subplanner.list = self
	return subplanner

func get_spells(actor: Actor) -> Array[BattleAction]:
	var spells = spell_list.duplicate()
	for item in actor.sheet.party_component.equips:
		spells.append_array(item.equip_actions)
	return spells
