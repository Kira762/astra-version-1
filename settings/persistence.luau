
local state = require(script.Parent.Parent.utilities.persistenceSettings)
local persistenceSettings = require(script.Parent.Parent.cache.persistenceCache)

local persistenceWrite = {}

function persistenceWrite.path(): (string, string)
    return state.getSettingsPath()
end

function persistenceWrite.save(persistence: { [string]: any }): boolean
    local ok = state.saveSettings({ settings = persistence })
    persistenceSettings.invalidateSettings()
    return ok
end

function persistenceWrite.load(values: { [string]: any }): boolean
    return state.loadSettings({ settings = values })
end

function persistenceWrite.read(key: string, default: any): any
    local _, path = state.getSettingsPath()
    local cached = persistenceSettings.getSettings(path)
    if cached == nil then
        local data = nil :: any?
        local fs = require(script.Parent.Parent.utilities.filesystem)
        local httpService = (require(script.Parent.Parent.core.state)).httpService
        pcall(function()
            if fs.isfile(path) then
                local raw = fs.readfile(path)
                local ok, decoded = pcall(httpService.JSONDecode, httpService, raw)
                if ok and type(decoded) == "table" then
                    data = decoded :: any
                end
            end
        end)
        persistenceSettings.putSettings(path, data or false)
        cached = persistenceSettings.getSettings(path)
    end
    if type(cached) == "table" and (cached :: any)[key] ~= nil then
        return (cached :: any)[key]
    end
    return default
end

return persistenceWrite
