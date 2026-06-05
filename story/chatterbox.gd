extends CanvasLayer

var oldest: ChatBalloon
var newest: ChatBalloon
var choice_balloon: ChoiceBalloon
@export var chat_balloon_scene: PackedScene
@export var choice_balloon_scene: PackedScene

var actors: Dictionary[String, Actor] = {}

func _ready():
	Storyteller.new_line.connect(func(line: String, tags: Array[String]):
		var l = await Storyteller.lock.shared_lock()
		var message = Message.from_str(line, tags)
		await self.message(message)
		l.call())

func wants_line(line: String, tags: Array[String]) -> bool:
	return Message.from_str(line, tags) != null
func take_line(line: String, tags: Array[String]):
	await message(Message.from_str(line, tags))


func queue_dialogue_choice():
	Storyteller.new_choices.connect(choose, ConnectFlags.CONNECT_ONE_SHOT)

func _physics_process(_delta: float) -> void:
	if oldest == null or not is_instance_valid(newest):
		return
	if oldest.expired or oldest.global_position.y < -100:
		oldest.queue_free()
		oldest = oldest.next_balloon
	%ChatLine.top_balloon = oldest
	if not is_instance_valid(newest):
		newest = null

func push_balloon(balloon: ChatBalloon):
	if newest == null:
		oldest = balloon
		newest = balloon
		add_child(balloon)
		return
	else:
		add_child(balloon)
		newest.next_balloon = balloon
		newest = balloon

func clear():
	if oldest == null:
		newest = null
		return
	oldest.queue_free()
	oldest = oldest.next_balloon
	clear()

func simple_message(actor: Actor, text: String):
	var message = Message.from_str("%s: %s" % [actor, text], [])
	message.actor = actor
	await self.message(message)
	#var balloon := chat_balloon_scene.instantiate()
	#balloon.text = text
	#balloon.actor = actor
	#balloon.character_root = actor.head
	#push_balloon(balloon)
	pass

func message(message: Message):
	if message == null:
		return
	var balloon: ChatBalloon = chat_balloon_scene.instantiate()
	if message.actor:
		balloon.actor = message.actor
		balloon.character_root = message.actor.head
	push_balloon(balloon)
	await balloon.play_message(message)

func choose(choices: Array[InkChoice]):
	var balloon: ChoiceBalloon = choice_balloon_scene.instantiate()
	balloon.anchor = newest
	var old_separation = newest.separation if newest else 0.
	if newest:
		newest.separation = 96.
	if choice_balloon != null:
		choice_balloon.queue_free()
	choice_balloon = balloon
	add_child(balloon)
	var choice = await balloon.choose(choices)
	choice_balloon.queue_free()
	if newest:
		newest.separation = old_separation
	Storyteller.story.ChooseChoiceIndex(choice)
