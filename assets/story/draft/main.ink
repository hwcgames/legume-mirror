INCLUDE calendar.ink
INCLUDE days.ink
INCLUDE calendar/d0_08_12.ink
INCLUDE calendar/d0_08_13.ink
INCLUDE forecast.ink
INCLUDE calendar/d0_08_14.ink
INCLUDE calendar/d0_08_15.ink
INCLUDE world/lib.ink
INCLUDE quests/lib.ink
INCLUDE characters/lib.ink
INCLUDE calendar/d0_08_16.ink






{in_inky(): {SEED_RANDOM(2765)}}

- (day_loop)
-> calendar.run_day ->
-> day_loop

EXTERNAL in_inky()
=== function in_inky()
~ return true

EXTERNAL ask(name, default)
=== function ask(name, default)
~ return default

VAR leader = "cipher"
























































