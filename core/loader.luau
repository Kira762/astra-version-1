local loader = {}

local loading: { [string]: boolean } = {}

local knownModules = {
	state = true,
	registry = true,
}

function loader.load(name: string)
	assert(knownModules[name], "Astra core loader: unknown module '" .. tostring(name) .. "'")
	if loading[name] then
		return nil
	end
	loading[name] = true
	local ok, result = pcall(function()
		return require((script :: any).Parent[name])
	end)
	loading[name] = nil
	if not ok then
		error(result, 0)
	end
	return result
end

function loader.service(name: string, factory: () -> any)
	local reg = loader.load("registry")
	reg.registerFactory(name, factory)
	return reg
end

return loader
