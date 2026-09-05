-- Persistence cache (cache/persistenceCache.luau).
--
-- Caches decoded persistence payloads so repeated reads of the same file do
-- not re-hit the filesystem. Invalidation rules:
--   - settings: the payload is cached until explicitly invalidated (settings
--     save paths call invalidateSettings() after writing).
--   - configurations: decoded flag tables are cached per absolute file path
--     and invalidated on save/delete of that path (window Save/Load/Delete
--     routes go through noteSaved/noteDeleted).

local persistenceCache = {}

local settingsCache: { [string]: any } = {}
local configCache: { [string]: any } = {}

function persistenceCache.getSettings(key: string): any?
    return settingsCache[key]
end

function persistenceCache.putSettings(key: string, value: any)
    settingsCache[key] = value
end

function persistenceCache.invalidateSettings(key: string?)
    if key then
        settingsCache[key] = nil
    else
        table.clear(settingsCache)
    end
end

function persistenceCache.getConfig(path: string): any?
    return configCache[path]
end

function persistenceCache.putConfig(path: string, value: any)
    configCache[path] = value
end

function persistenceCache.invalidateConfig(path: string)
    configCache[path] = nil
end

function persistenceCache.noteSaved(path: string, value: any)
    configCache[path] = value
end

function persistenceCache.noteDeleted(path: string)
    configCache[path] = nil
end

return persistenceCache
