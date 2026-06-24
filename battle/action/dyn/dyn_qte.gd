extends DynActionStep
class_name StepQte

@export var result_register: String = "skill"
@export var miss_message: String = "Swing and a miss..."
@export var miss_register: String = "miss"

func check(source: Object, them: Actor) -> bool:
	return true

func plan(source: Object, them: Actor, planner: BattlePlanner, registers: Dictionary) -> bool:
	return false

func before(source: Object, them: Actor, battlefield: Battlefield, registers: Dictionary) -> bool:
	var challenge: SkillChallenge = them.setup_challenge()
	challenge.frame_count = randi_range(20, 40)
	challenge.start()
	var skill = await challenge.result
	registers[result_register] = skill
	registers[miss_register] = skill <= 0
	if skill <= 0:
		Storyteller.find().choose(["%s misses" % them.name, "party misses"])
		battlefield.println(miss_message.format(registers))
		registers[miss_register] = true
		return true
	registers[miss_register] = false
	return false

func after(source: Object, them: Actor, battlefield: Battlefield, registers: Dictionary):
	pass
