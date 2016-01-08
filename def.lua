local class = require 'middleclass'
local inspect = require 'inspect'

local Def = class('Def')

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

function Def:prettyPrint(indentLevel)
	indentLevel = indentLevel or 0
	local name = self.name
	local values = self:getTraced()
	local indent = string.rep("  ", indentLevel)
	local string = "" --indent .. "'" .. self.name .. "' = { \n"
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
			overwriteDesc = overwriteDesc .. overwriter
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

function Def:getOverwrites(key)
	local trace = self.trace[key]
	local overwrites = {}
	for i, source in ipairs(trace.source) do
		if source == self then
			table.insert(overwrites, 'self')
		else
			table.insert(overwrites, source.name)
		end
	end
	return overwrites
end

function Def:getSource(key)
	local trace = self.trace[key]
	local last = trace.source[#trace.source]
	if last == self then
		return self
	else
		return last:getSource(key)
	end
end

function Def:getTraced()
	local traced = {}
	for key, trace in pairs(self.trace) do
		traced[key] = { value = trace.value, source = self:getSource(key).name, overwrites = self:getOverwrites(key) }
	end
	return traced
end

function Def:initialize(registry, name)
	self.registry = registry
	self.name = name
	self.composed = {}
	self.trace = {}
end

function Def:Render()
	for key, trace in pairs(self.trace) do

	end
end

function Def:add(key, value, source)
	if type(value) == 'table' then
		local subname = self.name .. ' ' .. key
		if self.trace[key] == nil then
			self.trace[key] = {
				value = self.registry:register(subname),
				source = { source }
			}
			print("made a new subtable class for ", key, subname)
			--print(self.subtableClasses[key])
		end

		local subtable = self.trace[key].value
		-- TODO: should this be Attrs? that is, should the subtable know that
		-- it comes from? where do subtables come from?
		-- overwrite with the fleshed object attrs
		if self == source then
			value = subtable:Attrs(value)
		else
			value = subtable:Extends(value.name)
		end
	end

	if self.trace[key] == nil then
		self.trace[key] = {
			value = value,
			source = { source },
		}
	else
		-- WARNING, overwriting!
		local existingSource = self.trace[key].source[1]
		self.trace[key].value = value
		table.insert(self.trace[key].source, source)
	end
end

-- deliberately only single inheritance. fail if there's been any mixing.
function Def:Extends (parentName)
	print(self.name .. " is extending: " .. parentName)
	--[[
	if #self.mixins > 0 then
		print("error! a class cannot inherit if it has mixed in other classes")
		return nil
	end
	]]--

	local parent = self.registry:get(parentName)
	if not parent then
		print("error! " .. parentName .. " has not yet been defined!")
		return
	end

	for key, trace in pairs(parent.trace) do
		if trace.value then
			self:add(key, trace.value, parent)
		end
	end

	--self.parent = parent

	return self
end

function Def:Attrs (attrs)
	--print(self.name .. " is implementing stuff:\n")
	--printTable(attrs)
	for key, value in pairs(attrs) do
		--print("\t" .. key .. ": ", value, "\n")
		self:add(key, value, self)
	end
	return self
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

return Def
