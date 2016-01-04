require '../oo'

local Weapon = DefGroup('weapons')

Weapon('Weapon'):Extends('Def'):Attrs{ 
	customparams = {
		onlytargetcategory = "FOO BAR BAZ"
	}
}

Weapon('HE'):Extends('Weapon'):Attrs{ 
	areaofeffect = 40
}

Weapon('Cannon'):Extends('Weapon'):Attrs{ 
	name = "Cannon",
	range = 400,
	edgeEffectiveness = 0.2
}

--[[
Weapon('HE Cannon'):Mixes('HE', 'Cannon'):Attrs{
	name = "HE cannon"
}
]]

print("--------------------")
print("Cannon:")
GetClass('Cannon'):printTrace()
