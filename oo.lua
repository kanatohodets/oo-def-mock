local class = require 'middleclass'
local inspect = require 'inspect'

local Registry = require 'registry'
local registry = Registry:new()

--TODO abstract classes
--TODO check if a class is used at all by impls
--TODO: get rid of def references to registry to kill cyclic refs

function Def (name)
	return registry:register(name)
end

Def('Weapon'):Extends('Def'):Attrs{
	color = "red",
	customparams = {
		onlytargetcategory = "FOO BAR BAZ"
	},
	damage = {
		properties = {
			intimidate = "very sparkle"
		},
		blorg = "FTW"
	}
}

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

print("--------------------")
--print("'HE Cannon' = {")
local Weapon = registry:get('Weapon')
local HECannon = registry:get('HE Cannon')
local HE = registry:get('HE')
local Cannon = registry:get('Cannon')
--print(inspect(HE))
--print(inspect(HECannon:Render()))
--print(HECannon:prettyPrint())
--print('users of values from class "HE":')
--print(inspect(Weapon:getOwnKeys()))
local users = registry:findUsers('Weapon')
print(inspect(users))
--print(inspect(Cannon:getOwnKeys()))
--
--print(HECannon:prettyPrint())

--local HowitzerHE = class('HowitzerHE'):Base('HE'):New{

