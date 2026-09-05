-- Public settings service entrypoint (settings/init.luau).
--
-- Consumed by the window to build its per-instance manager and by the
-- entrypoint's duplicate-window guard to read the persisted preference.

-- This file IS the `settings` ModuleScript (init.luau semantics): siblings are
-- children of `script`.
local manager = require(script.manager)
local registry = require(script.registry)
local defaults = require(script.defaults)
local persistence = require(script.persistence)

local settings = {
    manager = manager,
    registry = registry,
    defaults = defaults,
    persistence = persistence,
}

function settings.newManager(initialOverrides: { [string]: any }?)
    return manager.new(initialOverrides)
end

-- Single-setting disk read used before any window/manager exists.
function settings.readPersisted(key: string, fallback: any): any
    return persistence.read(key, fallback)
end

return settings
