===test
VAR dungeon_choice = "test"

~ change_level("test", "default")
~ spawn_party("default")

->lobby
= lobby
+ [chat]
    ~ actor_capture("leader")
    ~ actor_move("leader", "chat_pos", "default")
    ~ actor_wait("leader")
    dungeonman: Hello, friend!
    ~ actor_release("leader")
    -> lobby
+ [north]
    -> dungeon
= dungeon
~ actor_capture("leader")
~ actor_start_following_path("leader", "north_outgoing")
~ start_dungeon("test")
leader: I set off into the dungeon. #thought
~ allow_dungeon_progress()
+ [dungeon entered room]
-
leader: ... And was attacked by strange creatures! #thought
~block_dungeon_progress()
+ [battle won]
    leader: But they were vanquished. #thought
+ [battle lost]
    leader: But I wasn't strong enough... #thought
    ->test
-
+ [dungeon towards junction]
-
leader: Onwards, into the deep. #thought
~ allow_dungeon_progress()
+ [dungeon entered junction]
-
-> junction
= junction
~ block_dungeon_progress()
~ actor_release("leader")
{once: leader: I found myself presented with a choice.} #thought
* [dungeon towards monster]
    ~ actor_capture("leader")
    leader: I sought battle. #thought
* [dungeon towards item]
    ~ actor_capture("leader")
    leader: I sought riches. #thought
* [dungeon towards event]
    ~ actor_capture("leader")
    leader: I sought mystery. #thought
* [dungeon towards safe]
    ~ actor_capture("leader")
    leader: I sought refuge. #thought
* [dungeon towards boss]
    ~ actor_capture("leader")
    leader: I sought challenge. #thought
* [dungeon towards shop]
    ~ actor_capture("leader")
    leader: I sought trade. #thought
+ [dungeon towards room]
    ~ actor_capture("leader")
    {once: leader: I pressed onwards.} #thought
-
~ allow_dungeon_progress()
~ actor_start_following_path("leader", "forward")
+ [dungeon entered room]
-
{once: leader: And my search bore fruit.} #thought
+ [dungeon entered junction]
-
-> junction
->DONE