INCLUDE lib.ink
INCLUDE test.ink
INCLUDE prologue.ink
INCLUDE dungeon_banter.ink
INCLUDE prologue-dungeon.ink



~ dialogue_choice()
// ~ random_choice()
_
+ [Begin]
-

%as%crow: Hello, world! #ty:bird
%as%crow: This is a [i]very[/i] early prototype of an RPG currently codenamed %v:written%"Legume Traffick."
%as%crow: It's a little fragile yet, so please handle it with care.
%as%crow: Where would you like to begin?

~ dialogue_choice()
// + [In the test dungeon]
//     ~ clear_dialogue()
//     ->test
+ [At the start of the game]
    ~ clear_dialogue()
    -> prologue
+ [On the way to school]
    ~ clear_dialogue()
    ~ change_level("intro", "walk_to_school")
    _
    ~ spawn_party("default")
    ~ actor_capture("cipher")
    ~ actor_start_following_path("cipher", "forward")
    -> prologue.walk_to_school_begin_point
+ [Battling a creature]
    ~ clear_dialogue()
    ~ change_level("intro", "alleyway")
    _
    ~ set_weather("dungeon")
    ~ spawn_party("default")
    ~ actor_capture("cipher")
    ~ sleep(0.5)
    _
    -> prologue.battle_shadow_begin_point
+ [Registering for school]
    ~ clear_dialogue()
    -> prologue.register_for_school_begin_point
+ [Talking to a kind elder]
    ~ clear_dialogue()
    ~ fade_out("black")
    _
    -> prologue.register_apartment_begin_point
+ [Hitting the hay]
    ~ clear_dialogue()
    -> prologue.in_ciphers_room_begin_point
+ [Venturing into a dungeon]
    ~ clear_dialogue()
    -> prologue_dungeon.lobby
+ [Battling a formidable enemy]
    ~ clear_dialogue()
    ~ change_level("intro_dungeon", "hallway")
    _
    ~ set_weather("dungeon")
    ~ spawn_party("default")
    ~ actor_capture("cipher")
    ~ sleep(0.5)
    _
    ~ add_party_member("casey", "default")
    ~ add_party_member("mauve", "default")
    ~ add_party_member("april", "default")
    ~ actor_start_following_path("cipher", "forward")
    -> prologue_dungeon.boss


=== die
~ clear_dialogue()
: And so %p:1%the world was lost. #ty:typed
~ reset()
->END

=== meet_crow
->->