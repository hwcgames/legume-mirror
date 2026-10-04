=== ponder(->back)
<-ponder.general(back)
+ {LIST_COUNT(inventory) > 0} [(Try an item.)]
    ->ponder.item(back)
->DONE

= general(->back)

+ {false} ->
- -> back

= item(->back)

+ {inventory has journal} [Journal.]
    (You jot something down in your journal.)
    (TODO)
+ {inventory has cell_phone} [Phone.]
    (You get your phone out.)
    {in_subspace: (...But there's no signal.) ->back}
    (TODO)
- ->back