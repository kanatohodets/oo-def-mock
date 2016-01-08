-- you can mix multiple things, but only if they don't conflict
function Def:Does (...)
	local mixins = {...}
	local collisions = {}
	for i, className in ipairs(mixins) do
		local class = registry[className]
		if not class then
			print("error: " .. className .. " is not defined, cannot consume role \n")
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
			print("'" .. key .. "' cannot do '" .. self.name .. "' because it is provided by multiple classes: " .. list)
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

function Def:mix (className)

end


