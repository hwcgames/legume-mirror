INCLUDE lib.ink
INCLUDE test.ink
INCLUDE prologue.ink

~ dialogue_choice()
+ [Begin]
-

: Hello, world! #ty:written
: This is a prototype/demo of my RPG, currently codenamed "Legume Traffick."
: Please treat it kindly.
: Where would you like to begin?

~ dialogue_choice()
+ [In the test dungeon]
    ->test
+ [At the start of the game]
    -> prologue
+ [On the way to school]
    ~ change_level("intro_railway", "walk_to_school")
    _
    ~ spawn_party("default")
    ~ actor_capture("cipher")
    ~ actor_start_following_path("cipher", "forward")
    -> prologue.walk_to_school_begin_point