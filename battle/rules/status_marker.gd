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

func blink():
	%AnimationPlayer.play("flash")
