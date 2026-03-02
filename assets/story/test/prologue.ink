=== prologue

~ change_level("intro_railway", "default")
_
~ spawn_actor("intro_train", "train_entry")
~ actor_capture("intro_train")
~ actor_start_following_path("intro_train", "rails")
_
~ spawn_party("train_cipher_seat")
~ actor_capture("cipher")
~ actor_act("cipher", "sit")
~ gamemode = "textonly"
~ actor_act("cipher", "open_journal")

: %m:dd%Dear Diary%/m:dd%%p:2%%strike:dd% To whom it may concern; #ty:written
: If you happen to find this... Don't bother trying to return it to its rightful owner.%p:1% It isn't wanted, and I'm quite confident you couldn't find me even if it was. It's all yours, though I imagine it'd fetch quite the price if you were to sell it.%p:2% Much of it is classified, after all.
: It's a curious emotion - at least, I think it's an emotion. If all goes well, everything I've known in my life so far is behind me. I'm not sure how anyone else in today's world could even try to [i]partition[/i] their life so completely.
: I've never been a stranger before. Painting a self-portrait from a blank canvas... The thought is exhilarating, don't you think? Though I imagine you take it for granted.
~ sleep(1)
_
// ~ gamemode = "diorama"
~ play_sound("train_bingbong")
intro_train: Next stop, Weston Pier. Now approaching Weston Pier. Doors open on the right at Weston Pier. #ty:loudspeaker
~ gamemode = "textonly"
: Thanks for humoring me, #ty:written
: [i]A Fellow Stranger[/i]
: P.S: Sorry I just got you fired, mom.

~ gamemode = "diorama"

~ sleep(2)
_
~ actor_act("cipher", "close_journal")
~ actor_move("cipher", "window", "glide")
~ actor_wait("cipher")
_
~ actor_act("cipher", "throw_out_journal")
~ actor_wait("cipher")
_
~ actor_act("cipher", "dust_hands")
~ actor_wait("cipher")
_
~ actor_move("cipher", "train_cipher_seat", "glide")
~ actor_wait("cipher")
_
~ actor_act("cipher", "sit")
~ queue_room("railway/rail_station", "In")
~ actor_wait("intro_train")
~ actor_act("intro_train", "open_doors")
~ actor_act("intro_train", "busy")
~ sleep(3)
_
~ actor_act("intro_train", "close_doors")
~ actor_start_following_path("intro_train", "rails")
~ sleep(3)
_
~ fade_out("black")
~ gamemode = "textonly"
: 20XX-08-04%s:0.5%T%clock:15:23:05%%s:1%-08:00 #ty:keyboard
~ sleep(1)
_
~ gamemode = "diorama"
~ fade_in()
intro_train: Next stop, Northold, College and fifth. Now approaching Northold, College and fifth. Doors open on the left at Northold, College and fifth. #ty:loudspeaker
cipher: That's my stop. #ty:thought
~ queue_room("railway/rail_station", "In")
~ actor_wait("intro_train")
~ actor_act("intro_train", "open_doors")
~ actor_act("cipher", "idle")
~ actor_release("cipher")

train_announcer: This train is now out of service. #ty:loudspeaker
train_announcer: All passengers must leave the train.

->train_wait
=train_wait

+ (leave_train) [Leave train]
    ~ actor_capture("cipher")
    ~ actor_start_following_path("cipher", "leave_train")
    ~ actor_wait("cipher")
    _
    ~ actor_act("intro_train", "close_doors")
    ~ actor_wait("intro_train")
    _
    ~ actor_start_following_path("train", "rails")
    ~ actor_release("cipher")
    -> train_station
* [Think]
    cipher: I should get moving. #ty:thought
* [nag 15]
    train_announcer: Say again, all passengers must disembark. #ty:loudspeaker
* [nag 15]
    train_announcer: Attention, remaining passenger. #ty:loudspeaker
    train_announcer: You, in the hoodie.
    train_announcer: Please leave the car.
* [nag 15]
    cipher: I really ought to go. #ty:thought
    ->leave_train
-
-> train_wait
= train_station
+ [Leave station]
    ~ actor_capture("cipher")
    cipher: Something catches my eye. #ty:thought
    ~ actor_move("cipher", "take_map", "walk")
    cipher: There are brochures with maps of the city and its transit system.
    cipher: It would be good to have one, if only in case someone [i]else[/i] needs it.
    ~ actor_act("cipher", "take_item")
    ->walk_to_school
