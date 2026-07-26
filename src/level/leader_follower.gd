extends Node3D
class_name LeaderProxy

@onready var leader = Storyteller.find().story.FetchVariable("leader")
@onready var pm = Actor.find(leader)

#func _ready():
	#RenderingServer.frame_pre_draw.connect(tick)

func _process(_delta: float) -> void:
	var new_leader = Storyteller.find().story.FetchVariable("leader")
	if new_leader == null:
		return
	if new_leader != leader:
		leader = new_leader
		pm = Actor.find(leader)
	if pm == null:
		pm = Actor.find(leader)
		return
	global_position = pm.get_global_transform_interpolated().origin
