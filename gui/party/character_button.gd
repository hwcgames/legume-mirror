extends PanelContainer
class_name PartyUiCharacterButton

var sheet: ActorSheet:
	set(new_sheet):
		sheet = new_sheet
		update()

signal pressed(sheet: ActorSheet)

func update():
	%Name.text = sheet.name
	self_modulate = sheet.bg_color
	%Button.pressed.connect(func(): pressed.emit(sheet))
