=== prologue_dungeon
= lobby
~ change_level("intro_dungeon", "lobby")
_
~ fade_in()
~ set_weather("dungeon")
~ spawn_party("entrance")
~ add_party_member("casey", "entrance")
~ add_party_member("mauve", "entrance")
~ add_party_member("april", "entrance")
~ spawn_actor("crow", "crow_zone")
~ actor_capture("cipher")
~ actor_capture("casey")
~ actor_capture("mauve")
~ actor_capture("april")
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
april: Oh, shit... #ty:spoken
april: This place feels heavier than the ones from before, doesn't it?
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
crow: Psst, player! It's me, down here, scraw!

- (lobby_walkabout)
+ [Crow]
    ~ actor_capture("cipher")
    ~ set_camera("crow")
    ~ sleep(0.5)
    _
    {once:
    - crow: Caw, hello, player! #ty:bird
      crow: This is the next part of the game I've been asked to guide you to.
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
        ~ set_camera("casey")
        crow: You already know Casey, of course... #ty:bird
        crow: She's an excitable, intelligent girl, and the first person you properly met on the outside.
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
        {once:
            - mauve: Well, "social reasons" is a bit of an understatement. #ty:thought
                mauve: If you had X-ray vision, how would you prove you weren't using it to look through people's clothes?
                mauve: Obviously I don't try to hear anything private, but only another mind-reader could prove that.
                crow: Huh. #ty:bird
                crow: I wasn't expecting her to hear that.
            - mauve: It was awkward enough the first time. #ty:thought
            - mauve: [i]Come on.[/i] How many times do you have to hear it? #ty:thought
                crow: Oughtn't you be a little more polite, caw? #ty:bird
                crow: The game isn't very good-looking yet, you know.
                crow: We need to make a good first impression.
                mauve: Yeah, yeah. #ty:thought
        }
    + + [What do I do next?]
        ~ set_camera("show_door")
        crow: When you walk through that door... #ty:bird
        ~ set_camera("crow")
        crow: You'll begin exploring the dungeon.
        crow: There will be a series of rooms with enemies and items, with a boss at the end.
        crow: After that, the demo is over, and it'll reset for the next player.
    + + [Never mind.]
        ~ set_camera("_")
        ~ actor_release("cipher")
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
~ sleep(1.5)
_
~ actor_start_following_path("cipher", "north_outgoing")
// ~ block_dungeon_progress()
crow: Oh! By the by, squawk... #ty:bird
crow: The story is pretty barebones from here on out.
crow: This section focuses on gameplay, I hope you enjoy the upcoming battles.
crow: I'll see you afterwards, scraw!
~ clear_dialogue()
~ despawn_actor("crow")
~ allow_dungeon_progress()
+ [dungeon entered room]
-
cipher: I see something! #ty:spoken
casey: Get ready to fight, everyone!
+ [battle lost]
    -> die
+ [battle won]
- (dungeon_loop)
~ block_dungeon_progress()
+ [dungeon towards junction]
- (towards_junction)
{junction_next_room(-1) == "N/A" and junction_next_room(0) == "N/A" and junction_next_room(1) == "N/A":
    ->boss
}
->banter.junction->
~ allow_dungeon_progress()
+ [dungeon entered junction]
-
~ sleep(0.5)
_
~ actor_release("cipher")
{once:
  - cipher: There's a fork in the road. #ty:spoken
    mauve: I guess there must be a choice for us to make?
}
~ block_dungeon_progress()
+ [dungeon towards room]
-
~ actor_capture("cipher")
~ actor_start_following_path("cipher", "forward")
->banter.hallway->
_
~ allow_dungeon_progress()

<-dungeon_loop
+ [dungeon built safe]
    ~ spawn_actor("crow", "crow")
    + + [dungeon entered safe]
    - -
    ~ set_camera("crow")
    ~ actor_release("cipher")
    ~ actor_capture("cipher")
    ~ actor_move("cipher", "talk_to_crow", "glide")
    ~ actor_wait("cipher")
    _
    {once:
      - crow: Hello again, caw! #ty:bird
        crow: This is a safe-room.
        crow: Eventually, you'll be able to save here, scraw...
        crow: But for now, I'll restore your health!
      - crow: Hey, we just keep running into each other! #ty:bird
        crow: The usual, scraw?
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
    // - - (safe_room)
    // ~ actor_release("cipher")
    // <-out_of_room
    // + + [crow]
    //     ~ capture_actor("cipher")
    //     ~ actor_move("cipher")
    // - -
    // ~ actor_cap
    // -> safe_room
+ [dungeon built room]
-

-> dungeon_loop

= boss
mauve: ...Something big is coming up next. #ty:thought
// leader: I set off into the dungeon. #thought
// ~ allow_dungeon_progress()
// + [dungeon entered room]
// -
// leader: ... And was attacked by strange creatures! #thought
// ~block_dungeon_progress()
// + [battle won]
//     leader: But they were vanquished. #thought
// + [battle lost]
//     leader: But I wasn't strong enough... #thought
//     ->test
// -
// + [dungeon towards junction]
// -
// leader: Onwards, into the deep. #thought
// ~ allow_dungeon_progress()
// + [dungeon entered junction]
// -
// -> junction
// = junction
// ~ block_dungeon_progress()
// ~ actor_release("leader")
// {once: leader: I found myself presented with a choice.} #thought
// * [dungeon towards monster]
//     ~ actor_capture("leader")
//     leader: I sought battle. #thought
// * [dungeon towards item]
//     ~ actor_capture("leader")
//     leader: I sought riches. #thought
// * [dungeon towards event]
//     ~ actor_capture("leader")
//     leader: I sought mystery. #thought
// * [dungeon towards safe]
//     ~ actor_capture("leader")
//     leader: I sought refuge. #thought
// * [dungeon towards boss]
//     ~ actor_capture("leader")
//     leader: I sought challenge. #thought
// * [dungeon towards shop]
//     ~ actor_capture("leader")
//     leader: I sought trade. #thought
// + [dungeon towards room]
//     ~ actor_capture("leader")
//     {once: leader: I pressed onwards.} #thought
// -
// ~ allow_dungeon_progress()
// ~ actor_start_following_path("leader", "forward")
// + [dungeon entered room]
// -
// {once: leader: And my search bore fruit.} #thought
// + [dungeon entered junction]
// -
// -> junction
->DONE