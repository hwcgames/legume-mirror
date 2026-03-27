=== prologue_dungeon
= lobby
~ change_level("intro_dungeon", "lobby")
_
~ fade_in()
~ set_weather("dungeon")
~ spawn_party("entrance")
~ add_party_member("casey", "entrance")
~ add_party_member("april", "entrance")
~ add_party_member("mauve", "entrance")
~ spawn_actor("crow", "crow_zone")
~ actor_capture("cipher")
~ actor_capture("casey")
~ actor_capture("april")
~ actor_capture("mauve")
cipher: ..? #ty:thought
cipher: This place definitely isn't on the map of the city.
~ actor_move("cipher", "cipher_huddle", "walk")
~ actor_move("casey", "casey_huddle", "walk")
~ actor_move("mauve", "mauve_huddle", "walk")
~ actor_move("april", "april_huddle", "walk")
~ actor_wait("cipher")
_
~ set_camera("huddle")
: Everyone looks around, bewildered. #ty:typed
april: This place feels heavier than the ones from before, doesn't it? #ty:spoken
casey: It must be the source.
mauve: Definitely.
april: What next?
~ set_camera("_")
~ start_dungeon("prologue")
~ block_dungeon_progress()
~ actor_release("cipher")
// ~ actor_release("casey")
// ~ actor_release("mauve")
// ~ actor_release("april")
->input_tutorial->
{
    - meet_crow: crow: Psst, player! It's me, down here, scraw! #ty:bird
    - else: crow: Hey, you, human! Up in the sky, squawk! #ty:bird
}

- (lobby_walkabout)
+ [Crow]
    ~ actor_capture("cipher")
    ~ set_camera("crow")
    ~ sleep(0.5)
    _
    {
        - meet_crow:
            {once:
            - crow: Caw, hello, player! #ty:bird
              crow: This is the next part of the game I've been asked to guide you to.
            }
        - else:
            {once:
            - crow: Nice to meet you face-to-face, caw! #ty:bird
                crow: You were in a hurry to get here, eh?
                crow: I respect that - skip to the action.
            }
    }
    crow: Is there anything you'd like to know?
    - - (crow_talk)
    ~ set_camera("crow")
    ~ dialogue_choice()
    + + [Who are these people?]
        {once: 
            - crow: That's a fair question. #ty:bird
            - crow: Again? All right. #ty:bird
        }
        {
            - !meet_crow:
                crow: Cipher, the character you control, is an android of some sort who recently escaped from their mother's workplace. #ty:bird
                crow: You will choose their actions and keep them safe as they carve a niche into the concrete jungle.
        }
        ~ set_camera("casey")
        {
            - meet_crow:
                crow: You already know Casey, of course... #ty:bird
            - else:
                crow: This is Casey.
        }
        crow: She's excitable, intelligent, and the first person you properly met on the outside.
        crow: She uses her intellect to construct spells from mechanical parts.
        casey: Where even are we, physically? Underground? #ty:thought
        ~ set_camera("april")
        crow: This is April, a former basketball player who goes to another school. #ty:bird
        crow: She was recently put in a wheelchair by an injury, but for reasons that aren't yet clear, she's able to walk in this world.
        april: I wonder if we could set up a court here, somehow... #ty:thought
        april: I'd love to be able to play again.
        ~ set_camera("mauve")
        crow: This is Mauve, a strange girl you met when trying to find an explanation for your encounters with monsters in the city. #ty:bird
        crow: She founded the Paranormal Happenings Organization, a club at your school dedicated to finding the cause.
        crow: She has psychic abilities, but hides them for social reasons.
        {stopping:
            - mauve: Well, "social reasons" is a bit of an understatement. #ty:thought
                mauve: If you had X-ray vision, how would you prove you weren't using it to look through people's clothes?
                mauve: Obviously I don't try to hear anything private, but only another mind-reader could prove that.
                crow: Huh. #ty:bird
                crow: I wasn't expecting her to hear that.
                crow: Anyway, she <>
            - mauve: It was awkward enough the first time. #ty:thought
                crow: She <>
            - mauve: [i]Come on.[/i] How many times do you have to hear it? #ty:thought
                crow: Oughtn't you be a little more polite, caw? #ty:bird
                crow: The game isn't very good-looking yet, you know.
                crow: We need to make a good first impression.
                mauve: Yeah, yeah. #ty:thought
                crow: Anyway, she <>
            - crow: She <>
        }
        <>uses some of them here, but pretends they're the same kind of magic the others are using.
    + + [What do I do next?]
        ~ set_camera("show_door")
        crow: When you walk through that door... #ty:bird
        ~ set_camera("crow")
        crow: You'll begin exploring the dungeon.
        crow: There will be a series of rooms with enemies, with a boss at the end.
        crow: After that, the demo is over, and it'll reset for the next player.
    + + [(Done.)]
        ~ set_camera("_")
        ~ actor_release("cipher")
        ->meet_crow->
        -> lobby_walkabout
    - - -> crow_talk
