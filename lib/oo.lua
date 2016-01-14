local oo = {}
local lfs = require 'lfs'

local function prettyPrint (def, indentLevel)
    indentLevel = indentLevel or 0
    local name = def.name
    local indent = string.rep("  ", indentLevel)
    local string = ""

    if indentLevel == 0 then
        string = string .. indent .. "'" .. def.name .. "' = { \n"
    end

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
            local newIndent = string.rep("  ", indentLevel + 1)
            string = string .. newIndent .. "'" .. key .. "' = {\n" .. prettyPrint(value, indentLevel + 1)
        else
            local overwrites = def:getOverwrites(key)
            local overwriteDesc = ""
            for i, overwriter in ipairs(overwrites) do
                overwriteDesc = overwriteDesc .. overwriter.name
                if i < #overwrites then
                    overwriteDesc = overwriteDesc .. " -> "
                end
            end
            string = string .. indent .. "  " .. key .. " = '" .. tostring(value) .. "' -- " .. overwriteDesc .. " \n"
        end
    end

    return string .. indent .. "}\n"
end

local Registry = require 'registry'
local registry = Registry:new()

--TODO abstract classes
--TODO check if a class is used at all by impls
--TODO: get rid of def references to registry to kill cyclic refs

function Def (name)
	return registry:register(name)
end

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

local function users(def, key)

end

local function trace(def)

end

oo.prettyPrint = prettyPrint
oo.users = users
oo.trace = trace
oo.crawlDir = crawlDir
oo.render = function (name) 
	local def = registry:get(name)
	if def then
		return def:Render()
	end
end

return oo
