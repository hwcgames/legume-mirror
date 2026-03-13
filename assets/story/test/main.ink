INCLUDE lib.ink
INCLUDE test.ink
INCLUDE prologue.ink

~ dialogue_choice()
+ [Begin]
-

: Hello, world! #ty:written
: This is a [i]very[/i] early prototype of my RPG, currently codenamed %v:typed%"Legume Traffick."
: Please treat it kindly.
: Where would you like to begin?

~ dialogue_choice()
+ [In the test dungeon]
    ~ clear_dialogue()
    ->test
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
+ [Battling a shadow]
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
+ [Hitting the hay]
    ~ clear_dialogue()
    -> prologue.in_ciphers_room_begin_point


=== die
~ clear_dialogue()
: And so %p:1%the world was lost. #ty:typed
~ reset()
->END