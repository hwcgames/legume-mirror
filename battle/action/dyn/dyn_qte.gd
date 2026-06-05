extends DynActionStep
class_name StepQte

@export var result_register: String = "skill"
@export var miss_message: String = "Swing and a miss..."
@export var miss_register: String = "miss"

func check(them: Actor) -> bool:
	return true

func plan(them: Actor, planner: BattlePlanner, registers: Dictionary) -> bool:
	return false

func before(them: Actor, battlefield: Battlefield, registers: Dictionary) -> bool:
	var challenge: SkillChallenge = them.setup_challenge()
	challenge.frame_count = randi_range(20, 40)
	challenge.start()
	var skill = await challenge.result
	registers[result_register] = skill
	registers[miss_register] = skill <= 0
	if skill <= 0:
		Storyteller.choose_if_available(["%s misses" % them.name, "party misses"])
		battlefield.println(miss_message.format(registers))
		registers[miss_register] = true
		return true
	registers[miss_register] = false
	return false

func after(them: Actor, battlefield: Battlefield, registers: Dictionary):
	pass
