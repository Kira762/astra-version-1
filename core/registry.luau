-- Internal module/service registry (core/registry.luau).
--
-- Keeps a name -> module table for Astra's internal services so consumers can
-- resolve a service once without hard require chains, and so the loader can
-- lazily construct services on first use. UI elements should not need this;
-- it exists for cross-cutting services (settings, caches, icons, images).

local registry = {}

local registered: { [string]: any } = {}
local factories: { [string]: () -> any } = {}

function registry.register(name: string, module: any)
    registered[name] = module
end

function registry.registerFactory(name: string, factory: () -> any)
    factories[name] = factory
end

function registry.get(name: string): any?
    local existing = registered[name]
    if existing ~= nil then
        return existing
    end
    local factory = factories[name]
    if factory then
        local built = factory()
        registered[name] = built
        return built
    end
    return nil
end

function registry.names(): { string }
    local names = {}
    for name in registered do
        table.insert(names, name)
    end
    for name in factories do
        if registered[name] == nil then
            table.insert(names, name)
        end
    end
    table.sort(names)
    return names
end

return registry
