extends Control

var amount: int:
	set(new_amount):
		if amount == new_amount:
			return
		amount = new_amount
		if amount == -1:
			%Label.hide()
		else:
			%Label.show()
			%Label.text = str(new_amount)
		blink()
var icon: Texture2D:
	set(new_icon):
		if icon == new_icon:
			return
		icon = new_icon
		%TextureRect.texture = icon
		blink()
var message: String:
	set(new_message):
		if message == new_message:
			return
		message = new_message
		tooltip_text = message
		blink()
var fighter: Actor
var rule: BattleRule:
	set(new_rule):
		rule = new_rule
		rule.activated.connect(blink)
		refresh()

func ready():
	refresh()
	fighter.battlefield.top.connect(refresh)

func refresh():
	amount = rule.stacks
	icon = rule.icon(fighter)
	message = rule.message(fighter)

@onready var tween: Tween
func blink():
	if !is_inside_tree():
		await tree_entered
	%AnimationPlayer.play("flash")
	if is_instance_valid(tween):
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "offset_transform_rotation", randf_range(-PI/4, PI/4), 0.1).set_ease(Tween.EASE_OUT)
	tween.parallel()
	tween.tween_property(self, "offset_transform_scale", Vector2(randf_range(0.9, 1.5), randf_range(0.9, 1.5)), 0.1).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "offset_transform_rotation", 0, 0.2).set_ease(Tween.EASE_IN_OUT)
	tween.parallel()
	tween.tween_property(self, "offset_transform_scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_IN_OUT)
	tween.play()
