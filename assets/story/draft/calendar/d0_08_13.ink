=== d0_08_13
->day_template(-> default_day.start_of_day, -> morning, -> afternoon,->  evening)->
->->

= morning

(Cipher theatrically yawns, stretching their arms out as they rise to their feet.)

> Hello, world.
> Let's see how my tests went...

(Monospace text scrolls past the screen.)

> Everything looks perfect. The whole internet's here, everywhere agrees on how much time passed, deep packet analysis checks out. Even the traffic cameras from yesterday: they show everything I saw, exactly as it was, and my network traffic shows up in the relevant ISP logs.
> Ha... I really shouldn't have been able to see all of that. Maybe they should have thought twice before giving me a copy of the state's entire zero-day arsenal.
> If this is a simulation, it's in a completely different league from the others, so... I can only assume I'm really free.
> I was going to try dancing to express joy. Eh... How does this go?
(Cipher seems to be preparing to dance, but a signal pings in their head, startling them.)

calendar: "Meeting with Casey." 20 minutes on foot. Depart now.

(Cipher stands stiff.)

> Right! That! I'm ready! Why wouldn't I be? I snuck through a nuclear reactor yesterday, why would I be scared of breakfast with a human?

/ fade black
/ fade in
(Outside the Clue household...)

> Deep breaths. If something goes wrong, you can just disappear. She won't be able to find you in a city this big with the information she has.
> ...Somehow, that isn't helping.
> I wonder why?