+ [north]
    -> dungeon
    
- -> lobby_walkabout

= dungeon
~ actor_capture("cipher")
cipher: This looks like the only way forward. #ty:spoken
~ actor_release("casey")
~ actor_release("mauve")
~ actor_release("april")
~ actor_capture("crow")
~ actor_start_following_actor("crow", "cipher", "walk")
~ sleep(1)
_
~ actor_start_following_path("cipher", "north_outgoing")
// ~ block_dungeon_progress()
crow: Oh! By the by, squawk... #ty:bird
crow: The story is pretty barebones from here on out.
// crow: This section focuses on gameplay, I hope you enjoy the upcoming battles.
crow: I'll see you afterwards, scraw!
~ clear_dialogue()
~ despawn_actor("crow")
~ allow_dungeon_progress()
+ [dungeon entered room]
-
cipher: I see something! #ty:spoken
casey: Get ready to fight, everyone!
+ [battle enemy action]
-
~ lock_battlefield()
->dodge_tutorial->
~ free_battlefield()
+ [battle lost]
    -> die
+ [battle won]
- (dungeon_loop)
~ block_dungeon_progress()
+ [dungeon towards junction]
+ [dungeon done] -> boss
- (towards_junction)
// {junction_next_room(-1) == "N/A" and junction_next_room(0) == "N/A" and junction_next_room(1) == "N/A":
//     ->boss
// }
->banter.junction->
- (after_junct_banter)
~ allow_dungeon_progress()
+ [dungeon entered junction]
-
~ sleep(0.1)
_
~ actor_release("cipher")
{once:
  - cipher: There's a fork in the road. #ty:spoken
    mauve: Which way, though?
}
~ block_dungeon_progress()
+ [dungeon towards room]
-
~ actor_capture("cipher")
~ actor_start_following_path("cipher", "forward")
->banter.hallway->
- (after_hall_banter)
_
~ allow_dungeon_progress()

<- dungeon_loop
+ [dungeon built safe] ->dungeon_safe->
+ [dungeon built monster] ->dungeon_monster->
+ [dungeon built boss] ->dungeon_miniboss->
+ [dungeon built room]
-

-> dungeon_loop

= dungeon_monster
+ [battle top]
-

->banter.monster->

+ [battle won]
+ [battle lost]
    ->die
-
->->

= dungeon_miniboss
+ [battle top]
-

->banter.miniboss->

+ [battle won]
+ [battle lost]
    ->die
-
->->

= dungeon_safe
~ sleep(0.5)
_
~ spawn_actor("crow", "crow")
+ + [dungeon entered safe]
- -
~ set_camera("crow")
~ actor_release("cipher")
~ actor_capture("cipher")
~ actor_move("cipher", "talk_to_crow", "glide")
~ actor_wait("cipher")
_
{stopping:
  - crow: Hello again, caw! #ty:bird
    crow: This is a safe-room.
    crow: Eventually, you'll be able to save here, scraw...
    crow: But for now, I'll restore your health!
  - crow: Hey, we just keep running into each other! #ty:bird
  - crow: The usual, {caw|scraw|squawk}? #ty:bird
}
~ heal_party()
: You feel like new. #ty:typed
{once:
  - crow: That's all, squawk! #ty:bird
    crow: See you soon!
}
~ set_camera("_")
~ actor_start_following_path("cipher", "forward")
~ clear_dialogue()
->->

