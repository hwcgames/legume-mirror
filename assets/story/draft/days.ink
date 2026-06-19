
=== day_template(-> start, -> morning, -> afternoon, -> evening)
~ time = 0
->start->
>>> MORNING
->morning->
~ time = 1
>>> AFTERNOON
->afternoon->
~ time = 2
>>> EVENING
->evening->
->->

=== default_day
->day_template(-> start_of_day, -> morning, -> afternoon, -> evening)->
->->
// ~ time = 0
// ->start_of_day->
// >>> MORNING
// ->morning->
// ~ time = 1
// >>> AFTERNOON
// ->afternoon->
// ~ time = 2
// >>> EVENING
// ->evening->
// ->->

VAR do_hint = false

= start_of_day

// ->card_hint->

>>> day {name_day(year, month, day, weekday)}

{do_hint:
- (<>
    ->card_hint->
    <>)
}

->->

= morning

VAR had_a_dream_last_night = false
{RANDOM(0,6)==6 and !had_a_dream_last_night:
    - true: 
        ~ had_a_dream_last_night = true
        ->dream_hint->
    - false:
        ~ had_a_dream_last_night = false
}

{cycle:
    - {weekday <= 5:
        - true: {shuffle:
            - (You get ready for class.)
            - (...Another day. Time for school.)
        }
        - false: {shuffle:
            - (You get ready for your day.)
            - (You're glad to have a quiet day.)
        }
    }
    - {shuffle:
        - (You do some stretches.{once: You don't need them, but it's still nice.})
        - {stopping:
            - (Eating has its downsides - you have to brush your teeth now, for one.)
            - (You brush your teeth.)
        }
    }
}

->->

= afternoon

->->

= evening

->->