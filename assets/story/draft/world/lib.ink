INCLUDE world/apartment.ink
INCLUDE world/school.ink

VAR location = "uninit"

=== world_map
VAR map_accessible = true
~ location = "map"
>>> world map

{map_accessible:
    <- northold
    <- eastward
    <- southill
    <- weston
}
+ [map back]
-
>>> exit map
->->
= northold
+ {apartment_accessible} [map apartment]
    ->->apartment
+ {school_accessible} [map school]
    ->->school
->DONE
= eastward
->DONE
= southill
->DONE
= weston
->DONE

=== function ___location_name()
{location:
    - "map": ~ return "A bird's-eye view."
    - "school_front": ~ return "Before a learned place."
    - "apartment": ~ return "Someplace yours."
    - else: ~ return "A place outside place."
}