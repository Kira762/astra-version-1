local registry = {}

local modules: { [string]: any } = {}
local factories: { [string]: () -> any } = {}

function registry.register(name: string, module: any)
	modules[name] = module
end

function registry.registerFactory(name: string, factory: () -> any)
	factories[name] = factory
end

function registry.get(name: string): any?
	local cached = modules[name]
	if cached ~= nil then
		return cached
	end
	local factory = factories[name]
	if factory then
		local instance = factory()
		modules[name] = instance
		return instance
	end
	return nil
end

function registry.names(): { string }
	local list = {}
	for name in modules do
		table.insert(list, name)
	end
	for name in factories do
		if modules[name] == nil then
			table.insert(list, name)
		end
	end
	table.sort(list)
	return list
end

return registry
