LIST cards = Fool, Magician, HighPriestess, Empress, Emperor, Hierophant, Lovers, Chariot, Strength, Hermit, WheelOfFortune, Justice, HangedMan, Death, Temperance,  Devil, Tower, Star, Moon, Sun, Judgement, World
VAR reversed = ()

=== function give_random_card()

{cards != LIST_ALL(cards):
    -
        ~ temp card = LIST_RANDOM(LIST_INVERT(cards))
        ~ cards += card
        {RANDOM(0, 1) == 0:
            ~ reversed += card
        - else:
            ~ reversed -= card
        }
}

=== function take_card(card)
{card ? cards:
    - true:
        ~ cards -= card
        ~ reversed -= card
        ~ return true
    - false:
        ~ return false
}

=== function list_cards(list, r, if_empty)
~ temp card = LIST_RANDOM(list)
~ temp is_r = r ? card
{LIST_COUNT(list):
- 2:
    	{name_card(card, is_r)}, and {list_cards(list - card, r, if_empty)}
- 1:
    	{name_card(card, is_r)}
- 0:
		{if_empty}
- else:
  		{name_card(card, is_r)}, {list_cards(list - card, r, if_empty)}
}

=== function name_card(card, r)
{card:
    - Fool: ~ return "The Fool" + name_reversed(r)
    - Magician: ~ return "The Magician" + name_reversed(r)
    - HighPriestess: ~ return "The High Priestess" + name_reversed(r)
    - Empress: ~ return "The Empress" + name_reversed(r)
    - Emperor: ~ return "The Emperor" + name_reversed(r)
    - Hierophant: ~ return "The Hierophant" + name_reversed(r)
    - Lovers: ~ return "The Lovers" + name_reversed(r)
    - Chariot: ~ return "The Chariot" + name_reversed(r)
    - Strength: ~ return "Strength" + name_reversed(r)
    - Hermit: ~ return "The Hermit" + name_reversed(r)
    - WheelOfFortune: ~ return "The Wheel of Fortune" + name_reversed(r)
    - Justice: ~ return "Justice" + name_reversed(r)
    - HangedMan: ~ return "The Hanged Man" + name_reversed(r)
    - Death: ~ return "Death" + name_reversed(r)
    - Temperance: ~ return "Temperance" + name_reversed(r)
    - Devil: ~ return "The Devil" + name_reversed(r)
    - Tower: ~ return "The Tower" + name_reversed(r)
    - Star: ~ return "The Star" + name_reversed(r)
    - Moon: ~ return "The Moon" + name_reversed(r)
    - Sun: ~ return "The Sun" + name_reversed(r)
    - Judgement: ~ return "Judgement" + name_reversed(r)
    - World: ~ return "The World" + name_reversed(r)
}

=== function name_reversed(r)
{
    - r: ~ return " reversed"
    - else: ~ return ""
}

=== function explain_card(card, rev)
~ temp r = !rev

{card:
    - Fool: {r:
        ~ return "innocence, new beginnings, free spirit"
    - else:
        ~ return "recklessness, exploitation, inconsideration"
    }
    - Magician: {r:
        ~ return "willpower, desire, creation, manifestation"
    - else:
        ~ return "trickery, illusions, loss of touch"
    }
    - HighPriestess: {r:
        ~ return "intuition, unconscious, inner voice"
    - else:
        ~ return "lack of center, lost inner voice, repressed feelings"
    }
    - Empress: {r:
        ~ return "motherhood, fertility, nature"
    - else:
        ~ return "dependence, smothering, emptiness, nosiness"
    }
    - Emperor: {r:
        ~ return "authority, structure, control, fatherhood"
    - else:
        ~ return "tyranny, rigidity, coldness"
    }
    - Hierophant: {r:
        ~ return "tradition, conformity, morality, ethics"
    - else:
        ~ return "rebellion, subversiveness, new approaches"
    }
    - Lovers: {r:
        ~ return "partnerships, duality, union"
    - else:
        ~ return "loss of balance, one-sidedness, disharmony"
    }
    - Chariot: {r:
        ~ return "direction, control, willpower"
    - else:
        ~ return "lack of control, lack of direction, aggression"
    }
    - Strength: {r:
        ~ return "inner strength, bravery, compassion, focus"
    - else:
        ~ return "self doubt, weakness, insecurity"
    }
    - Hermit: {r:
        ~ return "contemplation, search for truth, inner guidance"
    - else:
        ~ return "loneliness, isolation, lost your way"
    }
    - WheelOfFortune: {r:
        ~ return "change, cycles, inevitable fate"
    - else:
        ~ return "no control, clinging to control, bad luck"
    }
    - Justice: {r:
        ~ return "cause and effect, clarity, truth"
    - else:
        ~ return "dishonesty, unaccountability, unfairness"
    }
    - HangedMan: {r:
        ~ return "sacrifice, release, martyrdom"
    - else:
        ~ return "stalling, needless sacrifice, fear of sacrifice"
    }
    - Death: {r:
        ~ return "end of cycle, beginnings, change, metamorphosis"
    - else:
        ~ return "fear of change, holding on, stagnation, decay"
    }
    - Temperance: {r:
        ~ return "middle path, patience, finding meaning"
    - else:
        ~ return "extremes, excess, lack of balance"
    }
    - Devil: {r:
        ~ return "addiction, materialism, playfulness"
    - else:
        ~ return "freedom, release, restoring control"
    }
    - Tower: {r:
        ~ return "sudden upheaval, broken pride, disaster"
    - else:
        ~ return "disaster avoided, delayed disaster, fear of suffering"
    }
    - Star: {r:
        ~ return "hope, faith, rejuvenation"
    - else:
        ~ return "faithlessness, discouragement, insecurity"
    }
    - Moon: {r:
        ~ return "unconscious, illusions, intuition"
    - else:
        ~ return "confusion, fear, misinterpretation"
    }
    - Sun: {r:
        ~ return "joy, success, celebration, positivity"
    - else:
        ~ return "negativity, depression, sadness"
    }
    - Judgement: {r:
        ~ return "reflection, reckoning, awakening"
    - else:
        ~ return "lack of self awareness, doubt, self loathing"
    }
    - World: {r:
        ~ return "fulfillment, harmony, completion"
    - else:
        ~ return "incompletion, no closure"
    }
}

=== draw_up_to(amt)
~ give_random_card()
{LIST_COUNT(cards) < amt:
    ->draw_up_to(amt)
}
->->

=== card_hint
{cards == ():
    ->->
}
~ temp card = LIST_RANDOM(cards)
~ temp r = reversed ? card
{name_card(card, r)}: {explain_card(card, r)}.
->->

=== explain_all_cards(list)
{list == ():
    ->->
}
~ temp card = LIST_RANDOM(list)
~ temp r = reversed ? card
~ temp rest = list - card
{name_card(card, r)}: {explain_card(card, r)}.
->explain_all_cards(rest)














