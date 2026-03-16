=== banter

= junction(-> back)
~ random_choice()
<-mauve_hints(back)
=mauve_hints(->back)
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
- ->back

= hallway(-> back)
~ random_choice()
_
<- generic_hallway(back)
{junction_current_room():
    - "monster": <-monster_hallway(back)
    - "item": <-item_hallway(back)
    - "event": <-event_hallway(back)
    - "safe": <-safe_hallway(back)
    - "boss": <-boss_hallway(back)
    - "shop": <-shop_hallway(back)
}

+ [_]
-
->back

= generic_hallway(-> back)
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
+ [_]
-
->back

= monster_hallway(-> back)
// + ->
// -
->DONE

= item_hallway(-> back)
+ [placeholder]
    : There would be an item here, if it was implemented.
-
->back

= event_hallway(-> back)
+ [placeholder]
    : There would be a special event here, if it was implemented.
-
->back

= safe_hallway(-> back)
// + ->
// -
->DONE

= boss_hallway(-> back)
+ [placeholder]
    : There would be a boss here, if it was implemented.
-
->back

= shop_hallway(-> back)
+ [placeholder]
    : There would be a shop here, if it was implemented.
-
->back
