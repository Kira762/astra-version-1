local a1 = require(script.Parent.Parent.core.state)
local a2 = require(script.Parent.path)

local a3 = {}

type ConfigWindow = {
    configuration: {
        fileName: string?,
        customFolder: string?,
    },
    name: string,
}

function a3.getConfigPath(window: ConfigWindow, a4: unknown?): (string?, string?)
    local a5 = a1.fileSystemManager:getPath("Configurations")
    if window.configuration.customFolder then
        a5 = a2.join(a5, a2.sanitizeFolder(window.configuration.customFolder))
    end
    if a4 ~= nil then
        local a6 = a2.sanitizeFile(a4)
        if a6 == "" then
            return nil, nil
        end
        return a5, a2.join(a5, a6 .. ".rfld")
    end
    local a7 = a2.sanitizeFile(window.configuration.fileName or window.name)
    if a7 == "" then
        a7 = a2.sanitizeFile(window.name)
    end
    if a7 == "" then
        a7 = "Configuration"
    end
    return a5, a2.join(a5, a7 .. ".rfld")
end

function a3.getSettingsPath(): (string, string)
    local a8 = a1.fileSystemManager:getPath("Settings")
    return a8, a2.join(a8, "astra.rfld")
end

return a3
