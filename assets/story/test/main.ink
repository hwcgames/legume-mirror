INCLUDE lib.ink
INCLUDE test.ink
INCLUDE prologue.ink

~ dialogue_choice()
+ [Begin]
-

: Hello, world! #ty:typed
: This is a prototype/demo of my RPG, currently codenamed "Legume Traffick."
: Please treat it kindly.
: Where would you like to begin?

~ dialogue_choice()
+ [In the test dungeon]
    ->test
+ [At the start of the game]
    -> prologue 