local oo = {}
local lfs = require 'lfs'

local function trace (def)
    local name = def.name
    local res = {}

    local ordered = {}
    for key, log in pairs(def.changelog) do
        table.insert(ordered, { key, log })
    end

    table.sort(ordered, function (a, b)
        return a[1] < b[1]
    end)

    for i, ordered in ipairs(ordered) do
        local key, log = ordered[1], ordered[2]
        local value = log.value

        if type(value) == 'table' then
            res[key] = trace(value)
        else
            local overwrites = def:getOverwrites(key)
			local overwriteNames = {}
			for i, overwriter in ipairs(overwrites) do
				table.insert(overwriteNames, overwriter.name)
			end
			res[key] = {
				value = value,
				source = overwriteNames
			}
        end
    end

    return res
end

local Registry = require 'registry'
local registry = Registry:new()

function Def (name)
	return registry:register(name)
end

function AbstractDef (name)
	return registry:registerAbstract(name)
end

--hack
dofile('defs/Base.lua')
local function crawlDir(dir)
	for filename in lfs.dir(dir) do
		if string.match(filename, ".lua$") then
			if filename ~= 'Base.lua' then
				dofile(dir .. "/" .. filename)
			end
		end
	end
end

local function users(defName)
	return registry:findUsers(defName)
end

local function traceClass(defName)
	local def = registry:get(defName)
	if def == nil then return nil end

	return trace(def)
end

local function unused()
	return registry:detectUnusedAbstractClasses()
end

oo.users = users
oo.trace = traceClass
oo.crawlDir = crawlDir
oo.registry = registry
oo.unused = unused
oo.render = function (name) 
	local def = registry:get(name)
	if def then
		return def:Render()
	end
end

return oo
