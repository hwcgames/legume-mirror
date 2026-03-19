=== banter
->->
= junction
~ random_choice()
<-mauve_hints
+ [_]
- ->->
=mauve_hints
VAR next_room = "N/A"

+ {junction_next_room(-1) != "N/A"} [Mauve hint left]
    ~ next_room = junction_next_room(-1)
    mauve: Something to the left feels <>{next_room:
        - "monster": monstrous
        - "item": resourceful
        - "event": interesting
        - "safe": comforting
        - "boss": fearsome
        - "shop": commercial
        - else: strange
    }<>... #ty:thought
+ {junction_next_room(0) != "N/A"} [Mauve hint middle]
    ~ next_room = junction_next_room(0)
    mauve: Something ahead feels <>{next_room:
        - "monster": monstrous
        - "item": resourceful
        - "event": interesting
        - "safe": comforting
        - "boss": fearsome
        - "shop": commercial
        - else: strange
    }<>... #ty:thought
+ {junction_next_room(1) != "N/A"} [Mauve hint right]
    ~ next_room = junction_next_room(1)
    mauve: Something to the right feels <>{next_room:
        - "monster": monstrous
        - "item": resourceful
        - "event": interesting
        - "safe": comforting
        - "boss": fearsome
        - "shop": commercial
        - else: strange
    }<>... #ty:thought
+ [_]
- ->->

= hallway
~ random_choice()
_
<- generic_hallway
{junction_current_room():
    - "monster": <-monster_hallway
    - "item": <-item_hallway
    - "event": <-event_hallway
    - "safe": <-safe_hallway
    - "boss": <-boss_hallway
    - "shop": <-shop_hallway
}

+ [_]
-
->->

= generic_hallway
* [Sensory]
    : The hallway looks something like what you know from your school, but there's an imposing aura... #ty:typed
* [Casey questions the workings of the dungeons]
    casey: Where do you all think we are? #ty:spoken
    cipher: Pardon?
    casey: I mean, like, physically? This place is way too big to fit inside the school.
    april: Yeah, and it's not like we're just underground...
    april: Otherwise... #ty:thought
    mauve: It's clear there's something we don't understand about this place. #ty:spoken
* [April questions what happens if it doesn't go away]
    april: Hey, can I ask you all something? #ty:spoken
    casey: Shoot.
    april: What happens if we get to the bottom of this place and the disappearances don't stop?
    cipher: That's a worrying possibility...
    casey: They're getting more frequent every day, so if we can't stop them...
    casey: The entire city would probably be sucked in. #expr:fear
-
->->

= monster_hallway
// + ->
// -
->DONE

= item_hallway
+ [placeholder]
    : There would be an item here, if it was implemented.
-
->->

= event_hallway
+ [placeholder]
    : There would be a special event here, if it was implemented.
-
->->

= safe_hallway
* [anyone tired]
    april: Oof, is anyone else ready for a break? #ty:spoken #expr:uneasysmile
* {TURNS_SINCE(->safe_hallway) < TURNS_SINCE(->boss_hallway)} [boss wore us out]
    casey: Is everyone holding up all right? That fight earlier really took it out of me... #ty:spoken
-
->->

= boss_hallway
* [mauve feels something]
    mauve: There's something up ahead... #ty:thought
* [cipher feels something]
    : The air feels harsh.
-
->->

= shop_hallway
+ [placeholder]
    : There would be a shop here, if it was implemented.
-
->->

= monster
~ random_choice()
+ [_]
-
->->

= miniboss
~ random_choice()
+ [_]
-
->->





