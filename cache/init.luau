-- cache/init.luau — folder module (init.luau semantics).
--
-- Exists to anchor the `cache` folder as a single ModuleScript in the Rojo/Wax
-- tree. Consumers require `cache.imageCache` and `cache.persistenceCache`
-- directly; this surface only re-exports the module cache.

local moduleCache = require(script.moduleCache)

local cache = {
    modules = moduleCache,
}

return cache
