-- Controlled/lazy loading of internal modules (core/loader.luau).
--
-- The core must stay small: this loader exists so heavy or rarely used
-- services (settings, caches, icon packs, images) are required on first use
-- instead of during startup. require() caches the module value after the
-- first call, so repeated loads are table lookups.

local loader = {}

local pending: { [string]: boolean } = {}

-- Load a module relative to the loader (script.Parent.<name> children).
-- Names are validated against an allowlist to keep the load surface explicit.
local allowed = {
    state = true,
    registry = true,
}

function loader.load(name: string)
    assert(allowed[name], "Astra core loader: unknown module '" .. tostring(name) .. "'")
    if pending[name] then
        return nil
    end
    pending[name] = true
    local ok, result = pcall(function()
        return require((script :: any).Parent[name])
    end)
    pending[name] = nil
    if not ok then
        error(result, 0)
    end
    return result
end

-- Register an external lazy service factory on the core registry.
function loader.service(name: string, factory: () -> any)
    local registry = loader.load("registry")
    registry.registerFactory(name, factory)
    return registry
end

return loader
