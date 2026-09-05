-- Core service entrypoint (core/init.luau).
--
-- Small by design: it wires together the shared state, registry, and loader.
-- Library modules may `require(core)` to reach all three without the core
-- becoming another giant utility module.

-- NOTE: this file IS the `core` ModuleScript (Rojo/Wax init.luau semantics),
-- so sibling modules are children of `script`, not of `script.Parent`.
local state = require(script.state)
local registry = require(script.registry)
local loader = require(script.loader)

local core = {
    state = state,
    registry = registry,
    loader = loader,
}

-- Pre-register the always-needed services so registry.get() can hand them
-- out without re-requiring; these modules are already loaded by the time the
-- library entrypoint pulls core in via the shared startup path.
registry.register("state", state)

return core
