EXTERNAL sleep(seconds)
=== function sleep(seconds)
>>> Sleep for {seconds}s.

EXTERNAL random_choice()
=== function random_choice()
>>> Choose randomly.

EXTERNAL actor_exists(actor)
=== function actor_exists(actor)
~ return true

// Track the characters in the party

// LIST party = (cipher), casey, tell, mauve, vince, prince, april
VAR leader = "cipher"

// Track the game's mode
// `cinema` blurs the world and draws actors in 
// `walkabout` allows the player to move freely.
VAR gamemode = "cinema"

EXTERNAL set_camera(camera)
=== function set_camera(camera)
>>> Activate camera {camera}

EXTERNAL fade_out(color)
=== function fade_out(color)
>>> Fade to {color}

EXTERNAL fade_in()
=== function fade_in()
>>> Fade in

EXTERNAL reset()
=== function reset()
>>> RESET

EXTERNAL clear_dialogue()
=== function clear_dialogue()

// Level management
EXTERNAL queue_room(room, seam)
=== function queue_room(room, seam) ===
>>> Ask the treadmill to get to {room} attached by {seam}.

EXTERNAL change_level(level, entrance)
VAR current_level = ""
=== function change_level(level, entrance)
~current_level = level
>>> Change level to {level} seeded with {entrance}.

EXTERNAL start_dungeon(level)
=== function start_dungeon(level)
>>> Set up the {level} dungeon

EXTERNAL stop_dungeon()
=== function stop_dungeon()
>>> Stop the currently-active dungeon

EXTERNAL block_dungeon_progress()
=== function block_dungeon_progress()
>>> Blocked dungeon progress

EXTERNAL allow_dungeon_progress()
=== function allow_dungeon_progress()
>>> Unblocked dungeon progress

// Actor management
EXTERNAL spawn_actor(id, landmark)
EXTERNAL spawn_party(landmark)
// EXTERNAL spawn_party_member(id, landmark)
EXTERNAL add_party_member(id, landmark)
EXTERNAL rm_party_member(id)
EXTERNAL spawn_enemy(id, name, landmark)
EXTERNAL despawn_actor(id)

=== function spawn_actor(id, landmark)
>>> Spawn actor {id} at {landmark} (or teleport them there).
=== function spawn_party(landmark)
>>> Spawn the party at {landmark} (or teleport them there).
=== function spawn_party_member(id, landmark)
>>> Spawn the party member {id} at {landmark}.
=== function add_party_member(id, landmark)
>>> Spawn the party member {id} at {landmark}.
=== function rm_party_member(id)
>>> Despawn the party member {id}.
=== function spawn_enemy(id, name, landmark)
>>> Spawn enemy {id} at {landmark}.
~ return id

EXTERNAL heal_party()
=== function heal_party()
>>> Healed the party.

EXTERNAL join_battle(actor)
=== function join_battle(actor)
>>> {actor} joins the fight!

=== function despawn_actor(id)
>>> {id} vanishes.

// Actor control
EXTERNAL actor_act(id, action)
=== function actor_act(id, action)
>>> {id} performs {action}.

EXTERNAL actor_move(id, landmark, style)
=== function actor_move(id, landmark, style)
>>> {id} walks to {landmark} with locomotion style {style}.

EXTERNAL actor_start_following_path(actor, path)
=== function actor_start_following_path(actor, path)
>>> {actor} starts automoving {path}.

EXTERNAL actor_start_following_actor(follower, followee, style)
=== function actor_start_following_actor(follower, followee, style)
>>> {follower} starts following {followee} with style {style}.

EXTERNAL actor_stop(actor)
=== function actor_stop(actor)
>>> {actor} stops whatever they're doing.

EXTERNAL actor_wait(actor)
=== function actor_wait(actor)
>>> Wait until {actor} is done with whatever they're doing.

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

EXTERNAL lock_battlefield()
=== function lock_battlefield()
>>> Take a shared lock on the battlefield

EXTERNAL free_battlefield()
=== function free_battlefield()
>>> Continue the battle

EXTERNAL start_battle()
=== function start_battle()
>>> FIGHT!

EXTERNAL enemy_state(enemy, state)
=== function enemy_state(enemy, state)
>>> {enemy} changes to state {state}

EXTERNAL dialogue_choice()
=== function dialogue_choice()
>>> This choice is presented to the player.

// Play sound
EXTERNAL play_sound(sound)
=== function play_sound(sound)
>>> You hear {sound}.

// Item management
LIST key_items = map_brochure

EXTERNAL confidant_level(confidant, level)
=== function confidant_level(confidant, level)
>>> I am thou, thou are I... {confidant} lv{level}

EXTERNAL set_weather(weather)
=== function set_weather(weather)
>>> It looks {weather} outside...

EXTERNAL junction_next_room(direction)
=== function junction_next_room(direction)
~ return "N/A"

EXTERNAL junction_current_room()
=== function junction_current_room()
~ return "N/A"