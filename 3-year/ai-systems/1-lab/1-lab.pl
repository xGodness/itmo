/* 
Define hostile mobs.
Hostile mobs will always attack player.
*/
is_hostile(creeper).
is_hostile(drowned).
is_hostile(endermite).
is_hostile(guardian).
is_hostile(hoglin).
is_hostile(piglin).
is_hostile(pillager).
is_hostile(skeleton).
is_hostile(slime).
is_hostile(witch).
is_hostile(zombie).

/* 
Define neutral mobs.
Neutral mobs will attack player only if player attacks them first.
*/
is_neutral(bee).
is_neutral(enderman).
is_neutral(polar_bear).
is_neutral(spider).
is_neutral(wolf).

/* 
Define passive mobs.
Passive mobs will never attack player.
*/
is_passive(axolotl).
is_passive(cat).
is_passive(chicken).
is_passive(fish).
is_passive(fox).
is_passive(pig).
is_passive(sheep).
is_passive(squid).
is_passive(villager).

/* 
Define pairs of mobs X and Y where mob X will always attack mob Y.
*/
attacks(axolotl, guardian).
attacks(axolotl, squid).
attacks(axolotl, fish).
attacks(axolotl, drowned).
attacks(enderman, endermite).
attacks(fox, chicken).
attacks(piglin, hoglin).
attacks(pillager, villager).
attacks(polar_bear, fox).
attacks(wolf, sheep).
attacks(wolf, skeleton).

/* 
Define health points, damage per second and height (in blocks) for every mob.
*/
mob_hp_dps_height(bee, 10, 2, 0.6).
mob_hp_dps_height(cat, 10, 0, 0.7).
mob_hp_dps_height(chicken, 4, 0, 0.7).
mob_hp_dps_height(creeper, 20, 43, 1.7). 
mob_hp_dps_height(drowned, 20, 3, 1.95).
mob_hp_dps_height(enderman, 40, 7, 2.9).
mob_hp_dps_height(fish, 3, 0, 0.4).
mob_hp_dps_height(fox, 10, 0, 0.6).
mob_hp_dps_height(guardian, 30, 6, 0.85).
mob_hp_dps_height(hoglin, 40, 6, 1.4).
mob_hp_dps_height(pig, 10, 0, 0.9).
mob_hp_dps_height(pillager, 24, 4, 1.95).
mob_hp_dps_height(polar_bear, 30, 6, 1.4).
mob_hp_dps_height(sheep, 8, 0, 1.3).
mob_hp_dps_height(skeleton, 20, 4, 1.99).
mob_hp_dps_height(slime, 16, 4, 2.04).
mob_hp_dps_height(spider, 16, 2, 0.5).
mob_hp_dps_height(squid, 10, 0, 0.8).
mob_hp_dps_height(villager, 20, 0, 1.95).
mob_hp_dps_height(witch, 26, 6, 1.95).
mob_hp_dps_height(wolf, 8, 4, 0.85).
mob_hp_dps_height(zombie, 20, 3, 1.95).

/* 
Define all types of possible armour sets.
*/
is_armour(none_arm).
is_armour(leather_arm).
is_armour(golden_arm).
is_armour(chainmail_arm).
is_armour(iron_arm).
is_armour(diamond_arm).
is_armour(netherite_arm).

/* 
Define defense points and toughness value for every set of armour.
*/
armour_def_toughness(none_arm, 0, 0).
armour_def_toughness(leather_arm, 7, 0).
armour_def_toughness(golden_arm, 11, 0).
armour_def_toughness(chainmail_arm, 12, 0).
armour_def_toughness(iron_arm, 15, 0).
armour_def_toughness(diamond_arm, 20, 8).
armour_def_toughness(netherite_arm, 20, 12).

/* 
Define all types of possible swords.
*/
is_weapon(none_wpn).
is_weapon(wooden_sword).
is_weapon(golden_sword).
is_weapon(stone_sword).
is_weapon(diamond_sword).
is_weapon(netherite_sword).

/* 
Define damage per second for every sword.
*/
weapon_dps(none_wpn, 1).
weapon_dps(wooden_sword, 6.4).
weapon_dps(golden_sword, 6.4).
weapon_dps(stone_sword, 8).
weapon_dps(diamond_sword, 9.6).
weapon_dps(netherite_sword, 11.2).

/* 
Rule that unites every defined set of mobs in general set of mobs.
*/
is_mob(Mob) :- 
	is_hostile(Mob) ; is_neutral(Mob) ; is_passive(Mob).

/* 
Rule that checks whether 'Mob' height is less than 'Height'.
*/
smaller_than(Mob, Height) :- 
	mob_hp_dps_height(Mob, _, _, Mob_height), Mob_height < Height.

/* 
Rule that checks whether 'Mob' is considered dangerous for the player.
*/
is_mob_dangerous(Mob) :-
	mob_hp_dps_height(Mob, Hp, Dps, _),
	Hp >= 20 , Dps >= 5.

/* 
Rule that checks whether player equipped with 'Armour' and 'Weapon' will be able to defeat 'Mob',
providing that they both deal 'Dps' amount of damage at the same time every second.
*/
player_kills(Mob, Armour, Weapon) :-
	armour_def_toughness(Armour, Def, Toughness),
	weapon_dps(Weapon, Player_dps),
	mob_hp_dps_height(Mob, Mob_hp, Mob_dps, _),

	Mob_ttl_dps = Mob_dps * (1 - (max(Def / 5, Def - (4 * Mob_dps) / (Toughness + 8)))) / 25,

	Mob_hp / Player_dps < 20 / (Mob_dps + 0.001).
