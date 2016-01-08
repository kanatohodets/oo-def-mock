local class = require 'middleclass'
local inspect = require 'inspect'

local Registry = class('Registry')
local Def = require 'def'

function Registry:__tostring()
	local ordered = {}
	for name, object in pairs(self.db) do
		table.insert(ordered, { name, object })
	end
	table.sort(ordered, function (a, b) 
		return a[1] < b[1]
	end)
	local string = ""
	for i, obj in ipairs(ordered) do
		string = string .. "\n" .. tostring(obj[2])
	end
	return string
end

function Registry:initialize()
	self.db = {
		Def = Def:new(self, 'Generic', 'Def')
	}
end

function Registry:register(name)
	if self.db[name] then
		print("error! " .. name .. " is already a registered class: " .. inspect(self.db[name]) .. "!\n")
		return nil
	else
		local newClass = Def:new(self, name)
		self.db[name] = newClass
		return newClass
	end
end

function Registry:get(name)
	return self.db[name]
end

return Registry
