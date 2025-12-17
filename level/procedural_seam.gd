@tool
extends RoomSeam
class_name ProceduralSeam

## This seam can only be matched with other seams of the same profile
@export var profile: StringName:
	set(p):
		profile = p
		update_configuration_warnings()

## When matching a backtrack seam, try to find an option with only one seam (that is, a dead end)
@export var backtrack: bool = false

func _get_configuration_warnings() -> PackedStringArray:
	var out = PackedStringArray()
	if not self.unique_name_in_owner:
		out.push_back("Seams should have a scene-unique name")
	if profile == "" or profile == null:
		out.push_back("Procedural seams should have a profile set")
	print("Seam %s looks OK" % name)
	return out
