
=== d0_08_12
->day_template(-> default_day.start_of_day, -> morning, -> afternoon, -> evening)->
->->

= morning
/ cut black
-> skip_news
> WESTON GAZETTE #v:typed
> 20XX-07-18
> MISSING CHILD ALERT ISSUED FOR 6-YEAR-OLD "BRAYDEN"

> 20XX-07-21
> OFFICER REMOVED FROM DUTY AFTER SHOOTING, DRUG USE SUSPECTED

> 20XX-07-22
> COMMUNITY SEARCH FOR LOST DOG ENDS IN TRAGEDY

> 20XX-07-24
> OPINION: THE ESTRANGEMENT CRISIS: WHY MY KIDS WON'T CALL ME BACK

> 20XX-07-25
> UNION ORGANIZER MIS████ █████ #w:0
> EDISON CEO ANNOUNCES WEDDING VENUE #clear

> 20XX-07-26
> INSPECTOR GENERAL COMMENTS ON STRING OF DISAPPEARANCES

> 20XX-07-28
> CULPRIT BEHIND BARS, CITY SAFE AGAIN

> 20XX-08-01
> MISSING CHILD ALERT ISSUED FOR 14-YEAR-OLD "RACHEL"

> 20XX-08-02
> OFFICER MISSING, TIPS REQUESTED

> 20XX-08-03
> MANIFESTO FOUND AT COURTHOUSE, POLITICALLY MOTIVATED?
- (skip_news)
/ level railway tunnel
/ spawn intro_train
/ spawn cipher
/ intro_train float
/ intro_train capture
/ intro_train appear train_entry
/ intro_train follow path rails
/ cipher capture
/ cipher appear train_cipher_seat
/ cipher root train_cipher_seat
/ cipher pose sit
/ cipher act open_journal
/ camera train_cipher_seat
/ fade in

