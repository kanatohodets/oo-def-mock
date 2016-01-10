local class = require 'middleclass'
local inspect = require 'inspect'

local Def = class('Def')

function Def:initialize(registry, name)
	self.registry = function ()
		return registry
	end
	self.name = name
	self.changelog = {}
end

function Def:prettyPrint(indentLevel)
	indentLevel = indentLevel or 0
	local name = self.name
	local values = self:getKeyTrace()
	local indent = string.rep("  ", indentLevel)
	local string = ""
	if indentLevel == 0 then
		string = string .. indent .. "'" .. self.name .. "' = { \n"
	end
	local ordered = {}

	for key, trace in pairs(values) do
		table.insert(ordered, { key, trace })
	end

	table.sort(ordered, function (a, b)
		return a[1] < b[1]
	end)

	for i, ordered in ipairs(ordered) do
		local key, trace = ordered[1], ordered[2]
		local value = trace.value
		local source = trace.source
		local overwrites = trace.overwrites
		local overwriteDesc = ""

		for i, overwriter in ipairs(overwrites) do
			overwriteDesc = overwriteDesc .. overwriter.name
			if i < #overwrites then
				overwriteDesc = overwriteDesc .. " -> "
			end
		end
		if type(value) == 'table' then
			local newIndent = string.rep("  ", indentLevel + 1)
			string = string .. newIndent .. "'" .. key .. "' = {\n" .. value:prettyPrint(indentLevel + 1)
		else
			string = string .. indent .. "  " .. key .. " = '" .. tostring(value) .. "' -- " .. overwriteDesc .. " \n"
		end
	end
	return string .. indent .. "}\n"
end

-- this could be performed during :add, but it seemed best to keep it off the
-- direct path (since :add gets called quite a lot, and on every game load)
function Def:_getOverwrites(key)
	local log = self.changelog[key]
	local overwrites = {}
	for i, source in ipairs(log.source) do
		local originalSource = source:getKeySource(key)
		-- collapse diamond to single source, e.g. when A -> B, C -> D.
		-- D should show the value as coming from A just once, rather than
		-- from A followed by A.
		local prev = overwrites[#overwrites]
		if originalSource ~= prev then
			table.insert(overwrites, originalSource)
		end
	end
	return overwrites
end

function Def:getKeySource(key)
	local log = self.changelog[key]
	local last = log.source[#log.source]
	if last == self then
		return self
	else
		return last:getKeySource(key)
	end
end

--TODO: how to handle this with subtables?
--I guess find the subtable keys sourced from name .. subtable name
--ditto getKeyTrace
function Def:getOwnKeys()
	local ownKeys = {}
	local trace = self:getKeyTrace()
	for key, trace in pairs(trace) do
		if trace.source == self then
			ownKeys[key] = trace.value
		end

		-- TODO: awful hack. gereralize the tree walking, because implementing
		-- it distinctly for each method makes it impossible for them to
		-- interoperate sanely
		if trace.value == nil then
			local subtable = self:registry():get(self.name .. ' ' .. key)
			ownKeys[key] = subtable:getOwnKeys()
		end
	end
	return ownKeys
end

function Def:getKeyTrace()
	local traced = {}
	for key, log in pairs(self.changelog) do
		if type(log.value) == 'table' then
			traced[key] = log.value:getKeyTrace()
		else
			traced[key] = {
				value = log.value,
				source = self:getKeySource(key),
				overwrites = self:_getOverwrites(key)
			}
		end
	end
	return traced
end

function Def:Render()
	local result = {}
	for key, log in pairs(self.changelog) do
		local value = log.value
		if type(value) == 'table' then
			result[key] = value:Render()
		else
			result[key] = value
		end
	end
	return result
end

function Def:add(key, value, source)
	if type(value) == 'table' then
		local subname = self.name .. ' ' .. key

		local existing = (self.changelog[key] or {}).value
		local subtable = existing or self.registry():register(subname)

		if self == source then
			value = subtable:Attrs(value)
		else
			value = subtable:Extends(value.name)
		end
	end

	if self.changelog[key] == nil then
		self.changelog[key] = {
			value = value,
			source = { source },
		}
	else
		-- WARNING, overwriting!
		local existingSource = self.changelog[key].source[1]
		self.changelog[key].value = value
		table.insert(self.changelog[key].source, source)
	end
end

-- deliberately only single inheritance. fail if there's been any mixing.
function Def:Extends (parentName)
	local parent = self.registry():get(parentName)
	if not parent then
		print("error! " .. parentName .. " has not yet been defined!")
		return
	end

	for key, log in pairs(parent.changelog) do
		self:add(key, log.value, parent)
	end

	return self
end

function Def:Attrs (attrs)
	for key, value in pairs(attrs) do
		self:add(key, value, self)
	end
	return self
end

return Def
