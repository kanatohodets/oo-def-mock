
-- Our shared funcs
function printTable (input, indentLevel)
	local ordered = {}
    indentLevel = indentLevel or 0
	for k,v in pairs (input) do table.insert(ordered, { k, v }) end
	table.sort(ordered, function (a, b) 
		return a[1] < b[1]
	end)

	for i, tuple in ipairs(ordered) do
		local k, v = tuple[1], tuple[2]
		local indent = string.rep("\t", indentLevel)
		if type(v) == "table" then
			print(indent .. k .. ": ")
			printTable(v, indentLevel + 1)
		else
			print(indent .. k, v)
		end
	end
end

local function merge (child, parent)
    for k,v in pairs(parent) do
        if type(k) == "string" and type(v) ~= "function" then
            k = k:lower()
        end
        if type(v) == "table" then
            if child[k] == nil then child[k] = {} end
            merge(child[k], v)
        else
			if child[k] == nil then child[k] = v end
        end
    end
end

local Def = {
	category = 'root',
	name = 'Def',
	composed = {},
	trace = {},
	parent = nil,
	mixins = {},
}

local registry = {
	Def = Def
}

function Def:new(category, name)
	local o = {
		category = category,
		name = name,
		-- rendered def
		composed = {},
		-- record of where keys came from
		trace = {},
		-- inheritance 
		parent = nil,
		mixins = {},
	}
	setmetatable(o, self)
	self.__index = self
	return o 
end

function Def:add(key, value, source)
	-- attributes from oneself are top priority
	if self == source or self.trace[key] == nil then
		self.trace[key] = {
			value = value,
			source = { source },
		}
		self.composed[key] = value
	else
		local existingSource = self.trace[key].source[1]
		print ("WHAT SOURCE\n")
		print(existingSource.name)
		print("'" .. source.name .. "' can't add key '" .. key .. "' to '" .. self.name .. "' because it has already been implemented by '" .. existingSource.name .. "'\n")
	end
end

function Def:printTrace()
	local ordered = {}
	for k,v in pairs (self.trace) do table.insert(ordered, { k, v }) end
	table.sort(ordered, function (a, b) 
		return a[1] < b[1]
	end)

	for i, tuple in ipairs(ordered) do
		local key, traceData = tuple[1], tuple[2]
		print(key .. " is ", traceData.value, " from " .. traceData.source[1].name)
	end
end

-- deliberately only single inheritance. fail if there's been any mixing.
function Def:Extends (parentName)
	print(self.name .. " is extending: " .. parentName)
	if #self.mixins > 0 then
		print("error! a class cannot inherit if it has mixed in other classes")
		return nil
	end

	local parent = registry[parentName]
	if not parent then
		print("error! " .. parentName .. " has not yet been defined!")
		return
	end

	for key, trace in pairs(parent.trace) do
		if trace.value then
			self:add(key, trace.value, parent)
		end
	end

	self.parent = parent

	--self:inherit(parentClass)
	return self
end

function Def:mix (className)

end

-- you can mix multiple things, but only if they don't conflict
function Def:Mixes (...)
	local mixins = {...}
	local collisions = {}
	for i, className in ipairs(mixins) do
		local class = registry[className]
		if not class then
			print("error: " .. className .. " is not defined, cannot mix in\n")
			return nil
		end

		for key, value in pairs(class.composed) do
			if not collisions[key] then
				collisions[key] = { }
			end
			table.insert(collisions[key], className)
		end
	end

	for key, colliders in pairs(collisions) do
		if #colliders > 1 then
			local list = table.concat(colliders, ', ')
			print("'" .. key .. "' cannot be mixed into '" .. self.name .. "' because it is provided by multiple classes: " .. list)
			return self
		end
	end

	for i, className in ipairs(mixins) do
		local class = registry[className]
		print("mixing in " .. className)
		for key, value in pairs(class.composed) do
			if trace.value then
				self:add(key, trace.value, class)
			end
		end
	end

	return self
end

function Def:Attrs (attrs)
	--print(self.name .. " is implementing stuff:\n")
	printTable(attrs)
	for key, value in pairs(attrs) do
		--print("\t" .. key .. ": ", value, "\n")
		self:add(key, value, self)
	end
	return self
end

function Def:Render ()
	return self.composed
end

--[[
local Weapon = Def:New{
	customparams = {
		onlytargetcategory = "FOO BAR BAZ"
	}
}

local HE = Weapon:New{
	areaofeffect = 40
}

]]--
--local HowitzerHE = class('HowitzerHE'):Base('HE'):New{ 

function DefGroup(category) 
	-- constructor for a new class
	return function (name) 
		local newClass = Def:new(category, name)

		if registry[name] then
			print("error! " .. name .. " is already a registered class in category " .. registry[name].category .. "!\n")
			return nil
		else
			local newClass = Def:new(category, name)
			registry[name] = newClass
			return newClass
		end
	end
end

function GetClass(name)
	return registry[name]
end
