-- Settings persistence (settings/persistence.luau).
--
-- Thin bridge over the existing settings persistence infrastructure
-- (utilities/persistenceSettings.luau, which keeps its JSON file format and
-- atomic write behavior). The manager talks to this module; nothing outside
-- settings/ touches the raw file format.

local persistenceSettings = require(script.Parent.Parent.utilities.persistenceSettings)
local persistenceCache = require(script.Parent.Parent.cache.persistenceCache)

local persistence = {}

function persistence.path(): (string, string)
    return persistenceSettings.getSettingsPath()
end

function persistence.save(settingsTable: { [string]: any }): boolean
    local ok = persistenceSettings.saveSettings({ settings = settingsTable })
    persistenceCache.invalidateSettings()
    return ok
end

function persistence.load(settingsTable: { [string]: any }): boolean
    return persistenceSettings.loadSettings({ settings = settingsTable })
end

-- Reads a single setting straight from disk with a fallback, used by the
-- window-duplicate guard before any window exists. Cached after first read;
-- the cache is invalidated whenever settings are saved.
function persistence.read(key: string, fallback: any): any
    local _, fullPath = persistenceSettings.getSettingsPath()
    local cached = persistenceCache.getSettings(fullPath)
    if cached == nil then
        local decoded = nil :: any?
        local filesystem = require(script.Parent.Parent.utilities.filesystem)
        local httpService = (require(script.Parent.Parent.core.state)).httpService
        pcall(function()
            if filesystem.isfile(fullPath) then
                local contents = filesystem.readfile(fullPath)
                local ok, parsed = pcall(httpService.JSONDecode, httpService, contents)
                if ok and type(parsed) == "table" then
                    decoded = parsed :: any
                end
            end
        end)
        persistenceCache.putSettings(fullPath, decoded or false)
        cached = persistenceCache.getSettings(fullPath)
    end
    if type(cached) == "table" and (cached :: any)[key] ~= nil then
        return (cached :: any)[key]
    end
    return fallback
end

return persistence