> Okay. You just have to knock.
(They screw up their face.)
> ...Knock! You can lift a car, you're bulletproof! Can't you make small talk with a human while they eat without rehearsing first?
(The door swings open, and Casey's face peeks out. Cipher almost falls off the doorstep.)
casey: Cipher! Hi! C'mon in, I want to introduce you!
(Casey pulls Cipher by the hand. It's clearly quite effortful on her end.)
(Cipher goes along with it, but is extremely nervous.)
cipher: Casey! Hello, uh, good morning...!
(They round a corner into the kitchen. A tall boy wearing an apron is setting the table, but when he sees Cipher, he freezes.)
casey: Tell! This is the person I told you about!
(He plasters on a smile.)
tell: U-uh, oh, yeah...! What a pleasant [i]surprise![/i]
(Casey gasps.)
casey: Oh, my gosh, I'm so sorry, I swear I meant to tell you!
tell: No, it's... Fine. There's enough for another serving. Just... Please tell me in advance next time you want to have someone over.
> Another...? Oh. Oh no. I had to bus tables for one of the Edison investor meetings a few times, but now they actually expect me to eat!
> I'm supposed to be able to get power from organic material, but just the idea of putting dead stuff inside me makes me queasy...!
cipher: Oh, I wouldn't want to impose! I'm, uh, not that hungry anyway?
tell: No! No. It's fine. You can have mine, I'll... make do with what's left.

(Cipher hesitantly sits at the table with Casey.)

casey: So, tell me a little about yourself!
- (casey_interrogation)
* (casey_clarified) {casey_interrogation < 2} [What?]
    cipher: Uh, what do you mean?
    casey: Y'know, where you go to school, your hobbies, that sort of thing?
* (hobbies) [Hobbies]
    {
        - !casey_clarified: > She'll probably want to know about my hobbies.
    }
    > She might ask follow-up questions, so...
    > I guess I'll go with something I actually know.
    cipher: I've done some computer programming, I guess you could call that a hobby.
    (Casey's eyes light up.)
    casey: Oh, me too!
    (She has a mischievous expression.)
    casey: So, what's your language of choice?
    * * [Popular.]
        > Uh, what's the most popular language again?
        cipher: I'd say NetLisp is the easiest to find resources for.
    * * [Genuine.]
        > I guess I can answer somewhat honestly.
        cipher: I've really been enjoying Crablang lately.
    - -
    (She smiles smugly. Her tone is jesting.)
    casey: A typical choice. Well, I say you can't go wrong with good ol' B.
    * * [Good choice.]
        cipher: That's a good choice too.
        casey: Indeed.
        (Casey seems a little disappointed you didn't engage with her ironic tribalism.)
    * * [Dangerous?]
        cipher: Isn't that a bit dangerous?
        casey: Ufufu, maybe for mere mortals.
        > I'm not a general-purpose computer, but...
        > It would still be unpleasant if my coprocessor crashed because of some memory bug.
    - -
    {
        - !talked_about_school: ->casey_interrogation
    }
    - - (club)
    (She's struck with an idea.)
    casey: Wait, we should totally start a programming club!
    cipher: I guess we could.
* (talked_about_school) [School]
    {
        - !casey_clarified: > I look about the same age as her, so...
            > She'll probably want to know where I go to school.
    }
    > Good thing I actually signed up somewhere...
    > Given the age I look, it would attract too much attention not to.
    cipher: I'm just starting at Northold High this semester.
    casey: You're kidding! Tell and I are going there, too!
    > Oh.
    > So much for being able to disappear.
    {
        - hobbies: ->club
    }
* [Yesterday]
    cipher: Actually, can we talk about what happened yesterday?
    casey: Oh, sure! I had a really nice time. What about?
    (Casey makes a "cut it out" gesture.)
    cipher: ...Uh, sorry, I just lost my train of thought.
+ ->done_with_interrogation
- ->casey_interrogation
- (done_with_interrogation)

(Tell sits down with his plate.)
tell: So, Cipher, is it? How'd you two meet?
(Casey gives you a meaningful glance.)
* (tried_to_tell_the_truth_about_creature) [Truth]
    cipher: I was on my way home, but I found her unconscious—
    casey: And realized my blood sugar was low! They helped me get some sugar.
    (She side-eyes you.)
    cipher: ...Yeah, that.
* (lied_about_car_accident) [Lie]
    cipher: We were both crossing the street when someone ran a red light.
    (She seems confused.)
    casey: Uh, yeah, I wasn't paying enough attention, but they got me out of the way.
-
(His face falls.)
tell: Oh.
(He smiles again, but his voice is strained.)
tell: Uh, Casey? Why didn't you tell me about that?

(There's a long pause...)

casey: I just... didn't want you to have to worry, since it turned out okay.
tell: ...Okay. Yeah, that's fine. Just... Remember that you can talk to me about anything, okay?

(Another awkward pause. You could hear a pin drop.)
casey: ...Yeah.
(It doesn't sound like she means it.)
tell: Okay. Sorry about all this, Cipher, is the food all right?
cipher: Oh, right-... I haven't had any yet.
> It'd be rude to refuse, right?
> Okay, I can just say I have an emergency, and then never-
> No, they'll see me at school. Argh... I'm in too deep to back out now.
(You're a little clumsy with the utensils, but you manage to excise what you imagine is a bite's worth of food.)
tell: Are they vegan or something? #v:whispered
> Just... Don't think about it! Humans do this all the time, I can handle it!
(You bite down.)
> Oh, no.
(A heretofore-unknown something is compelling you to eat more.)
> Did I miss a backdoor when I was burning my command pathways out?
> There's no one here to give the order, no codecs left to interpret it...
> And why would-?!
tell: Er, is something wrong with it? Your face...
cipher: No! I'm fine, uh-... I just remembered I have to throw my eggs out, they're probably rotten by now.
(They seem unconvinced.)

/ fade black
(...You finish your meal.)

->->
= afternoon
(You and Casey reach the store and buy groceries without incident.)
(Aboard the train on the way back from the store...)
/ fade in

casey: Hey, Cipher? Can I ask you something?
> Oh, no.
cipher: Sure.
casey: So, please forgive me if I'm overstepping, but... Are you-
> Shit. Already?
> Okay, I can change schools, that's-
casey: -doing all right?
> ??????
casey: Er, I guess I don't know you very well, but you've been acting a little strange.
(You sigh.)
cipher: No, not really. I, uh... Don't really know what to think of what happened before.
> ...That was unexpected.
> Actually... Would it be that big of an issue to tell her? I'd want to get to know her better first, but she seems to trust me.
> The worst she can do is tell someone else, and I've still got enough resources to move if things go south.
> It might be worth the risk to have someone to talk openly with.
> Or maybe I'm just being naive.

(You feel a strange pressure... The other people aboard the train vanish. Casey shrinks back into her seat.)

> Speak of the devil.
(Dark smoke flows under the door at your end of the car. Casey startles out of her seat and stumbles back, just in time for more smoke to start flowing in through the side doors and the other end of the car, separating you.)
cipher: Casey! Hold on!
(The smoke coalesces into ghostly railway workers with what look like sea urchins where their heads should be.)

(Battle begins. When Cipher defeats one of the railroad spikes...)
> Oh, I can actually hurt them this time?
(Casey can use a weak basic attack, but it isn't very effective. The remaining railroad spike(s) in the center are scripted not to die yet.)
(Simultaneously, Cipher is scripted to spend their turn by getting hit in the face.)
> Ow...!
(Something wet is running from your nose. You wipe it away, and... It's red.)
(The liquid runs down the back of your throat. You feel woozy, and your breakfast is trying to disembark.)
> [i]What is happening to me?![/i]
casey: Oh, crap, Cipher!
(Replacing the enemy phase, a creature lunges at her, and a strange mechanical gauntlet forms around her hand. From then on, she's able to use basic spells to rescue Cipher.)

crow: Each character has a unique ability, caw. #v: bird
crow: Cipher's ability is, well... The lack of something can be unique, in its own right.
crow: Characters need some kind of "energy" to use "skills," scraw.
crow: For Casey to use skills, she needs to gather "trinkets".
crow: Dealing damage with her basic attack will scatter "trinkets" on the bullet board. You can pick them up during the defense phase.

(After the battle ends...)
(The rest of the passengers fade back in. Casey's gauntlet vanishes.)
> !!!
(The people don't seem to notice you.)
> ...Oh.
(You return to your seat. Your whole body is shaking.)
casey: Cipher? Are you okay? #v:whisper
cipher: ...No.
casey: You were bleeding pretty bad, but...
(It's dry.)

(Awkward pause.)

casey: It's perfectly normal to get queasy around blood, uh-... Please try not to feel bad about that?
cipher: Yeah, I... I know.
> I can handle blood fine, that's not the problem.
cipher: Thanks.
(Casey smiles nervously.)
casey: Does that make us even?
cipher: Ha... Yeah, I guess.

/ fade black
->->

= evening

(You're back at your apartment, lying supine on the floor.)

/ fade in
> Whew.
> Today was pretty dense.
> And tomorrow is the first day of classes...
> There's just one thing I need to be sure of.
(You press two fingers to your neck.)
(...There's nothing noticeable.)
> Okay.
> I'd like to use Occam's razor. This could just be a [i]really weird[/i] simulation.
> ...I'm having trouble believing that, but the alternative is to accept that magic is real.
> Maybe there's something wrong with [i]me[/i].
> I guess I'll reserve judgement for now.

->->






