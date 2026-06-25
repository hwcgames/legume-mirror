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

=== function location_name(of)
~ return 0
{of:
    - "map": ~ return "A bird's-eye view."
    - "school_front": ~ return "Before a learned place."
    - "apartment": ~ return "Someplace yours."
}
~ return "A place outside place."

VAR _location_name = ""

=== function ___update_location_name()
~ _location_name = location_name(location)