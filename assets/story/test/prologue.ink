=== input_tutorial
* ->
    : Use the [b]arrow keys[/b] to move and the [b]spacebar[/b] to interact with objects and people. # ty:typed
+ ->
-
->->

=== dodge_tutorial
* ->
    : Use the [b]arrow keys[/b] to dodge. # ty:typed
+ ->
-
->->

=== intro_headlines
->prologue

~ fade_out("black")
: WESTON GAZETTE #ty:typed
: 20XX-07-18
: MISSING CHILD ALERT ISSUED FOR 6-YEAR-OLD "BRAYDEN"
~ sleep(1)
_
: 20XX-07-21
: OFFICER REMOVED FROM DUTY AFTER SHOOTING, DRUG USE SUSPECTED
~ sleep(1)
_
: 20XX-07-22
: COMMUNITY SEARCH FOR LOST DOG ENDS IN TRAGEDY
~ sleep(1)
_
: 20XX-07-24
: OPINION: THE ESTRANGEMENT CRISIS: WHY MY KIDS WON'T CALL ME BACK
~ sleep(1)
_
: 20XX-07-25
: UNION ORGANIZER MIS%i%████ █████
~ clear_dialogue()
: 20XX-07-25
: EDISON CEO ANNOUNCES WEDDING VENUE
~ sleep(1)
_
: 20XX-07-26
: INSPECTOR GENERAL COMMENTS ON STRING OF DISAPPEARANCES
~ sleep(1)
_
: 20XX-07-28
: CULPRIT BEHIND BARS, CITY SAFE AGAIN
~ sleep(5)
_
: 20XX-08-01
: MISSING CHILD ALERT ISSUED FOR 14-YEAR-OLD "RACHEL"
~ sleep(1)
_
: 20XX-08-02
: OFFICER MISSING, TIPS REQUESTED
~ sleep(1)
_
: 20XX-08-03
: MANIFESTO FOUND AT COURTHOUSE, POLITICALLY MOTIVATED?
~ sleep(5)
_
~ clear_dialogue()
->prologue
=== prologue
~ change_level("intro", "default")
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
~ fade_in()

%as%cipher: Dear Diary; #ty:written
~ sleep(1)
_
%as%cipher: (Or... To whom it may concern;)
%as%cipher: If you happen to find this... Don't bother trying to return it. It isn't wanted, and I'm quite confident you couldn't find me even if it was. I imagine it'd fetch quite the price if you were to sell it.%p:2% Much of it is classified, after all.
%as%cipher: It's a curious emotion. If all goes well, everything I've known in my life so far is behind me. I'm not sure how anyone else in today's world could even try to start over like this.
%as%cipher: The thought of being a stranger is exhilarating, don't you think? Though I imagine you take it for granted.
~ sleep(1)
_
// ~ gamemode = "diorama"
~ set_camera("focus_on_speaker")
~ play_sound("train_bingbong")
intro_train: Next stop, Weston Pier. Now approaching Weston Pier. Doors open on the right at Weston Pier. #ty:loudspeaker
~ gamemode = "textonly"
~ set_camera("_")
%as%cipher: Thanks for humoring me, #ty:written
%as%cipher: [i]A Fellow Stranger[/i]
%as%cipher: P.S: Sorry I just got you fired, mom.

~ gamemode = "diorama"

