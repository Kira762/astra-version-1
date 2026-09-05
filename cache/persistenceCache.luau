-- Persistence cache (cache/persistenceCache.luau).
--
-- Caches decoded settings payloads so repeated reads of the same file do not
-- re-hit the filesystem. The settings payload is cached until explicitly
-- invalidated; settings save paths call invalidateSettings() after writing.

local persistenceCache = {}

local settingsCache: { [string]: any } = {}

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

return persistenceCache
