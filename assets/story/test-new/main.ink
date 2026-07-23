VAR leader = "cipher" // The game crashes without this
->hub
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