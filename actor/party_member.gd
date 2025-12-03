extends Fighter
class_name PartyMember

## How many turns this actor has left.
## Usually 0 or 1, but not always.
var turns: int = 0

@onready var battle_planner: BattlePlanner = $BattlePlanner
@onready var skill_challenge: SkillChallenge = $SkillChallenge

func _player_action():
	turns = 1
	while turns > 0 and battlefield.phase == Battlefield.PHASE.PLAYER_ACTION:
		var action = await battle_planner.choose()
		await action.call(self)
		turns -= 1

func basic_attack(_p: PartyMember, target: Enemy):
	var lock = await battlefield.exclusive_lock()
	await get_tree().create_timer(1.).timeout
	if !target.alive:
		for enemy in battlefield.enemies:
			if enemy.alive:
				target = enemy
	if !target.alive:
		print("No living targets!")
		lock.call()
		return
	print(self, " attacks ", target, "!")
	var skill = await skill_challenge.skill_challenge(randi_range(20,40))
	var damage = (self.strength*skill/20)-(3*target.defense)
	if damage > 0:
		print(damage, " damage!")
		target.take_damage(damage)
	else:
		print("Miss!")
	lock.call()