* [Think in station]
    cipher: Woof, that's not a pleasant smell. #ty:thought
    cipher: The place I've been living until now might have spoiled me, but still... #ty:thought
* [Talk to attendant]
    ~ actor_capture("cipher")
    ~ actor_move("cipher", "talk_to_attendant", "zip")
    cipher: Hello. #ty:spoken
    attendant: Hello! How can I help you? #expr:cheery
    : ...
    cipher: I guess I don't know what exactly people are supposed to talk about. #ty:thought
    cipher: Have a nice day! #ty:spoken
    attendant: You too! #expr:fingerguns
    attendant: ??? #ty:thought
-
->train_station
=walk_to_school
~ actor_start_following_path("cipher", "to_highschool_prologue")
~ sleep(3)

cipher: My first priority is registering with the school. #ty:thought
cipher: I'm a little later than I expected, and I couldn't get a straight answer on when they close... I should take a shortcut.
~ queue_room("prologue_alleyway", "in")
~ actor_wait("cipher")
~ actor_move("cipher", "look_into_alley", "walk")
cipher: I don't remember this from the map...
cipher: But it should be in the right direction, and I can see a light at the end.
~ actor_start_following_path("cipher", "into_alley")
~ sleep(5)
~ actor_release("cipher")
~ actor_capture("cipher")
~ actor_act("cipher", "shiver")
cipher: Suddenly, it feels like there's a lead weight on my chest...
~ sleep(1)
cipher: ...The end of the alleyway's gone dark.
cipher: I'm getting a bad feeling about this.
~ actor_start_following_path("cipher", "backtrack")
~ actor_wait("cipher")
cipher: What the..? #expr:fear
~ actor_move("cipher", "backtrack_wall", "run")
~ actor_act("cipher", "pound_on_wall")
~ actor_wait("cipher")
cipher: It's as solid as it looks.
~ actor_release("cipher")

-> free_in_alleyway
= free_in_alleyway
+ [Unload intro_backtrack]
* [Inspect backtrack_wall]
    ~ actor_capture("cipher")
    cipher: Still no headway here.
    ~ actor_release("cipher")
    -> free_in_alleyway
- 

+ [Inspect backtrack_wall]
    ~ actor_capture("cipher")
    cipher: Did it... move?
    ~ actor_release("cipher")
    ~ sleep(2)
    -> hear_casey
* (hear_casey) [nag 10]
    ~ play_sound("casey_scream")
    ~ actor_capture("cipher")
    ~ actor_act("cipher", "flinch")
    cipher: What was that..?
    ~ actor_start_following_path("cipher", "forward")
    ~ queue_room("prologue_city_encounter", "In")
