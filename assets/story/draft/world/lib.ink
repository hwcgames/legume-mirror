INCLUDE world/neighborhood.ink
INCLUDE world/school.ink

VAR location = "uninit"

=== world_map
VAR map_accessible = true
~ location = "map"
/ world map

{map_accessible:
    <- northold
    <- eastward
    <- southill
    <- weston
}
+ [map back]
-
/ exit map
->->
= northold
+ {neighborhood_accessible} [map neighborhood]
    ->train_interstitial->
    ->->neighborhood
+ {school_accessible} [map school]
    ->train_interstitial->
    ->->school
->DONE
= eastward
->DONE
= southill
->DONE
= weston
->DONE

=== function location_name(of)
{of:
    - "map": ~ return "A bird's-eye view."
    - "school_front": ~ return "Before a learned place."
    - "apartment": ~ return "Someplace yours."

    // Interstitials
    - "railway": ~ return "A world-shrinking place."
    - "street": ~ return "A place afoot."

    // Dungeons
    - "dogdungeon": ~ return "tok!ma-nasa pi++soweli monsuta"
    - "schooldungeon": ~ return "tok!ma-nasa pi+tomo-sona"
    - "museumdungeon": ~ return "tok!ma-nasa pi++tenpo tawa"
    - "netdungeon": ~ return "tok!ma-nasa pi+toki-weka"
    - "simdungeon": ~ return "tok!ma-nasa pi+lon-ala"
    - "parkdungeon": ~ return "tok!ma-nasa kasi"
    - "librarydungeon": ~ return "tok!ma-nasa pi+tomo-sitelen"
    - "edisondungeon": ~ return "tok!ma-nasa pi+tomo-mani"
}
~ return "...Where are you?"

VAR _location_name = ""

=== function ___update_location_name()
~ _location_name = location_name(location)


=== location_setup
->setup_characters->
->quest.setup->
->->
=== location_choices(-> back)
<- character_choices(back)
<- quest.choices(back)
->DONE


=== train_interstitial
/ level railway tunnel
/ spawn cipher
/ spawn intro_train
/ intro_train capture
/ intro_train float
/ intro_train appear train_entry
/ intro_train follow path rails
/ cipher capture
/ cipher appear train_cipher_seat
/ cipher root train_cipher_seat
/ cipher pose sit
/ camera train_cipher_seat
/ fade in

{shuffle:
    - (Click-clack, click-clack...)
    - (The clamor of the other passengers has a curious timbre.)
    - (You drum on your leg with your fingers.)
    - (You close your eyes and listen to the noises of the subway.)
}

/ fade black
->->