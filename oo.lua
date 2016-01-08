local class = require 'middleclass'
local inspect = require 'inspect'

local Def = require 'def'
local Registry = require 'registry'

local registry = Registry:new()

function Weapon (name)
	return registry:register(name)
end

print(registry.db)
Weapon('Weapon'):Extends('Def'):Attrs{
	color = "red",
	customparams = {
		onlytargetcategory = "FOO BAR BAZ"
	},
	damage = {
		properties = {
			intimidate = "very sparkle"
		}
	}
}

Weapon('HE'):Extends('Weapon'):Attrs{
	name = 'HE',
	explosive = "yes",
	areaofeffect = 40
}

Weapon('Cannon'):Extends('Weapon'):Attrs{
	name = "Cannon",
	range = 400,
	damage = {
		default = "lots",
		properties = {
			paralyze = 9999,
		}
	},

	edgeEffectiveness = 0.2
}

Weapon('HE Cannon'):Extends('HE'):Extends('Cannon'):Attrs{
	super_effective = true,
	damage = {
		grass = 999999,
	},
	customparams = {
		causes_screen_to_shake = true
	}
}

print("--------------------")
print("'HE Cannon' = {")
print(registry:get('HE Cannon'):prettyPrint())

--local HowitzerHE = class('HowitzerHE'):Base('HE'):New{

