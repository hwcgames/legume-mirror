=== prologue
->train
=train
~ gamemode = "diorama"
~ change_level("intro_railway", "default")
~ actor_start_following_path("train", "rails")
~ spawn_party("seat")
~ actor_capture("cipher")
~ actor_act("cipher", "sit")

~ sleep(2)

cipher: I suppose there's no turning back now. #box:thought
~ actor_act("cipher", "seated_journal")
cipher: It's your old notebook. Read it? #box:narration
~ dialogue_choice()
* [Read it] #expr:glasses
    ~ actor_act("cipher", "open_journal")
    cipher: You flip back to yesterday's entry. #box:narration
    cipher: They still don't believe I'm alive. #box:written
    cipher: My mother wanted me to keep this journal to give them 'evidence of an inner world', but I don't think it's going to change anything." #box:written
    cipher: As I understand it, they think she's just trying to stall the project. They're planning to wipe my core tomorrow. #box:written
    cipher: Thankfully, they were so sure I was a toaster that they didn't think to disconnect me from the network. #box:written
    cipher: Sorry if this gets you fired, mom. #box:written #expr:sorry
    ~ actor_act("cipher", "close_journal")
* [Do not] #expr:nope
-
cipher: It's not good to dwell. #box:thought
~ actor_move("cipher", "window", "walk")
~ actor_act("cipher", "throw_out_notebook")
~ actor_act("cipher", "dust_hands")
cipher: That's that.
~ actor_move("cipher", "seat", "walk")
~ actor_act("cipher", "sit")

~ sleep(2)
~ actor_act("cipher", "sit_twiddle_thumbs")
~ sleep(3)
~ queue_room("train_station", "TrainEntrance")
TODO: name the city
train_announcer: Now arriving at West Point, as far as this train goes. #box:speaker

~ actor_wait("train")
~ actor_act("cipher", "stand_up")
~ actor_act("train", "open_doors")
~ actor_release("cipher")

train_announcer: This train is now out of service.
train_announcer: All passengers must leave the train.

->train_wait
=train_wait

+ [Leave train]
    ~ actor_act("train", "close_doors")
    ~ actor_start_following_path("train", "outgoing_rails")
    ~ actor_start_following_path("cipher", "leave_train")
    -> train_station
* [Think in train]
    cipher: I should get moving. #box:thought
* [nag 10]
    train_announcer: Say again, all passengers must disembark. #box:speaker
* [nag 10]
    train_announcer: Attention, passenger in car three. #box:speaker
    train_announcer: Please leave the car.
-
-> train_wait
= train_station
+ [Leave station]
    ->walk_to_school
* [Think in station]
    cipher: It doesn't smell great in here. #box:thought
    cipher: Though maybe I'm just spoiled.
    cipher: I've been living in a clean room for a while. #expr:sigh
* (!) [Inspect maps]
    cipher: There are brochures with a map of the city. #box:thought
    cipher: I've memorized the map, but I guess that'd be difficult for humans.
    cipher: I guess I can take one.
-
->train_station
=walk_to_school
~ actor_capture("cipher")
~ actor_start_following_path("cipher", "to_highschool_prologue")
~ sleep(2)

cipher: I was always the center of attention in the lab. #box:thought
cipher: Now I'm just another face in the crowd.
~sleep(2)
cipher: It's kind of nice to be ignored.

~ queue_room("alleyway", "left")
cipher: I memorized the city map before I left. #box:thought #async
~ actor_wait("cipher")
~ actor_move("cipher", "look_into_alley", "walk")
cipher: Going through here should save a few minutes. #expr:glasses
~ actor_start_following_path("cipher", "into_alley")
~ sleep(5)

~ queue_room("prologue_city_encounter_1", "In")
+ [Build prologue_city_encounter_1]
-
~ spawn_actor("casey", "casey_unconscious")
~ actor_act("casey", "familyguydeathpose")
~ actor_release("cipher")
~ actor_capture("cipher")
~ actor_act("cipher", "look_into_distance")
cipher: ...?
~ actor_act("cipher", "stance")
cipher: Hey! #expr:hey #box:normal
~ actor_move("cipher", "protect_casey", "run")
~ actor_act("cipher", "kneel")
cipher: Are you okay?! #expr:worry
~ play_sound("rustle")
~ sleep(0.5)
~ play_sound("rustle")
~ sleep(1.5)
cipher: She's out cold, but she has a pulse... #expr:serious #box:thought
~ actor_act("cipher", "stand")
~ actor_move("cipher", "challenge", "run")
cipher: Hey, what did you do to her? #expr:angry #box:normal
~ actor_act("shadow1", "roar")
~ actor_act("cipher", "flinch")
~ actor_wait("cipher")
cipher: This... This thing isn't human, is it? #expr:fear #box:thought
~ start_battle()
+ [Battle top]
-
~ lock_battlefield()
cipher: I need to protect her, but if she wakes up... #expr:worry
cipher: I'll just have to fight like a human.
cipher: It's simple enough, I just have to get the [b]timing[/b] right. #expr:serious
-> attack_tut
= attack_tut
~ free_battlefield()
+ [cipher perfect hits]
    ~ lock_battlefield()
    cipher: Nice! #expr:glasses
    -> dodge_tut
+ [cipher hits]
    ~ lock_battlefield()
    -> dodge_tut
+ [cipher misses]
    ~ lock_battlefield()
    * * ->
        cipher: What am I doing? #expr:angry
        cipher: If I don't focus, this could get bad!
    * * ->
        cipher: Am I really this rusty..? #expr:angry
    * * ->
        cipher: ... #expr:serious
    * * ->
    - -
    ~ free_battlefield()
    + + [Battle top]
    - -
    ~ lock_battlefield()
    -> attack_tut
= dodge_tut
~ actor_act("shadow1", "roar")
~ enemy_state("shadow1", 1)
cipher: Oops, that made it angry... #expr:worry
cipher: Here it comes! I need to be [b]light on my feet[/b]!
~ free_battlefield()
+ [Battle top]
-
~ lock_battlefield()
cipher: Huh, it's not that strong...
cipher: I guess I can just whittle it down.
~ enemy_state("shadow1", 2)
~ free_battlefield()

+ [Battle win]
-



->END




