-
+ [Build prologue_city_encounter_1]
-
~ spawn_actor("casey", "casey_unconscious")
~ actor_act("casey", "familyguydeathpose")
~ spawn_enemy("intro_shadow", "stand_over_casey")
~ actor_release("cipher")
~ actor_capture("cipher")
~ actor_act("cipher", "flinch")
cipher: Hey! #expr:hey #ty:spoken
~ actor_move("cipher", "protect_casey", "run")
~ actor_wait("cipher")
~ actor_act("cipher", "shove")
~ start_battle()
+ [battle top]
-
~ lock_battlefield()
: You meet the figure's eyes, and you can feel the walls thrum with malice.
~ actor_act("cipher", "shiver")
cipher: What is this feeling..? #ty:thought
cipher: I've fought before, but...
~ actor_act("cipher", "stance")
cipher: No. I just need to remember my training.
cipher: I can't go all out with her around, so I'll have to focus on hitting its [i]weak spots[/i].
~ free_battlefield()
+ [cipher hits]
-
~ lock_battlefield()
cipher: ..?!
cipher: It shouldn't even be able to breathe right now, how is it still in the fight?!
~ actor_act("shadow 1", "roar")
~ actor_act("cipher", "flinch")
cipher: It's angry now.
cipher: It's good that its attention is off the girl, but I'm not invincible.
~ actor_act("shadow 1", "roar")
cipher: I can probably withstand a [i]few direct hits[/i], but I need to [i]dodge[/i] the others!
~ free_battlefield()
+ [battle top]
-
~lock_battlefield()
cipher: I think I'll be in trouble if I keep fighting like this...
cipher: I need to change my [i]tactics[/i].
~free_battlefield()
+ [cipher attempts to flee]
-
~lock_battlefield()
cipher: I can't protect both of us at the same time, so I'll have to be [i]careful not to get hit[/i]!
+ [cipher escapes]
-
~ actor_start_following_path("cipher", "forward")
cipher: I don't hear it following me..?
: You feel the pressure on your chest ease, and the light at the end of the alleyway returns.
~ actor_release("cipher")
~ actor_capture("cipher")
~ actor_act("cipher", "carrying_casey_look_over_shoulder")
~ actor_wait("cipher")
cipher: Everything's back to normal..?
casey: Whuh? Ugh, my head..! #ty:spoken
cipher: Oh, you're awake-
~ gamemode = "cinema"
~ spawn_actor("cipher", "left")
~ spawn_actor("casey", "right")
~ actor_act("cipher", "set_casey_down")
~ actor_act("casey", "cipher_sets_down")
~ actor_wait("casey")
casey: %expr:confuse%How did I get here...? The last thing I remember is...
~ actor_act("casey", "sit_scared")
casey: I was ambushed by [i]that thing[/i]. #expr:terror
cipher: You're safe now. Are you all right?
~ actor_act("cipher", "intro_comfort_casey")
~ actor_act("casey", "intro_knight_in_shining_armor")
casey: %expr:blush%...%expr:embarrassed%Uh, yeah. Yeah, I think I'm fine.%expr:uneasysmile% I'm Casey, what's your name?
cipher: My name? I'm...
>>> TODO: Name selection
cipher: ...%char:cipher:given%, nice to meet you.
casey: Huh, that's an %expr:cipher:nervous%interesting name. #expr:curious
cipher: I'm... not from around here. Are you all right on your own? I have somewhere I need to be.
casey: %expr:smile%Yeah-...%expr:blush% Uh, but if you have time to accompany me to school, I'd feel better about it.
cipher: If you mean %expr:casey:curious%Northold High, that's where I was heading anyway.
casey: Really? I haven't seen you there before, %expr:cipher:nervous%are you a transfer student?
cipher: ...Something like that%expr:casey:excuseme%.
~ sleep(1)
~ fade_out("black")

~ change_level("northold_high", "entrance")
~ spawn_party("intro_entrance")
~ fade_in()
~ actor_start_following_path("cipher", "intro_enter_school")
~ gamemode = "cinema"
~ spawn_actor("cipher", "left")
cipher: Northold high... It's convenient that I look the age I do. #ty:thought
cipher: If what I've read is correct, high school students are in the stage of development where they decide [i]what kind of person[/i] they are.
cipher: Our tasks aren't dissimilar, so in a way I'm among peers.

~ spawn_actor("casey", "right")
casey: You really waited until the last minute to sign up, huh? #expr:ehehe #ty:spoken
cipher: There were... %expr:casey:oof%complications during my move, so I wasn't able to get here in person as early as I would have liked.
casey: Woof, then I'm glad you got them sourted out. %expr:casey:huh%To be honest, I'm surprised they're even letting you sign up the weekend before the start of the semester.
cipher: My parents and I have done most of the paperwork online.%expr:casey:humu% They've been very understanding of %expr:casey:nervous%my situation.
cipher: Though if they knew what was going on... #ty:thought
cipher: There's a chance they'd side with me, but there's also a chance they'd rat me out.
cipher: I can't afford to take risks like that.
casey: Your situation...? #ty:spoken
casey What could...? %expr:fear%Oh. Oh no, is it [i]that?[/i] #ty:thought
casey: I'm so sorry, er... %expr:neutral%Admissions is down that hall, I think. #ty:spoken
cipher: Thanks for your help, see you later.
casey: Yeah, thank you too-... %expr:blush%Uh, do you want to exchange numbers? Keep in touch?
cipher: Oh, sure.
~ actor_act("casey", "phone")
casey: Thanks.
~ sleep(1)
~ actor_act("casey", "normal")
casey: ...Uh, aren't you going to put me in your %expr:cipher:nervous%phone?
cipher: My phone doesn't hold a charge well, so I usually leave it at home. %expr:smile%I'll put you in when I get there.
casey: %expr:blink%%p:1%%expr:smile%All right. Talk to you later, then.

