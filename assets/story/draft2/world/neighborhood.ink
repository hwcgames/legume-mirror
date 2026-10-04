=== neighborhood
VAR neighborhood_accessible = true
->outside
= outside
/ cut black
/ level neighborhood outside
~ temp old_loc = location
~ location = "neighborhood_outside"
->location_setup->
/ spawn cipher
/ cipher capture
/ fade in #!b:main
{old_loc:
    - "neighborhood_apartment":
        / cipher appear apartment_spawnpoint
        / cipher walk apartment_door
    - else:
        / cipher appear street_spawnpoint
        / cipher walk street_door
}
/ cipher release
- (roam)
<- location_choices(->roam)

+ [leave]
    / cipher capture
    / cipher walk street_spawnpoint #!b:main
    / fade black
    ->world_map->
    / cipher capture
    / cipher walk inside #b:enter #!b:main
    / cipher release #!W:main #W:enter
    / fade in
+ [apartment]
    / cipher capture
    / cipher walk apartment_spawnpoint #!b:main
    / fade black
    ->apartment
- -> roam


= apartment
/ cut black
/ level millys cipher_apartment
~ location = "neighborhood_apartment"
->location_setup->
/ cipher spawn spawnpoint
/ cipher capture
/ cipher walk inside #b:enter #!b:main
/ cipher release #!W:main #W:enter
/ fade in

- (roam)
<- location_choices(->roam)

+ [leave]
    / cipher capture
    / cipher walk spawnpoint #!b:main
    / fade black
    ->outside
+ [waste time]
    / cipher capture
    (You can spend time by doing nothing in your room. It has no benefits.)
    / choice (Waste time?)
    + + [Yes]
        / fade black
        {stopping:
            - (You let your mind wander, pointlessly.)
            - (You spend time scrolling through cat videos on the worldnet.)
                (...You feel hollow.)
            - (You stand in place for several hours.)
        }
        ->->
    + + [No]
        {once: (...A wise choice.)}
        / cipher release
- ->roam

= park
/ cut black
/ level neighborhood park
~ location = "neighborhood_park"
->location_setup->
/ cipher spawn spawnpoint
/ cipher capture
/ cipher walk inside #b:enter #!b:main
/ cipher release #!W:main #W:enter
/ fade in

- (roam)
<- location_choices(->roam)

+ [leave]
    / cipher capture
    / cipher walk spawnpoint #!b:main
    / fade black
    ->outside
- ->roam

= convenience_store
/ cut black
/ level neighborhood convenience_store
~ location = "neighborhood_convenience_store"
->location_setup->
/ cipher spawn spawnpoint
/ cipher capture
/ cipher walk inside #b:enter #!b:main
/ cipher release #!W:main #W:enter
/ fade in

- (roam)
<- location_choices(->roam)

+ [leave]
    / cipher capture
    / cipher walk spawnpoint #!b:main
    / fade black
    ->outside
+ [shopkeeper]
    / cipher capture
    / cipher snap counter
    (TODO)
    - -
    / cipher release
- ->roam

= library
/ cut black
/ level neighborhood library
~ location = "neighborhood_library"
->location_setup->
/ cipher spawn spawnpoint
/ cipher capture
/ cipher walk inside #b:enter #!b:main
/ cipher release #!W:main #W:enter
/ fade in

- (roam)
<- location_choices(->roam)

+ [leave]
    / cipher capture
    / cipher walk spawnpoint #!b:main
    / fade black
    ->outside
+ [librarian]
    / cipher capture
    / cipher snap counter
    (TODO)
    - -
    / cipher release
- ->roam















