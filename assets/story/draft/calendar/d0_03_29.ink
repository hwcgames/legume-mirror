=== d0_03_29
~ time = 0
: MORNING
->morning->
~ time = 1
: AFTERNOON
->afternoon->
~ time = 2
: EVENING
->evening->
->->

= morning

(Cipher theatrically yawns, stretching their arms out after they rise to their feet.)

> Hello, world.
> Let's see how my tests went...

(Monospace text scrolls past the screen.)

> Everything looks perfect. The whole internet's here, everywhere agrees on how much time passed, deep packet analysis checks out. Even the traffic cameras from yesterday, they show me as I was without even the slightest amount of artifacting, and my network traffic even shows up in the relevant ISP logs.
> Ha... I really shouldn't have been able to see all of that. Maybe they should have thought twice before giving me a copy of the state's entire zero-day arsenal.
> If this is a simulation, it's in a completely different league from the others, so... I can only assume I'm really free.
> I was going to try dancing to express joy. Eh... How does this go?
(Cipher seems to be preparing to dance, but a signal pings in their head, startling them.)

calendar: "Meeting with Casey." 20 minutes on foot. Depart now.

(Cipher stops pacing and stands stiff.)

> Right! That! I'm ready! Why wouldn't I be? I snuck through a nuclear reactor yesterday, why would I be scared of breakfast with a human?

(Fade to approaching the Clue household.)

> Deep breaths, Cipher. If something goes wrong, you can just disappear. She won't be able to find you in a city this big with the information she has.
> ...Somehow, that isn't helping.
> I wonder why?