(Cipher is aboard a train crossing a bridge.)
(It's not busy, but there are several others aboard.)

> Dear Diary, #v:written
(They cross it out.)
> To whom it may concern, #v:written
> I'm not going to belabor my situation - you've probably already been briefed on it. If you haven't, well... I'm sure someone will reach out to you soon. Regardless, I'm quite confident this is the last you'll be hearing from me. Arguably, leaving this here is a big risk, but when I imagine the look on the safety director's face... Well, if you know him, you'll understand why I decided to indulge. It might break him when he learns that even the "prototype" thought he was insufferable, though.
// If you happen to find this... Don't bother trying to return it. It isn't wanted, and I'm quite confident you couldn't find me even if it was. I imagine it'd fetch quite the price if you were to sell it. Much of it is classified, after all.
// It's a curious emotion. If all goes well, everything I've known in my life so far is behind me. I'm not sure how anyone else in today's world could even try to start over like this.
> I've been thinking about what this means. I've never had to tell someone [i]who I am[/i] before. Will it be difficult? Scary? I've read that a person's "personality" is like a muscle: it develops when you have other people to bounce it off of, but atrophes when you're alone. Will they be able to tell I haven't been able to use mine?
> Even just this - it's my first time writing my own words for someone else to read. 

/ camera focus_on_speaker
/ sound train_bingbong
intro_train: Next stop, Weston Pier. Now approaching Weston Pier. Doors open on the left at Weston Pier. #v:speaker
/ camera back

> Well, this is my stop. #v:written
> Goodbye,
> A Fellow Stranger.

> P.S: I'm not sure if I can call you "mom," but... Regardless, if you're reading this somehow: thanks for everything. Sorry if I got you fired.

(Cipher tears the last page out of their journal and leaves it on the seat.)
(They open the window and throw the rest of it into the ocean. After a moment, a splash is heard.)

/ fade black
/ save in place
/ level city street
/ weather light_rain instant
/ crowd umbrellas
/ spawn cipher
/ cipher capture
/ cipher appear default
/ cipher follow path forward
/ fade in

(Fade through black to Cipher walking down a busy street.)

> So many people...
> I haven't felt like this before. I don't think I know the right word.
// > If a human felt like this, they'd probably dance, or sing, or something like that.
// > I'd like to try, but people would ask questions if I did it here.
/ queue room alleyway_branch
> Anxiety, trepidation... "Dizzy," maybe.
> Woof. I should find someplace to rest.

/ cipher wait
/ cipher pose trudge
/ cipher walk resting
/ cipher pose sit
> Bwah...
> That's a little better.
/ delete room alleyway_branch
/ build room alleyway_wall a:cipher/backward forward
/ weather overworld_dungeon instant
/ cipher face alleyway_wall
/ cipher pose default
/ cipher act startle_back
/ cipher emote startle

> Huh..?
/ cipher run alleyway_wall
/ cipher act punch_wall
/ sound punch_wall
> It's solid.

/ cipher emote unnerved

> Wh-wait, have I...?
/ fade jpeg #!W:main
(You perform a diagnostic.)
/ fade in #!b:main
/ cipher act hop_on_toes #!b:main

> My body's real as far as I can tell, but the forces are off by almost ten percent.
> Don't tell me... The whole time, I've-?

/ cipher face forward
/ cipher act startle_back
/ cipher emote startle
/ sound fem_scream
(You hear a scream from further down the alley.)

> ...There's a human in trouble.
/ cipher emote determined
> If there's any chance this isn't a simulation..!

/ queue room alley_battle
+ [build alley_battle]
-
/ spawn casey
/ casey capture
/ casey appear behind_p1
/ casey pose unconscious
/ spawn static/spookyguy
/ spookyguy appear loom
/ spookyguy pose loom
/ wait 1
/ cipher stop
> !!!
/ cipher run p1
/ cipher act kick

-> tutorial_battle
= tutorial_battle

/ battle setup devel
/ spawn cipher
/ spawn casey
/ casey capture
/ spawn spookyguy
/ cipher joins battle
/ casey spectates battle
/ spookyguy joins battle
/ battle!

+ [battle top]
-
/ battle lock
(You meet the creature's eyes.)
(There's a thrum of energy around you.)
/ done
/ battle unlock

+ [party hits]
-
/ spookyguy state 1
/ spookyguy act splash
/ battle lock
(The creature breaks up into droplets before reforming. Something smells electric.)
/ sound roar
/ spookyguy act roar #!W:main
(The creature lets out a gurgling roar.) #!W:main
> Good. Its attention is off of the human.
/ spookyguy act roar
(Dodge using the arrow keys.)
/ done
/ battle unlock

+ [battle top]
+ [battle lost]
    (Death message.)
    -> DONE
-
/ battle lock
/ spookyguy state 2
> It's fighting like I didn't even hit it...
> This is a losing game.
(Take special actions in combat using the "tactics" button.)
/ done
/ battle unlock
- (flee_loop)
+ [cipher attempts to flee]
+ [battle top]
    / battle lock
    {stopping:
        - > It's still not doing anything.
        - > I should find another solution.
        - > I don't think I'm doing any damage.
        - > Maybe I could get her away from it somehow?
        - (Use the "flee" action in the "tactics" menu.)
    }
    / done
    / battle unlock
    ->flee_loop
+ [battle lost]
    (Death message.)
    ->DONE
-
/ casey disappear
/ battle lock
> I can't defend us both at once...
> I need to be careful now.
/ done
/ battle unlock

+ [battle won]
+ [battle lost]
    (Death message.)
    -> DONE
-

/ battle end
/ casey spawn
/ casey cargo cipher

> ...Oh!
> She just moved.

/ cipher middle
/ casey stop
/ casey appear by_wall
/ casey pose sit
/ casey act headache #!b:main

casey: Ugh, my head...!
cipher: Hello, are you all right?
/ casey act startle #!b:main
casey: Huh-!
casey: Oh, you... Did you save me?
cipher: Yes. You were unconscious, do you mind if I look you over?
casey: Yeah, er- \{cmd / casey act startle\}Wait, that was real!?
> I hope so.
cipher: As far as I know.
casey: How did you even beat that thing?
cipher: I didn't.
/ casey act look_around #!b:main
cipher: It's not like that. I just \{cmd / casey emote blush\}picked you up and ran. Eventually, I got out of... Wherever that was.
/ cipher emote confused
cipher: Wait, your wounds are all gone?
/ casey act self_examine
casey: ...Huh. It couldn't have been some kind of dream, right? Since you found me there?
cipher: I guess not. Are you doing all right? I have an obligation in a few minutes that I need to get to.
/ cipher walk forward #!b:main
/ casey pose stand
/ casey act get_phone
casey: Uh- before you go, do you want to get each other's chat IDs so we can keep in touch?
/ pause
/ fade jpeg
> Just a sec-
/ done
/ gui chat_signup captcha
> Ugh.
/ done
/ gui animation captcha
/ gui page signup
(The player picks their display name and username.)
> There, now I have an account.
/ gui close
/ fade in
/ unpause
cipher: Yes, I'm null_hypothesis. How about you?
casey: clueXfour.
cipher: Okay, I'll put you in once I get home.
/ camera stick
/ cipher face forward
/ cipher act wave
/ cipher follow path forward

casey: null_hypothesis... There it is. Oh, I guess their name's Cipher. Haha, what's that say about me, asking their chat ID first? #v:whisper
/ casey emote pfft
/ casey emote huh
casey: Registered... just now? But they didn't... #v:whisper
/ camera back
/ fade black
/ save in place

->->

= afternoon

> I know this is important for humans, but...
> I wish it could wait until I had a better way to get money.
> I doubt they'll be able to trace me, but even though our relationship is a little "strained..."
> Stealing from my "parents" seems ill-advised.
> Even so, this part is important, so I've rehearsed my character.

milly: Oh, hello, dearie! What can I do for you?
cipher: I'm Cipher, my parents said they talked to you?
milly: Of course, of course! They said they'd send me your picture in "the goggle," but, oh, you know how it is with those new electric computers. So complicated!
> I'm flattered.
> We've had transistors for almost thirty years, though...?
+ (told_milly_computers_are_hard) cipher: Tell me about it!
    cipher: I keep saying, there's nothing they can do that clockwork can't.
    > That's especially ironic, considering who's saying it...
    milly: Oh, well, I'm sure you can still run circles around me.
+ (told_milly_computers_are_easy) cipher: Really? I hadn't noticed.
    milly: Well, of course, kids your age have had them your whole lives. Back in my day, when the pressure went out you could work the computer with a crank!
-
milly: Say, I'm supposed to get a "goggle letter" for my taxes soon, would it be a bother to help me get it?
milly: I don't want to go all the way to the bank to get them to print it out for me.
> ...I'm not even going to ask what she means by that.
> This is an opportunity, though. Having a rapport will make her more likely to back me up if things go south.
cipher: Of course! Call me anytime.
milly: You're a peach, thank you. Do you need help with your bags?
cipher: No, I couldn't ask you to help with that. Besides, I'm stronger than I look!
> I don't actually have any luggage. If a semi truck ever breaks down in front of her driveway, though...
milly: Aww, aren't you independent? Well, if you ever need anything, just let Aunt Milly know!

->->

= evening

> It's my room.
> ...That felt good to say.
(Cipher looks out their window.)
> So, that was my first day on the outside.
> Or... Was I actually?
(They get up and pace.)
> The possibility that I'm still stuck inside a simulation is difficult to ignore.
> How would I know, though? Maybe I could-
(A signal! Cipher almost trips.)

/ open phone
/ conversation: cipher casey

casey: hello, stranger!
> Oh. Right.
cipher: Hello.
casey: thanks again for saving me today
> What else could I have done?
casey: i still don't understand
casey: where the hell were we? #expr:confused
casey: what would have happened to me if you hadn't shown up #expr:fear
cipher: I don't think there's any way to know for sure.
cipher: I just hope it doesn't happen again.
(A moment's pause.)
casey: btw
casey: are you busy tomorrow?
cipher: No, why?
casey: do you want to come by my house? my parents are going to be out but i can get my brother to make lunch to repay you
> Oh no. This is way too soon for something like that.
cipher: That's really not necessary, I was just in the right place at the right time.
casey: ok
casey: but consider
casey: i want to get to know you
casey: and i'm offering you free breakfast
casey: and tbh i'm scared to go out alone in case it happens again but i have to buy school supplies
cipher: ...Sure. Time and place?
> Damn my bleeding heart.
> ...Heh.
(A calendar file. It's at 9 AM tomorrow, a little less than a mile north of here.)
> Did she just... have that at the ready?
casey: is that ok?
/ sleep 1.5
cipher: Sure.

> None of the actors in simulations have ever been able to hold a conversation like that before.
> Do they have a human jacked in somehow? Or...
(Hope wells up inside you.)
> I could actually be free.
> ...I'll run more tests in the background while I sleep.

(The world dissolves into static.)

->->



























































