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
+ [Battling a shadow]
    ~ change_level("intro_railway", "alleyway")
    _
    ~ spawn_party("default")
    ~ actor_capture("cipher")
    ~ sleep(0.5)
    _
    -> prologue.battle_shadow_begin_point


=== die
: And so %p:1%the world was lost. #ty:typed
    ~ reset()