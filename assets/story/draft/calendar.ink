=== function days_in_month(m)
{m:
    - 1: ~ return 31
    - 2: {
        - year % 4 == 0: ~ return 29
        - else: ~ return 28
    }
    - 3: ~ return 31
    - 4: ~ return 30
    - 5: ~ return 31
    - 6: ~ return 30
    - 7: ~ return 31
    - 8: ~ return 31
    - 9: ~ return 30
    - 10: ~ return 31
    - 11: ~ return 30
    - 12: ~ return 31
}
=== function name_month(m)
{m:
    - 1: ~return "January"
    - 2: ~return "February"
    - 3: ~return "March"
    - 4: ~return "April"
    - 5: ~return "May"
    - 6: ~return "June"
    - 7: ~return "July"
    - 8: ~return "August"
    - 9: ~return "September"
    - 10: ~return "October"
    - 11: ~return "November"
    - 12: ~return "December"
}
=== function name_weekday(w)
{w:
    - 1: ~return "Monday"
    - 2: ~return "Tuesday"
    - 3: ~return "Wednesday"
    - 4: ~return "Thursday"
    - 5: ~return "Friday"
    - 6: ~return "Saturday"
    - 7: ~return "Sunday"
}
=== function ordinal(num)
{num}<>
{num / 10:
    - 1: th
    - else: {num % 10:
        - 1: st
        - 2: nd
        - 3: rd
        - else: th
    }
}

===function name_day(y, m, d, w)
{name_weekday(w)}, {name_month(m)} {ordinal(d)}, 20X<>{y:
    - 0: X
    - 1: Y
    - 2: Z
    - else: {y}
}

=== function next_day()
~ day += 1
~ weekday += 1
{day > days_in_month(month):
    ~ day = 1
    ~ month += 1
}
{month > 12:
    ~ month = 1
    ~ year += 1
}
{weekday > 7:
    ~ weekday = 1
}

=== function season(m, d)
{m:
    - 1: ~ return "Winter"
    - 2: ~ return "Winter"
    - 3: {
        - d < 20: ~ return "Winter"
        - d >= 20: ~ return "Spring"
    }
    - 4: ~ return "Spring"
    - 5: ~ return "Spring"
    - 6: {
        - d < 20: ~ return "Spring"
        - d >= 20: ~ return "Summer"
    }
    - 7: ~ return "Summer"
    - 8: ~ return "Summer"
    - 9: {
        - d < 22: ~ return "Summer"
        - d >= 22: ~ return "Fall"
    }
    - 10: ~ return "Fall"
    - 11: ~ return "Fall"
    - 12: {
        - d < 21: ~ return "Fall"
        - d >= 21: ~ return "Winter"
    }
}

VAR _day_name = ""
=== function ___update_day_name()
~ _day_name = name_day(year, month, day, weekday)

=== calendar
VAR year = 0
VAR month = 8
VAR day = 12
VAR weekday = 6
VAR time = 0
->DONE


= test_days
Calendar test:
- (loop)
~ next_day()
{year == 2: ->->}
{name_day(year, month, day, weekday)}
->loop

= run_day
->draw_up_to(4)->
{year:
    - 0: ->y0->
    - 1: ->y1->
    - else: ->END
}
/ EOD
+ [Move on.]
-
~ next_day()
->->

= y0
{month:
    - 8: -> y0m8
    - 9: -> y0m9
    - 10: -> y0m10
    - 11: -> y0m11
    - 12: -> y0m12
    - else: -> END
}

= y1
{month:
    - 1: -> y1m1
    - 2: -> y1m2
    - 3: -> y1m3
    - 4: -> y1m4
    - 5: -> END
    - 6: -> y1m6
    - 7: -> y1m7
    - 8: -> y1m8
    - 9: -> y1m9
    - 10: -> y1m10
    - 11: -> y1m11
    - 12: -> y1m12
    - else: -> END
}

= y0m8
{day:
    - 12: -> d0_08_12
    - 13: -> d0_08_13
    - 14: -> d0_08_14
    - 15: -> d0_08_15
    - 16: -> d0_08_16
    - 17: -> d0_08_17
}
-> default_day
= y0m9
{day:
    - 0: -> default_day
}
-> default_day
= y0m10
{day:
    - 0: -> default_day
}
-> default_day
= y0m11
{day:
    - 0: -> default_day
}
-> default_day
= y0m12
{day:
    - 0: -> default_day
}
-> default_day
= y1m1
{day:
    - 0: -> default_day
}
-> default_day
= y1m2
{day:
    - 0: -> default_day
}
-> default_day
= y1m3
{day:
    - 0: -> default_day
}
-> default_day
= y1m4
{day:
    - 0: -> default_day
}
-> default_day
= y1m5
{day:
    - 0: -> default_day
}
-> default_day
= y1m6
{day:
    - 0: -> default_day
}
-> default_day
= y1m7
{day:
    - 0: -> default_day
}
-> default_day
= y1m8
{day:
    - 0: -> default_day
}
-> default_day
= y1m9
{day:
    - 0: -> default_day
}
-> default_day
= y1m10
{day:
    - 0: -> default_day
}
-> default_day
= y1m11
{day:
    - 0: -> default_day
}
-> default_day
= y1m12
{day:
    - 0: -> default_day
}
-> default_day


