= boss
~ sleep(1)
_
// mauve: ...Something big is coming up. #ty:thought
~ queue_room("superintendent-office", "In")
+ [Build superintendent-office]
-
~ spawn_enemy("static/deliberatestew", "boss", "boss_chair")
~ spawn_actor("crow", "crow")
~ actor_capture("boss")
~ hide("desk_lights")
~ hide("battle_lights")
// cipher: ..? #ty:thought
: The air grows yet heavier. #ty:typed
~ actor_wait("cipher")
_
_
~ actor_capture("casey")
~ actor_capture("april")
~ actor_capture("mauve")
~ actor_move("cipher", "Player1", "glide")
~ actor_move("casey", "Player2", "glide")
~ actor_move("april", "Player3", "glide")
~ actor_move("mauve", "Player4", "glide")
~ actor_wait("cipher")
_
crow: Hello, player! #ty:bird
crow: You've just about made it to the end.
april: Is that... a bowl of soup? #ty:spoken
~ set_camera("dramatic_boss_camera")
~ sleep(6)
_
~ show("desk_lights")
boss: Do you know why you're here? #ty:spoken
~ set_camera("_")
- (why_are_you_here)
~ dialogue_choice()
* [Dungeon]
    cipher: To clear the dungeon. #ty:spoken
    boss: Dungeon? Is this some kind of game to you?
    - - (why_are_you_here_hint)
    {stopping:
        - april: What's that supposed to mean? #ty:spoken
        - casey: Maybe it doesn't want to know the real reason we're here? #ty:spoken
        - mauve: We're in a school, maybe it's asking about that? #ty:spoken
    }
    -> why_are_you_here
* [Disappearances]
    cipher: To find the people who have disappeared. #ty:spoken
    boss: Disappeared? What kind of myths have you brats been spreading about me?
    -> why_are_you_here_hint
* [Talk]
    cipher: To talk things out. #ty:spoken
    boss: You'd like that, wouldn't you?
    -> why_are_you_here_hint
+ [Education]
    cipher: To learn about the world. #ty:spoken
    ~ set_camera("dramatic_boss_camera")
    ~ sleep(5)
    _
    boss: Exactly.
-
~ hide("desk_lights")
~ set_camera("BattleCamera")
~ actor_move("boss", "Enemy1", "walk")
~ actor_wait("boss")
_
~ show("battle_lights")
boss: Prepare yourselves for a lesson in humility.
~ join_battle("cipher")
~ join_battle("casey")
~ join_battle("april")
~ join_battle("mauve")
~ join_battle("boss")
~ start_battle()
- (top)
<- won_or_lost
+ [battle top]
-
<- won_or_lost
+ [battle telegraph]
-
~ lock_battlefield()
{stopping:
    - : Suddenly, the room is lit in vibrant colors. #ty:typed
    - {shuffle once:
        - boss: Haha, is that all you've got? #ty:spoken
        - boss: Let's see how you handle my next attack..! #ty:spoken
        - : A gust of wind comes from outside the window. #ty:typed
        - april: Is everyone doing all right? #ty:spoken
    }
}
~ free_battlefield()

<- won_or_lost
+ [battle player action]
-
- (player_action)
<- won_or_lost
* [party hits]
    ~ lock_battlefield()
    boss: You little..! #ty:spoken
    ~ free_battlefield()
    -> player_action
* [april hits]
    ~ lock_battlefield()
    april: Euch, some soup splashed on me..! #expr:fear #ty:spoken
    ~ free_battlefield()
    -> player_action
+ [battle enemy action]
-

{shuffle:
    - boss: What do you think of this? #ty:spoken
    - boss: Prepare yourself! #ty:spoken
    - casey: Look out, everyone! #ty:spoken
}

- (won_or_lost)
+ [battle won]
+ [battle lost]
    -> die
-
boss: Ngh... You're a pain in my side, you know that? #ty:spoken
~ despawn_actor("boss")
: The soup-headed superintendent vanishes into dust. #ty:typed
~ set_camera("crow")
~ sleep(1)
_
{
    - meet_crow:
        crow: Hello again, player! #ty:bird
    - else:
        crow: Hello! #ty:bird
        crow: You started too late in the demo, so you don't know me, but...
}
crow: Congratulations! You've reached the end of the demo!
crow: Thanks so much for your time. I hope you had fun, despite the rough edges!
crow: If you'd like to tell my boss what you think, you can send an email to %v:typed%w@wolo.dev! #ty:bird
crow: That's %v:typed%w%v:bird% at %v:typed%wolo.dev.
crow: Oops, it's time for us to part ways-
crow: See you soon!
~ fade_out("jpeg")
_
~ reset()
->END


