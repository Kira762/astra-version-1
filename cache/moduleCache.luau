-- Module cache (cache/moduleCache.luau).
--
-- Prevents repeated initialization of loaded modules/services. Roblox's
-- require() already caches module return values per ModuleScript instance,
-- so this cache exists for values that are *constructed* rather than required:
-- services built with .new() that must only ever be constructed once, keyed by
-- an explicit name. Factories are registered by the settings/images/icons
-- services through core/registry integration.
--
-- Entries are intentionally never evicted: everything cached here is a small
-- stateless singleton (or a handle to one), so staleness cannot occur.

local moduleCache = {}

local singletons: { [string]: any } = {}
local factories: { [string]: () -> any } = {}

function moduleCache.singleton(name: string, factory: () -> any): any
    local existing = singletons[name]
    if existing ~= nil then
        return existing
    end
    local built = factory()
    singletons[name] = built
    return built
end

function moduleCache.get(name: string): any?
    return singletons[name]
end

function moduleCache.peek(name: string): boolean
    return singletons[name] ~= nil
end

-- Test/integration hook: forget a constructed singleton. Only call this for
-- factories that are safe to re-run; the library itself never evicts.
function moduleCache._forget(name: string)
    singletons[name] = nil
    factories[name] = nil
end

return moduleCache
