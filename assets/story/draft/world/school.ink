=== school
VAR school_accessible = true
- (front)
/ cut black
/ level school room front
->setup_characters->
->setup_quests->
/ cipher spawn street_spawnpoint
/ cipher capture
/ cipher walk street_inside #b:enter #!b:main
/ cipher release #!W:main #W:enter


~ location = "school_front"
- (front_roam)
<- character_choices(->front_roam)
<- quest_choices(->front_roam)
+ [leave]
    / cipher capture
    / cipher walk spawnpoint #!b:main
    / fade black
    ->world_map->
    / cipher capture
    / cipher walk inside #b:enter #!b:main
    / cipher release #!W:main #W:enter
    / fade in
    -> front_roam