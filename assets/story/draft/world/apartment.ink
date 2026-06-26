=== apartment
VAR apartment_accessible = true
/ cut black
/ level millys room cipher_apartment
/ cipher spawn spawnpoint
/ cipher capture
/ cipher walk inside #b:enter #!b:main
/ cipher release #!W:main #W:enter
~ location = "apartment"
/ fade in

- (roam)

+ [leave]
    / cipher capture
    / cipher walk spawnpoint #!b:main
    / fade black
    ->world_map->
    / cipher capture
    / cipher walk inside #b:enter #!b:main
    / cipher release #!W:main #W:enter
    / fade in
- ->roam