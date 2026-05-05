extends Encounterable
class_name Encounter

@export var enemies: Array[EnemyFactory]
@export var song: PackedScene

func roll_encounter() -> Encounter:
	return self

func apply_to_battlefield(battlefield: Battlefield):
	battlefield.song = song
	for enemy in battlefield.enemies:
		enemy.queue_free()
	battlefield.enemies.clear()
	for enemy_factory in enemies:
		var enemy_sheet: ActorSheet = enemy_factory.roll_enemy()
		var enemy: Actor = Actor.from_sheet(enemy_sheet)
		battlefield.enemies.push_back(enemy)
		enemy.home_landmark = battlefield.enemy_landmarks[len(battlefield.enemies)-1]
		battlefield.add_child(enemy)
		enemy.global_transform = enemy.home_landmark.global_transform