~ sleep(2)
_
~ set_camera("outside_cipher_throw")
~ actor_act("cipher", "close_journal")
~ actor_move("cipher", "window", "glide")
~ actor_wait("cipher")
_
~ actor_act("cipher", "throw_out_journal")
~ actor_wait("cipher")
_
: Your journal thuds against the wall of the tunnel. #ty:typed
: You watch it tumble to a stop, quickly falling behind and out of view.
~ actor_act("cipher", "dust_hands")
~ actor_wait("cipher")
_
~ actor_move("cipher", "train_cipher_seat", "glide")
~ actor_wait("cipher")
_
~ actor_act("cipher", "sit")
~ queue_room("railway/rail_station", "In")
+ [Build railway/rail_station]
-
~ set_camera("rail_station")
~ actor_wait("intro_train")
_
~ actor_act("intro_train", "open_doors")
~ actor_act("intro_train", "busy")
~ sleep(2)
_
~ actor_act("intro_train", "close_doors")
~ actor_start_following_path("intro_train", "rails")
~ sleep(2)
~ fade_out("black")
_
~ set_camera("_")
~ gamemode = "textonly"
: 20XX-08-04T15:23:05-08:00 #ty:typed
~ sleep(1)
_
~ gamemode = "diorama"
~ fade_in()
intro_train: Next stop, Northold, College and fifth. Now approaching Northold, College and fifth. Doors open on the left at Northold, College and fifth. #ty:loudspeaker
cipher: That's my stop. #ty:thought
~ queue_room("railway/rail_station", "In")
+ [Build railway/rail_station]
-
~ spawn_actor("station_attendant", "station_attendant")
~ set_camera("rail_station")
~ actor_wait("intro_train")
_
~ actor_act("intro_train", "open_doors")
~ actor_act("cipher", "idle")

intro_train: This train is now out of service. #ty:loudspeaker
intro_train: All passengers must leave the train.
~ actor_release("cipher")
~ set_camera("_")
->input_tutorial->

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
    ~ actor_start_following_path("intro_train", "rails")
    ~ actor_release("cipher")
    ~ actor_wait("intro_train")
    _
    ~ despawn_actor("intro_train")
    -> train_station
* [Think]
    cipher: I should get moving. #ty:thought
* [nag 15]
    intro_train: Say again, all passengers must disembark. #ty:loudspeaker
* [nag 15]
    intro_train: Attention, remaining passenger. #ty:loudspeaker
    intro_train: Hey, you.
    intro_train: Please leave the car.
* [nag 15]
    cipher: I really ought to go. #ty:thought
    ->leave_train
-
-> train_wait
= train_station
+ [Leave station]
    ~ actor_capture("cipher")
    // cipher: Something catches my eye. #ty:thought
    // ~ actor_move("cipher", "take_map", "walk")
    // cipher: There are brochures with maps of the city and its transit system.
    // cipher: It would be good to have one, if only in case someone [i]else[/i] needs it.
    // ~ actor_act("cipher", "take_item")
    ->walk_to_school
* [Think in station]
    cipher: Woof, that's not a pleasant smell. #ty:thought
    cipher: The place I've been living until now might have spoiled me, but still... #ty:thought
* [Station Attendant]
    ~ actor_capture("cipher")
    ~ actor_move("cipher", "talk_to_attendant", "glide")
    ~ set_camera("talk_to_attendant")
    cipher: Hello. #ty:spoken
    station_attendant: Hello! #expr:smile
    cipher: ... #ty:thought
    cipher: I guess I don't know what exactly people are supposed to talk about.
    cipher: Have a nice day! #ty:spoken
    station_attendant: You too! #expr:uneasysmile
    station_attendant: ??? #ty:thought #expr:embarrassed
    ~ set_camera("_")
    ~ actor_release("cipher")
    cipher: That wasn't the best first impression...
-
->train_station
=walk_to_school
~ actor_start_following_path("cipher", "to_highschool_prologue")
~ fade_out("black")
_
~ sleep(1)
_
~ fade_in()

- (walk_to_school_begin_point)

