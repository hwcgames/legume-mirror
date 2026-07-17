extends RefCounted
class_name PartyUiState

enum TAB {
	WEAPON,
	ARMOR,
	SPELL,
	CONSUMABLE,
}
var tab: TAB = TAB.CONSUMABLE:
	set(new_tab):
		tab = new_tab
		changed.emit()

var party: Array[ActorSheet]:
	set(new_party):
		party = new_party
		for sheet in party:
			sheet.changed.connect(changed.emit)
		changed.emit()
var selected_actor: ActorSheet:
	set(new_selected_actor):
		selected_actor = new_selected_actor
		changed.emit()

var hover_item: Item = null:
	set(new_hover_item):
		hover_item = new_hover_item
		changed.emit()
enum ACTION {
	EQUIP,
	UNEQUIP,
	APPLY,
}
var action: ACTION = ACTION.EQUIP:
	set(new_action):
		action = new_action
		changed.emit()
#var src_item: Item = null:
	#set(new_src_item):
		#src_item = new_src_item
		#changed.emit()
#var dest_item: Item = null:
	#set(new_dest_item):
		#dest_item = new_dest_item
		#changed.emit()

signal changed;
