
=== default_day
~ time = 0
->start_of_day->
: MORNING
->morning->
~ time = 1
: AFTERNOON
->afternoon->
~ time = 2
: EVENING
->evening->
->->

= start_of_day

: {name_day(year, month, day, weekday)}

->->

= morning

->->

= afternoon

->->

= evening

->->