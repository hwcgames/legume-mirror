
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
/ level intro default
/ spawn intro_train
/ spawn cipher
/ intro_train float
/ intro_train capture
/ intro_train appear train_entry
/ intro_train follow path rails
/ cipher capture
/ cipher appear train_cipher_seat
/ cipher pose sit
/ cipher act open_journal
/ camera 
/ fade in

(Cipher is aboard a train crossing a bridge.)
(They're alone, apart from someone asleep on the other end of the car.)

> Dear Diary, #v:written
(They cross it out.)
> To whom it may concern, #v:written
> I'm not going to belabor my situation - you've probably already been briefed on it. If you haven't, well... I'm sure someone will reach out to you soon. Regardless, I'm quite confident this is the last you'll be hearing from me. Arguably, leaving this here is a big risk, but when I imagine the look on the safety director's face... Well, if you know him, you'll understand why I decided to indulge. 
// If you happen to find this... Don't bother trying to return it. It isn't wanted, and I'm quite confident you couldn't find me even if it was. I imagine it'd fetch quite the price if you were to sell it. Much of it is classified, after all.
// It's a curious emotion. If all goes well, everything I've known in my life so far is behind me. I'm not sure how anyone else in today's world could even try to start over like this.
- (test)
> I've been thinking about what this means. I've never had to tell someone [i]who I am[/i] before. Will it be difficult? Scary? I've read that a person's "personality" is like a muscle: it develops when you have other people to bounce it off of, but atrophes when you're alone. Will they be able to tell I haven't been able to use mine?
> Even just this - it's my first time writing my own words for someone else to read. 

/ camera focus_on_speaker
/ sound train_bingbong
intro_train: Next stop, Weston Pier. Now approaching Weston Pier. Doors open on the left at Weston Pier. #v:speaker


> Goodbye, #v:written
> A Fellow Stranger.

> P.S: I'm not sure if I can call you "mom," but... Regardless, if you're reading this somehow: thanks for everything. Sorry if I got you fired.

(Cipher tears the last page out of their journal and leaves it on the seat.)
(They open the window and throw the rest of it into the ocean. After a moment, a splash is heard.)

(Fade through black to Cipher walking down a busy street.)

> So many people...
> I haven't felt like this before. I don't think I know the right word.
// > If a human felt like this, they'd probably dance, or sing, or something like that.
// > I'd like to try, but people would ask questions if I did it here.
> Anxiety, trepidation... "Dizzy," maybe.
> Woof. I should find someplace to rest.

(Cipher ducks into an alleyway, but shortly after they sit down, the opening is replaced with a brick wall, faster than the blink of an eye, and they startle away from it.)

> Huh..?

(They bang on the wall.)

> It's solid.

(They go stiff.)

> Wh-wait, have I...?

(The world dissolves into blocky noise. Monospace text flies past the screen before fading out.)
(You perform a diagnostic.)
(You hop on your toes.)

> My body's real as far as I can tell, but the forces are off by almost ten percent.
> Don't tell me... The whole time, I've-?

(Cipher hears a scream from further down the alley.)

> !!!
> There's a human in trouble.
> If there's any chance this isn't a simulation..!

-> tutorial_battle
= tutorial_battle

(They encounter Casey, lying on the ground, with a strange creature standing over her.)
/ spawn cipher
/ battle setup devel
/ spawn static/spookyguy
/ cipher joins battle
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
+ [battle enemy action]
-
/ battle lock
/ spookyguy state 1
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
+ [cipher attempts to flee]
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


> ...Oh!
> She just moved.

(Cipher sets her down.)

casey: Ugh, my head...!
cipher: Hello, are you all right?
casey: Huh-!
(Casey startles.)
casey: Oh, you... Did you save me?
cipher: Yes. You were unconscious, do you mind if I look you over?
casey: Yeah, er- Wait, that was real!?
> I hope so.
cipher: As far as I know.
casey: How did you even beat that thing?
cipher: I didn't.
(Casey looks around, alarmed.)
cipher: It's not like that. I just picked you up and ran. Eventually, I got out of... Wherever that was.
(Cipher steps back.)
cipher: Wait, your wounds are all gone?
(Casey looks herself over.)
casey: ...Huh. It couldn't have been some kind of dream, right? Since you found me there?
cipher: I guess not. Are you doing all right? I have an obligation in a few minutes that I need to get to.
(Casey digs her phone out of her pocket.)
casey: Yeah, uh- but before you go, do you want to get each other's chat IDs so we can keep in touch?
(The world freezes and dissolves into blocky noise.)
> Oops, just a sec-
(A registration webpage appears.)
> Ugh, I hate the world-net. Too many CAPTCHAs.
(The player picks their display name and username.)
> There, now I have an account.
(The world falls back into focus.)
cipher: Yes, I'm null_hypothesis. How about you?
casey: clueXfour.
(Cipher turns to leave and waves goodbye.)
cipher: Okay, I'll put you in once I get home.
(The camera lingers on Casey.)
Ca (whisper): null_hypothesis... There it is. Oh, I guess their name's Cipher. Haha, what's that say about me, asking their chat ID first?
(She laughs to herself, but something catches her eye.)
Ca (whisper): Registered... just now? But they didn't...

(Camera moves after Cipher, fade to black.)

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
+ (told_milly_computers_are_hard) cipher: Tell me about it!
    milly: Oh, well, I'm sure you can still run circles around me.
+ (told_milly_computers_are_easy) cipher: Really? I hadn't noticed.
    milly: Well, of course, kids your age have had them your whole lives.
-
milly: Say, I'm supposed to get a "goggle letter" for my taxes soon, would it be a bother to help me get it?
milly: I don't want to go all the way to the bank to get them to print it out for me.
> ...I'm not even going to ask what she means by that.
> This is an opportunity, though. Having a rapport will make her more likely to back me up if things go south.
cipher: Of course! Call me anytime.
milly: You're a peach, thank you. Do you need help with your bags?
cipher: No, I couldn't ask you to help with that. Besides, I'm stronger than I look!
> I don't actually have any luggage. If a semi truck ever breaks down in front of her driveway...
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

cxf: hello, stranger!
> Oh. Right.
nh: Hello.
cxf: thanks again for saving me today
> What else could I have done?
cxf: i still don't understand
cxf: where the hell were we? #expr:confused
cxf: what would have happened to me if you hadn't shown up #expr:fear
nh: I don't think there's any way to know for sure.
nh: I just hope it doesn't happen again.
(A moment's pause.)
cxf: btw
cxf: are you busy tomorrow?
nh: No, why?
cxf: do you want to come by my house? my parents are going to be out but i can get my brother to make lunch to repay you
> Oh no. This is way too soon for something like that.
nh: That's really not necessary, I was just in the right place at the right time.
cxf: ok
cxf: but consider
cxf: i want to get to know you
cxf: and i'm offering you free breakfast
cxf: and tbh i'm scared to go out alone in case it happens again but i have to buy school supplies
> Damn. If it's for safety, I can't say no.
nh: Okay. Time and place?
(A calendar file. It's at 9 AM tomorrow, a little less than a mile north of here.)
> Did she just... have that at the ready?
cxf: is that ok?
(A moment's pause.)
nh: Sure.

> None of the actors in simulations have ever been able to hold a conversation like that before.
> Do they have a human jacked in somehow? Or...
(Hope wells up inside you.)
> I could actually be free.
> ...I'll run more tests in the background while I sleep.

(The world dissolves into static.)

->->



























































