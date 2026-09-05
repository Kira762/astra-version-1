
local a1 = require(script.Parent.Parent.utilities.persistenceSettings)
local a2 = require(script.Parent.Parent.cache.persistenceCache)

local a3 = {}

function a3.path(): (string, string)
    return a1.getSettingsPath()
end

function a3.save(a4: { [string]: any }): boolean
    local ok = a1.saveSettings({ settings = a4 })
    a2.invalidateSettings()
    return ok
end

function a3.load(a5: { [string]: any }): boolean
    return a1.loadSettings({ settings = a5 })
end

function a3.read(a6: string, a7: any): any
    local _, a8 = a1.getSettingsPath()
    local a9 = a2.getSettings(a8)
    if a9 == nil then
        local a10 = nil :: any?
        local a11 = require(script.Parent.Parent.utilities.filesystem)
        local a12 = (require(script.Parent.Parent.core.state)).httpService
        pcall(function()
            if a11.isfile(a8) then
                local a13 = a11.readfile(a8)
                local ok, a14 = pcall(a12.JSONDecode, a12, a13)
                if ok and type(a14) == "table" then
                    a10 = a14 :: any
                end
            end
        end)
        a2.putSettings(a8, a10 or false)
        a9 = a2.getSettings(a8)
    end
    if type(a9) == "table" and (a9 :: any)[a6] ~= nil then
        return (a9 :: any)[a6]
    end
    return a7
end

return a3