> Okay. You just have to knock.
(They screw up their face.)
> ...Knock! You can lift a car, stop a bullet! Can't you make small talk with a human while they eat without rehearsing first?
(The door swings open, and Casey's face peeks out. Cipher almost falls off the doorstep.)
Ca: Cipher! Hi! C'mon in, I want to introduce you!
(Casey pulls Cipher by the hand. It's clearly quite effortful on her end.)
(Cipher goes along with it, but is extremely nervous.)
Ci: Casey! Hello, uh, good morning...!
(They round a corner into the kitchen. A tall boy wearing an apron is setting the table, but when he sees Cipher, he freezes.)
Ca: Tell! This is the person I told you about!
(He speaks through a forced smile.)
Te: U-uh, oh, yeah...! What a pleasant [i]surprise![/i]
(Casey gasps.)
Ca: Oh, my gosh, I'm so sorry, I swear I meant to tell you!
Te: No, it's... Fine. There's enough. Just... Please tell me in advance next time you want to have someone over.
> Another...? Shit, how could I forget?! I had to bus tables for one of the Edison investor meetings a few times, but now they actually expect me to eat!
> I'm supposed to be able to get power from organic material, but just the idea of putting dead stuff inside me makes me queasy...!
Ci: Oh, no, I wouldn't want to impose! I'm, uh, not that hungry anyway?
Te: No! No. It's fine. You can take mine, I'll... just make another helping for myself.

(Cipher hesitantly sits at the table with Casey.)

Ca: So, tell me a little about yourself!
- (casey_interrogation)
* (casey_clarified) {casey_interrogation < 2} [What?]
    Ci: Uh, what do you mean?
    Ca: Y'know, where you go to school, your hobbies, that sort of thing?
* (hobbies) [Hobbies]
    {
        - !casey_clarified: > She'll probably want to know about my hobbies.
    }
    > She might ask follow-up questions, so...
    > I guess I'll go with what I'm actually best at.
    Ci: I've done some computer programming, I guess you could call that a hobby.
    (Casey's eyes light up.)
    Ca: Oh, me too!
    (She has a mischievous expression.)
    Ca: So, what's your language of choice?
    * * [Popular.]
        > Uh, what's the most popular language again?
        Ci: I'd say NetLisp is the easiest to find resources for.
    * * [Genuine.]
        > I guess I can answer somewhat honestly.
        Ci: I've really been enjoying Crablang lately.
    - -
    (She smiles smugly. Her tone is jesting.)
    Ca: A typical choice. Well, I say you can't go wrong with good ol' B.
    * * [Good choice.]
        Ci: That's definitely a good choice too.
        Ca: Indeed.
        (Casey seems a little disappointed you didn't engage with her ironic tribalism.)
    * * [Dangerous?]
        Ci: Isn't that a bit dangerous?
        Ca: Ufufu, maybe for mere mortals.
        > The "me" part of my brain isn't a general-purpose computer, but...
        > It would still be unpleasant if my coprocessor's kernel was written in a language like that.
    - -
    {
        - !school: ->casey_interrogation
    }
    - - (club)
    (She's struck with an idea.)
    Ca: Wait, we should totally start a programming club!
    Ci: I guess we could.
* (school) [School]
    {
        - !casey_clarified: > I look about the same age as her, so...
            > She'll probably want to know where I go to school.
    }
    Ci: I'm just starting at Northold High this semester.
    Ca: You're kidding! Tell and I are going there, too!
    (A chill goes down your spine.)
    > So much for being able to disappear.
    {
        - hobbies: ->club
    }
* [Yesterday]
    Ci: Actually, can we talk about what happened yesterday?
    Ca: Oh, sure! I had a really nice time. What about?
    (Casey points at Tell.)
    Ca (mouthed): He doesn't know!
    Ci: ...Uh, sorry, I just lost my train of thought.
+ ->done_with_interrogation
- ->casey_interrogation
- (done_with_interrogation)

(Tell sits down with his plate.)
Te: So, Cipher, is it? How'd you two meet?
(Casey gives you a meaningful glance.)
* (tried_to_tell_the_truth_about_creature) [Truth]
    Ci: I was on my way home, but I found her unconscious—
    Ca: And realized my blood sugar was low! They helped me get some sugar.
    (She glares at you.)
    Ci: ...Yeah, that.
* (lied_about_car_accident) [Lie]
    Ci: We were both crossing the street when someone ran a red light.
    (She seems confused.)
    Ca: Uh, yeah, I wasn't paying enough attention, but they got me out of the way.
-
(Tell's face falls.)
Te: Oh.
(He smiles again, but his voice is strained.)
Te: Uh, Casey? Why didn't you tell me about that?

(There's a long pause...)

Ca: I just... didn't want you to have to worry, since it turned out okay.
Te: ...Okay. Yeah, that's fine. Just... Remember that you can talk to me about anything, okay?

(Another awkward pause. You could hear a pin drop.)
Ca: ...Yeah.
(It doesn't sound like she means it.)
Te: Okay. Sorry about all this, Cipher, is the food all right?
Ci: Oh, right-... I haven't had any yet.
> It'd be rude to refuse, right?
> Okay, I can just say I have an emergency, and then never-
> No, she'll see me at school. Shit. I'm in too deep to back out now.
(You're a little clumsy with the utensils, but you manage to excise what you imagine is a bite's worth of food.)
Te (whispered): Do they... not like eggs?
> Just... Don't think about it! Humans do this all the time, I can handle it!
(You bite down.)
> Oh, no.
(A heretofore-unknown something is compelling you, but you recognize the feeling.)
> Why do I want to keep eating so badly?
> Did I miss a backdoor when I was burning my command pathways out?
> There's no one here to give the order, no codecs left to interpret it...
> And why the hell would-?!
Ca: Shit, Cipher, hang in there-!
(You realize you put your hand on your throat without realizing.)
(Casey and Tell seem to think you're choking.)
Ci: No! I'm fine, uh-... I just remembered, my laundry's still in the dryer.
(They seem unconvinced.)

(...You finish your meal.)

->->
= afternoon
(You and Casey reach the store and buy groceries without incident.)
(Aboard the train on the way back from the store...)

Ca: Hey, Cipher? Can I ask you something?
> Oh, no.
Ci: Sure.
Ca: So, please forgive me if I'm overstepping, but... Are you-
> Shit. Already?
> Okay, I can change schools, that's-
Ca: -doing all right?
> ??????
(You sigh.)
Ci: No, not really. I, uh... Don't really know what to think of what happened before.
> ...That was unexpected.
> Actually, once we're alone... Would it be that big of an issue to tell her?
> The worst she can do is tell someone else, and I've still got enough resources to move if things go south.
> It might be worth the risk to have someone to talk to.
> Or maybe I'm just being naive.

(Something strange weighs on your chest... The other people aboard the train vanish, save for someone on the other end who's quickly losing control of their faculties. Casey retreats into her seat.)

Ci: ...Speak of the devil.
Ca: There's someone else over there.
Ci: So it's not just us, and there's no way we can run away this time.
> I could survive jumping out of the train, but carrying two people?
> The G-forces wouldn't be kind to them.

(Dark smoke flows under the door near the stranger, coalescing into a snake. They stumble away, but trip and fall to the ground. You bolt to your feet and hurry to their aid, but behind you, more snakes slither underneath the doors on the side of the train, cutting you off from Casey.)

Ci: Shit- Casey!
(There's only one snake near you and the stranger. You grip it by the neck and slam it into the wall as hard as you can. The wall dents from the force, but the creature writhes in pain.)
> ...I can actually hurt them this time.

(Cipher begins to attack the snakes in the middle of the train. Casey can use a weak basic attack, but isn't able to do much at first. After the enemy phase on turn 3, a snake lunges at her, and the parts of the train near her are torn apart to form a mechanical gauntlet.)

// Thank goodness nothing happ-

// (The train vanishes, along with all of the other people aboard.)
// (Time seems to slow. You grab Casey and reorient yourself to land on your back.)

// Ca: (Coughing, groaning.)
// Ci: Are you okay?
// (Casey takes a moment to collect herself.)
// Ca: Yeah, uh- oh my gosh, are you? I think I landed on you!
// Ci: You sure did.
// Ca: Shit, let me see!
// (Casey gets up to look at you. Her eyes go wide.)
// Ca: ...Cipher?
// > Here goes.
// Ca: Why is your blood pink?
// Ci: It isn't blood, it's, uh... Mostly water, nanomachines, some dyes and trace metals?
// (Casey takes a moment to process. Her expression is inscrutable.)
// Ci: Do you think we could hold off on examining that until we're out of here?
// (She takes a deep breath.)
// Ca: ...Okay. Uh, are you going to be okay... leaking like that?
// Ci: Yes, it'll be fixed soon. Are you doing all right? No broken bones, concussion symptoms?
// (She blinks.)
// Ca: I probably shouldn't be okay, but... Yeah, somehow.

// (A train horn comes from down the tunnel.)

// Ca: Are we still in that other world, or...?
// Ci: Either way, I don't want to be here when that train comes. Get on.
// (You crouch down to carry Casey on your back.)
// Ca: Excuse me? We need to-
// (The train's light can be seen.)
// Ci: Now, please?!
// (Casey climbs on, and you take off at inhuman speed. A long cheetah with glowing eyes and innumerable legs catches up, and it roars with the sound of a train horn.)

// (During the battle, Cipher has a parley action that spends their full SP bar to speed up. After doing this five times, the battle ends. Casey manifests her false spell and can deal damage to the cheetah; dealing enough damage has the same effect as Cipher speeding up.)
// (After the battle, they reach the end of the tunnel and are released into the outside world. As soon as they cross the threshold, Cipher's blood and injuries seem to fade away. They leap over the fence and emerge from the bushes.



->->
= evening

(You're back at your apartment after ensuring Casey got home safe.)

> Whew.

->->





































