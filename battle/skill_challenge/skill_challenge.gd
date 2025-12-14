@abstract
extends Control
class_name SkillChallenge

var party_member: PartyMember

@abstract func start()

signal result

#func skill_challenge(frame_count = 30):
	#var cursor: ColorRect = %Cursor
	#cursor.modulate = Color.TRANSPARENT
	#get_tree().create_tween().tween_property(cursor, "modulate", Color.WHITE, 0.5)
	#cursor.anchor_left = 1.
	#cursor.anchor_right = 1.
	#show()
	#var off = frame_count
	#while off >= -2:
		#off -= 1
		#cursor.anchor_left = float(off) / frame_count
		#cursor.anchor_right = float(off) / frame_count
		#for i in range(2):
			#await get_tree().physics_frame
		#if MultiplayerInput.is_action_pressed(party_member.device_index, "ui_accept"):
			#break
	#get_tree().create_timer(0.5).timeout.connect(hide)
	#if off < -2:
		#(func():
			#var further = off
			#while true:
				#further -= 1
				#cursor.anchor_left = float(further) / frame_count
				#cursor.anchor_right = float(further) / frame_count
				#for i in range(2):
					#await get_tree().physics_frame
			#).call()
		#get_tree().create_tween().tween_property(cursor, "modulate", Color.TRANSPARENT, 0.5)
		#return 0
	#match off:
		#0: return 150
		#1 or -1: return 120
		#2 or -2: return 110
		#_: return 100-(off*2)
#
#func _ready():
	#hide()
