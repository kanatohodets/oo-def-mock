local class = require 'middleclass'
local inspect = require 'inspect'

local Registry = class('Registry')
local Def = require 'def'

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

function Registry:findUsers(baseClassName)
	local baseClass = self:get(baseClassName)
	if not baseClass then return nil end

	local ownKeys = baseClass:getOwnKeys()
	-- key = name of key, value = array of classes that source the value from this base class
	local users = {}
	for name, class in pairs(self.db) do
		if class ~= baseClass then
			for key, value in pairs(ownKeys) do
				print(key)
				if class.changelog[key] then
					if type(value) == 'table' then
						users[key] = self:findUsers(value.name)
					else
						local source = class:getKeySource(key)
						if source == baseClass then
							if not users[key] then
								users[key] = { 
									value = ownKeys[key],
									consumers = { class.name }
								}
							else
								table.insert(users[key].consumers, class.name)
							end
						end
					end
				end
			end
		end
	end
	return users
end

return Registry
