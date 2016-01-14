Def('HE'):Extends('Weapon'):Attrs{
	name = 'HE',
	explosive = "yes",
	areaofeffect = 40
}

Def('Cannon'):Extends('Weapon'):Attrs{
	name = "Cannon",
	range = 400,
	damage = {
		default = "lots",
		properties = {
			paralyze = 9999,
		},
		blorg = "LOSE"
	},

	edgeEffectiveness = 0.2
}

Def('HE Cannon'):Extends('HE'):Extends('Cannon'):Attrs{
	super_effective = true,
	damage = {
		grass = 999999,
	},
	customparams = {
		causes_screen_to_shake = true
	}
}

