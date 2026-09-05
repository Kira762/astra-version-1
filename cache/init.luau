-- Central cache layer (cache/init.luau).
--
-- Exposes the module cache plus the moved image cache, and registers the
-- persistence cache factory. Caches here must reduce repeated work without
-- creating stale-state bugs; each submodule documents its invalidation rules.

-- This file IS the `cache` ModuleScript (init.luau semantics).
local moduleCache = require(script.moduleCache)

local cache = {
    modules = moduleCache,
}

return cache
