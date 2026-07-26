VAR leader = "cipher" // The game crashes without this
->hub

VAR location = "a"
VAR year = 0
VAR month = 0
VAR day = 0
VAR weekday = 1

=== function location_name(of)
~ return "Test story."

=== hub
/ level test hub
/ cut black
/ spawn cipher
/ spawn crow
/ cipher appear default
/ crow appear crow_l
/ fade in

+ [crow]
    / cipher capture
    / camera talk_to_crow
    / choice ?
    + + [dungeon]
- ->hub