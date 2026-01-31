extends CanvasLayer

var oldest: ChatBalloon
var newest: ChatBalloon
@export var chat_balloon_scene: PackedScene

var actors: Dictionary[String, Actor] = {}

func _physics_process(_delta: float) -> void:
	if oldest == null:
		return
	if oldest.expired or oldest.global_position.y < -100:
		oldest.queue_free()
		oldest = oldest.next_balloon
	%ChatLine.top_balloon = oldest

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

func message(actor: Actor, text: String):
	var balloon := chat_balloon_scene.instantiate()
	balloon.text = text
	balloon.actor = actor
	balloon.character_root = actor.head
	push_balloon(balloon)
	pass