~ fade_out("black")
~ gamemode = "diorama"
~ change_level("apartment_building", "entrance")
~ spawn_actor("milly", "frontdesk")
~ actor_act("milly", "clickclack")
~ spawn_party("entrance")
~ actor_move("cipher", "talktodesk", "stroll")
cipher: It's a good thing the school didn't do a proper background check. My story was convincing enough, I guess. Next up is an apartment. I was initially going to go without, but... Things can be difficult if you don't have an address. It does mean I'll have to figure out an income stream sooner or later, but I've got enough to get by for the time being. #ty:thought
~ actor_wait("cipher")
milly: %expr:hello%Oh, hello, dearie! %expr:smile%What can I do for you?
cipher: I'm %char:cipher:given%, my parents said they talked to you?
cipher: Both of the parents she talked to were actually me. #expr:shifty #ty:thought
cipher: She thinks a gas line broke in our house while they were away on business, so I need to live somewhere else for the foreseeable future.
milly: %expr:ohoho%Of course! %expr:splain%They sent me your picture in the goggle, %expr:wave%but I'm too old for that kind of thing. %expr:smile% I bet you knew the computer better than me before you could even walk, %expr:ohoho%hoho!
cipher: Haha, good one: #expr:laugh
cipher: You don't know how right you are. #expr:shifty #ty:thought
milly: %expr:splain%So, is there anything you need? Do you want me to help you with your bags?
cipher: No, thanks! I'm stronger than I look. #expr:smile
cipher: And I don't actually [i]have[/i] any luggage to carry. #ty:thought #expr:shifty
mildred: %expr:aww%Aww, aren't you independent? %expr:splain%Well, if you ever need anything, just let Aunt Milly know! #ty:spoken
cipher: You're too kind. You let me know if you ever need any help with the "Goggle" in return, all right? #expr:smile
cipher: It's a good idea to build up more of a rapport. "The hand that feeds..." #ty:thought
~ confidant_level("milly", 1)
~ actor_move("cipher", "exit", "stroll")
~ sleep(1)
~ fade_out("black")
~ change_level("apartment_building", "myroom")
~ spawn_party("entrance_to_myroom")
~ fade_in()
~ actor_move("cipher", "center_of_room", "stroll")
cipher: This is my room. It's unfurnished, but that's nothing new. #ty:thought
~ actor_move("cipher", "against_wall", "stroll")
~ actor_act("cipher", "criss_cross_applesauce")
cipher: My first day living on the outside... I was expecting it to have a little more impace. I guess this is what I was aiming for, though: a normal- #interrupt
~ actor_act("cipher", "radio_pling")
~ fade_out("jpeg")
cipher as casey: hello, stranger! #ty:text
cipher: Hello.
cipher as casey: thanks again for saving me today
cipher as casey: i still dont' understand
cipher as casey: where the hell were we?
cipher as casey: what would have happened to me if you hadn't shown up
cipher: I don't think there's any way to know for sure.
cipher: I just hope it doesn't happen again.
cipher as casey: maybe it has something to do with the disappearances?
cipher: Pardon?
cipher as casey: ppl are going missing, its been all over the news
~ sleep(1)
cipher as casey: i think i wasa lmost one of them
cipher: Maybe.
~ sleep(3)
cipher as casey: btw
cipher as casey: are you busy tomorrow?
cipher: No, why?
cipher as casey: do you want to come by my house? my parents are going to be out but i can get my brother to make lunch
cipher as casey: i think you'd get along well with him too, he's in our year
cipher as casey: you certainly text like him lol
~ fade_in()
cipher: I wasn't expecting something like this so soon... I'll have to be on guard, but it's a good opportunity to learn. #ty:thought
~ fade_out("jpeg")
cipher: I'd be happy to, when should I come by? #ty:text
cipher as casey: 11 or so should be fine
cipher as casey: see you then!
~ fade_in()
cipher: This is what it's like... It's a little scary, not having my life planned out for me, but for the first time it feels like it's [i]mine[/i]. #ty:thought
cipher: I hope this lasts.
~ fade_out("jpeg")

~ sleep(5)

~ gamemode = "cinema"
~ spawn_actor("crow", "right_on_msgbox")
~ actor_act("crow", "fly_in")
~ actor_wait("crow")
crow: Nice to meet you, caw. #ty:otherworldly
crow: We'll talk more later, squawk... But we need to introduce ourselves first.
crow: What's that? Yes, you've already named our friend %char:cipher:given%, caw... But I need to know [i]your[/i] name.
crow: %char:player:given%? Let me write that down, squawk.
crow: Oh, by the way, please don't close the game if you see me taking notes, caw. It's difficult enough to write without thumbs, you see, so I would prefer not 
crow: That said, squawk, I'm very glad that you decided to play this game. I'll get out of your hair for now.



->END




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




























