EXTERNAL sleep(seconds)
=== function sleep(seconds)
>>> Sleep for {seconds}s.

// Track the characters in the party

LIST party = (cipher), casey, tell, mauve, vince, prince, april
VAR leader = cipher

// Track the game's mode
// `cinema` disables player control for cinematics.
// `walkabout` allows the player to move freely.
LIST gamemode = (cinema), walkabout

// Level management
EXTERNAL queue_room(room, exit)

=== function queue_room(room, seam) ===
>>> Place {room} attached by {seam}.

EXTERNAL change_level(level)
VAR current_level = ""
=== function change_level(level)
~current_level = level
~gamemode = cinema
>>> Change level to {level} and switch to cinema mode.

// Actor management
EXTERNAL spawn_actor(id, landmark)
EXTERNAL spawn_party(landmark)
EXTERNAL spawn_party_member(id, landmark)
EXTERNAL spawn_enemy(id, landmark)

=== function spawn_actor(id, landmark)
>>> Spawn actor {id} at {landmark} (or teleport them there).
=== function spawn_party(landmark)
>>> Spawn the party ({party}) at {landmark} (or teleport them there).
=== function spawn_party_member(id, landmark)
>>> Spawn a party member at {landmark} (or teleport them there).
=== function spawn_enemy(id, landmark)
>>> Spawn enemy {id} at {landmark}.
~ return id

// Actor control
EXTERNAL actor_act(id, action)
=== function actor_act(id, action)
>>> {id} performs {action}.

EXTERNAL actor_move(id, landmark, style)
=== function actor_move(id, landmark, style)
>>> {id} walks to {landmark} with locomotion style {style}.

EXTERNAL actor_capture(id)
=== function actor_capture(id)
>>> {id} is under story control.

EXTERNAL actor_release(id)
=== function actor_release(id)
>>> {id} is released from story control.

// Dialogue control
EXTERNAL open_dialogue_box()
=== function open_dialogue_box()
>>> Open the dialogue box.

EXTERNAL close_dialogue_box()
=== function close_dialogue_box()
>>> Close the dialogue box.

// Battle management
EXTERNAL spawn_encounter(id)
=== function spawn_encounter(id)
>>> The next encounter will be {id}