cipher: My first priority is registering with the school. #ty:thought
cipher: I'm a little later than I expected, and I couldn't get a straight answer on when they close... I should take a shortcut.
~ queue_room("prologue_alleyway_entrance", "In")
+ [Build prologue_alleyway_entrance]
-
cipher: ..? #ty:thought
~ actor_wait("cipher")
_
~ sleep(0.5)
_
~ actor_move("cipher", "look_into_alley", "walk")
~ actor_wait("cipher")
_
cipher: I don't remember this from the map...
cipher: But it should be in the right direction, and I can see a light at the end.
~ actor_start_following_path("cipher", "into_alley")
~ sleep(5)
_
~ actor_release("cipher")
_
~ actor_capture("cipher")
~ actor_act("cipher", "shiver")
~ set_weather("dungeon")
cipher: Suddenly, it feels like there's a lead weight on my chest...
~ sleep(1)
cipher: ...The end of the alleyway's gone dark.
cipher: I'm getting a bad feeling about this.
~ actor_start_following_path("cipher", "backtrack")
~ queue_room("prologue_alleyway_deadend", "In")
~ actor_wait("cipher")
_
cipher: What the..? #expr:fear
~ actor_move("cipher", "backtrack_wall", "run")
~ actor_act("cipher", "pound_on_wall")
~ actor_wait("cipher")
_
cipher: It's as solid as it looks.
~ actor_release("cipher")
->input_tutorial->

-> free_in_alleyway
= free_in_alleyway
+ [Unload prologue_alleyway_deadend]
* [Inspect backtrack_wall]
    ~ actor_capture("cipher")
    cipher: I just... came from there, didn't I?
    ~ actor_release("cipher")
    -> free_in_alleyway
* [Inspect backtrack_wall]
    ~ actor_capture("cipher")
    cipher: What's going on here?
    ~ actor_release("cipher")
    -> free_in_alleyway
- 

+ [Inspect backtrack_wall]
    ~ actor_capture("cipher")
    cipher: It definitely wasn't that far forward before.
    ~ actor_release("cipher")
    ~ sleep(2)
    -> hear_casey
* (hear_casey) [nag 15]
    ~ actor_capture("cipher")
    ~ actor_act("cipher", "flinch")
    ~ play_sound("casey_scream")
    : You hear a scream from somewhere ahead. #ty:typed
    cipher: What was that..? #ty:spoken
    - (battle_shadow_begin_point)
    ~ actor_start_following_path("cipher", "forward")
    ~ queue_room("alley_battle", "In")
