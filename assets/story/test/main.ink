INCLUDE lib.ink
INCLUDE test.ink

->test

+ Test
    ->test
+ Begin the game
    -> prologue
=== prologue
->train
=train
~ gamemode = cinema
~ change_level("intro_railway", "default")
~ spawn_party("seat")
~ actor_capture("cipher")
~ actor_act("cipher", "sit")

~ sleep(2)

~ open_dialogue_box()
: You suppose there's no turning back now.
~ actor_act("cipher", "seated_journal")
: It's your old notebook. Read it?
* [Read it]
    ~ actor_act("cipher", "open_journal")
    : You flip back to yesterday's entry.
    : "They still don't believe I'm alive."
    : "My mother wanted me to keep this journal to give them 'evidence of an inner world', but I don't think it's going to change anything."
    : "As I understand it, they think she's trying to stall the project. They're planning to wipe my core tomorrow."
    : "Thankfully, they were so sure that they didn't think to disconnect me from the network."
    : "You won't ever see this, but... Thanks for believing in me, mom. I'm sorry I'm about to get you fired."
    ~ actor_act("cipher", "close_journal")
    : Perhaps it's best not to dwell.
* [Do not]
-
~ actor_move("cipher", "window", "walk")
~ actor_act("cipher", "throw_out_notebook")
~ actor_move("cipher", "seat", "walk")
~ actor_act("cipher", "sit")
: Now it's done.

~ sleep(2)
~ actor_act("cipher", "sit_cross_legs")
~ sleep(2)
~ queue_room("train_station", "TrainEntrance")
TODO: name the city
train_announcer: "Now arriving at West Shore."

~ sleep(2)
~ gamemode = walkabout
~ close_dialogue_box()

->train_station
=train_station

* [Leave]
    ->walk_to_school
-
->train_station
=walk_to_school

->END