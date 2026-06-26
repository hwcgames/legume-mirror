extends CanvasLayer
class_name BattleWorld

var battlefield: Battlefield:
	get:
		return %Battlefield

func setup(environment: BattleEnvironment):
	%Battlefield.player_landmarks = environment.players
	%Battlefield.enemy_landmarks = environment.enemies
	if environment.is_inside_tree():
		environment.reparent(%SubViewport, false)
	else:
		%SubViewport.add_child(environment)