-
+ [Build alley_battle]
-
~ add_party_member("casey", "casey_unconscious")
~ actor_capture("casey")
~ actor_act("casey", "dead")
~ spawn_enemy("static/spookyguy", "spookyguy", "stand_over_casey")
~ actor_capture("spookyguy")
~ actor_act("spookyguy", "loom")
~ actor_release("cipher")
~ actor_capture("cipher")
~ actor_act("cipher", "flinch")
cipher: Hey! #ty:spoken
~ actor_move("cipher", "protect_casey", "run")
~ actor_wait("cipher")
_
~ actor_act("cipher", "shove")
~ actor_wait("cipher")
_
~ actor_move("spookyguy", "spookyguy_battle", "fall_back")
~ actor_wait("spookyguy")
_
~ actor_release("cipher")
~ actor_capture("cipher")
~ actor_release("spookyguy")
~ actor_capture("spookyguy")
~ join_battle("cipher")
~ join_battle("spookyguy")
~ start_battle()
~ clear_dialogue()
+ [battle top]
-
~ lock_battlefield()
: When you meet the creature's eyes, you feel a thrum of energy around you. #ty:typed
cipher: This thing looks like bad news... #ty:thought
// ~ actor_act("cipher", "shiver")
// cipher: I've fought before, but this is... [i]different[/i] somehow. #ty:thought
// ~ actor_act("cipher", "stance")
// cipher: No. I just need to remember my training.
cipher: I'll try to find its [i]weak spots[/i].
: When using your [b]Basic Attack[/b], try to hit the [b]spacebar[/b] at the last second.
~ free_battlefield()
~ clear_dialogue()
+ (tut_perfect_hit) [cipher perfect hits]
+ [cipher hits]
-
+ [battle enemy action]
-
~ lock_battlefield()
_
cipher: ..?! #expr:blink
{tut_perfect_hit: cipher: I hit it perfectly, but it's still standing!}
~ actor_act("shadow 1", "roar")
~ actor_act("cipher", "flinch")
~ enemy_state("spookyguy", 1)
cipher: It's angry now.
cipher: It's good that its attention is off the human, but I'm not invincible.
~ actor_act("shadow 1", "roar")
cipher: I can probably withstand a [i]few direct hits[/i], but I need to [i]dodge[/i] the others!
->dodge_tutorial->
~ free_battlefield()
~ clear_dialogue()
+ [battle top]
+ [battle lost]
    ->die
-
~ lock_battlefield()
~ enemy_state("spookyguy", 2)
cipher: I think I'll be in trouble if I keep fighting like this...
cipher: I need to change my [i]tactics[/i]. #expr:humu
~free_battlefield()
~ clear_dialogue()
+ [cipher attempts to flee]
+ [battle lost]
    ->die
-
~lock_battlefield()
cipher: I can't defend us both at once, so I'll have to be [i]careful not to get hit[/i]!
~ clear_dialogue()
~ free_battlefield()
+ [battle won]
+ [battle lost]
    ->die
-
~ actor_start_following_path("cipher", "forward")
~ sleep(3)
~ set_camera("runaway")
_
~ set_camera("_")
cipher: I don't hear it following me..?
~ set_weather("default")
: You feel the pressure on your chest ease, and the light at the end of the alleyway returns.
~ actor_release("cipher")
~ actor_capture("cipher")
~ actor_act("cipher", "carrying_casey_look_over_shoulder")
~ actor_wait("cipher")
cipher: Everything's back to normal..?
casey: Whuh? Ugh, my head..! #ty:spoken
cipher: Oh, you're awake-
// ~ gamemode = "cinema"
// ~ spawn_actor("cipher", "left")
// ~ spawn_party_member("casey", "right")
// ~ actor_act("cipher", "set_casey_down")
// ~ actor_act("casey", "cipher_sets_down")
// ~ actor_wait("casey")
~ actor_stop("casey")
~ actor_move("casey", "rest_by_wall", "walk")
~ actor_move("cipher", "talk_by_wall", "walk")
casey: %expr:confuse%How did I get here...? The last thing I remember is...
~ actor_act("casey", "sit_scared")
casey: I was ambushed by [i]that thing[/i]. #expr:fear
cipher: Are you all right?
~ actor_act("cipher", "intro_comfort_casey")
~ actor_act("casey", "intro_wow")
casey: %expr:blush%...%expr:embarrassed%Uh, yeah. Yeah, I think I'm fine.%expr:uneasysmile% I'm Casey, what's your name?
cipher: My name? I'm...
: You would pick your name here, if it was implemented.
cipher: ...%char:cipher%, nice to meet you.
casey: Huh, that's an %expr:cipher:embarrassed%interesting name. #expr:curious
cipher: I'm... not from around here. Are you all right on your own? I have somewhere I need to be.
casey: %expr:smile%Yeah-...%expr:blush% Uh, but if you have time to accompany me to school, I'd feel better about it.
cipher: If you mean %expr:casey:curious%Northold High, that's where I was heading anyway.
casey: Really? I haven't seen you there before, %expr:cipher:embarrassed%are you a transfer student?
cipher: ...Something like that%expr:casey:confused%.
~ sleep(1)
~ fade_out("black")
_
- (register_for_school_begin_point)
~ change_level("intro", "northold_high")
_
~ spawn_party("entrance")
~ add_party_member("casey", "entrance2")
~ fade_in()
~ actor_start_following_path("cipher", "intro_enter_school")
~ gamemode = "cinema"
// ~ spawn_actor("cipher", "left")
// cipher: Northold high... It's convenient that I look the age I do. #ty:thought
// cipher: If what I've read is correct, high school students are in the stage of development where they decide [i]what kind of person[/i] they are.
// cipher: Our tasks aren't dissimilar, so in a way I'm among peers.

// ~ spawn_party_member("casey", "right")
casey: You really waited until the last minute to sign up, huh? #expr:embarrassed #ty:spoken
cipher: There were... %expr:casey:oof%complications during my move, so I wasn't able to get here in person as early as I would have liked.
casey: Oof, then I'm glad you got them sorted out. %expr:casey:confused%To be honest, I'm surprised they're even letting you sign up the weekend before the start of the semester.
cipher: I did most of the paperwork online.%expr:casey:humu% They've been very understanding of %expr:casey:embarrassed%my situation.
cipher: Though if they knew what was going on... #ty:thought
cipher: There's a chance they'd side with me, but there's also a chance they'd rat me out.
cipher: I can't afford to take risks like that.
casey: Your situation...? #ty:spoken
casey: What could...? #ty:thought #expr:fear
casey: I'm sorry, er... Admissions is down that hall, I think. #ty:spoken
cipher: Thanks for your help, see you later.
casey: Yeah, thank you too-... %expr:blush%Uh, do you want to exchange numbers? Keep in touch?
cipher: Oh, sure.
// ~ actor_act("casey", "phone")
casey: Thanks.
: ...
_
// ~ actor_act("casey", "normal")
casey: ...Uh, aren't you going to put me in your %expr:cipher:embarrassed%phone?
cipher: Ah. #ty:thought
cipher: My phone doesn't hold a charge well, so I usually leave it at home. %expr:smile%I'll put you in when I get there. #ty:spoken
casey: %expr:blink%...%expr:smile%All right. Talk to you later, then.

~ fade_out("black")
~ clear_dialogue()
_
~ gamemode = "diorama"
- (register_apartment_begin_point)
~ change_level("intro", "apartment_office")
_
~ set_weather("indoors")
~ spawn_actor("milly", "frontdesk")
~ actor_capture("milly")
~ actor_act("milly", "clickclack")
~ spawn_party("entrance")
~ actor_capture("cipher")
cipher: It's a good thing the school didn't do a proper background check. My story was convincing enough, I guess. Next up is an apartment. I was initially going to go without, but... Life can be difficult if you don't have an address. #ty:thought
cipher: It does mean I'll have to figure out an income stream sooner or later, but I've got enough to get by for the time being.
~ fade_in()
_
~ actor_move("cipher", "talktodesk", "walk")
~ actor_wait("cipher")
_
~ set_camera("talk")
milly: %expr:ohoho%Oh, hello, dearie! %expr:smile%What can I do for you? #ty:spoken
cipher: I'm %char:cipher%, my parents said they talked to you?
cipher: Both of the parents she talked to were actually me, of course. #ty:thought
cipher: She thinks a gas line broke in our house while they were away on business, so I need to live somewhere else for the foreseeable future.
milly: %expr:ohoho%Of course! %expr:humu%They sent me your picture in the goggle, %expr:pshaww%but I'm too old for that kind of thing.%expr:smile% I bet you were using that thing when you were still in diapers, %expr:ohoho%hoho! #ty:spoken
cipher: ...Something like that. #ty:thought
milly: %expr:humu%So, is there anything you need? Do you want me to help you with your bags? #ty:spoken
cipher: No, thanks! I'm stronger than I look.
cipher: And I don't actually [i]have[/i] any luggage to carry. #ty:thought
milly: %expr:aww%Aww, aren't you independent? %expr:humu%Well, if you ever need anything, %expr:ohoho%just let Aunt Milly know! #ty:spoken
cipher: You're too kind. You let me know if you ever need any help with the %expr:ohoho%"Goggle" in return, all right?
cipher: It's a good idea to build up more of a rapport. %expr:humu%"The hand that feeds..." #ty:thought
~ confidant_level("milly", 1)
_
~ actor_move("cipher", "entrance", "walk")
~ fade_out("black")
_
- (in_ciphers_room_begin_point)
~ change_level("intro", "myroom")
_
~ set_weather("indoors")
~ spawn_party("entrance_to_myroom")
~ fade_in()
~ actor_move("cipher", "center_of_room", "walk")
cipher: This is my room. It's unfurnished, but that's nothing new. #ty:thought
~ actor_move("cipher", "against_wall", "walk")
~ actor_act("cipher", "criss_cross_applesauce")
cipher: My first day living on the outside... I was expecting it to have a little more impact. I guess this is what I was aiming for, though: a normal- #interrupt
~ actor_act("cipher", "radio_pling")
~ fade_out("jpeg")
_
: A signal pings in the back of your head. #ty:typed
cipher%as%casey: hello, stranger! #ty:text #expr:ohoho
cipher: %i%Hello.%p:1% #ty:text
cipher%as%casey: thanks again for saving me today
cipher%as%casey: i still dont' understand
cipher%as%casey: where the hell were we? #expr:confused
cipher%as%casey: what would have happened to me if you hadn't shown up #expr:fear
cipher: %i%I don't think there's any way to know for sure.
cipher: %i%I just hope it doesn't happen again.%p:2%
// cipher%as%casey: maybe it has something to do with those disappearances? #expr:humu
// cipher: %i%Pardon?%p:1%
// cipher%as%casey: ppl are going missing, its been all over the news
// ~ sleep(1)
// cipher%as%casey: i think i wasa lmost one of them #expr:embarrassed
// cipher: %i%Maybe.%p:1%
~ sleep(3)
cipher%as%casey: btw #expr:curious
cipher%as%casey: are you busy tomorrow? #expr:uneasysmile
cipher: %i%No, why?%p:1%
cipher%as%casey: do you want to come by my house? my parents are going to be out but i can get my brother to make lunch #expr:blush
cipher%as%casey: i think you'd get along well with him too, he's in our year
~ fade_in()
cipher: I wasn't expecting something like this so soon... I'll have to be on guard, but it's a good opportunity to learn. #ty:thought
~ fade_out("jpeg")
_
cipher%as%casey: btw you type crazy fast lol #ty:text #expr:embarrassed
~ fade_in()
_
cipher: Oops. #ty:thought
cipher: Humans take time to type. Right.
~ fade_out("jpeg")
_
cipher: I'd be happy to, when should I come by? #ty:text
cipher%as%casey: 11 or so should be fine
cipher%as%casey: see you then! #expr:ohoho
~ fade_in()
cipher: This is what it's like... It's a little scary, not having my life planned out for me, but for the first time it feels like it's [i]mine[/i]. #ty:thought
cipher: I hope this lasts.
~ fade_out("jpeg")
: Your thoughts slow to a crawl as you prepare to shut down for the night. #ty:typed

~ sleep(5)
_
~ spawn_actor("crow", "windowsill")
~ actor_capture("crow")
~ set_camera("live_crow_reaction")
~ sleep(1)
_
~ fade_in()
// ~ gamemode = "cinema"
// ~ spawn_actor("crow", "right_on_msgbox")
~ actor_act("crow", "fly_in")
~ actor_wait("crow")
->meet_crow->
crow: Nice to meet you face-to-face, caw. #ty:bird
crow: We'll talk more later, squawk... But we need to introduce ourselves first.
crow: What's that? Yes, you've already named our friend %char:cipher%, caw... But I need to know [i]your[/i] name.
: You would set your name here, if it was implemented. #ty:typed
// crow: %playername%? Let me write that down, squawk.
// crow: Oh, by the way, please don't close the game if you see me taking notes, caw. It's difficult enough to write without thumbs, you see, so I would prefer not to be interrupted.
// crow: That said, squawk, I'm very glad that you decided to play this game. I'll get out of your hair for now.
crow: Oh, right... This is the demo. #ty:bird
crow: That said, squawk, I'm very glad that you decided to play.
crow: The next few days of the game aren't ready yet, and they wouldn't be that interesting in a demo regardless...
crow: So, caw, my superiors have asked me to escort you further into the game.
crow: If you'll follow me, squawk...
~ fade_out("black")
~ sleep(1)
_
crow: Ack! Who turned out the lights?!
~ sleep(0.5)
_
~ clear_dialogue()
->prologue_dungeon.lobby



->END
