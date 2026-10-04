
=== d0_08_12
->day_template(-> default_day.start_of_day, -> morning, -> afternoon, -> evening)->
->->

= morning
/ cut black
~ location = "apartment"
/ level millys cipher-apartment
/ spawn cipher
/ cipher costume pajamas
/ spawn journal
/ spawn cell_phone
/ cipher capture
/ cipher spawn apartment-bed
/ journal spawn desk-journal
/ cell_phone spawn bedside-phone
/ cipher act sleep
/ text mode
(...)
(You feel as if you've forgotten something.)
/ game mode
/ cut in
/ cipher act shock_awake
(You jolt awake.)
/ cipher walk apartment-by-bed
/ cipher release

- (walkabout)

+ (pondered) [ponder]
    / cipher capture
    <-ponder(->ponder_return)
    - - (ponder_loop)
    * * (where_am_i) cipher: (Where am I?) #v:thought #expr:question
        (You appear to be in a studio apartment.)
        cipher: (Is it mine?) #expr:confusion
        (That's not clear.)
        {
            - inventory has journal: (...You found your diary here, so it's a reasonable assumption.)
            - inventory has cell_phone: (...You found your cell phone here, so it's a reasonable assumption.)
            - else: (...You're the only one here, so for the moment, you assume it is.)
        }
        ->ponder_loop
    * * (who_am_i) {where_am_i} cipher: (...Who am I?) #v:thought #expr:nervous
        {inventory has cell_phone or inventory has journal:
            - true: (You're Forrest Rasmussen, according to your <>{
                - inventory has journal: journal
                - inventory has cell_phone: cell phone
            }<>.)
                (Other than that...?)
            - false: (...)
                (Nothing comes to mind.)
        }
        cipher: (Oh, no.) #expr:fear
        {inventory hasnt journal: (...There's a journal over there. Maybe it's yours?)}
        {inventory hasnt cell_phone: (There's{inventory hasnt journal: also} a cell phone on the desk. It might have more information.)}
        {inventory has journal: cipher: (I guess it's for the best that no one will know me at school.)}
        ->ponder_loop
    + + [(Done.)]
    - - (ponder_return)
    / cipher release
* {walkabout < 2} [nag 10]
    (You can move with the arrow keys and interact with objects using the Z key.)
* {!pondered} [nag 10]
    (You can hold the "Z" key to think.)
+ {inventory hasnt journal} [journal]
    / cipher capture
    / cipher walk by-desk
    {once:
        - (It's a journal, spiral-bound, with covers that look like wood, but are really just printed cardboard.)
            (Take it?)
        - (You return to the journal.)
        - (Shockingly, it's a journal.)
    }
    + + cipher: [(Take it.)] (I take the journal and look inside.)
        ~ inventory += journal
        (You pick up the journal.)
        (Its covers are clean, but opening it releases a cloud of dust...)
        ("Forrest Rasmussen" is written on the inside cover.)
        cipher: (That name rings a bell.) #v:thought #expr:ooh
        (Skimming it...)
        (Your parents are out on business for the next year.)
        cipher: (Is it legal to leave a minor alone for that long?) #expr:question
        (What's more, you just moved to this area.)
        (You seem to be anxious about your first day of high school this coming week.)
        {inventory has cell_phone:
            (...School starts today, apparently.)
            (Perhaps you should get ready?)
        }
        {who_am_i: cipher: (I guess it's for the best that no one knows me.)}
    + + cipher: [(Do not.)] (Never mind.)
    - -
    / cipher release
+ {inventory hasnt cell_phone} [cell_phone]
    / cipher capture
    {once:
        - (It's a cell phone. A sleek, black rectangle with no notable features.)
            (Take it?)
        - (The phone remains beside the bed. It's fully charged.)
        - true: / sound battle-start #!b:main
            (The phone suddenly springs to life and attacks!)
            (...Just kidding.)
    }
    + + cipher: [(Take it.)] (I take the cell phone and turn it on.)
        ~ inventory += cell_phone
        (You pick up the cell phone.)
        (It's not logged into anything, but the primary account is named "Forrest Rasmussen".)
        (Actually, it seems to be all factory defaults, apart from a few pictures in the camera roll.)
        (One shows someone blowing out candles... You recognize the face as your own.)
        (You try searching the name online, but nothing comes up.)
        {inventory has journal:
            (The date catches your eye. According to your journal, you're supposed to start school today.)
            (Perhaps you should get ready?)
        }
    + + cipher: [(Do not.)] (Never mind.)
    - -
    / cipher release
+ {!dressed} [wardrobe]
    / cipher capture
    (It's a wardrobe.)
    (Get dressed?)
    + + (dressed) cipher: (Get dressed.)
        (You aren't the biggest fan of this selection.)
        / fade black
        / cipher costume summer
        / fade in
        (...But it'll have to do.)
    + + cipher [(Do not.)] (Never mind.)
    - -
    / cipher release
* {inventory has cell_phone and inventory has journal and dressed and pondered} [nag 0]
    / cipher capture
    (You feel like you're ready to go out now.)
    / cipher release
+ {inventory has cell_phone and inventory has journal and dressed and pondered} [exit]
    / cipher capture
    / fade black
    ->->
+ [exit]
    / cipher capture
    {stopping:
        - (Somehow, you feel like you aren't ready to go out yet.)
        - (You still aren't ready to go.)
        - (Perhaps you'll know when you're ready.)
        - {shuffle:
            - (Nope.)
            - (Not yet.)
            - {
                - inventory hasnt journal or inventory hasnt cell_phone: (Without looking around?)
                - !dressed: (Dressed like that?)
                - !pondered: (Without taking time to think?)
                - else: (Nah.)
            }
        }
    }
    / cipher release
- ->walkabout
->->

= afternoon
/ cut black
~ location = "school_classroom"
/ level school hallway
/ crowd 3
/ spawn cipher
/ cipher capture
/ spawn casey
/ spawn mauve
/ spawn sonor-student
/ cipher spawn hallway-center
/ cipher follow path forward
/ fade in

cipher: (Other students...) #v:thought #expr:thoughtful
cipher: (I feel so out-of-place.)
(You remember that that's normal for a transfer student.)
cipher: (...Right.) #expr:doubtful

// Suddenly, Cipher is taken to a dungeon!
/ cipher stop
/ cut freeze
/ replace level d1 hallway
/ build cipher:forward tutorial-battle-hallway
/ mauve spawn watch-corner
/ casey spawn casey-unconscious
/ sonor-student spawn over-casey
/ cut jpeg
/ fade in #!b:main
/ cipher act shock #!b:main
(You feel a weight on your chest. It's hard to breathe.)
cipher: (!?!?!?!)
cipher: (Is [i]that[/i] normal for a transfer student?)
(Y-you, ah... You don't think so.)
/ sonor-student act chitter #!b:main
/ cipher act startle #!b:main
/ vfx speedlines sonor-student
sonor-student: P-P-PIZZICATO.
cipher: (Wha-?! The hell is that, it's so loud!)
(It doesn't have a face... You wonder if it's human.)
/ sonor-student act rummage #!b:main
/ sound rummage #!b:main
(The creature is attempting to pull the unconscious student by the leg!)
cipher: Hey! #v:yell
/ sonor-student act roar
/ battle setup school
/ cipher joins battle
/ sonor-student joins battle
/ casey spectates battle
/ battle!
+ [battle top]
-
/ battle lock
(Something electric passes over and through you.)
(It's your turn. What will you do?)
/ battle unlock
- (battle_loop)
* [cipher basic attacks]
    / battle lock
    (You ready your fists to attack.)
    (Aim for the last moment!)
    / battle unlock
* [battle enemy action]
    / battle lock
    sonor-student: <>{shuffle:
        - S-SOPRANO?
        - DRAMMATICO...
        - BEL-BELLICOSO!
        - KLANGFARBENMELODIE?
        - SOGNANDO...?
    }
    (The enemy winds up for an attack...!)
    (The enemy is about to shoot bullets at you.)
    (Use the arrow keys to move your CORE and avoid losing HEALTH.)
    (If you run out of HEALTH, you will fall unconscious.)
    (You can GRAZE a bullet by getting close without getting hit.)
    (You will regain ENERGY when grazing. Everyone uses ENERGY differently; you convert it directly into HEALTH.)
    (All right, the enemy will start attacking now. Ready...? Set...?)
    / battle unlock
* [battle enemy action]
    / battle lock
    sonor-student: <>{shuffle:
        - S-SOPRANO?
        - DRAMMATICO...
        - BEL-BELLICOSO!
        - KLANGFARBENMELODIE?
        - SOGNANDO...?
    }
    / battle unlock
* [cipher sings]
    / battle lock
    (Everyone has a special power.)
    (Yours is the ability to [i]improvise[/i]. Improv actions come from the enemies and the battlefield, rather than from your own skills. They can turn the tide of battle or defeat enemies nonviolently.)
    (This enemy looks like it might like [i]music[/i]. Sing to the beat!)
    / battle unlock
* [battle won]
    ->battle_end
* [battle lost]
    ->die
- -> battle_loop
- (battle_end)
/ battle end
/ sonor-student despawn
/ cut freeze
/ replace level school hallway
/ crowd 3
/ cut jpeg
/ fade in #!b:main
/ cipher run over-casey-2
/ cipher act crouch
casey: Agh... Crap, my head...
cipher: Are you okay? #v:normal #expr:worried
/ casey act getup-headache #!b:main
/ cipher act normal #!b:main
casey: Yeah, uh... I think so.
/ sleep 0.5
casey: D-did you see the... The speaker thing?
(You nod silently.)
casey: So that was... It was real?
cipher: I don't know. If we both saw it I guess it must have been?
/ camera turn mauve #!b:main
/ casey face mauve #!b:main
/ mauve act startle
/ mauve run todo-away-landmark #!b:main
casey: Er, excuse me!
/ fade black
TODO: Casey appears near Mauve.
/ fade in
casey: Excuse me, Mauve, did you see anything just now?
mauve: What? No, what should I have seen?
TODO: Cipher approaches.
/ mauve act startle
/ mauve act normal
cipher: I saw you looking at me when I was fighting, do you have any idea what just happened?
(She looks around covertly, then speaks louder than seems necessary.)
mauve: Haha, you're so funny! Hey, what's your number? #expr:forced-smile
cipher: Wh... What? 
mauve: We can talk about that later, okay? I don't want to be late to class. #expr:forced-smile
cipher: Ooookay...?
(You trade phone numbers.)
TODO: Mauve leaves.
casey: Wh... What the heck was that!?
cipher: She might not want to talk about it where others might hear?
casey: I guess, she's certainly... [i]protective[/i] of her reputation. #expr:disgust
cipher: Hmm, good to know.
casey: I guess we might as well trade numbers too, right?
cipher: Sure.
(You trade phone numbers.)
casey: I'm Casey, by the way.
cipher: Forrest. It's nice to meet you.

->->

= evening

->->



























































