extends Window

@onready var party_picker: OptionButton = %PartyPicker
@onready var enemy_picker: OptionButton = %EnemyPicker
@onready var battletest: Node3D = $".."
@onready var battlefield: Battlefield = %Battlefield

func _ready():
	populate_party()
	populate_enemies()
	battlefield.done.connect(func(_w): get_tree().reload_current_scene())

func populate_party():
	var dir := DirAccess.open("res://database/party_members")
	party_picker.clear()
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		if not file.ends_with(".tres"):
			continue
		party_picker.add_item(file)
		party_picker.set_item_metadata(-1, load("res://database/party_members/%s" % file))

func populate_enemies():
	var dir := DirAccess.open("res://database/enemy/static")
	enemy_picker.clear()
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		if not file.ends_with(".tres"):
			continue
		enemy_picker.add_item(file)
		enemy_picker.set_item_metadata(-1, load("res://database/enemy/static/%s" % file))

func spawn_selected_ally():
	var sheet: CharacterSheet = party_picker.get_selected_metadata()
	var ally: PartyMember = PartyMember.from_character_sheet(sheet)
	battletest.add_child(ally)
	battlefield.players.push_back(ally)
	pass

func spawn_selected_enemy():
	var sheet: EnemySheet = enemy_picker.get_selected_metadata()
	var enemy: Enemy = Enemy.from_enemy_factory(sheet)
	battletest.add_child(enemy)
	battlefield.enemies.push_back(enemy)
	pass
