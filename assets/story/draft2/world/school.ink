=== school
VAR school_accessible = true
->front

= front
/ cut black
/ level school front
~ temp old_loc = location
~ location = "school_front"
->location_setup->
/ cipher capture
/ fade in #!b:main
{old_loc:
    - "school_hallway":
        / cipher spawn school_spawnpoint
        / cipher walk school_door
    - else:
        / cipher spawn street_spawnpoint
        / cipher walk street_inside
}
/ cipher release


- (front_roam)
<- location_choices(->front_roam)
+ [leave]
    / cipher capture
    / cipher walk street_spawnpoint #!b:main
    / fade black
    ->world_map->
    / cipher capture
    / cipher walk inside #b:enter #!b:main
    / cipher release #!W:main #W:enter
    / fade in
    -> front_roam
+ [to hallway]
    / cipher capture
    / cipher walk school_spawnpoint #!b:main
    / fade black
    ->hallway

= classroom
/ cut black
/ level school classroom
~ temp old_loc = location
~ location = "school_classroom"
->location_setup->
/ spawn cipher
/ cipher capture
/ fade in #!b:main
{old_loc:
    - "school_hallway":
        / cipher appear hallway_spawnpoint
        / cipher walk hallway_door
    - else:
        / cipher appear cipher_seat
        / cipher walk by_cipher_seat
}
/ cipher release

- (school_roam)
<- location_choices(->school_roam)
+ [to hallway]
    / cipher capture
    / cipher walk hallway_spawnpoint #!b:main
    / fade black
    ->hallway

= hallway
/ cut black
/ level school hallway
~ temp old_loc = location
~ location = "school_hallway"
->location_setup->
/ spawn cipher
/ fade in #!b:main
/ cipher capture
{old_loc:
    - "school_classroom":
        / cipher appear classroom_spawnpoint
        / cipher walk classroom_door
    - "school_front":
        / cipher appear front_spawnpoint
        / cipher walk front_door
}
/ cipher release

- (hallway_roam)
<- location_choices(->hallway_roam)
+ [to classroom]
    / cipher capture
    / cipher walk classroom_spawnpoint #!b:main
    / fade black
    ->classroom
+ [to front]
    / cipher capture
    / cipher walk front_spawnpoint #!b:main
    / fade black
    ->front










