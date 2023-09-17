is_mob(X).

smaller_than(X, 1).

is_hostile(X) , mob_hp_dps_height(X, Hp, Dps, _) , Hp =< 25 , Dps =< 5.

is_mob_dangerous(X) , mob_hp_dps_height(X, _, _, Height) , Height >= 1.4 , player_kills(X, leather_arm, Wpn).

is_armour(Arm) , armour_def_toughness(Arm, Def, _) , Def < 15 , Def > 9 , (is_hostile(Mob) ; is_neutral(Mob)) , player_kills(Mob, Arm, stone_sword).
